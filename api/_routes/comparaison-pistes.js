import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";
import { construireComparaisonPistes } from "../_lib/comparaisonPistesEngine.js";
import { analyserHesitation } from "../_lib/hesitationEngine.js";

const envoyerErreur = (res, status, message) => res.status(status).json({ success: false, message });

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const path = new URL(req.url || "", `http://${req.headers.host || "localhost"}`).pathname;

  /* =====================================================================
     1. GET : Récupération des questions de comparaison depuis Supabase
  ===================================================================== */
  if (req.method === "GET") {
    try {
      const { data: questions, error: questionsError } = await supabase
        .from("hesitation_question")
        .select("id_question, question, ordre, actif")
        .eq("actif", true)
        .order("ordre", { ascending: true });

      if (questionsError) throw questionsError;

      const questionIds = (questions || []).map((q) => q.id_question);
      let reponses = [];

      if (questionIds.length > 0) {
        const { data: reponsesData, error: reponsesError } = await supabase
          .from("hesitation_reponse")
          .select("id_reponse, id_question, texte, code, ordre")
          .in("id_question", questionIds)
          .order("ordre", { ascending: true });

        if (reponsesError) throw reponsesError;
        reponses = reponsesData || [];
      }

      const resultat = (questions || []).map((q) => ({
        id_question: q.id_question,
        id: q.id_question,
        question: q.question,
        ordre: q.ordre,
        reponses: reponses
          .filter((r) => r.id_question === q.id_question)
          .map((r) => ({
            id_reponse: r.id_reponse,
            id_question: r.id_question,
            texte: r.texte,
            code: r.code,
            ordre: r.ordre,
          })),
      }));

      return res.status(200).json({
        success: true,
        data: resultat,
      });
    } catch (err) {
      console.error("Erreur récupération questions comparaison :", err);
      return res.status(500).json({
        success: false,
        message: "Impossible de récupérer les questions de comparaison.",
      });
    }
  }

  /* =====================================================================
     2. POST : Enregistrement des réponses & Analyse décisionnelle
  ===================================================================== */
  if (req.method !== "POST") return envoyerErreur(res, 405, "Méthode non autorisée.");

  const utilisateur = getUserFromRequest(req);
  if (!utilisateur?.id_user) return envoyerErreur(res, 401, "Utilisateur non connecté.");

  const idsBruts = req.body?.id_pistes;
  if (!Array.isArray(idsBruts)) return envoyerErreur(res, 400, "Le champ id_pistes doit contenir deux ou trois identifiants.");
  const ids = [...new Set(idsBruts.map((id) => Number(id)).filter((id) => Number.isInteger(id) && id > 0))];
  if (ids.length < 2 || ids.length > 3 || ids.length !== idsBruts.length) {
    return envoyerErreur(res, 400, "Sélectionne deux ou trois pistes valides, sans doublon.");
  }

  try {
    // 1. Récupérer les pistes de l'utilisateur
    const { data: pistes, error: pistesError } = await supabase
      .from("piste_utilisateur")
      .select("id_piste, id_user, type_piste, id_metier, id_filiere, date_ajout, statut")
      .eq("id_user", utilisateur.id_user)
      .eq("statut", "active")
      .in("id_piste", ids);
    if (pistesError) throw pistesError;
    if (!pistes || pistes.length !== ids.length) return envoyerErreur(res, 404, "Une ou plusieurs pistes sont introuvables, archivées ou ne t'appartiennent pas.");

    const types = [...new Set(pistes.map((piste) => piste.type_piste))];
    if (types.length !== 1 || !["metier", "filiere"].includes(types[0])) return envoyerErreur(res, 400, "Compare les métiers entre eux ou les filières entre elles, sans mélanger les types.");
    const typePiste = types[0];
    const idsCibles = pistes.map((piste) => typePiste === "metier" ? piste.id_metier : piste.id_filiere).filter(Boolean);
    const tableCatalogue = typePiste === "metier" ? "metier" : "filiere";
    const { data: catalogue, error: catalogueError } = await supabase.from(tableCatalogue).select("*").in(typePiste === "metier" ? "id_metier" : "id_filiere", idsCibles);
    if (catalogueError) throw catalogueError;
    const parId = new Map((catalogue || []).map((element) => [Number(typePiste === "metier" ? element.id_metier : element.id_filiere), element]));
    const pistesEnrichies = pistes.map((piste) => ({ ...piste, ...(parId.get(Number(typePiste === "metier" ? piste.id_metier : piste.id_filiere)) || {}) }));

    // 2. Création de la session dans hesitation_test
    const { data: session, error: sessionError } = await supabase
      .from("hesitation_test")
      .insert({
        id_user: utilisateur.id_user,
        type_choix: typePiste,
        statut: "en_cours"
      })
      .select("id_hesitation_test")
      .single();
    if (sessionError) throw sessionError;

    // 3. Création des options de la session dans hesitation_option
    const optionRows = pistes.map((piste, index) => ({
      id_hesitation_test: session.id_hesitation_test,
      id_metier: typePiste === "metier" ? piste.id_metier : null,
      id_filiere: typePiste === "filiere" ? piste.id_filiere : null,
      ordre: index + 1
    }));
    const { error: optionError } = await supabase.from("hesitation_option").insert(optionRows);
    if (optionError) throw optionError;

    // 4. Enregistrement des réponses dans hesitation_reponse_utilisateur
    const reponsesBrutes = Array.isArray(req.body?.reponses) ? req.body.reponses : [];
    let reponsesEnrichies = [];

    if (reponsesBrutes.length > 0) {
      const idReponsesList = reponsesBrutes.map((r) => parseInt(r.id_reponse, 10)).filter(Number.isInteger);
      const { data: reponsesDb } = await supabase
        .from("hesitation_reponse")
        .select("id_reponse, id_question, code, texte")
        .in("id_reponse", idReponsesList);

      const codeMap = new Map((reponsesDb || []).map((r) => [r.id_reponse, r]));

      const rowsToInsert = reponsesBrutes
        .map((r) => ({
          id_hesitation_test: session.id_hesitation_test,
          id_question: parseInt(r.id_question, 10),
          id_reponse: parseInt(r.id_reponse, 10)
        }))
        .filter((r) => Number.isInteger(r.id_question) && Number.isInteger(r.id_reponse));

      if (rowsToInsert.length > 0) {
        const { error: reponseInsertError } = await supabase.from("hesitation_reponse_utilisateur").insert(rowsToInsert);
        if (reponseInsertError) console.warn("Erreur insertion hesitation_reponse_utilisateur:", reponseInsertError.message);
      }

      reponsesEnrichies = reponsesBrutes.map((r) => {
        const info = codeMap.get(parseInt(r.id_reponse, 10));
        return {
          id_question: parseInt(r.id_question, 10),
          id_reponse: parseInt(r.id_reponse, 10),
          code: r.code || info?.code || null,
          texte: r.texte || info?.texte || ""
        };
      });
    }

    // 5. Exécution du moteur d'analyse décisionnelle (hesitationEngine)
    let analyse = null;
    try {
      analyse = await analyserHesitation({
        idUser: utilisateur.id_user,
        idHesitationTest: session.id_hesitation_test,
        reponses: reponsesEnrichies
      });

      // 6. Sauvegarde des résultats dans hesitation_analyse & hesitation_analyse_piste
      const { data: analyseDb, error: analyseInsertError } = await supabase
        .from("hesitation_analyse")
        .insert({
          id_hesitation_test: session.id_hesitation_test,
          id_test_riasec: analyse.id_test_riasec,
          id_piste_dominante: analyse.dominante?.piste?.id_piste || null,
          version_moteur: "v1.2.0",
          niveau_confiance: analyse.dominante?.niveauConfiance || null,
          synthese: analyse.synthese
        })
        .select("id_analyse")
        .single();

      if (!analyseInsertError && analyseDb?.id_analyse) {
        const analysePisteRows = (analyse.resultats || []).map((resultat) => ({
          id_analyse: analyseDb.id_analyse,
          id_piste: resultat.piste.id_piste,
          score_riasec: resultat.scoreRiasec,
          score_criteres: resultat.scoreCriteres,
          score_convergence: resultat.scoreConvergence,
          score_information: resultat.scoreInformation,
          score_differenciation: resultat.scoreDifferenciation,
          score_global: resultat.scoreGlobal,
          rang: resultat.rang,
          niveau_confiance: resultat.niveauConfiance,
          position: resultat.position,
          raisons: resultat.raisons,
          points_vigilance: resultat.pointsVigilance,
          prochaines_etapes: resultat.prochainesEtapes,
          features_snapshot: {
            score_riasec: resultat.scoreRiasec,
            score_criteres: resultat.scoreCriteres,
            score_convergence: resultat.scoreConvergence,
            score_information: resultat.scoreInformation,
            score_differenciation: resultat.scoreDifferenciation,
            score_global: resultat.scoreGlobal,
            couverture_criteres: resultat.couvertureCriteres,
            marge: resultat.marge,
            nombre_reponses: analyse.metadata?.nombre_reponses,
            riasec_disponible: analyse.metadata?.riasec_disponible
          }
        }));

        if (analysePisteRows.length) {
          await supabase.from("hesitation_analyse_piste").insert(analysePisteRows);
        }
      }

      // Marquer la session comme terminée
      await supabase
        .from("hesitation_test")
        .update({ statut: "termine" })
        .eq("id_hesitation_test", session.id_hesitation_test)
        .eq("id_user", utilisateur.id_user);

      // Enregistrer l'événement analytique
      await supabase.from("hesitation_evenement").insert({
        id_user: utilisateur.id_user,
        id_hesitation_test: session.id_hesitation_test,
        id_piste: analyse.dominante?.piste?.id_piste || null,
        type_evenement: "ANALYSE_TERMINEE",
        contexte: {
          version_moteur: "v1.2.0",
          nombre_pistes: analyse.resultats?.length || 0,
          piste_dominante_id: analyse.dominante?.piste?.id_piste || null
        }
      });
    } catch (engineError) {
      console.warn("Erreur moteur d'analyse :", engineError?.message || engineError);
    }

    // 7. Construction de la grille descriptive comparative
    const { data: criteres } = await supabase.from("hesitation_critere").select("id_critere, code, nom, categorie, actif").eq("actif", true).order("id_critere", { ascending: true });
    const tableValeurs = typePiste === "metier" ? "metier_critere" : "filiere_critere";
    const cleCible = typePiste === "metier" ? "id_metier" : "id_filiere";
    const { data: lignesValeurs } = await supabase.from(tableValeurs).select(`${cleCible}, id_critere, valeur`).in(cleCible, idsCibles);

    const valeursParCible = new Map();
    for (const ligne of lignesValeurs || []) {
      const idCible = Number(ligne[cleCible]);
      if (!valeursParCible.has(idCible)) valeursParCible.set(idCible, new Map());
      const valeur = ligne.valeur === null || ligne.valeur === undefined ? null : Number(ligne.valeur);
      if (Number.isFinite(valeur)) valeursParCible.get(idCible).set(Number(ligne.id_critere), valeur);
    }

    const { data: tests } = await supabase.from("test_riasec")
      .select("id_test, date_test, profil_dominant, score_r, score_i, score_a, score_s, score_e, score_c")
      .eq("id_user", utilisateur.id_user)
      .not("profil_dominant", "is", null)
      .order("date_test", { ascending: false })
      .order("id_test", { ascending: false })
      .limit(10);

    const testRiasec = (tests || []).find((test) => /^[RIASEC]{2,3}$/.test(String(test.profil_dominant || "").toUpperCase()) && new Set(String(test.profil_dominant).toUpperCase()).size === String(test.profil_dominant).length) || null;

    let metiersAssocies = [];
    let universitesAssociees = [];
    if (typePiste === "filiere") {
      const { data: liens } = await supabase.from("metier_filiere").select("id_filiere, id_metier").in("id_filiere", idsCibles);
      const idsMetiers = [...new Set((liens || []).map((lien) => Number(lien.id_metier)))];
      if (idsMetiers.length) {
        const { data: metiers } = await supabase.from("metier").select("id_metier, nom, secteur, profil_riasec").in("id_metier", idsMetiers);
        const liensParMetier = new Map((liens || []).map((lien) => [Number(lien.id_metier), Number(lien.id_filiere)]));
        metiersAssocies = (metiers || []).map((metier) => ({ ...metier, id_filiere: liensParMetier.get(Number(metier.id_metier)) }));
      }
      const { data: liensUniversites } = await supabase.from("universite_filiere").select("id_filiere, id_universite").in("id_filiere", idsCibles);
      const idsUniversites = [...new Set((liensUniversites || []).map((lien) => Number(lien.id_universite)))];
      if (idsUniversites.length) {
        const { data: universites } = await supabase.from("universite").select("id_universite, nom, ville, type, region").in("id_universite", idsUniversites);
        universitesAssociees = (liensUniversites || []).flatMap((lien) => {
          const universite = (universites || []).find((item) => Number(item.id_universite) === Number(lien.id_universite));
          return universite ? [{ ...universite, id_filiere: Number(lien.id_filiere) }] : [];
        });
      }
    } else {
      const { data: liens } = await supabase.from("metier_filiere").select("id_metier, id_filiere").in("id_metier", idsCibles);
      const idsFilieres = [...new Set((liens || []).map((lien) => Number(lien.id_filiere)))];
      if (idsFilieres.length) {
        const { data: filieres } = await supabase.from("filiere").select("id_filiere, nom, domaine").in("id_filiere", idsFilieres);
        const liensParMetier = new Map();
        for (const lien of liens || []) {
          if (!liensParMetier.has(Number(lien.id_metier))) liensParMetier.set(Number(lien.id_metier), []);
          const filiere = (filieres || []).find((item) => Number(item.id_filiere) === Number(lien.id_filiere));
          if (filiere) liensParMetier.get(Number(lien.id_metier)).push(filiere);
        }
        metiersAssocies = idsCibles.flatMap((idMetier) => (liensParMetier.get(Number(idMetier)) || []).map((filiere) => ({ id_metier: idMetier, ...filiere })));
      }
    }

    const comparaison = construireComparaisonPistes({
      typePiste,
      pistes: pistesEnrichies,
      criteres: criteres || [],
      valeursParCible,
      profilRiasec: testRiasec,
      metiersAssocies,
      universitesAssociees
    });

    return res.status(200).json({
      success: true,
      data: {
        ...comparaison,
        id_hesitation_test: session.id_hesitation_test,
        analyse: analyse ? {
          synthese: analyse.synthese,
          dominante: analyse.dominante,
          resultats: analyse.resultats,
          preferences: analyse.preferences,
          blocages: analyse.blocages,
          metadata: analyse.metadata
        } : null
      }
    });
  } catch (error) {
    console.error("Comparaison pistes error:", error);
    return res.status(500).json({ success: false, message: "Impossible de construire l'analyse avec les données disponibles." });
  }
}

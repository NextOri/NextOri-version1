import { supabase } from "./supabase.js";

/**
 * ============================================================
 * NEXTORI — J'HÉSITE V1.2
 * MOTEUR D'ANALYSE DÉCISIONNELLE
 * ============================================================
 *
 * Le moteur :
 * 1. récupère les pistes de la session
 * 2. récupère le dernier profil RIASEC
 * 3. récupère les réponses J'HÉSITE
 * 4. récupère les critères métier/filière
 * 5. calcule plusieurs dimensions
 * 6. fait ressortir une piste dominante si les données
 *    permettent réellement de le faire
 * 7. explique pourquoi
 * 8. indique ce qui reste à vérifier
 *
 * IMPORTANT :
 * - aucun score fictif
 * - aucun catalogue hardcodé
 * - aucun résultat définitif
 * ============================================================
 */

const RIasecLetters = ["R", "I", "A", "S", "E", "C"];

/**
 * ------------------------------------------------------------
 * Utilitaires
 * ------------------------------------------------------------
 */

function clamp(value, min = 0, max = 100) {
  return Math.min(max, Math.max(min, value));
}

function round(value, decimals = 2) {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
}

function normalize(value, min, max) {
  if (max === min) return 100;
  return clamp(((value - min) / (max - min)) * 100);
}

function safeArray(value) {
  return Array.isArray(value) ? value : [];
}

/**
 * ------------------------------------------------------------
 * RIASEC
 * ------------------------------------------------------------
 */

/**
 * Transforme les scores RIASEC utilisateur en pourcentages
 * relatifs au meilleur score du profil.
 */
function normaliserProfilRiasec(test) {
  if (!test) return null;

  const scores = {
    R: Number(test.score_r || 0),
    I: Number(test.score_i || 0),
    A: Number(test.score_a || 0),
    S: Number(test.score_s || 0),
    E: Number(test.score_e || 0),
    C: Number(test.score_c || 0),
  };

  const maximum = Math.max(...Object.values(scores));

  if (maximum <= 0) return null;

  const normalises = {};

  for (const lettre of RIasecLetters) {
    normalises[lettre] = clamp(
      (scores[lettre] / maximum) * 100
    );
  }

  return {
    scores,
    normalises,
    profil_dominant: test.profil_dominant || null,
    id_test: test.id_test,
  };
}

/**
 * Compare le profil utilisateur avec un code RIASEC métier.
 *
 * Exemple :
 * utilisateur = I 100 / R 80 / C 70...
 * métier = "IRC"
 */
function calculerCompatibiliteRiasec(profilUtilisateur, codeProfil) {
  if (!profilUtilisateur || !codeProfil) {
    return null;
  }

  const code = String(codeProfil)
    .toUpperCase()
    .replace(/[^RIASEC]/g, "");

  if (!code.length) return null;

  const lettres = [...new Set(code.split(""))];

  const valeurs = lettres
    .map((lettre) => profilUtilisateur.normalises[lettre])
    .filter((value) => Number.isFinite(value));

  if (!valeurs.length) return null;

  return round(
    valeurs.reduce((sum, value) => sum + value, 0) /
      valeurs.length
  );
}

/**
 * ------------------------------------------------------------
 * RÉPONSES J'HÉSITE → PRÉFÉRENCES
 * ------------------------------------------------------------
 */

function construirePreferences(reponses) {
  const poids = {};

  const ajouterPoids = (code, poidsAjoute) => {
    if (!code) return;

    poids[code] = (poids[code] || 0) + poidsAjoute;
  };

  for (const reponse of safeArray(reponses)) {
    const code = String(reponse.code || "").toUpperCase();

    switch (code) {
      /*
       * Question 1 — attraction
       */
      case "ATTIRANCE_CONTENU":
        ajouterPoids("contenu", 1);
        break;

      case "ATTIRANCE_SENS":
        ajouterPoids("sens", 1);
        break;

      case "ATTIRANCE_DEBOUCHES":
      case "ATTIRANCE_OPPORTUNITES":
        ajouterPoids("debouches", 1);
        break;

      case "ATTIRANCE_CONDITIONS":
      case "ATTIRANCE_CADRE":
        ajouterPoids("conditions", 1);
        break;

      case "ATTIRANCE_PROGRESSION":
      case "ATTIRANCE_DEFI":
        ajouterPoids("progression", 1);
        break;

      /*
       * Question 2 — forces
       */
      case "FORCE_ANALYSE":
      case "FORCE_ANALYSER":
        ajouterPoids("analyse", 1);
        break;

      case "FORCE_CREATION":
      case "FORCE_CREER":
        ajouterPoids("creation", 1);
        break;

      case "FORCE_RELATION":
      case "FORCE_AIDER":
        ajouterPoids("relation", 1);
        break;

      case "FORCE_ORGANISATION":
      case "FORCE_ORGANISER":
        ajouterPoids("organisation", 1);
        break;

      case "FORCE_ACTION":
      case "FORCE_AGIR":
        ajouterPoids("action", 1);
        break;

      /*
       * Question 3 — blocages
       * Ces réponses ne servent pas directement à
       * augmenter une piste.
       * Elles alimentent les points de vigilance.
       */
      case "BLOCAGE_ERREUR":
      case "BLOCAGE_OPTIONS":
      case "BLOCAGE_INFORMATION":
      case "BLOCAGE_CAPACITES":
      case "BLOCAGE_ENTOURAGE":
        break;

      /*
       * Question 4 — critère prioritaire
       */
      case "CRITERE_INTERET":
        ajouterPoids("interet", 2);
        break;

      case "CRITERE_CAPACITES":
        ajouterPoids("capacites", 2);
        break;

      case "CRITERE_DEBOUCHES":
        ajouterPoids("debouches", 2);
        break;

      case "CRITERE_CONDITIONS":
        ajouterPoids("conditions", 2);
        break;

      case "CRITERE_STABILITE":
        ajouterPoids("stabilite", 2);
        break;

      /*
       * Question 5 — besoin pour avancer
       */
      case "BESOIN_COMPARAISON":
        ajouterPoids("comparaison", 1);
        break;

      case "BESOIN_COMPATIBILITE":
        ajouterPoids("capacites", 1);
        break;

      case "BESOIN_REALITE":
        ajouterPoids("conditions", 1);
        break;

      case "BESOIN_DEBOUCHES":
        ajouterPoids("debouches", 1);
        break;

      case "BESOIN_RASSURANCE":
        ajouterPoids("stabilite", 1);
        break;

      default:
        break;
    }
  }

  return poids;
}

/**
 * ------------------------------------------------------------
 * SCORE CRITÈRES
 * ------------------------------------------------------------
 */

function calculerScoreCriteres(
  lignesCriteres,
  preferences,
  maxParCritere
) {
  const criteresDisponibles = new Map();

  for (const ligne of safeArray(lignesCriteres)) {
    criteresDisponibles.set(
      Number(ligne.id_critere),
      ligne
    );
  }

  const preferenceEntries = Object.entries(preferences);

  if (!preferenceEntries.length) {
    return {
      score: null,
      details: [],
      couverture: 0,
    };
  }

  let somme = 0;
  let poidsTotal = 0;
  let criteresTrouves = 0;

  const details = [];

  for (const [code, poids] of preferenceEntries) {
    const critere = lignesCriteres.find(
      (ligne) =>
        String(ligne.critere?.code || "").toLowerCase() ===
        String(code).toLowerCase()
    );

    if (!critere) continue;

    const valeur = Number(critere.valeur);

    if (!Number.isFinite(valeur)) continue;

    const maximum =
      Number(maxParCritere[code]) || 0;

    if (maximum <= 0) continue;

    const valeurNormalisee = clamp(
      (valeur / maximum) * 100
    );

    somme += valeurNormalisee * poids;
    poidsTotal += poids;
    criteresTrouves++;

    details.push({
      code,
      valeur,
      score: round(valeurNormalisee),
      poids,
    });
  }

  if (!poidsTotal) {
    return {
      score: null,
      details,
      couverture: 0,
    };
  }

  return {
    score: round(somme / poidsTotal),
    details,
    couverture: round(
      (criteresTrouves / preferenceEntries.length) * 100
    ),
  };
}

/**
 * ------------------------------------------------------------
 * RIASEC D'UNE FILIÈRE
 * ------------------------------------------------------------
 *
 * Une filière ne possède pas directement de profil_riasec.
 *
 * On construit donc un profil dérivé à partir des métiers
 * associés à cette filière.
 *
 * Ce profil est explicitement marqué comme "derive".
 * ------------------------------------------------------------
 */

function construireProfilRiasecFiliere(metiers) {
  const profils = safeArray(metiers)
    .map((metier) =>
      String(metier.profil_riasec || "")
        .toUpperCase()
        .replace(/[^RIASEC]/g, "")
    )
    .filter(Boolean);

  if (!profils.length) return null;

  const scores = {
    R: 0,
    I: 0,
    A: 0,
    S: 0,
    E: 0,
    C: 0,
  };

  let total = 0;

  for (const profil of profils) {
    const lettres = [...new Set(profil.split(""))];

    for (const lettre of lettres) {
      scores[lettre] += 1;
    }

    total++;
  }

  if (!total) return null;

  const normalises = {};

  for (const lettre of RIasecLetters) {
    normalises[lettre] =
      (scores[lettre] / total) * 100;
  }

  return {
    scores,
    normalises,
    derive: true,
    nombre_metiers: total,
  };
}

function calculerCompatibiliteProfilDerive(
  profilUtilisateur,
  profilCible
) {
  if (!profilUtilisateur || !profilCible) {
    return null;
  }

  let somme = 0;

  for (const lettre of RIasecLetters) {
    const utilisateur =
      profilUtilisateur.normalises[lettre] || 0;

    const cible =
      profilCible.normalises[lettre] || 0;

    /*
     * Similarité simple :
     * plus les deux niveaux sont proches,
     * plus la convergence est élevée.
     */
    somme +=
      100 - Math.abs(utilisateur - cible);
  }

  return round(somme / RIasecLetters.length);
}

/**
 * ------------------------------------------------------------
 * INFORMATION
 * ------------------------------------------------------------
 */

function calculerScoreInformation(
  piste,
  lignesCriteres,
  profilRiasec
) {
  let total = 0;
  let obtenu = 0;

  /*
   * Identité / description
   */
  total += 2;

  if (
    piste.type_piste === "metier" &&
    piste.metier
  ) {
    if (piste.metier.nom) obtenu++;
    if (
      piste.metier.presentation ||
      piste.metier.description
    ) {
      obtenu++;
    }
  }

  if (
    piste.type_piste === "filiere" &&
    piste.filiere
  ) {
    if (piste.filiere.nom) obtenu++;
    if (
      piste.filiere.presentation ||
      piste.filiere.description
    ) {
      obtenu++;
    }
  }

  /*
   * Critères
   */
  total += 3;

  if (lignesCriteres.length > 0) obtenu++;
  if (lignesCriteres.length >= 5) obtenu++;
  if (lignesCriteres.length >= 8) obtenu++;

  /*
   * RIASEC
   */
  total++;

  if (profilRiasec) obtenu++;

  return round((obtenu / total) * 100);
}

/**
 * ------------------------------------------------------------
 * DIFFÉRENCIATION
 * ------------------------------------------------------------
 */

function calculerDifferenciation(score, scoresTous) {
  if (scoresTous.length < 2) {
    return 50;
  }

  const autres = scoresTous.filter(
    (value) => value !== score
  );

  if (!autres.length) return 50;

  const moyenne =
    autres.reduce((sum, value) => sum + value, 0) /
    autres.length;

  const minimum = Math.min(...scoresTous);
  const maximum = Math.max(...scoresTous);

  const amplitude = maximum - minimum;

  if (amplitude <= 0) return 50;

  const difference = score - moyenne;

  return clamp(
    50 + (difference / amplitude) * 50
  );
}

/**
 * ------------------------------------------------------------
 * POSITION
 * ------------------------------------------------------------
 */

function determinerPosition(
  rang,
  scoreGlobal,
  differenciation,
  confiance,
  marge
) {
  if (
    rang === 1 &&
    scoreGlobal >= 65 &&
    differenciation >= 65 &&
    confiance >= 60 &&
    marge >= 8
  ) {
    return "dominante";
  }

  if (
    rang <= 2 &&
    scoreGlobal >= 55 &&
    confiance >= 50
  ) {
    return "forte";
  }

  if (scoreGlobal >= 45) {
    return "proche";
  }

  return "a_verifier";
}

/**
 * ------------------------------------------------------------
 * EXPLICATION
 * ------------------------------------------------------------
 */

function construireExplication({
  piste,
  scoreRiasec,
  scoreCriteres,
  scoreInformation,
  differenciation,
  preferences,
  detailsCriteres,
  blocages,
}) {
  const raisons = [];
  const pointsVigilance = [];
  const prochainesEtapes = [];

  if (
    scoreRiasec !== null &&
    scoreRiasec >= 70
  ) {
    raisons.push(
      "Cette piste présente une forte convergence avec ton profil RIASEC."
    );
  } else if (
    scoreRiasec !== null &&
    scoreRiasec >= 50
  ) {
    raisons.push(
      "Cette piste présente une convergence correcte avec ton profil RIASEC."
    );
  }

  if (
    scoreCriteres !== null &&
    scoreCriteres >= 70
  ) {
    raisons.push(
      "Elle correspond bien aux critères que tu as déclarés importants."
    );
  } else if (
    scoreCriteres !== null &&
    scoreCriteres >= 50
  ) {
    raisons.push(
      "Elle répond à plusieurs de tes critères personnels."
    );
  }

  const meilleursCriteres = safeArray(detailsCriteres)
    .filter((item) => item.score >= 65)
    .sort((a, b) => b.score - a.score)
    .slice(0, 3);

  for (const critere of meilleursCriteres) {
    raisons.push(
      `Le critère « ${critere.code} » constitue un point de convergence.`
    );
  }

  if (scoreInformation < 60) {
    pointsVigilance.push(
      "Les informations disponibles sur cette piste sont encore incomplètes."
    );
  }

  if (scoreRiasec !== null && scoreRiasec < 50) {
    pointsVigilance.push(
      "La convergence avec ton profil RIASEC mérite d'être vérifiée."
    );
  }

  for (const blocage of safeArray(blocages)) {
    switch (blocage) {
      case "BLOCAGE_INFORMATION":
        pointsVigilance.push(
          "Tu as indiqué manquer d'informations : approfondis la réalité de cette piste."
        );
        break;

      case "BLOCAGE_CAPACITES":
        pointsVigilance.push(
          "Tu doutes de tes capacités : vérifie les compétences réellement demandées et celles que tu peux développer."
        );
        break;

      case "BLOCAGE_OPTIONS":
        pointsVigilance.push(
          "Le nombre de possibilités te fait hésiter : compare les différences concrètes plutôt que de chercher une réponse immédiate."
        );
        break;

      case "BLOCAGE_ERREUR":
        pointsVigilance.push(
          "La peur de te tromper est présente : utilise cette analyse comme une étape de vérification, pas comme un verdict."
        );
        break;

      case "BLOCAGE_ENTOURAGE":
        pointsVigilance.push(
          "Ton entourage influence ton choix : distingue tes propres critères de ceux des autres."
        );
        break;

      default:
        break;
    }
  }

  if (piste.type_piste === "metier") {
    prochainesEtapes.push(
      "Consulter les formations qui permettent d'accéder à ce métier."
    );

    prochainesEtapes.push(
      "Vérifier les établissements où ces formations sont disponibles."
    );
  }

  if (piste.type_piste === "filiere") {
    prochainesEtapes.push(
      "Explorer les métiers associés à cette filière."
    );

    prochainesEtapes.push(
      "Vérifier les établissements où cette filière est proposée."
    );
  }

  prochainesEtapes.push(
    "Comparer cette piste avec les autres avant de prendre une décision."
  );

  return {
    raisons: [...new Set(raisons)].slice(0, 5),
    points_vigilance: [
      ...new Set(pointsVigilance),
    ].slice(0, 5),
    prochaines_etapes: [
      ...new Set(prochainesEtapes),
    ].slice(0, 4),
  };
}

/**
 * ------------------------------------------------------------
 * MOTEUR PRINCIPAL
 * ------------------------------------------------------------
 */

export async function analyserHesitation({
  idUser,
  idHesitationTest,
  reponses = [],
}) {
  /*
   * ----------------------------------------------------------
   * 1. Session
   * ----------------------------------------------------------
   */

  const { data: session, error: sessionError } =
    await supabase
      .from("hesitation_test")
      .select("*")
      .eq("id_hesitation_test", idHesitationTest)
      .eq("id_user", idUser)
      .maybeSingle();

  if (sessionError) throw sessionError;

  if (!session) {
    throw new Error("Session J'HÉSITE introuvable.");
  }

  /*
   * ----------------------------------------------------------
   * 2. Options
   * ----------------------------------------------------------
   */

  const { data: options, error: optionsError } =
    await supabase
      .from("hesitation_option")
      .select("*")
      .eq(
        "id_hesitation_test",
        idHesitationTest
      )
      .order("ordre", { ascending: true });

  if (optionsError) throw optionsError;

  if (!options || options.length < 2) {
    throw new Error(
      "Une analyse nécessite au moins deux pistes."
    );
  }

  /*
   * ----------------------------------------------------------
   * 3. Pistes
   * ----------------------------------------------------------
   */

  const pisteIds = [
    ...new Set(
      options
        .map((option) => {
          if (option.id_metier) {
            return Number(option.id_metier);
          }

          if (option.id_filiere) {
            return Number(option.id_filiere);
          }

          return null;
        })
        .filter(Boolean)
    ),
  ];

  const { data: pistes, error: pistesError } =
    await supabase
      .from("piste_utilisateur")
      .select(`
        id_piste,
        id_user,
        type_piste,
        id_metier,
        id_filiere,
        statut,
        date_ajout,
        metier (
          id_metier,
          nom,
          description,
          presentation,
          secteur,
          niveau_etude,
          salaire_min,
          salaire_max,
          profil_riasec,
          tendance
        ),
        filiere (
          id_filiere,
          nom,
          description,
          presentation,
          domaine,
          duree
        )
      `)
      .eq("id_user", idUser)
      .eq("statut", "active");

  if (pistesError) throw pistesError;

  const pistesSession = safeArray(pistes).filter(
    (piste) =>
      pisteIds.includes(Number(piste.id_metier)) ||
      pisteIds.includes(Number(piste.id_filiere))
  );

  /*
   * ----------------------------------------------------------
   * 4. Dernier RIASEC
   * ----------------------------------------------------------
   */

  const {
    data: testRiasec,
    error: riasecError,
  } = await supabase
    .from("test_riasec")
    .select(`
      id_test,
      id_user,
      id_questionnaire,
      date_test,
      score_r,
      score_i,
      score_a,
      score_s,
      score_e,
      score_c,
      profil_dominant
    `)
    .eq("id_user", idUser)
    .order("id_test", {
      ascending: false,
    })
    .limit(1)
    .maybeSingle();

  if (riasecError) throw riasecError;

  const profilUtilisateur =
    normaliserProfilRiasec(testRiasec);

  /*
   * ----------------------------------------------------------
   * 5. Critères
   * ----------------------------------------------------------
   */

  const { data: criteres, error: criteresError } =
    await supabase
      .from("hesitation_critere")
      .select(`
        id_critere,
        code,
        nom,
        categorie,
        actif
      `)
      .eq("actif", true);

  if (criteresError) throw criteresError;

  const critereById = new Map();

  for (const critere of safeArray(criteres)) {
    critereById.set(
      Number(critere.id_critere),
      critere
    );
  }

  /*
   * ----------------------------------------------------------
   * 6. Réponses
   * ----------------------------------------------------------
   */

  let reponsesAnalyse = safeArray(reponses);

  /*
   * Si le frontend ne renvoie pas les réponses,
   * on récupère celles déjà enregistrées.
   */

  if (!reponsesAnalyse.length) {
    const {
      data: reponsesExistantes,
      error: reponsesError,
    } = await supabase
      .from("hesitation_reponse_utilisateur")
      .select(`
        id_question,
        id_reponse,
        hesitation_reponse (
          id_reponse,
          id_question,
          code,
          texte,
          ordre
        )
      `)
      .eq(
        "id_hesitation_test",
        idHesitationTest
      );

    if (reponsesError) throw reponsesError;

    reponsesAnalyse = safeArray(
      reponsesExistantes
    ).map((item) => ({
      id_question: item.id_question,
      id_reponse: item.id_reponse,
      code:
        item.hesitation_reponse?.code || null,
    }));
  }

  const preferences =
    construirePreferences(reponsesAnalyse);

  const blocages = reponsesAnalyse
    .map((reponse) => reponse.code)
    .filter((code) =>
      String(code || "").startsWith("BLOCAGE_")
    );

  /*
   * ----------------------------------------------------------
   * 7. Critères de toutes les pistes
   * ----------------------------------------------------------
   */

  const metierIds = pistesSession
    .filter((piste) => piste.type_piste === "metier")
    .map((piste) => piste.id_metier)
    .filter(Boolean);

  const filiereIds = pistesSession
    .filter((piste) => piste.type_piste === "filiere")
    .map((piste) => piste.id_filiere)
    .filter(Boolean);

  const [
    { data: metierCriteres, error: metierCriteresError },
    { data: filiereCriteres, error: filiereCriteresError },
  ] = await Promise.all([
    metierIds.length
      ? supabase
          .from("metier_critere")
          .select(`
            id_metier,
            id_critere,
            valeur
          `)
          .in("id_metier", metierIds)
      : Promise.resolve({
          data: [],
          error: null,
        }),

    filiereIds.length
      ? supabase
          .from("filiere_critere")
          .select(`
            id_filiere,
            id_critere,
            valeur
          `)
          .in("id_filiere", filiereIds)
      : Promise.resolve({
          data: [],
          error: null,
        }),
  ]);

  if (metierCriteresError) {
    throw metierCriteresError;
  }

  if (filiereCriteresError) {
    throw filiereCriteresError;
  }

  /*
   * ----------------------------------------------------------
   * 8. Maximum par critère
   * ----------------------------------------------------------
   *
   * On ne suppose pas arbitrairement que la base est sur 5.
   * Le moteur observe les valeurs présentes dans les données
   * utilisées pour l'analyse.
   * ----------------------------------------------------------
   */

  const maxParCritere = {};

  for (const ligne of [
    ...safeArray(metierCriteres),
    ...safeArray(filiereCriteres),
  ]) {
    const critere =
      critereById.get(Number(ligne.id_critere));

    if (!critere) continue;

    const code = critere.code;
    const valeur = Number(ligne.valeur);

    if (!Number.isFinite(valeur)) continue;

    maxParCritere[code] = Math.max(
      maxParCritere[code] || 0,
      valeur
    );
  }

  /*
   * ----------------------------------------------------------
   * 9. Calcul de chaque piste
   * ----------------------------------------------------------
   */

  const resultats = [];

  for (const piste of pistesSession) {
    let lignesCriteres = [];

    if (piste.type_piste === "metier") {
      lignesCriteres = safeArray(
        metierCriteres
      )
        .filter(
          (ligne) =>
            Number(ligne.id_metier) ===
            Number(piste.id_metier)
        )
        .map((ligne) => ({
          ...ligne,
          critere: critereById.get(
            Number(ligne.id_critere)
          ),
        }))
        .filter((ligne) => ligne.critere);
    }

    if (piste.type_piste === "filiere") {
      lignesCriteres = safeArray(
        filiereCriteres
      )
        .filter(
          (ligne) =>
            Number(ligne.id_filiere) ===
            Number(piste.id_filiere)
        )
        .map((ligne) => ({
          ...ligne,
          critere: critereById.get(
            Number(ligne.id_critere)
          ),
        }))
        .filter((ligne) => ligne.critere);
    }

    /*
     * RIASEC
     */
    let profilCible = null;
    let scoreRiasec = null;

    if (
      piste.type_piste === "metier" &&
      piste.metier?.profil_riasec
    ) {
      scoreRiasec =
        calculerCompatibiliteRiasec(
          profilUtilisateur,
          piste.metier.profil_riasec
        );
    }

    /*
     * Score critères
     */
    const scoreCriteresData =
      calculerScoreCriteres(
        lignesCriteres,
        preferences,
        maxParCritere
      );

    const scoreCriteres =
      scoreCriteresData.score;

    /*
     * Information
     */
    const scoreInformation =
      calculerScoreInformation(
        piste,
        lignesCriteres,
        profilCible
      );

    /*
     * Pour l'instant, convergence = combinaison
     * des dimensions disponibles.
     */
    const dimensions = [];

    if (scoreRiasec !== null) {
      dimensions.push({
        score: scoreRiasec,
        poids: 0.5,
      });
    }

    if (scoreCriteres !== null) {
      dimensions.push({
        score: scoreCriteres,
        poids: 0.5,
      });
    }

    let scoreConvergence = null;

    if (dimensions.length) {
      const poidsTotal = dimensions.reduce(
        (sum, item) => sum + item.poids,
        0
      );

      scoreConvergence =
        dimensions.reduce(
          (sum, item) =>
            sum + item.score * item.poids,
          0
        ) / poidsTotal;
    }

    resultats.push({
      piste,
      lignesCriteres,
      scoreRiasec,
      scoreCriteres,
      scoreConvergence,
      scoreInformation,
      scoreCriteresDetails:
        scoreCriteresData.details,
      couvertureCriteres:
        scoreCriteresData.couverture,
    });
  }

  /*
   * ----------------------------------------------------------
   * 10. Score global
   * ----------------------------------------------------------
   *
   * Priorité :
   * - RIASEC : 45 %
   * - critères personnels : 40 %
   * - qualité des informations : 15 %
   *
   * Si une dimension est absente, les poids sont
   * automatiquement redistribués.
   * ----------------------------------------------------------
   */

  for (const resultat of resultats) {
    const dimensions = [];

    if (resultat.scoreRiasec !== null) {
      dimensions.push({
        score: resultat.scoreRiasec,
        poids: 45,
      });
    }

    if (resultat.scoreCriteres !== null) {
      dimensions.push({
        score: resultat.scoreCriteres,
        poids: 40,
      });
    }

    dimensions.push({
      score: resultat.scoreInformation,
      poids: 15,
    });

    const poidsTotal = dimensions.reduce(
      (sum, item) => sum + item.poids,
      0
    );

    resultat.scoreGlobal = round(
      dimensions.reduce(
        (sum, item) =>
          sum + item.score * item.poids,
        0
      ) / poidsTotal
    );
  }

  /*
   * ----------------------------------------------------------
   * 11. Différenciation
   * ----------------------------------------------------------
   */

  const scoresGlobaux = resultats.map(
    (resultat) => resultat.scoreGlobal
  );

  for (const resultat of resultats) {
    resultat.scoreDifferenciation =
      round(
        calculerDifferenciation(
          resultat.scoreGlobal,
          scoresGlobaux
        )
      );
  }

  /*
   * ----------------------------------------------------------
   * 12. Classement
   * ----------------------------------------------------------
   */

  resultats.sort(
    (a, b) =>
      b.scoreGlobal - a.scoreGlobal
  );

  /*
   * ----------------------------------------------------------
   * 13. Marge + confiance + position
   * ----------------------------------------------------------
   */

  for (let index = 0; index < resultats.length; index++) {
    const resultat = resultats[index];

    const suivant =
      resultats[index + 1];

    const marge = suivant
      ? resultat.scoreGlobal -
        suivant.scoreGlobal
      : resultat.scoreGlobal;

    resultat.rang = index + 1;
    resultat.marge = round(marge);

    /*
     * La confiance dépend de :
     * - qualité de l'information
     * - différenciation
     * - quantité de données réellement disponibles
     */
    resultat.niveauConfiance = round(
      resultat.scoreInformation * 0.6 +
        resultat.scoreDifferenciation * 0.4
    );

    resultat.position =
      determinerPosition(
        resultat.rang,
        resultat.scoreGlobal,
        resultat.scoreDifferenciation,
        resultat.niveauConfiance,
        resultat.marge
      );

    const explication =
      construireExplication({
        piste: resultat.piste,
        scoreRiasec: resultat.scoreRiasec,
        scoreCriteres: resultat.scoreCriteres,
        scoreInformation:
          resultat.scoreInformation,
        differenciation:
          resultat.scoreDifferenciation,
        preferences,
        detailsCriteres:
          resultat.scoreCriteresDetails,
        blocages,
      });

    resultat.raisons =
      explication.raisons;

    resultat.pointsVigilance =
      explication.points_vigilance;

    resultat.prochainesEtapes =
      explication.prochaines_etapes;
  }

  /*
   * ----------------------------------------------------------
   * 14. Piste dominante
   * ----------------------------------------------------------
   */

  const dominante =
    resultats.find(
      (resultat) =>
        resultat.position === "dominante"
    ) || null;

  /*
   * ----------------------------------------------------------
   * 15. Synthèse
   * ----------------------------------------------------------
   */

  let synthese;

  if (dominante) {
    const nom =
      dominante.piste.type_piste === "metier"
        ? dominante.piste.metier?.nom
        : dominante.piste.filiere?.nom;

    synthese =
      `Une piste ressort actuellement de la comparaison : ${nom}. ` +
      `Elle présente la meilleure convergence entre les données disponibles et les critères exprimés. ` +
      `Ce résultat constitue une piste de réflexion et non une décision définitive.`;
  } else {
    synthese =
      "Aucune piste ne se détache suffisamment pour être considérée comme dominante. " +
      "Les options restent proches ou nécessitent davantage d'informations avant de faire ressortir une direction.";
  }

  /*
   * ----------------------------------------------------------
   * 16. Retour complet
   * ----------------------------------------------------------
   */

  return {
    session,
    id_test_riasec:
      profilUtilisateur?.id_test || null,
    preferences,
    blocages,
    synthese,
    dominante,
    resultats,
    metadata: {
      version_moteur: "v1.2.0",
      nombre_pistes: resultats.length,
      riasec_disponible:
        Boolean(profilUtilisateur),
      nombre_reponses:
        reponsesAnalyse.length,
    },
  };
}
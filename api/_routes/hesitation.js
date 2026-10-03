import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";

/**
 * ============================================================
 * NEXTORI — J'HÉSITE V1.2
 * Backend principal
 * ============================================================
 *
 * Gestion :
 * - critères
 * - questions
 * - pistes personnelles
 * - sessions J'HÉSITE
 * - options d'une session
 * - événements structurés
 *
 * Le moteur d'analyse sera branché ensuite sur
 * hesitation_analyse + hesitation_analyse_piste.
 * ============================================================
 */

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const authUser = getUserFromRequest(req);
  const idUser = authUser && authUser.id_user ? parseInt(authUser.id_user, 10) : null;

  const requireAuth = () => {
    if (!idUser) {
      res.status(401).json({
        success: false,
        message: "Utilisateur non connecté.",
      });
      return false;
    }
    return true;
  };

  try {
    const path = new URL(
      req.url || "",
      `http://${req.headers.host || "localhost"}`
    ).pathname;

    /*
     * ========================================================
     * 1. CRITÈRES
     * GET /api/hesitation/criteres
     * ========================================================
     */

    if (req.method === "GET" && path.endsWith("/criteres")) {
      const { data, error } = await supabase
        .from("hesitation_critere")
        .select(
          "id_critere, code, nom, categorie, actif"
        )
        .eq("actif", true)
        .order("id_critere", { ascending: true });

      if (error) throw error;

      return res.status(200).json({
        success: true,
        data: data || [],
      });
    }

    /*
     * ========================================================
     * 2. QUESTIONS
     * GET /api/hesitation/questions
     * ========================================================
     */

    if (req.method === "GET" && path.endsWith("/questions")) {
      const { data: questions, error: questionsError } =
        await supabase
          .from("hesitation_question")
          .select(
            "id_question, question, ordre, actif"
          )
          .eq("actif", true)
          .order("ordre", { ascending: true });

      if (questionsError) throw questionsError;

      const questionIds = (questions || []).map(
        (question) => question.id_question
      );

      let reponses = [];

      if (questionIds.length > 0) {
        const { data, error } = await supabase
          .from("hesitation_reponse")
          .select(
            "id_reponse, id_question, texte, code, ordre"
          )
          .in("id_question", questionIds)
          .order("ordre", { ascending: true });

        if (error) throw error;

        reponses = data || [];
      }

      const result = (questions || []).map((question) => ({
        ...question,
        reponses: reponses.filter(
          (reponse) =>
            reponse.id_question === question.id_question
        ),
      }));

      return res.status(200).json({
        success: true,
        data: result,
      });
    }

    /*
     * ========================================================
     * 3. MES PISTES
     * GET /api/hesitation/pistes
     * ========================================================
     */

    if (req.method === "GET" && path.endsWith("/pistes")) {
      if (!requireAuth()) return;

      const { data, error } = await supabase
        .from("piste_utilisateur")
        .select(`
          id_piste,
          id_user,
          type_piste,
          id_metier,
          id_filiere,
          date_ajout,
          statut,
          metier (
            id_metier,
            nom,
            presentation,
            secteur,
            niveau_etude,
            salaire_min,
            salaire_max,
            tendance,
            profil_riasec
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
        .eq("statut", "active")
        .order("date_ajout", { ascending: false });

      if (error) throw error;

      return res.status(200).json({
        success: true,
        data: data || [],
      });
    }

    /*
     * ========================================================
     * 4. AJOUTER UNE PISTE
     *
     * POST /api/hesitation/pistes
     *
     * Body :
     * {
     *   "type_piste": "metier",
     *   "id_metier": 12
     * }
     *
     * OU
     *
     * {
     *   "type_piste": "filiere",
     *   "id_filiere": 8
     * }
     * ========================================================
     */

    if (
      req.method === "POST" &&
      path.endsWith("/pistes")
    ) {
      if (!requireAuth()) return;

      const {
        type_piste,
        id_metier,
        id_filiere,
      } = req.body || {};

      if (!["metier", "filiere"].includes(type_piste)) {
        return res.status(400).json({
          success: false,
          message:
            "type_piste doit être 'metier' ou 'filiere'.",
        });
      }

      const metierId =
        id_metier !== undefined && id_metier !== null
          ? parseInt(id_metier, 10)
          : null;

      const filiereId =
        id_filiere !== undefined && id_filiere !== null
          ? parseInt(id_filiere, 10)
          : null;

      if (type_piste === "metier") {
        if (!Number.isInteger(metierId)) {
          return res.status(400).json({
            success: false,
            message: "id_metier est requis.",
          });
        }

        const { data: metier, error: metierError } =
          await supabase
            .from("metier")
            .select("id_metier, nom")
            .eq("id_metier", metierId)
            .maybeSingle();

        if (metierError) throw metierError;

        if (!metier) {
          return res.status(404).json({
            success: false,
            message: "Métier introuvable.",
          });
        }
      }

      if (type_piste === "filiere") {
        if (!Number.isInteger(filiereId)) {
          return res.status(400).json({
            success: false,
            message: "id_filiere est requis.",
          });
        }

        const { data: filiere, error: filiereError } =
          await supabase
            .from("filiere")
            .select("id_filiere, nom")
            .eq("id_filiere", filiereId)
            .maybeSingle();

        if (filiereError) throw filiereError;

        if (!filiere) {
          return res.status(404).json({
            success: false,
            message: "Filière introuvable.",
          });
        }
      }

      /*
       * Grâce aux index uniques créés dans la migration,
       * une même piste ne peut pas être ajoutée deux fois.
       */

      let existingQuery = supabase
        .from("piste_utilisateur")
        .select("*")
        .eq("id_user", idUser)
        .eq("statut", "active");

      if (type_piste === "metier") {
        existingQuery = existingQuery.eq(
          "id_metier",
          metierId
        );
      } else {
        existingQuery = existingQuery.eq(
          "id_filiere",
          filiereId
        );
      }

      const {
        data: existing,
        error: existingError,
      } = await existingQuery.maybeSingle();

      if (existingError) throw existingError;

      if (existing) {
        return res.status(200).json({
          success: true,
          already_exists: true,
          data: existing,
          message: "Cette piste est déjà enregistrée.",
        });
      }

      const pistePayload = {
        id_user: idUser,
        type_piste,
        id_metier:
          type_piste === "metier"
            ? metierId
            : null,
        id_filiere:
          type_piste === "filiere"
            ? filiereId
            : null,
        statut: "active",
      };

      const {
        data: piste,
        error: pisteError,
      } = await supabase
        .from("piste_utilisateur")
        .insert([pistePayload])
        .select(`
          id_piste,
          id_user,
          type_piste,
          id_metier,
          id_filiere,
          date_ajout,
          statut,
          metier (
            id_metier,
            nom,
            presentation,
            secteur,
            niveau_etude,
            salaire_min,
            salaire_max,
            tendance,
            profil_riasec
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
        .single();

      if (pisteError) throw pisteError;

      /*
       * Événement structuré
       */

      await supabase
        .from("hesitation_evenement")
        .insert([
          {
            id_user: idUser,
            id_piste: piste.id_piste,
            type_evenement: "PISTE_AJOUTEE",
            contexte: {
              type_piste,
              id_metier: metierId,
              id_filiere: filiereId,
            },
          },
        ]);

      return res.status(201).json({
        success: true,
        data: piste,
        message: "Piste ajoutée avec succès.",
      });
    }

    /*
     * ========================================================
     * 5. ARCHIVER UNE PISTE
     *
     * DELETE /api/hesitation/pistes?id_piste=12
     *
     * On n'efface pas réellement la piste.
     * Elle est archivée pour préserver l'historique.
     * ========================================================
     */

    if (
      req.method === "DELETE" &&
      path.endsWith("/pistes")
    ) {
      if (!requireAuth()) return;

      const idPiste = parseInt(
        req.query?.id_piste,
        10
      );

      if (!Number.isInteger(idPiste)) {
        return res.status(400).json({
          success: false,
          message: "id_piste est requis.",
        });
      }

      const {
        data: piste,
        error: pisteError,
      } = await supabase
        .from("piste_utilisateur")
        .select("id_piste, id_user, statut")
        .eq("id_piste", idPiste)
        .eq("id_user", idUser)
        .maybeSingle();

      if (pisteError) throw pisteError;

      if (!piste) {
        return res.status(404).json({
          success: false,
          message: "Piste introuvable.",
        });
      }

      if (piste.statut === "archive") {
        return res.status(200).json({
          success: true,
          message: "Piste déjà archivée.",
        });
      }

      const { error: archiveError } = await supabase
        .from("piste_utilisateur")
        .update({ statut: "archive" })
        .eq("id_piste", idPiste)
        .eq("id_user", idUser);

      if (archiveError) throw archiveError;

      await supabase
        .from("hesitation_evenement")
        .insert([
          {
            id_user: idUser,
            id_piste: idPiste,
            type_evenement: "PISTE_ARCHIVEE",
            contexte: {},
          },
        ]);

      return res.status(200).json({
        success: true,
        message: "Piste retirée de vos pistes.",
      });
    }

    /*
     * ========================================================
     * 6. CRÉER UNE SESSION J'HÉSITE
     *
     * POST /api/hesitation/session
     *
     * Body :
     * {
     *   "pistes": [12, 18, 25]
     * }
     *
     * Les IDs sont des id_piste de l'utilisateur.
     * ========================================================
     */

    if (
      req.method === "POST" &&
      path.endsWith("/session")
    ) {
      if (!requireAuth()) return;

      const { pistes } = req.body || {};

      if (
        !Array.isArray(pistes) ||
        pistes.length < 2
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Au moins deux pistes sont nécessaires pour commencer J'HÉSITE.",
        });
      }

      const pisteIds = [
        ...new Set(
          pistes
            .map((id) => parseInt(id, 10))
            .filter((id) => Number.isInteger(id))
        ),
      ];

      if (pisteIds.length < 2) {
        return res.status(400).json({
          success: false,
          message:
            "Les pistes sélectionnées sont invalides.",
        });
      }

      /*
       * Vérifier que toutes les pistes appartiennent
       * réellement à l'utilisateur.
       */

      const {
        data: selectedPistes,
        error: pistesError,
      } = await supabase
        .from("piste_utilisateur")
        .select(`
          id_piste,
          id_user,
          type_piste,
          id_metier,
          id_filiere,
          statut,
          metier (
            id_metier,
            nom
          ),
          filiere (
            id_filiere,
            nom
          )
        `)
        .eq("id_user", idUser)
        .eq("statut", "active")
        .in("id_piste", pisteIds);

      if (pistesError) throw pistesError;

      if (
        !selectedPistes ||
        selectedPistes.length !== pisteIds.length
      ) {
        return res.status(403).json({
          success: false,
          message:
            "Une ou plusieurs pistes sélectionnées ne vous appartiennent pas ou ne sont plus actives.",
        });
      }

      /*
       * Récupérer le dernier RIASEC.
       * On conserve tous les anciens tests.
       * Le dernier test est simplement celui utilisé
       * comme profil actif pour cette analyse.
       */

      const {
        data: riasec,
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

      /*
       * Une session peut fonctionner sans RIASEC.
       * id_test_riasec restera alors NULL dans
       * hesitation_analyse.
       */

      /*
       * Créer la session.
       */

      const { data: session, error: sessionError } =
        await supabase
          .from("hesitation_test")
          .insert([
            {
              id_user: idUser,
              type_choix: "mixte",
              statut: "en_cours",
            },
          ])
          .select(`
            id_hesitation_test,
            id_user,
            type_choix,
            date_creation,
            statut
          `)
          .single();

      if (sessionError) throw sessionError;

      /*
       * Créer les options de la session.
       */

      const optionRows = selectedPistes.map((piste, index) => ({
        id_hesitation_test:
          session.id_hesitation_test,
        id_metier:
          piste.type_piste === "metier"
            ? piste.id_metier
            : null,
        id_filiere:
          piste.type_piste === "filiere"
            ? piste.id_filiere
            : null,
        ordre: index + 1,
      }));

      const {
        data: options,
        error: optionsError,
      } = await supabase
        .from("hesitation_option")
        .insert(optionRows)
        .select(`
          id_hesitation_option,
          id_hesitation_test,
          id_metier,
          id_filiere,
          ordre
        `);

      if (optionsError) {
        /*
         * Si les options échouent, on supprime la session
         * créée juste avant afin de ne pas laisser une
         * session incomplète.
         */

        await supabase
          .from("hesitation_test")
          .delete()
          .eq(
            "id_hesitation_test",
            session.id_hesitation_test
          );

        throw optionsError;
      }

      /*
       * Événement session créée.
       */

      await supabase
        .from("hesitation_evenement")
        .insert([
          {
            id_user: idUser,
            id_hesitation_test:
              session.id_hesitation_test,
            type_evenement: "SESSION_CREEE",
            contexte: {
              nombre_pistes: selectedPistes.length,
              pistes: pisteIds,
              id_test_riasec: riasec?.id_test || null,
            },
          },
        ]);

      return res.status(201).json({
        success: true,
        data: {
          session,
          pistes: selectedPistes,
          options: options || [],
          riasec: riasec || null,
        },
        message:
          "Session J'HÉSITE créée avec succès.",
      });
    }

    /*
     * ========================================================
     * 7. RÉCUPÉRER UNE SESSION
     *
     * GET /api/hesitation/session?id_hesitation_test=...
     * ========================================================
     */

    if (
      req.method === "GET" &&
      path.endsWith("/session")
    ) {
      if (!requireAuth()) return;

      const idSession = parseInt(
        req.query?.id_hesitation_test,
        10
      );

      if (!Number.isInteger(idSession)) {
        return res.status(400).json({
          success: false,
          message:
            "id_hesitation_test est requis.",
        });
      }

      const {
        data: session,
        error: sessionError,
      } = await supabase
        .from("hesitation_test")
        .select(`
          id_hesitation_test,
          id_user,
          type_choix,
          date_creation,
          statut
        `)
        .eq("id_hesitation_test", idSession)
        .eq("id_user", idUser)
        .maybeSingle();

      if (sessionError) throw sessionError;

      if (!session) {
        return res.status(404).json({
          success: false,
          message: "Session introuvable.",
        });
      }

      const {
        data: options,
        error: optionsError,
      } = await supabase
        .from("hesitation_option")
        .select(`
          id_hesitation_option,
          id_hesitation_test,
          id_metier,
          id_filiere,
          ordre,
          metier (
            id_metier,
            nom,
            presentation,
            secteur,
            niveau_etude,
            salaire_min,
            salaire_max,
            tendance,
            profil_riasec
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
        .eq(
          "id_hesitation_test",
          idSession
        )
        .order("ordre", {
          ascending: true,
        });

      if (optionsError) throw optionsError;

      const {
        data: analyse,
        error: analyseError,
      } = await supabase
        .from("hesitation_analyse")
        .select(`
          id_analyse,
          id_hesitation_test,
          id_test_riasec,
          id_piste_dominante,
          version_moteur,
          niveau_confiance,
          synthese,
          date_analyse
        `)
        .eq(
          "id_hesitation_test",
          idSession
        )
        .maybeSingle();

      if (analyseError) throw analyseError;

      return res.status(200).json({
        success: true,
        data: {
          session,
          options: options || [],
          analyse: analyse || null,
        },
      });
    }

    /*
     * ========================================================
     * ROUTE RACINE
     * ========================================================
     */

    if (req.method === "GET") {
      return res.status(200).json({
        success: true,
        message: "Service J'HÉSITE V1.2 actif.",
        endpoints: {
          criteres: "/api/hesitation/criteres",
          questions: "/api/hesitation/questions",
          pistes: "/api/hesitation/pistes",
          session: "/api/hesitation/session",
        },
      });
    }

    return res.status(405).json({
      success: false,
      message: "Méthode non autorisée.",
    });
  } catch (err) {
    console.error("Hesitation V1.2 error:", err);

    return res.status(500).json({
      success: false,
      message:
        err.message ||
        "Erreur serveur J'HÉSITE.",
    });
  }
}
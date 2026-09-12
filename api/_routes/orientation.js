import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";
import {
  calculateRiasecScores,
  getRecommendedMetiers,
} from "../_lib/orientationEngine.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const authUser = getUserFromRequest(req);
  if (!authUser || !authUser.id_user) {
    return res.status(401).json({
      success: false,
      message: "Utilisateur non connecté.",
    });
  }

  const idUser = authUser.id_user;

  try {
    if (req.method === "GET") {
      // Obtenir le dernier résultat
      const { data: lastTest, error: testErr } = await supabase
        .from("test_riasec")
        .select("*")
        .eq("id_user", idUser)
        .order("id_test", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (testErr || !lastTest) {
        return res.status(404).json({
          success: false,
          message: "Aucun résultat trouvé.",
        });
      }

      const { data: user } = await supabase
        .from("utilisateur")
        .select("id_serie")
        .eq("id_user", idUser)
        .maybeSingle();

      const idSerie = user?.id_serie || null;
      const recommandations = await getRecommendedMetiers(lastTest.profil_dominant, idSerie);

      const responseData = {
        id_test: lastTest.id_test,
        profil: {
          principal: lastTest.profil_dominant,
          scores: {
            R: lastTest.score_r ?? lastTest.score_R ?? 0,
            I: lastTest.score_i ?? lastTest.score_I ?? 0,
            A: lastTest.score_a ?? lastTest.score_A ?? 0,
            S: lastTest.score_s ?? lastTest.score_S ?? 0,
            E: lastTest.score_e ?? lastTest.score_E ?? 0,
            C: lastTest.score_c ?? lastTest.score_C ?? 0,
          },
        },
        recommandations,
      };

      return res.status(200).json({
        success: true,
        data: responseData,
        ...responseData,
      });
    }

    if (req.method === "POST") {
      const { id_questionnaire, reponses } = req.body || {};

      if (!reponses || !Array.isArray(reponses) || reponses.length === 0) {
        return res.status(400).json({
          success: false,
          message: "Réponses manquantes ou invalides.",
        });
      }

      // 1. Récupérer les propositions sélectionnées pour connaître leur type_riasec
      const propIds = reponses.map((r) => parseInt(r.id_proposition, 10)).filter(Boolean);
      const { data: propositions, error: propErr } = await supabase
        .from("proposition")
        .select("id_proposition, type_riasec")
        .in("id_proposition", propIds);

      if (propErr) throw propErr;

      const typesList = (propositions || []).map((p) => p.type_riasec);
      const { scores, dominantProfile } = calculateRiasecScores(typesList);

      // 2. Créer le test avec ses scores
      let testInsert = {
        id_user: idUser,
        id_questionnaire: id_questionnaire ? parseInt(id_questionnaire, 10) : 1,
        date_test: new Date().toISOString(),
        score_r: scores.R,
        score_i: scores.I,
        score_a: scores.A,
        score_s: scores.S,
        score_e: scores.E,
        score_c: scores.C,
        profil_dominant: dominantProfile,
      };

      let { data: newTest, error: createTestErr } = await supabase
        .from("test_riasec")
        .insert([testInsert])
        .select("id_test")
        .single();

      // Tentative avec colonnes majuscules si nécessaire
      if (createTestErr) {
        console.warn("Retrying test insert with uppercase score column names:", createTestErr.message);
        testInsert = {
          id_user: idUser,
          id_questionnaire: id_questionnaire ? parseInt(id_questionnaire, 10) : 1,
          date_test: new Date().toISOString(),
          score_R: scores.R,
          score_I: scores.I,
          score_A: scores.A,
          score_S: scores.S,
          score_E: scores.E,
          score_C: scores.C,
          profil_dominant: dominantProfile,
        };
        const retry = await supabase
          .from("test_riasec")
          .insert([testInsert])
          .select("id_test")
          .single();
        newTest = retry.data;
        createTestErr = retry.error;
      }

      if (createTestErr || !newTest) {
        console.error("Test creation error:", createTestErr);
        throw new Error("Impossible de créer le test.");
      }

      const idTest = newTest.id_test;

      // 3. Enregistrer les réponses
      try {
        const reponsesRows = reponses
          .map((r) => ({
            id_test: idTest,
            id_proposition: parseInt(r.id_proposition, 10),
          }))
          .filter((r) => !isNaN(r.id_proposition));

        if (reponsesRows.length > 0) {
          await supabase.from("reponse").insert(reponsesRows);
        }
      } catch (repErr) {
        console.warn("Erreur enregistrement réponses (non-bloquant):", repErr);
      }

      // 4. Attribuer automatiquement le badge EXPLORATEUR
      try {
        const { data: badgeExplorateur } = await supabase
          .from("badge")
          .select("id_badge")
          .eq("code", "EXPLORATEUR")
          .maybeSingle();

        if (badgeExplorateur) {
          const today = new Date().toISOString().split("T")[0];
          await supabase.from("badge_utilisateur").upsert(
            {
              id_user: idUser,
              id_badge: badgeExplorateur.id_badge,
              date_obtention: today,
            },
            { onConflict: "id_user,id_badge" }
          );
        }
      } catch (bErr) {
        console.warn("Erreur attribution badge EXPLORATEUR:", bErr);
      }

      // 5. Enregistrer les actions dans l'historique
      try {
        const nowIso = new Date().toISOString();
        await supabase.from("historique").insert([
          { id_user: idUser, action: "TEST_EFFECTUE", date_action: nowIso },
          { id_user: idUser, action: "METIERS_CONSULTES", date_action: nowIso },
        ]);
      } catch (hErr) {
        console.warn("Erreur enregistrement historique test:", hErr);
      }

      // 6. Calculer recommandations
      const { data: user } = await supabase
        .from("utilisateur")
        .select("id_serie")
        .eq("id_user", idUser)
        .maybeSingle();

      const idSerie = user?.id_serie || null;
      const recommandations = await getRecommendedMetiers(dominantProfile, idSerie);

      const responseData = {
        id_test: idTest,
        profil: {
          principal: dominantProfile,
          scores,
        },
        recommandations,
      };

      return res.status(200).json({
        success: true,
        data: responseData,
        ...responseData,
      });
    }

    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  } catch (err) {
    console.error("Orientation error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur lors du traitement de l'orientation.",
    });
  }
}

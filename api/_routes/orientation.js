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

      return res.status(200).json({
        success: true,
        id_test: lastTest.id_test,
        profil: {
          principal: lastTest.profil_dominant,
          scores: {
            R: lastTest.score_r,
            I: lastTest.score_i,
            A: lastTest.score_a,
            S: lastTest.score_s,
            E: lastTest.score_e,
            C: lastTest.score_c,
          },
        },
        recommandations,
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

      // 1. Créer le test
      const { data: newTest, error: createTestErr } = await supabase
        .from("test_riasec")
        .insert([
          {
            id_user: idUser,
            id_questionnaire: id_questionnaire ? parseInt(id_questionnaire, 10) : 1,
            date_test: new Date().toISOString(),
          },
        ])
        .select("id_test")
        .single();

      if (createTestErr || !newTest) {
        console.error("Test creation error:", createTestErr);
        throw new Error("Impossible de créer le test.");
      }

      const idTest = newTest.id_test;

      // 2. Récupérer les propositions sélectionnées pour connaître leur type_riasec
      const propIds = reponses.map((r) => parseInt(r.id_proposition, 10)).filter(Boolean);
      const { data: propositions, error: propErr } = await supabase
        .from("proposition")
        .select("id_proposition, type_riasec")
        .in("id_proposition", propIds);

      if (propErr) throw propErr;

      const typesList = (propositions || []).map((p) => p.type_riasec);
      const { scores, dominantProfile } = calculateRiasecScores(typesList);

      // 3. Enregistrer les réponses
      const reponsesRows = reponses.map((r) => ({
        id_test: idTest,
        id_question: parseInt(r.id_question, 10),
        id_proposition: parseInt(r.id_proposition, 10),
      }));

      await supabase.from("reponse").insert(reponsesRows);

      // 4. Mettre à jour le test avec les scores
      await supabase
        .from("test_riasec")
        .update({
          score_r: scores.R,
          score_i: scores.I,
          score_a: scores.A,
          score_s: scores.S,
          score_e: scores.E,
          score_c: scores.C,
          profil_dominant: dominantProfile,
        })
        .eq("id_test", idTest);

      // 5. Calculer recommandations
      const { data: user } = await supabase
        .from("utilisateur")
        .select("id_serie")
        .eq("id_user", idUser)
        .maybeSingle();

      const idSerie = user?.id_serie || null;
      const recommandations = await getRecommendedMetiers(dominantProfile, idSerie);

      return res.status(200).json({
        success: true,
        id_test: idTest,
        profil: {
          principal: dominantProfile,
          scores,
        },
        recommandations,
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

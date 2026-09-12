import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";
import { getRecommendedMetiers } from "../_lib/orientationEngine.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const authUser = getUserFromRequest(req);
  if (!authUser || !authUser.id_user) {
    return res.status(401).json({
      success: false,
      message: "Utilisateur non connecté.",
    });
  }

  const idTest = req.query.id_test;
  if (!idTest) {
    return res.status(400).json({
      success: false,
      message: "Identifiant du test manquant.",
    });
  }

  try {
    const { data: test, error } = await supabase
      .from("test_riasec")
      .select("*")
      .eq("id_test", parseInt(idTest, 10))
      .eq("id_user", authUser.id_user)
      .maybeSingle();

    if (error || !test) {
      return res.status(404).json({
        success: false,
        message: "Test introuvable.",
      });
    }

    const { data: user } = await supabase
      .from("utilisateur")
      .select("id_serie")
      .eq("id_user", authUser.id_user)
      .maybeSingle();

    const idSerie = user?.id_serie || null;
    const recommandations = await getRecommendedMetiers(test.profil_dominant, idSerie);

    return res.status(200).json({
      success: true,
      data: {
        id_test: test.id_test,
        date_test: test.date_test,
        profil: {
          principal: test.profil_dominant,
          scores: {
            R: test.score_r ?? test.score_R ?? 0,
            I: test.score_i ?? test.score_I ?? 0,
            A: test.score_a ?? test.score_A ?? 0,
            S: test.score_s ?? test.score_S ?? 0,
            E: test.score_e ?? test.score_E ?? 0,
            C: test.score_c ?? test.score_C ?? 0,
          },
        },
        recommandations,
      },
      message: "Test historique récupéré avec succès.",
    });
  } catch (err) {
    console.error("Historique test detail error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur.",
    });
  }
}

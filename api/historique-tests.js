import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";
import { getUserFromRequest } from "./_lib/auth.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const authUser = getUserFromRequest(req);
  if (!authUser || !authUser.id_user) {
    return res.status(401).json({
      success: false,
      message: "Utilisateur non connecté.",
    });
  }

  try {
    const { data: tests, error } = await supabase
      .from("test_riasec")
      .select("id_test, id_user, id_questionnaire, date_test, score_r, score_i, score_a, score_s, score_e, score_c, profil_dominant")
      .eq("id_user", authUser.id_user)
      .order("date_test", { ascending: false });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      data: tests || [],
      message: "Historique des tests récupéré avec succès.",
    });
  } catch (err) {
    console.error("Historique tests error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur lors de la récupération de l'historique.",
    });
  }
}

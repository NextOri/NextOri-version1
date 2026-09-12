import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";

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
      .select("*")
      .eq("id_user", authUser.id_user)
      .order("date_test", { ascending: false });

    if (error) throw error;

    const normalizedTests = (tests || []).map((t) => {
      const r = t.score_r ?? t.score_R ?? 0;
      const i = t.score_i ?? t.score_I ?? 0;
      const a = t.score_a ?? t.score_A ?? 0;
      const s = t.score_s ?? t.score_S ?? 0;
      const e = t.score_e ?? t.score_E ?? 0;
      const c = t.score_c ?? t.score_C ?? 0;

      return {
        ...t,
        score_r: r,
        score_i: i,
        score_a: a,
        score_s: s,
        score_e: e,
        score_c: c,
        score_R: r,
        score_I: i,
        score_A: a,
        score_S: s,
        score_E: e,
        score_C: c,
      };
    });

    return res.status(200).json({
      success: true,
      data: normalizedTests,
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

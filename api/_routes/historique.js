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
    const { action } = req.body || {};

    if (!action) {
      return res.status(400).json({
        success: false,
        message: "Action requise.",
      });
    }

    const { error } = await supabase.from("historique").insert([
      {
        id_user: authUser.id_user,
        action: String(action),
        date_action: new Date().toISOString(),
      },
    ]);

    if (error) throw error;

    return res.status(200).json({
      success: true,
      message: "Action enregistrée",
    });
  } catch (err) {
    console.error("Historique error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

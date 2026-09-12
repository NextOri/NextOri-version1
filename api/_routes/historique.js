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
    if (req.method === "GET") {
      const { data: actions, error } = await supabase
        .from("historique")
        .select("*")
        .eq("id_user", authUser.id_user)
        .order("date_action", { ascending: false });

      if (error) throw error;

      return res.status(200).json({
        success: true,
        data: actions || [],
        message: "Historique récupéré avec succès.",
      });
    }

    if (req.method === "POST") {
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
    }

    return res.status(405).json({
      success: false,
      message: "Méthode non autorisée.",
    });
  } catch (err) {
    console.error("Historique error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";
import { getUserFromRequest } from "./_lib/auth.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "GET") {
    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  }

  try {
    const authUser = getUserFromRequest(req);
    const idUser = req.query.id_user || (authUser && authUser.id_user);

    if (!idUser) {
      return res.status(400).json({
        success: false,
        message: "ID utilisateur manquant.",
      });
    }

    const { data: utilisateur, error } = await supabase
      .from("utilisateur")
      .select("id_user, nom, prenom, email, role, pays, niveau_etude, id_serie, telephone, statut_actuel, date_creation")
      .eq("id_user", parseInt(idUser, 10))
      .single();

    if (error || !utilisateur) {
      return res.status(404).json({
        success: false,
        message: "Utilisateur introuvable.",
      });
    }

    return res.status(200).json({
      success: true,
      utilisateur,
    });
  } catch (err) {
    console.error("Profil error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la récupération du profil.",
    });
  }
}

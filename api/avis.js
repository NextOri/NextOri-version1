import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";
import { getUserFromRequest } from "./_lib/auth.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  }

  const authUser = getUserFromRequest(req);
  if (!authUser || !authUser.id_user) {
    return res.status(401).json({ success: false, message: "Utilisateur non connecté." });
  }

  try {
    const { note, commentaire, afficher } = req.body || {};

    const numNote = parseInt(note, 10);
    if (isNaN(numNote) || numNote < 1 || numNote > 5) {
      return res.status(400).json({
        success: false,
        message: "La note doit être comprise entre 1 et 5.",
      });
    }

    if (!commentaire || !String(commentaire).trim()) {
      return res.status(400).json({
        success: false,
        message: "Veuillez écrire un commentaire.",
      });
    }

    const { data: newAvis, error } = await supabase
      .from("avis")
      .insert([
        {
          id_user: authUser.id_user,
          note: numNote,
          commentaire: String(commentaire).trim(),
          afficher: Boolean(afficher),
          approuve: false,
          date_creation: new Date().toISOString(),
        },
      ])
      .select("*")
      .single();

    if (error) throw error;

    // Enregistrer l'action dans l'historique
    await supabase.from("historique").insert([
      {
        id_user: authUser.id_user,
        action: "AVIS_DONNE",
        date_action: new Date().toISOString(),
      },
    ]);

    return res.status(200).json({
      success: true,
      message: "Merci pour ton avis !",
      data: newAvis,
    });
  } catch (err) {
    console.error("Avis error:", err);
    return res.status(500).json({
      success: false,
      message: "Une erreur est survenue lors de l'enregistrement de l'avis.",
    });
  }
}

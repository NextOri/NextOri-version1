import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";

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
    const { fonctionnalite } = req.body || {};

    if (!fonctionnalite || !String(fonctionnalite).trim()) {
      return res.status(400).json({
        success: false,
        message: "Fonctionnalité non renseignée.",
      });
    }

    const fonctionnaliteNormalisee = String(fonctionnalite).trim();

    const { data: inscriptionExistante, error: erreurVerification } = await supabase
      .from("attente_fonctionnalite")
      .select("id_user")
      .eq("id_user", authUser.id_user)
      .eq("fonctionnalite", fonctionnaliteNormalisee)
      .maybeSingle();

    if (erreurVerification) throw erreurVerification;

    if (inscriptionExistante) {
      return res.status(200).json({
        success: true,
        dejaInscrit: true,
        message: "Vous êtes déjà inscrit pour cette fonctionnalité.",
      });
    }

    const { error } = await supabase.from("attente_fonctionnalite").upsert(
      {
        id_user: authUser.id_user,
        fonctionnalite: fonctionnaliteNormalisee,
        statut: "EN_ATTENTE",
        date_inscription: new Date().toISOString(),
      },
      { onConflict: "id_user,fonctionnalite" }
    );

    if (error) throw error;

    return res.status(200).json({
      success: true,
      dejaInscrit: false,
      message: "Vous serez notifié dès que cette fonctionnalité sera disponible !",
    });
  } catch (err) {
    console.error("Notifier error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur.",
    });
  }
}

import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const { data: temoignages, error } = await supabase
      .from("avis")
      .select("id_avis, note, commentaire, date_creation, utilisateur(nom)")
      .eq("afficher", true)
      .order("date_creation", { ascending: false });

    if (error) throw error;

    const formatted = (temoignages || []).map((t) => ({
      id_avis: t.id_avis,
      note: t.note,
      commentaire: t.commentaire,
      date_creation: t.date_creation,
      nom_utilisateur: t.utilisateur?.nom || "Utilisateur",
    }));

    return res.status(200).json({
      success: true,
      temoignages: formatted,
    });
  } catch (err) {
    console.error("Temoignages error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération des témoignages.",
      erreur: err.message,
    });
  }
}

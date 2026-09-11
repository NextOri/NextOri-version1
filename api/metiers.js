import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const { data: metiers, error } = await supabase
      .from("metier")
      .select("id_metier, nom, description, secteur, niveau_etude, salaire_min, salaire_max, tendance")
      .order("nom", { ascending: true });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      data: metiers || [],
    });
  } catch (err) {
    console.error("Metiers error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur lors de la récupération des métiers.",
    });
  }
}

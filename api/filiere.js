import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const { data: filieres, error } = await supabase
      .from("filiere")
      .select("id_filiere, nom, description, domaine, duree, presentation, competences_developpees")
      .order("nom", { ascending: true });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      data: filieres || [],
    });
  } catch (err) {
    console.error("Filiere error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur lors de la récupération des filières.",
    });
  }
}

import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idMetier = req.query.id_metier;

    if (idMetier) {
      const { data: links, error } = await supabase
        .from("metier_filiere")
        .select("id_filiere, filiere(id_filiere, nom, description, domaine, duree)")
        .eq("id_metier", parseInt(idMetier, 10));

      if (error) throw error;

      const formations = (links || [])
        .map((l) => l.filiere)
        .filter(Boolean);

      return res.status(200).json({
        success: true,
        formations,
      });
    }

    // Si aucun id_metier n'est fourni, retourner toutes les filières
    const { data: filieres, error } = await supabase
      .from("filiere")
      .select("id_filiere, nom, description, domaine, duree")
      .order("nom", { ascending: true });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      formations: filieres || [],
    });
  } catch (err) {
    console.error("Filieres error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur lors du chargement des formations.",
      error: err.message,
    });
  }
}

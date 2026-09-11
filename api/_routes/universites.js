import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idFiliere = req.query.id_filiere;

    if (!idFiliere) {
      return res.status(400).json({
        success: false,
        message: "Aucune filière fournie.",
      });
    }

    const { data: links, error } = await supabase
      .from("universite_filiere")
      .select("universite(id_universite, nom, description, type, pays, ville, site_web, logo)")
      .eq("id_filiere", parseInt(idFiliere, 10));

    if (error) throw error;

    const universites = (links || [])
      .map((l) => l.universite)
      .filter(Boolean);

    return res.status(200).json({
      success: true,
      universites,
    });
  } catch (err) {
    console.error("Universites error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur lors du chargement des universités.",
      error: err.message,
    });
  }
}

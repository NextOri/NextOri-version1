import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idMetier = req.query.id_metier;

    if (!idMetier) {
      return res.status(400).json({
        success: false,
        message: "ID métier manquant",
      });
    }

    const { data: metier, error } = await supabase
      .from("metier")
      .select("id_metier, nom, presentation, competences, secteur, niveau_etude, salaire_min, salaire_max, tendance")
      .eq("id_metier", parseInt(idMetier, 10))
      .maybeSingle();

    if (error || !metier) {
      return res.status(404).json({
        success: false,
        message: "Métier introuvable",
      });
    }

    // Récupérer les filières associées
    const { data: filieresLinks } = await supabase
      .from("metier_filiere")
      .select("id_filiere, filiere(id_filiere, nom)")
      .eq("id_metier", parseInt(idMetier, 10));

    const filieres = (filieresLinks || [])
      .map((item) => item.filiere)
      .filter(Boolean);

    metier.filieres = filieres;

    return res.status(200).json({
      success: true,
      data: metier,
    });
  } catch (err) {
    console.error("Metier detail error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

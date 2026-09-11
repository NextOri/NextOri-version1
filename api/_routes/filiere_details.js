import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idFiliere = req.query.id_filiere;

    if (!idFiliere) {
      return res.status(400).json({
        success: false,
        message: "ID filière manquant.",
      });
    }

    const fid = parseInt(idFiliere, 10);

    const { data: filiere, error } = await supabase
      .from("filiere")
      .select("id_filiere, nom, description, presentation, domaine, duree, competences_developpees")
      .eq("id_filiere", fid)
      .maybeSingle();

    if (error || !filiere) {
      return res.status(404).json({
        success: false,
        message: "Filière introuvable.",
      });
    }

    // Récupérer métiers associés
    const { data: metierLinks } = await supabase
      .from("metier_filiere")
      .select("metier(id_metier, nom, secteur)")
      .eq("id_filiere", fid);

    const metiers = (metierLinks || [])
      .map((m) => m.metier)
      .filter(Boolean);

    // Récupérer universités associées
    const { data: univLinks } = await supabase
      .from("universite_filiere")
      .select("universite(id_universite, nom, ville, pays, logo)")
      .eq("id_filiere", fid);

    const universites = (univLinks || [])
      .map((u) => u.universite)
      .filter(Boolean);

    return res.status(200).json({
      success: true,
      data: filiere,
      metiers,
      universites,
    });
  } catch (err) {
    console.error("Filiere details error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur.",
    });
  }
}

import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idUniversite = req.query.id_universite;

    if (!idUniversite) {
      return res.status(400).json({
        success: false,
        message: "Le paramètre id_universite est obligatoire.",
      });
    }

    const uid = parseInt(idUniversite, 10);

    const { data: universite, error: uError } = await supabase
      .from("universite")
      .select("*")
      .eq("id_universite", uid)
      .maybeSingle();

    if (uError || !universite) {
      return res.status(404).json({
        success: false,
        message: "Université introuvable.",
      });
    }

    const { data: detail } = await supabase
      .from("universite_detail")
      .select("*")
      .eq("id_universite", uid)
      .maybeSingle();

    const { data: filiereLinks } = await supabase
      .from("universite_filiere")
      .select("filiere(id_filiere, nom, domaine, duree)")
      .eq("id_universite", uid);

    const filieres = (filiereLinks || [])
      .map((f) => f.filiere)
      .filter(Boolean);

    return res.status(200).json({
      success: true,
      universite,
      detail: detail || null,
      filieres,
    });
  } catch (err) {
    console.error("Universite detail error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const { data: universites, error } = await supabase
      .from("universite")
      .select("id_universite, nom, description, type, pays, ville, site_web, logo")
      .order("nom", { ascending: true });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      data: universites || [],
    });
  } catch (err) {
    console.error("Universite catalogue error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

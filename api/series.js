import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const { data: series, error } = await supabase
      .from("serie")
      .select("id_serie, nom")
      .order("id_serie", { ascending: true });

    if (error) throw error;

    return res.status(200).json(series || []);
  } catch (err) {
    console.error("Series error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération des séries.",
    });
  }
}

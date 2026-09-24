import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "GET") {
    return res.status(405).json({
      success: false,
      message: "Méthode non autorisée.",
    });
  }

  try {
    const code = String(req.query?.code || "").trim().toUpperCase();
    let query = supabase
      .from("profil_riasec")
      .select("code, nom, description, forces, competences, environnements")
      .eq("actif", true)
      .order("code", { ascending: true });

    if (code) {
      query = query.eq("code", code);
    }

    const { data, error } = await query;
    if (error) throw error;

    const profils = Object.fromEntries(
      (data || []).map((profil) => [profil.code, profil])
    );

    return res.status(200).json({
      success: true,
      data: code ? profils[code] || null : profils,
    });
  } catch (err) {
    console.error("Profils RIASEC error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur lors du chargement des profils RIASEC.",
    });
  }
}

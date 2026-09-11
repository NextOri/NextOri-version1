import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idQuestion = req.query.id_question;

    if (!idQuestion) {
      return res.status(400).json({
        success: false,
        message: "id_question manquant.",
      });
    }

    const { data: propositions, error } = await supabase
      .from("proposition")
      .select("id_proposition, lettre, libelle, type_riasec")
      .eq("id_question", parseInt(idQuestion, 10))
      .order("lettre", { ascending: true });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      data: propositions || [],
    });
  } catch (err) {
    console.error("Propositions error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

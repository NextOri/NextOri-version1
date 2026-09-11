import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const idQuestionnaire = req.query.id_questionnaire || 1;

    const { data: questions, error } = await supabase
      .from("question")
      .select("id_question, texte, ordre")
      .eq("id_questionnaire", parseInt(idQuestionnaire, 10))
      .order("ordre", { ascending: true });

    if (error) throw error;

    return res.status(200).json({
      success: true,
      data: questions || [],
    });
  } catch (err) {
    console.error("Questions error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur",
    });
  }
}

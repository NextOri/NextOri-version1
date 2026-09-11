import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const url = req.url || "";
  const method = req.method;

  try {
    if (method === "GET" && url.includes("/criteres")) {
      const { data: criteres, error } = await supabase
        .from("hesitation_critere")
        .select("*")
        .eq("actif", true)
        .order("id_critere", { ascending: true });

      if (error) throw error;
      return res.status(200).json({ success: true, data: criteres || [] });
    }

    if (method === "GET" && (url.includes("/questions") || !url.includes("/criteres"))) {
      const { data: questions, error } = await supabase
        .from("hesitation_question")
        .select("*, options:hesitation_option(*)")
        .order("ordre", { ascending: true });

      if (error) throw error;
      return res.status(200).json({ success: true, data: questions || [] });
    }

    return res.status(200).json({ success: true, message: "Service Hésitation actif." });
  } catch (err) {
    console.error("Hesitation error:", err);
    return res.status(500).json({ success: false, message: err.message || "Erreur serveur." });
  }
}

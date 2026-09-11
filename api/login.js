import bcrypt from "bcryptjs";
import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";
import { signToken, setAuthCookie } from "./_lib/auth.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  }

  try {
    const { email, mot_de_passe } = req.body || {};

    if (!email || !mot_de_passe) {
      return res.status(400).json({
        success: false,
        message: "Veuillez renseigner l'email et le mot de passe.",
      });
    }

    const { data: user, error } = await supabase
      .from("utilisateur")
      .select("*")
      .ilike("email", email.trim())
      .single();

    if (error || !user) {
      return res.status(401).json({
        success: false,
        message: "Email ou mot de passe incorrect.",
      });
    }

    const isMatch = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Email ou mot de passe incorrect.",
      });
    }

    // Update last login
    await supabase
      .from("utilisateur")
      .update({ derniere_connexion: new Date().toISOString() })
      .eq("id_user", user.id_user);

    // Remove password before sending back
    const { mot_de_passe: _, ...safeUser } = user;

    const token = signToken({ id_user: user.id_user, email: user.email });
    setAuthCookie(res, token);

    return res.status(200).json({
      success: true,
      message: "Connexion réussie.",
      utilisateur: safeUser,
      token,
    });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la connexion.",
    });
  }
}

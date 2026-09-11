import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { signToken, setAuthCookie } from "../_lib/auth.js";

const JWT_SECRET = process.env.JWT_SECRET || "nextori_super_secret_jwt_key_2026";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  }

  try {
    const { code, verificationToken } = req.body || {};

    if (!code || !verificationToken) {
      return res.status(400).json({
        success: false,
        message: "Code de vérification et jeton requis.",
      });
    }

    // 1. Vérification du token temporaire
    let decoded;
    try {
      decoded = jwt.verify(verificationToken, JWT_SECRET);
    } catch (err) {
      if (err.name === "TokenExpiredError") {
        return res.status(400).json({
          success: false,
          message: "Le code a expiré. Veuillez demander un nouveau code.",
        });
      }
      return res.status(400).json({
        success: false,
        message: "Jeton de vérification invalide.",
      });
    }

    // 2. Vérification de l'action du token
    if (decoded.action !== "EMAIL_VERIFICATION") {
      return res.status(400).json({
        success: false,
        message: "Jeton non valide pour cette action.",
      });
    }

    // 3. Vérification du code saisi
    const isMatch = await bcrypt.compare(String(code).trim(), decoded.codeHash);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: "Code de vérification incorrect. Veuillez vérifier vos emails.",
      });
    }

    const { nom, email, mot_de_passe, pays, niveau_etude, id_serie } = decoded;

    // 4. Double vérification : l'email n'a pas été enregistré entre temps
    const { data: existing } = await supabase
      .from("utilisateur")
      .select("id_user")
      .ilike("email", email)
      .maybeSingle();

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Un compte existe déjà avec cette adresse email.",
      });
    }

    // 5. Création définitive de l'utilisateur dans Supabase
    const { data: newUser, error: insertError } = await supabase
      .from("utilisateur")
      .insert([
        {
          nom,
          email,
          mot_de_passe,
          pays,
          niveau_etude,
          id_serie: id_serie ? parseInt(id_serie, 10) : null,
          date_creation: new Date().toISOString(),
        },
      ])
      .select("id_user, nom, email, pays, niveau_etude, id_serie, date_creation")
      .single();

    if (insertError || !newUser) {
      console.error("Insert user error post verification:", insertError);
      return res.status(500).json({
        success: false,
        message: "Erreur lors de la finalisation du compte.",
      });
    }

    // 6. Attribution du badge de bienvenue "PREMIER_PAS"
    try {
      const { data: badge } = await supabase
        .from("badge")
        .select("id_badge")
        .eq("code", "PREMIER_PAS")
        .maybeSingle();

      if (badge) {
        await supabase.from("badge_utilisateur").insert([
          {
            id_user: newUser.id_user,
            id_badge: badge.id_badge,
            date_obtention: new Date().toISOString().split("T")[0],
          },
        ]);
      }
    } catch (badgeErr) {
      console.warn("Badge attribution warning:", badgeErr);
    }

    // 7. Connexion automatique : création du token JWT de session et cookie
    const token = signToken({ id_user: newUser.id_user, email: newUser.email });
    setAuthCookie(res, token);

    return res.status(200).json({
      success: true,
      message: "Votre adresse email a été vérifiée avec succès. Bienvenue sur NextOri !",
      utilisateur: newUser,
      token,
    });
  } catch (err) {
    console.error("Verify code error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la vérification du code.",
    });
  }
}

import bcrypt from "bcryptjs";
import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { signToken, setAuthCookie } from "../_lib/auth.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  }

  try {
    const { nom, email, mot_de_passe, pays, niveau_etude, id_serie } = req.body || {};

    if (!nom || !email || !mot_de_passe || !pays || !niveau_etude) {
      return res.status(400).json({
        success: false,
        message: "Tous les champs sont obligatoires.",
      });
    }

    // Validation syntaxe email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
    const cleanEmail = email.trim().toLowerCase();
    if (!emailRegex.test(cleanEmail)) {
      return res.status(400).json({
        success: false,
        message: "Format d'adresse email invalide.",
      });
    }

    // Blocage des domaines jetables / fictifs
    const domain = cleanEmail.split("@")[1];
    const disposableDomains = [
      "yopmail.com", "mailinator.com", "tempmail.com", "guerrillamail.com",
      "10minutemail.com", "trashmail.com", "fake.com", "test.com", "example.com",
      "sharklasers.com", "throwawaymail.com", "dispostable.com"
    ];
    if (disposableDomains.includes(domain)) {
      return res.status(400).json({
        success: false,
        message: "Les adresses emails temporaires ou fictives ne sont pas autorisées.",
      });
    }

    // Validation mot de passe
    if (mot_de_passe.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Le mot de passe doit comporter au moins 6 caractères.",
      });
    }

    // Check if email already exists
    const { data: existing } = await supabase
      .from("utilisateur")
      .select("id_user")
      .ilike("email", cleanEmail)
      .maybeSingle();

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Cet email est déjà utilisé.",
      });
    }

    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

    // Création directe de l'utilisateur
    const { data: newUser, error: insertError } = await supabase
      .from("utilisateur")
      .insert([
        {
          nom: nom.trim(),
          email: cleanEmail,
          mot_de_passe: hashedPassword,
          pays: pays.trim(),
          niveau_etude: niveau_etude.trim(),
          id_serie: id_serie ? parseInt(id_serie, 10) : null,
          date_creation: new Date().toISOString(),
        },
      ])
      .select("id_user, nom, email, pays, niveau_etude, id_serie, date_creation")
      .single();

    if (insertError || !newUser) {
      console.error("Insert user error:", insertError);
      return res.status(500).json({
        success: false,
        message: "Erreur lors de la création du compte.",
      });
    }

    // Attribution automatique du badge "Premier Pas" (PREMIER_PAS)
    try {
      const { data: badge } = await supabase
        .from("badge")
        .select("id_badge")
        .eq("code", "PREMIER_PAS")
        .maybeSingle();

      if (badge) {
        await supabase.from("badge_utilisateur").upsert(
          [
            {
              id_user: newUser.id_user,
              id_badge: badge.id_badge,
              date_obtention: new Date().toISOString().split("T")[0],
            },
          ],
          { onConflict: "id_user,id_badge" }
        );
      }
    } catch (badgeErr) {
      console.warn("Badge attribution warning:", badgeErr);
    }

    // Connexion automatique avec session JWT et cookie
    const token = signToken({ id_user: newUser.id_user, email: newUser.email });
    setAuthCookie(res, token);

    return res.status(200).json({
      success: true,
      message: "Compte créé avec succès ! Bienvenue sur NextOri.",
      utilisateur: newUser,
      token,
    });
  } catch (err) {
    console.error("Register error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors de l'inscription.",
    });
  }
}


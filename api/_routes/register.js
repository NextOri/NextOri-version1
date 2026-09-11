import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { signToken, setAuthCookie } from "../_lib/auth.js";
import { envoyerEmailVerification } from "../_lib/email.js";

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
      .ilike("email", email.trim())
      .maybeSingle();

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Cet email est déjà utilisé.",
      });
    }

    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);

    // Génération du code OTP à 6 chiffres
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const codeHash = await bcrypt.hash(code, 6);

    const JWT_SECRET = process.env.JWT_SECRET || "nextori_super_secret_jwt_key_2026";
    const verificationToken = jwt.sign(
      {
        action: "EMAIL_VERIFICATION",
        nom: nom.trim(),
        email: cleanEmail,
        mot_de_passe: hashedPassword,
        pays: pays.trim(),
        niveau_etude: niveau_etude.trim(),
        id_serie: id_serie ? parseInt(id_serie, 10) : null,
        codeHash,
      },
      JWT_SECRET,
      { expiresIn: "15m" }
    );

    // Envoi de l'email avec le logo officiel NextOri
    const resultatEmail = await envoyerEmailVerification({
      email: cleanEmail,
      nom: nom.trim(),
      code,
    });

    const msg = resultatEmail.simulation
      ? `[Mode test - Aucun serveur email configuré dans Vercel]. Votre code de test est : ${code}`
      : `Un code de vérification a été envoyé à ${cleanEmail}. Veuillez vérifier votre boîte de réception.`;

    return res.status(200).json({
      success: true,
      pendingVerification: true,
      email: cleanEmail,
      verificationToken,
      message: msg,
    });
  } catch (err) {
    console.error("Register error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors de l'inscription.",
    });
  }
}

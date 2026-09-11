import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { handleCors } from "../_lib/cors.js";
import { envoyerEmailVerification } from "../_lib/email.js";

const JWT_SECRET = process.env.JWT_SECRET || "nextori_super_secret_jwt_key_2026";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (req.method !== "POST") {
    return res.status(405).json({ success: false, message: "Méthode non autorisée." });
  }

  try {
    const { verificationToken } = req.body || {};

    if (!verificationToken) {
      return res.status(400).json({
        success: false,
        message: "Jeton de vérification requis pour renvoyer le code.",
      });
    }

    // Décodage du token même s'il a expiré pour récupérer les données utilisateur
    let decoded;
    try {
      decoded = jwt.verify(verificationToken, JWT_SECRET, { ignoreExpiration: true });
    } catch {
      return res.status(400).json({
        success: false,
        message: "Jeton de vérification invalide.",
      });
    }

    if (decoded.action !== "EMAIL_VERIFICATION") {
      return res.status(400).json({
        success: false,
        message: "Action non autorisée.",
      });
    }

    // Génération d'un nouveau code OTP à 6 chiffres
    const nouveauCode = Math.floor(100000 + Math.random() * 900000).toString();
    const nouveauCodeHash = await bcrypt.hash(nouveauCode, 6);

    // Nouveau token JWT valable 15 minutes
    const nouveauToken = jwt.sign(
      {
        action: "EMAIL_VERIFICATION",
        nom: decoded.nom,
        email: decoded.email,
        mot_de_passe: decoded.mot_de_passe,
        pays: decoded.pays,
        niveau_etude: decoded.niveau_etude,
        id_serie: decoded.id_serie,
        codeHash: nouveauCodeHash,
      },
      JWT_SECRET,
      { expiresIn: "15m" }
    );

    // Envoi du nouvel email
    const resultatEmail = await envoyerEmailVerification({
      email: decoded.email,
      nom: decoded.nom,
      code: nouveauCode,
    });

    const msg = resultatEmail.simulation
      ? `[Mode test - Aucun serveur email configuré dans Vercel]. Nouveau code de test : ${nouveauCode}`
      : "Un nouveau code de vérification a été envoyé à votre adresse email.";

    return res.status(200).json({
      success: true,
      message: msg,
      verificationToken: nouveauToken,
    });
  } catch (err) {
    console.error("Resend code error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur serveur lors du renvoi du code.",
    });
  }
}

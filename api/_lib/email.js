import nodemailer from "nodemailer";

// =========================================================
// CHARTE GRAPHIQUE OFFICIELLE NEXTORI
// =========================================================
const BRAND = {
  deepBlue: "#0D1B2A",
  blue: "#1E3A8A",
  orange: "#F4B400",
  lightGray: "#F2F4F7",
  white: "#FFFFFF",
};

const APP_URL = process.env.APP_URL || "https://nextori-indol.vercel.app";

/**
 * Génère le template HTML complet respectant strictement la charte de NextOri
 */
export function genererEmailVerificationHtml(nom, code) {
  const logoUrl = `${APP_URL}/images/logo-nextori.jpg`;

  return `
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vérification de votre compte NextOri</title>
</head>
<body style="margin:0;padding:0;background-color:${BRAND.lightGray};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:${BRAND.deepBlue};">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:${BRAND.lightGray};padding:40px 15px;">
    <tr>
      <td align="center">
        <!-- Container principal -->
        <table role="presentation" width="100%" style="max-width:520px;background-color:${BRAND.white};border-radius:18px;box-shadow:0 8px 24px rgba(13,27,42,0.08);overflow:hidden;border:1px solid #E2E8F0;" cellspacing="0" cellpadding="0" border="0">
          
          <!-- Bandeau supérieur aux couleurs officielles NextOri -->
          <tr>
            <td style="background-color:${BRAND.deepBlue};padding:32px 24px;text-align:center;">
              <img src="${logoUrl}" alt="NextOri" width="100" height="100" style="display:block;margin:0 auto;border-radius:50%;object-fit:cover;border:3px solid ${BRAND.orange};" />
              <h1 style="color:${BRAND.white};margin:16px 0 0 0;font-size:24px;font-weight:700;letter-spacing:0.5px;">Next<span style="color:${BRAND.orange};">Ori</span></h1>
              <p style="color:${BRAND.lightGray};margin:6px 0 0 0;font-size:13px;opacity:0.85;">Plateforme d'orientation académique & professionnelle</p>
            </td>
          </tr>

          <!-- Contenu -->
          <tr>
            <td style="padding:32px 28px 24px 28px;background-color:${BRAND.white};">
              <h2 style="color:${BRAND.deepBlue};margin:0 0 14px 0;font-size:20px;font-weight:700;">
                Confirmez votre adresse email ✉️
              </h2>
              
              <p style="color:${BRAND.deepBlue};margin:0 0 16px 0;font-size:15px;line-height:1.6;">
                Bonjour <strong>${nom || "futur bachelier / étudiant"}</strong>,
              </p>
              
              <p style="color:${BRAND.blue};margin:0 0 24px 0;font-size:15px;line-height:1.6;">
                Bienvenue sur <strong>NextOri</strong> ! Pour finaliser la création de votre compte et accéder à votre tableau de bord d'orientation, voici votre code de confirmation :
              </p>

              <!-- Carte du code OTP avec bordure orange #F4B400 et fond #F2F4F7 -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin:24px 0;">
                <tr>
                  <td align="center" style="background-color:${BRAND.lightGray};border:2px dashed ${BRAND.orange};border-radius:12px;padding:22px;">
                    <span style="font-size:12px;text-transform:uppercase;letter-spacing:1.5px;color:${BRAND.blue};font-weight:700;display:block;margin-bottom:8px;">Votre code de sécurité</span>
                    <span style="font-family:'Courier New',Courier,monospace;font-size:38px;font-weight:800;letter-spacing:10px;color:${BRAND.deepBlue};display:block;padding-left:10px;">${code}</span>
                    <span style="font-size:12px;color:${BRAND.blue};font-weight:600;display:block;margin-top:8px;">⏳ Valable pendant 15 minutes</span>
                  </td>
                </tr>
              </table>

              <p style="color:${BRAND.deepBlue};margin:24px 0 0 0;font-size:13px;line-height:1.5;opacity:0.75;">
                ⚠️ Ne partagez ce code avec personne. Si vous n'êtes pas à l'origine de cette inscription sur NextOri, ignorez simplement cet email.
              </p>
            </td>
          </tr>

          <!-- Séparateur -->
          <tr>
            <td style="padding:0 28px;background-color:${BRAND.white};">
              <div style="border-top:1px solid ${BRAND.lightGray};"></div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:22px 28px;background-color:${BRAND.lightGray};text-align:center;">
              <p style="color:${BRAND.deepBlue};margin:0 0 6px 0;font-size:12px;line-height:1.5;font-weight:600;">
                NextOri — Trouvez la voie qui correspond à votre potentiel
              </p>
              <p style="color:${BRAND.blue};margin:0;font-size:11px;opacity:0.75;">
                &copy; ${new Date().getFullYear()} NextOri. Tous droits réservés.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim();
}

/**
 * Envoie l'email via SMTP (Gmail, Workspace, ou hébergeur cPanel)
 */
async function envoyerViaSMTP({ email, nom, code, html }) {
  const host = process.env.SMTP_HOST || "smtp.gmail.com";
  const port = parseInt(process.env.SMTP_PORT || "465", 10);
  const secure = port === 465;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;
  const from = process.env.SMTP_FROM || `"NextOri" <${user}>`;

  const transporter = nodemailer.createTransport({
    host,
    port,
    secure,
    auth: { user, pass },
  });

  const info = await transporter.sendMail({
    from,
    to: email,
    subject: `[NextOri] ${code} est votre code de vérification`,
    html,
  });

  return { success: true, id: info.messageId, provider: "smtp" };
}

/**
 * Envoie l'email via Resend
 */
async function envoyerViaResend({ email, nom, code, html }) {
  const apiKey = process.env.RESEND_API_KEY;
  const from = process.env.EMAIL_FROM || "NextOri <onboarding@resend.dev>";

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to: [email],
      subject: `[NextOri] ${code} est votre code de vérification`,
      html,
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(data.message || "Erreur lors de l'envoi via Resend.");
  }

  return { success: true, id: data.id, provider: "resend" };
}

/**
 * Envoie l'email via Brevo (ex-Sendinblue)
 */
async function envoyerViaBrevo({ email, nom, code, html }) {
  const apiKey = process.env.BREVO_API_KEY;
  const senderEmail = process.env.BREVO_SENDER_EMAIL || process.env.EMAIL_FROM || "contact@nextori.com";
  const senderName = process.env.BREVO_SENDER_NAME || "NextOri";

  const res = await fetch("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: {
      "api-key": apiKey,
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: JSON.stringify({
      sender: { name: senderName, email: senderEmail },
      to: [{ email, name: nom || "Étudiant NextOri" }],
      subject: `[NextOri] ${code} est votre code de vérification`,
      htmlContent: html,
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(data.message || "Erreur lors de l'envoi via Brevo.");
  }

  return { success: true, id: data.messageId, provider: "brevo" };
}

/**
 * Fonction universelle d'envoi d'email
 * Détecte automatiquement le fournisseur configuré dans les variables d'environnement
 */
export async function envoyerEmailVerification({ email, nom, code }) {
  const html = genererEmailVerificationHtml(nom, code);

  // 1. Essai SMTP (si SMTP_USER et SMTP_PASS sont définis)
  if (process.env.SMTP_USER && process.env.SMTP_PASS) {
    try {
      return await envoyerViaSMTP({ email, nom, code, html });
    } catch (err) {
      console.error("Échec envoi SMTP:", err);
      throw new Error(`Erreur SMTP : ${err.message}`);
    }
  }

  // 2. Essai Brevo (si BREVO_API_KEY est définie)
  if (process.env.BREVO_API_KEY) {
    try {
      return await envoyerViaBrevo({ email, nom, code, html });
    } catch (err) {
      console.error("Échec envoi Brevo:", err);
      throw new Error(`Erreur Brevo : ${err.message}`);
    }
  }

  // 3. Essai Resend (si RESEND_API_KEY est définie)
  if (process.env.RESEND_API_KEY) {
    try {
      return await envoyerViaResend({ email, nom, code, html });
    } catch (err) {
      console.error("Échec envoi Resend:", err);
      throw new Error(`Erreur Resend : ${err.message}`);
    }
  }

  // 4. Aucun fournisseur d'email configuré
  console.warn("⚠️ [NextOri] Aucun fournisseur email configuré (ni SMTP_USER/SMTP_PASS, ni BREVO_API_KEY, ni RESEND_API_KEY).");
  console.warn(`🔑 [NextOri OTP] Code généré pour ${email} : ${code}`);

  return {
    success: true,
    simulation: true,
    code, // Renvoyé pour faciliter le test tant que les identifiants ne sont pas renseignés
    message: "Fournisseur d'email non configuré dans les variables d'environnement.",
  };
}

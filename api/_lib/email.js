// Service d'envoi d'emails pour NextOri via Resend (https://resend.com)
// Utilise fetch natif (zéro dépendance externe)

const RESEND_API_KEY = process.env.RESEND_API_KEY || "";
const FROM_EMAIL = process.env.EMAIL_FROM || "NextOri <onboarding@resend.dev>";
const APP_URL = process.env.APP_URL || "https://nextori-indol.vercel.app";

/**
 * Génère le template HTML complet avec le logo officiel NextOri et le code OTP
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
<body style="margin:0;padding:0;background-color:#F1F5F9;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;color:#1E293B;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:#F1F5F9;padding:40px 15px;">
    <tr>
      <td align="center">
        <!-- Container principal -->
        <table role="presentation" width="100%" style="max-width:540px;background-color:#FFFFFF;border-radius:16px;box-shadow:0 10px 25px rgba(15,23,42,0.06);overflow:hidden;border:1px solid #E2E8F0;" cellspacing="0" cellpadding="0" border="0">
          
          <!-- Bandeau supérieur avec couleur de marque -->
          <tr>
            <td style="background:linear-gradient(135deg, #0A192F 0%, #1E3A8A 100%);padding:28px 24px;text-align:center;">
              <img src="${logoUrl}" alt="NextOri" width="110" height="110" style="display:block;margin:0 auto;border-radius:50%;object-fit:cover;border:3px solid #F59E0B;box-shadow:0 4px 12px rgba(0,0,0,0.25);" />
              <h1 style="color:#FFFFFF;margin:16px 0 0 0;font-size:22px;font-weight:700;letter-spacing:0.5px;">Next<span style="color:#F59E0B;">Ori</span></h1>
              <p style="color:#94A3B8;margin:4px 0 0 0;font-size:13px;letter-spacing:0.3px;">Plateforme d'orientation académique & professionnelle</p>
            </td>
          </tr>

          <!-- Contenu -->
          <tr>
            <td style="padding:32px 28px 24px 28px;">
              <h2 style="color:#0F172A;margin:0 0 12px 0;font-size:20px;font-weight:700;">
                Confirmez votre adresse email ✉️
              </h2>
              
              <p style="color:#475569;margin:0 0 18px 0;font-size:15px;line-height:1.6;">
                Bonjour <strong>${nom || "futur bachelier / étudiant"}</strong>,
              </p>
              
              <p style="color:#475569;margin:0 0 24px 0;font-size:15px;line-height:1.6;">
                Bienvenue sur <strong>NextOri</strong> ! Pour finaliser la création de votre compte et accéder à votre tableau de bord d'orientation, veuillez saisir le code de vérification suivant :
              </p>

              <!-- Carte du code OTP -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin:24px 0;">
                <tr>
                  <td align="center" style="background-color:#F8FAFC;border:2px dashed #F59E0B;border-radius:12px;padding:20px;">
                    <span style="font-size:12px;text-transform:uppercase;letter-spacing:1.5px;color:#64748B;font-weight:600;display:block;margin-bottom:8px;">Votre code de sécurité</span>
                    <span style="font-family:'Courier New',Courier,monospace;font-size:36px;font-weight:800;letter-spacing:10px;color:#0A192F;display:block;padding-left:10px;">${code}</span>
                    <span style="font-size:12px;color:#EA580C;font-weight:600;display:block;margin-top:8px;">⏳ Valable pendant 15 minutes</span>
                  </td>
                </tr>
              </table>

              <p style="color:#64748B;margin:24px 0 0 0;font-size:13px;line-height:1.5;">
                ⚠️ <strong>Sécurité :</strong> Ne partagez ce code avec personne. Si vous n'êtes pas à l'origine de cette inscription, ignorez simplement cet email.
              </p>
            </td>
          </tr>

          <!-- Séparateur -->
          <tr>
            <td style="padding:0 28px;">
              <div style="border-top:1px solid #E2E8F0;"></div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px 28px 28px 28px;background-color:#FAFAFA;text-align:center;">
              <p style="color:#94A3B8;margin:0 0 8px 0;font-size:12px;line-height:1.5;">
                NextOri — Trouvez la voie qui correspond à votre potentiel
              </p>
              <p style="color:#CBD5E1;margin:0;font-size:11px;">
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
 * Envoie un email de vérification avec le code OTP via l'API Resend
 */
export async function envoyerEmailVerification({ email, nom, code }) {
  const html = genererEmailVerificationHtml(nom, code);

  // Si aucune clé Resend n'est encore configurée, on affiche le code dans les logs
  if (!RESEND_API_KEY) {
    console.warn("⚠️ [NextOri] RESEND_API_KEY non configurée. Code OTP de secours pour", email, "=>", code);
    return {
      success: true,
      simulation: true,
      message: "Email simulé (RESEND_API_KEY non renseignée). Le code est dans les logs du serveur.",
    };
  }

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [email],
        subject: `[NextOri] ${code} est votre code de vérification`,
        html,
      }),
    });

    const data = await res.json();

    if (!res.ok) {
      console.error("Resend API error:", data);
      throw new Error(data.message || "Erreur lors de l'envoi de l'email via Resend.");
    }

    return {
      success: true,
      id: data.id,
    };
  } catch (err) {
    console.error("Erreur envoi email:", err);
    throw err;
  }
}

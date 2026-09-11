import { handleCors } from "../_lib/cors.js";
import { clearAuthCookie } from "../_lib/auth.js";

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  clearAuthCookie(res);

  return res.status(200).json({
    success: true,
    message: "Déconnexion réussie.",
  });
}

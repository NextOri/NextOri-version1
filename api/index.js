import { handleCors } from "./_lib/cors.js";

import avisHandler from "./_routes/avis.js";
import dashboardHandler from "./_routes/dashboard.js";
import filiereHandler from "./_routes/filiere.js";
import filieresHandler from "./_routes/filieres.js";
import filiereDetailsHandler from "./_routes/filiere_details.js";
import hesitationHandler from "./_routes/hesitation.js";
import historiqueTestDetailHandler from "./_routes/historique-test-detail.js";
import historiqueTestsHandler from "./_routes/historique-tests.js";
import historiqueHandler from "./_routes/historique.js";
import loginHandler from "./_routes/login.js";
import logoutHandler from "./_routes/logout.js";
import metiersHandler from "./_routes/metiers.js";
import metiersDetailsHandler from "./_routes/metiers_details.js";
import notifierHandler from "./_routes/notifier-fonctionnalite.js";
import orientationHandler from "./_routes/orientation.js";
import profilHandler from "./_routes/profil.js";
import profileHandler from "./_routes/profile.js";
import propositionsHandler from "./_routes/propositions.js";
import questionsHandler from "./_routes/questions.js";
import registerHandler from "./_routes/register.js";
import resultatsHandler from "./_routes/resultats.js";
import seriesHandler from "./_routes/series.js";
import temoignagesHandler from "./_routes/temoignages.js";
import univCatHandler from "./_routes/universite-catalogue.js";
import univDetailHandler from "./_routes/universite-detail.js";
import universitesHandler from "./_routes/universites.js";
import verifyCodeHandler from "./_routes/verify-code.js";
import resendCodeHandler from "./_routes/resend-code.js";

const routes = {
  "verify-code": verifyCodeHandler,
  "resend-code": resendCodeHandler,
  "avis": avisHandler,
  "dashboard": dashboardHandler,
  "filiere": filiereHandler,
  "filieres": filieresHandler,
  "filiere_details": filiereDetailsHandler,
  "hesitation": hesitationHandler,
  "historique-test-detail": historiqueTestDetailHandler,
  "historique-tests": historiqueTestsHandler,
  "historique": historiqueHandler,
  "login": loginHandler,
  "logout": logoutHandler,
  "metiers": metiersHandler,
  "metiers_details": metiersDetailsHandler,
  "notifier-fonctionnalite": notifierHandler,
  "orientation": orientationHandler,
  "profil": profilHandler,
  "profile": profileHandler,
  "propositions": propositionsHandler,
  "questions": questionsHandler,
  "register": registerHandler,
  "resultats": resultatsHandler,
  "series": seriesHandler,
  "temoignages": temoignagesHandler,
  "universite-catalogue": univCatHandler,
  "universite-detail": univDetailHandler,
  "universites": universitesHandler,
};

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  try {
    const parsedUrl = new URL(req.url, `http://${req.headers.host || "localhost"}`);
    
    // Extract endpoint: strip leading /api/, and strip trailing .php if present
    let endpoint = parsedUrl.pathname
      .replace(/^\/api\/?/, "")
      .replace(/\.php$/, "")
      .trim();

    // In case endpoint is empty (e.g. GET /api)
    if (!endpoint) {
      return res.status(200).json({
        success: true,
        message: "NextOri API Serverless Gateway",
        available_endpoints: Object.keys(routes),
      });
    }

    // Populate req.query from search params if not already set by Vercel
    if (!req.query) {
      req.query = {};
    }
    for (const [key, value] of parsedUrl.searchParams.entries()) {
      if (!req.query[key]) {
        req.query[key] = value;
      }
    }

    const routeHandler = routes[endpoint];

    if (routeHandler) {
      return await routeHandler(req, res);
    }

    return res.status(404).json({
      success: false,
      message: `Endpoint inconnu: /api/${endpoint}`,
    });
  } catch (err) {
    console.error("Gateway error:", err);
    return res.status(500).json({
      success: false,
      message: "Erreur interne de l'API Gateway.",
      error: err.message,
    });
  }
}

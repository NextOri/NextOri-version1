import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";

// Clé secrète admin — à définir dans les variables d'environnement Vercel
const ADMIN_SECRET = process.env.ADMIN_SECRET || "nextori_admin_secret_2026";

function isAdmin(req) {
  // Accepte la clé via header X-Admin-Secret ou query param admin_secret
  const headerSecret = req.headers && req.headers["x-admin-secret"];
  const querySecret = req.query && req.query.admin_secret;
  return headerSecret === ADMIN_SECRET || querySecret === ADMIN_SECRET;
}

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  if (!isAdmin(req)) {
    return res.status(403).json({ success: false, message: "Accès non autorisé." });
  }

  // ── GET : liste tous les avis (en attente d'approbation ou tous) ────────────
  if (req.method === "GET") {
    try {
      const filtre = req.query.filtre || "tous"; // "tous" | "en_attente" | "approuves" | "rejetes"

      let query = supabase
        .from("avis")
        .select("id_avis, note, commentaire, afficher, approuve, date_creation, utilisateur(id_user, nom, email)")
        .order("date_creation", { ascending: false });

      if (filtre === "en_attente") {
        query = query.eq("approuve", false).eq("afficher", true);
      } else if (filtre === "approuves") {
        query = query.eq("approuve", true);
      } else if (filtre === "rejetes") {
        query = query.eq("approuve", false).eq("afficher", false);
      }
      // "tous" ne filtre rien

      const { data: avis, error } = await query;
      if (error) throw error;

      return res.status(200).json({
        success: true,
        total: (avis || []).length,
        avis: (avis || []).map((a) => ({
          id_avis: a.id_avis,
          note: a.note,
          commentaire: a.commentaire,
          afficher: a.afficher,
          approuve: a.approuve,
          date_creation: a.date_creation,
          utilisateur: a.utilisateur
            ? { id_user: a.utilisateur.id_user, nom: a.utilisateur.nom, email: a.utilisateur.email }
            : null,
        })),
      });
    } catch (err) {
      console.error("Admin avis GET error:", err);
      return res.status(500).json({ success: false, message: err.message });
    }
  }

  // ── PATCH : approuver ou rejeter un avis ────────────────────────────────────
  if (req.method === "PATCH") {
    try {
      const { id_avis, action } = req.body || {};

      if (!id_avis || !["approuver", "rejeter"].includes(action)) {
        return res.status(400).json({
          success: false,
          message: "Paramètres invalides. Fournissez id_avis et action ('approuver' ou 'rejeter').",
        });
      }

      const updateData =
        action === "approuver"
          ? { approuve: true }
          : { approuve: false, afficher: false }; // rejeter : on cache aussi l'avis

      const { data: updated, error } = await supabase
        .from("avis")
        .update(updateData)
        .eq("id_avis", id_avis)
        .select("id_avis, note, commentaire, afficher, approuve")
        .single();

      if (error) throw error;

      return res.status(200).json({
        success: true,
        message: action === "approuver" ? "Avis approuvé et publié." : "Avis rejeté et masqué.",
        avis: updated,
      });
    } catch (err) {
      console.error("Admin avis PATCH error:", err);
      return res.status(500).json({ success: false, message: err.message });
    }
  }

  return res.status(405).json({ success: false, message: "Méthode non autorisée." });
}

import { supabase } from "./_lib/supabase.js";
import { handleCors } from "./_lib/cors.js";
import { getUserFromRequest } from "./_lib/auth.js";

function calculerNiveau(points) {
  const paliers = [
    { niveau: "Débutant", min: 0, max: 100 },
    { niveau: "Explorateur", min: 101, max: 300 },
    { niveau: "Aventurier", min: 301, max: 600 },
    { niveau: "Expert", min: 601, max: 1000 },
    { niveau: "Maître", min: 1001, max: 99999 },
  ];

  for (const p of paliers) {
    if (points <= p.max) {
      const etendue = p.max - p.min;
      const prog = points - p.min;
      const pct = Math.min(100, Math.max(0, Math.round((prog / (etendue || 1)) * 100)));
      return {
        nom: p.niveau,
        points_actuels: points,
        points_suivant: p.max,
        pourcentage: pct,
      };
    }
  }

  return { nom: "Maître", points_actuels: points, points_suivant: points, pourcentage: 100 };
}

export default async function handler(req, res) {
  if (handleCors(req, res)) return;

  const authUser = getUserFromRequest(req);
  if (!authUser || !authUser.id_user) {
    return res.status(401).json({
      success: false,
      message: "Utilisateur non connecté.",
    });
  }

  const idUser = authUser.id_user;

  try {
    const { data: user, error: userErr } = await supabase
      .from("utilisateur")
      .select("nom")
      .eq("id_user", idUser)
      .maybeSingle();

    if (userErr || !user) {
      return res.status(404).json({ success: false, message: "Utilisateur introuvable." });
    }

    const today = new Date().toISOString().split("T")[0];

    // Enregistrer connexion du jour
    await supabase.from("connexion_utilisateur").upsert(
      { id_user: idUser, date_connexion: today },
      { onConflict: "id_user,date_connexion" }
    );

    // 1. Tests RIASEC faits ?
    const { count: testCount } = await supabase
      .from("test_riasec")
      .select("id_test", { count: "exact", head: true })
      .eq("id_user", idUser);

    // 2. Historique des actions
    const { data: actionsData } = await supabase
      .from("historique")
      .select("action")
      .eq("id_user", idUser);

    const actions = (actionsData || []).map((a) => a.action);

    // 3. Badges utilisateur
    const { data: badgesData } = await supabase
      .from("badge_utilisateur")
      .select("id_badge, date_obtention, badge(id_badge, nom, description, icone, points)")
      .eq("id_user", idUser);

    const badges = (badgesData || []).map((b) => ({
      ...b.badge,
      date_obtention: b.date_obtention,
    }));

    // 4. Calcul des points
    let points = 20; // profil créé
    if ((testCount || 0) > 0) points += 50;
    if (actions.includes("PROFIL_CONSULTE")) points += 20;
    if (actions.includes("METIERS_CONSULTES")) points += 20;
    if (actions.includes("FORMATION_CONSULTEE")) points += 10;
    if (actions.includes("UNIVERSITES_CONSULTEES")) points += 10;
    if (actions.includes("AVIS_DONNE")) points += 20;

    // Connexions
    const { count: connCount } = await supabase
      .from("connexion_utilisateur")
      .select("id_connexion", { count: "exact", head: true })
      .eq("id_user", idUser);

    points += (connCount || 0) * 5;

    for (const b of badges) {
      points += b.points || 0;
    }

    const parcours = {
      profil: true,
      test: (testCount || 0) > 0,
      profilConsulte: actions.includes("PROFIL_CONSULTE"),
      metiersConsultes: actions.includes("METIERS_CONSULTES"),
      formationConsultee: actions.includes("FORMATION_CONSULTEE"),
      universitesConsultees: actions.includes("UNIVERSITES_CONSULTEES"),
      avisDonne: actions.includes("AVIS_DONNE"),
    };

    const niveau = calculerNiveau(points);

    return res.status(200).json({
      utilisateur: {
        nom: user.nom,
      },
      niveau,
      statistiques: {
        points,
        serie: connCount || 1,
        badges: badges.length,
      },
      parcours,
      liste_badges: badges,
    });
  } catch (err) {
    console.error("Dashboard error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Erreur serveur lors de la récupération du dashboard.",
    });
  }
}

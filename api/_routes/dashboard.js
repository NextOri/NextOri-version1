import { supabase } from "../_lib/supabase.js";
import { handleCors } from "../_lib/cors.js";
import { getUserFromRequest } from "../_lib/auth.js";

function calculerNiveau(points) {
  const paliers = [
    { numero: 1, niveau: "Débutant", min: 0, max: 100 },
    { numero: 2, niveau: "Explorateur", min: 101, max: 300 },
    { numero: 3, niveau: "Aventurier", min: 301, max: 600 },
    { numero: 4, niveau: "Expert", min: 601, max: 1000 },
    { numero: 5, niveau: "Maître", min: 1001, max: 99999 },
  ];

  for (const p of paliers) {
    if (points <= p.max) {
      const etendue = p.max - p.min;
      const prog = points - p.min;
      const pct = Math.min(100, Math.max(0, Math.round((prog / (etendue || 1)) * 100)));
      return {
        numero: p.numero,
        nom: p.niveau,
        points_actuels: points,
        points_suivant: p.max,
        pourcentage: pct,
      };
    }
  }

  return { numero: 5, nom: "Maître", points_actuels: points, points_suivant: points, pourcentage: 100 };
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

    // 3. Récupérer tous les badges définis dans le système
    const { data: allBadges } = await supabase
      .from("badge")
      .select("id_badge, code, nom, description, icone, points");

    const badgesMap = new Map((allBadges || []).map((b) => [b.code, b]));

    // 4. Badges utilisateur existants
    let { data: badgesData } = await supabase
      .from("badge_utilisateur")
      .select("id_badge, date_obtention, badge(id_badge, code, nom, description, icone, points)")
      .eq("id_user", idUser);

    if (!badgesData) badgesData = [];

    // Connexions pour séries
    const { count: connCount } = await supabase
      .from("connexion_utilisateur")
      .select("id_connexion", { count: "exact", head: true })
      .eq("id_user", idUser);

    const serieJours = connCount || 1;

    // Détection des actions effectuées (supporte égalité exacte et préfixe)
    const hasProfil = true;
    const hasTest = (testCount || 0) > 0;
    const hasProfilConsulte = actions.includes("PROFIL_CONSULTE");
    const hasMetiersConsultes =
      actions.includes("METIERS_CONSULTES") ||
      actions.some((a) => a && a.startsWith("METIER_CONSULTE"));
    const hasFormationConsultee =
      actions.includes("FORMATION_CONSULTEE") ||
      actions.some((a) => a && a.startsWith("FORMATION_CONSULTEE"));
    const hasUniversitesConsultees =
      actions.includes("UNIVERSITES_CONSULTEES") ||
      actions.some((a) => a && a.startsWith("UNIVERSITE_CONSULTEE"));
    const hasAvisDonne = actions.includes("AVIS_DONNE");

    // Liste des codes de badges éligibles pour l'utilisateur
    const eligibleBadges = ["PREMIER_PAS"];
    if (hasTest) eligibleBadges.push("EXPLORATEUR");
    if (hasProfilConsulte) eligibleBadges.push("CONNAISSANCE_SOI");
    if (hasMetiersConsultes) eligibleBadges.push("DECOUVREUR_METIERS");
    if (hasFormationConsultee) eligibleBadges.push("CHOIX_CARRIERE");
    if (hasUniversitesConsultees) eligibleBadges.push("PRET_UNIVERSITE");
    if (hasAvisDonne) eligibleBadges.push("CONTRIBUTEUR");
    if (serieJours >= 5) eligibleBadges.push("SERIE_5_JOURS");
    if (serieJours >= 7) eligibleBadges.push("SERIE_7_JOURS");
    if (serieJours >= 15) eligibleBadges.push("SERIE_15_JOURS");
    if (serieJours >= 30) eligibleBadges.push("SERIE_30_JOURS");

    // Attribution automatique des badges éligibles manquants
    for (const code of eligibleBadges) {
      const alreadyHas = badgesData.some(
        (b) => b.badge?.code === code || (badgesMap.get(code) && b.id_badge === badgesMap.get(code).id_badge)
      );

      if (!alreadyHas && badgesMap.has(code)) {
        const badgeDef = badgesMap.get(code);
        try {
          await supabase.from("badge_utilisateur").upsert(
            {
              id_user: idUser,
              id_badge: badgeDef.id_badge,
              date_obtention: today,
            },
            { onConflict: "id_user,id_badge" }
          );

          badgesData.push({
            id_badge: badgeDef.id_badge,
            date_obtention: today,
            badge: badgeDef,
          });
        } catch (badgeErr) {
          console.warn(`Erreur attribution badge ${code}:`, badgeErr);
        }
      }
    }

    const badges = (badgesData || []).map((b) => ({
      ...b.badge,
      date_obtention: b.date_obtention,
    }));

    // 5. Calcul des points
    let points = 20; // Profil créé
    if (hasTest) points += 50;
    if (hasProfilConsulte) points += 20;
    if (hasMetiersConsultes) points += 20;
    if (hasFormationConsultee) points += 10;
    if (hasUniversitesConsultees) points += 10;
    if (hasAvisDonne) points += 20;

    // Points des connexions journalières (+5 points par jour)
    points += (connCount || 0) * 5;

    // Points des badges obtenus
    for (const b of badges) {
      points += b.points || 0;
    }

    const parcours = {
      profil: hasProfil,
      test: hasTest,
      profilConsulte: hasProfilConsulte,
      metiersConsultes: hasMetiersConsultes,
      formationConsultee: hasFormationConsultee,
      universitesConsultees: hasUniversitesConsultees,
      avisDonne: hasAvisDonne,
    };

    const niveau = calculerNiveau(points);

    return res.status(200).json({
      utilisateur: {
        nom: user.nom,
      },
      niveau,
      statistiques: {
        points,
        serie: serieJours,
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

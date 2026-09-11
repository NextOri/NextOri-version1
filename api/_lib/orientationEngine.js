import { supabase } from "./supabase.js";

export function calculateRiasecScores(typesList) {
  const scores = { R: 0, I: 0, A: 0, S: 0, E: 0, C: 0 };
  for (const type of typesList) {
    const t = (type || "").toUpperCase().trim();
    if (scores[t] !== undefined) {
      scores[t]++;
    }
  }

  // Sort descending
  const sortedLetters = Object.keys(scores).sort((a, b) => scores[b] - scores[a]);
  const dominantProfile = `${sortedLetters[0]}${sortedLetters[1]}`;

  return { scores, dominantProfile, fullProfile: sortedLetters.join("") };
}

export function calculateCompatibility(userProfile, metierProfile) {
  const u = (userProfile || "").toUpperCase().trim();
  const m = (metierProfile || "").toUpperCase().trim();
  if (!u || !m) return 0;

  let score = 0;
  // First letter
  if (u[0]) {
    const pos = m.indexOf(u[0]);
    if (pos === 0) score += 4;
    else if (pos === 1) score += 2;
    else if (pos === 2) score += 1;
  }
  // Second letter
  if (u[1]) {
    const pos = m.indexOf(u[1]);
    if (pos === 1) score += 2;
    else if (pos === 0) score += 2;
    else if (pos === 2) score += 1;
  }

  return score;
}

export function countMatches(userProfile, metierProfile) {
  const u = (userProfile || "").toUpperCase().trim();
  const m = (metierProfile || "").toUpperCase().trim();
  let count = 0;
  if (u[0] && m.includes(u[0])) count++;
  if (u[1] && m.includes(u[1])) count++;
  return count;
}

export async function getRecommendedMetiers(dominantProfile, idSerie = null) {
  let metiers = [];

  if (idSerie) {
    const { data: serieLinks } = await supabase
      .from("metier_serie")
      .select("metier(*)")
      .eq("id_serie", parseInt(idSerie, 10));

    metiers = (serieLinks || []).map((l) => l.metier).filter(Boolean);
  } else {
    const { data: allMetiers } = await supabase
      .from("metier")
      .select("*")
      .order("nom", { ascending: true });

    metiers = allMetiers || [];
  }

  for (const m of metiers) {
    m.score_compatibilite = calculateCompatibility(dominantProfile, m.profil_riasec);
    m.nombre_correspondances = countMatches(dominantProfile, m.profil_riasec);
  }

  // Sort by score_compatibilite DESC, then nombre_correspondances DESC
  metiers.sort((a, b) => {
    if (b.score_compatibilite !== a.score_compatibilite) {
      return b.score_compatibilite - a.score_compatibilite;
    }
    return b.nombre_correspondances - a.nombre_correspondances;
  });

  // Filter positive compatibility
  const filtered = metiers.filter((m) => m.score_compatibilite > 0);

  const principaux = filtered.slice(0, 5);
  const secondaires = filtered.slice(5, 10);

  return {
    principaux: await enrichMetiersWithFormations(principaux),
    secondaires: await enrichMetiersWithFormations(secondaires),
  };
}

export async function enrichMetiersWithFormations(metiers) {
  const enriched = [];

  for (const metier of metiers) {
    const { data: filiereLinks } = await supabase
      .from("metier_filiere")
      .select("filiere(*)")
      .eq("id_metier", metier.id_metier);

    const filieres = (filiereLinks || []).map((fl) => fl.filiere).filter(Boolean);
    const filieresCompletes = [];

    for (const filiere of filieres) {
      const { data: univLinks } = await supabase
        .from("universite_filiere")
        .select("universite(*)")
        .eq("id_filiere", filiere.id_filiere);

      const universites = (univLinks || []).map((ul) => ul.universite).filter(Boolean);

      filieresCompletes.push({
        filiere,
        universites,
      });
    }

    enriched.push({
      ...metier,
      filieres: filieresCompletes,
    });
  }

  return enriched;
}

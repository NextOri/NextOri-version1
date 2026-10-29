import { API_ROUTES_URL } from "../config/api";

export async function getQuestionsComparaison() {
  const urls = [
    `${API_ROUTES_URL}/comparaison-pistes/questions`,
    `${API_ROUTES_URL}/comparaison-pistes`,
    `${API_ROUTES_URL}/hesitation/questions`
  ];

  for (const url of urls) {
    try {
      const response = await fetch(url, {
        method: "GET",
        headers: { "Content-Type": "application/json" },
        credentials: "include"
      });
      const resultat = await response.json().catch(() => ({}));
      if (response.ok && resultat.success && Array.isArray(resultat.data) && resultat.data.length > 0) {
        return resultat.data;
      }
    } catch {
      // tenter l'URL suivante
    }
  }

  throw new Error("Impossible de charger les questions depuis le serveur.");
}

export async function comparerPistes(idPistes, reponses = []) {
  const response = await fetch(`${API_ROUTES_URL}/comparaison-pistes`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify({ id_pistes: idPistes, reponses })
  });
  const resultat = await response.json().catch(() => ({}));
  if (!response.ok || !resultat.success) {
    throw new Error(resultat.message || "Impossible d'analyser ces pistes.");
  }
  return resultat.data;
}

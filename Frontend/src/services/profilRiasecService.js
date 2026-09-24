import { API_ROUTES_URL } from "../config/api";

export async function recupererProfilsRiasec() {
    const response = await fetch(`${API_ROUTES_URL}/profils-riasec`);
    const resultat = await response.json();

    if (!response.ok || !resultat.success) {
        throw new Error(
            resultat.message || "Impossible de charger les profils RIASEC."
        );
    }

    return resultat.data;
}

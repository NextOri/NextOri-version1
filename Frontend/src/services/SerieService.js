import { API_ROUTES_URL } from "../config/api";


export async function recupererSeries() {

    try {

        const response = await fetch(
            `${API_ROUTES_URL}/series.php`,
            {
                method: "GET",
                headers: {
                    "Content-Type": "application/json"
                }
            }
        );

        return await response.json();

    } catch (error) {

        console.error(
            "Erreur lors de la récupération des séries :",
            error
        );

        return [];

    }
}

import { API_ROUTES_URL } from "../config/api";

export const envoyerAvis = async (note, commentaire, afficher) => {

    try {

        const response = await fetch(
            `${API_ROUTES_URL}/avis.php`,
            {
                credentials: "include",

                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({
                    note: note,
                    commentaire: commentaire,
                    afficher: afficher
                })
            }
        );

        const data = await response.json();

        if (!response.ok) {
            throw new Error(
                data.message || "Erreur lors de l'envoi de l'avis."
            );
        }

        return data;

    } catch (error) {

        console.error(
            "Erreur avis :",
            error
        );

        throw error;
    }
};

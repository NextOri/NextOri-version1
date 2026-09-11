import { API_ROUTES_URL } from "../config/api";

export const enregistrerAction = async (action) => {

    try {

        const response = await fetch(
            `${API_ROUTES_URL}/historique.php`,
            {
                credentials: "include",

                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({

                    action: action

                })

            }
        );


        const data = await response.json();

        return data;


    } catch(error) {

        console.error(
            "Erreur historique :",
            error
        );

        throw error;

    }
};

import { API_ROUTES_URL } from "../config/api";

export const enregistrerAction = async (action) => {
    try {
        let id_user = null;
        let token = null;
        try {
            const userStr = localStorage.getItem("utilisateur");
            if (userStr) {
                const u = JSON.parse(userStr);
                id_user = u?.id_user || null;
            }
            token = localStorage.getItem("token") || null;
        } catch (_) {}

        const headers = {
            "Content-Type": "application/json"
        };
        if (token) {
            headers["Authorization"] = `Bearer ${token}`;
        }

        const response = await fetch(
            `${API_ROUTES_URL}/historique`,
            {
                credentials: "include",
                method: "POST",
                headers,
                body: JSON.stringify({
                    action: action,
                    id_user: id_user
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
        return { success: false, message: error.message };
    }
};

export const recupererHistorique = async () => {
    try {
        let idUserQuery = "";
        try {
            const u = JSON.parse(localStorage.getItem("utilisateur") || "{}");
            if (u?.id_user) idUserQuery = `?id_user=${u.id_user}`;
        } catch (_) {}

        const response = await fetch(
            `${API_ROUTES_URL}/historique${idUserQuery}`,
            {
                credentials: "include"
            }
        );

        return await response.json();
    } catch (error) {
        console.error("Erreur récupération historique :", error);
        return { success: false, data: [] };
    }
};

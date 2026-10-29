import { API_ROUTES_URL } from "../config/api";

/**
 * =========================================================
 * NEXTORI — SERVICE MES PISTES
 * =========================================================
 */

function getUserQuery() {

    try {

        const utilisateur =
            JSON.parse(
                localStorage.getItem("utilisateur") || "{}"
            );

        if (utilisateur?.id_user) {

            return `&id_user=${utilisateur.id_user}`;

        }

    } catch (error) {

        console.error(
            "Erreur récupération utilisateur :",
            error
        );

    }

    return "";

}


/**
 * Récupérer toutes les pistes
 */
export async function getPistes(type = null) {

    let url = `${API_ROUTES_URL}/pistes`;

    const params = [];

    if (type) {
        params.push(`type=${encodeURIComponent(type)}`);
    }

    const userQuery = getUserQuery();

    if (userQuery) {
        params.push(userQuery.substring(1));
    }

    if (params.length > 0) {
        url += `?${params.join("&")}`;
    }

    const response = await fetch(
        url,
        {
            method: "GET",
            credentials: "include"
        }
    );

    const data = await response.json();

    if (!response.ok) {

        throw new Error(
            data.message ||
            "Impossible de récupérer les pistes."
        );

    }

    return data;

}


/**
 * Vérifier si une cible est déjà une piste
 */
export async function verifierPiste(
    typePiste,
    id
) {

    const params = new URLSearchParams();

    params.set(
        "type_piste",
        typePiste
    );

    if (typePiste === "metier") {

        params.set(
            "id_metier",
            id
        );

    } else {

        params.set(
            "id_filiere",
            id
        );

    }

    const userQuery = getUserQuery();

    if (userQuery) {

        const utilisateur =
            JSON.parse(
                localStorage.getItem("utilisateur") || "{}"
            );

        if (utilisateur?.id_user) {

            params.set(
                "id_user",
                utilisateur.id_user
            );

        }

    }

    const response = await fetch(
        `${API_ROUTES_URL}/pistes/check?${params.toString()}`,
        {
            method: "GET",
            credentials: "include"
        }
    );

    const data = await response.json();

    if (!response.ok) {

        throw new Error(
            data.message ||
            "Impossible de vérifier la piste."
        );

    }

    return data;

}


/**
 * Ajouter une piste
 */
export async function ajouterPiste(
    typePiste,
    id
) {

    const body = {
        type_piste: typePiste
    };

    if (typePiste === "metier") {

        body.id_metier = Number(id);

    } else {

        body.id_filiere = Number(id);

    }

    const userQuery = getUserQuery();

    const url = userQuery
        ? `${API_ROUTES_URL}/pistes?${userQuery.substring(1)}`
        : `${API_ROUTES_URL}/pistes`;

    const response = await fetch(
        url,
        {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(body)
        }
    );

    const data = await response.json();

    if (!response.ok) {

        throw new Error(
            data.message ||
            "Impossible d'ajouter la piste."
        );

    }

    return data;

}


/**
 * Retirer une piste
 */
export async function retirerPiste(
    idPiste
) {

    const userQuery = getUserQuery();

    const url = userQuery
        ? `${API_ROUTES_URL}/pistes/${idPiste}?${userQuery.substring(1)}`
        : `${API_ROUTES_URL}/pistes/${idPiste}`;

    const response = await fetch(
        url,
        {
            method: "DELETE",
            credentials: "include"
        }
    );

    const data = await response.json();

    if (!response.ok) {

        throw new Error(
            data.message ||
            "Impossible de retirer la piste."
        );

    }

    return data;

}
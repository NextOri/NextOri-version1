import { API_ROUTES_URL } from "../config/api";

export async function login(email, mot_de_passe) {

    const response = await fetch(
        `${API_ROUTES_URL}/login.php`,
        {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                email,
                mot_de_passe
            })
        }
    );

    return await response.json();

}



export async function register(utilisateur) {

    const response = await fetch(
        `${API_ROUTES_URL}/register.php`,
        {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(utilisateur)
        }
    );

    return await response.json();

}



export async function getProfile(id_user) {

    const response = await fetch(
        `${API_ROUTES_URL}/profile.php?id_user=${id_user}`,
        {
            method: "GET",
            headers: {
                "Content-Type": "application/json"
            }
        }
    );

    return await response.json();

}


export async function logout() {

    const response = await fetch(
        `${API_ROUTES_URL}/logout.php`,
        {
            method: "POST",
            credentials: "include"
        }
    );

    return await response.json();
}

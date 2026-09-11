import api from "../api/axios";

export async function lancerOrientation(donnees) {

    try {

        const response = await api.post(

            "/routes/orientation.php",

            donnees

        );

        return response.data;

    } catch (error) {

        console.error(error);

        throw error;

    }

}
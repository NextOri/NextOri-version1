import { useState } from "react";
import { login } from "../services/AuthService";
import { useNavigate } from "react-router-dom";
import "../styles/Auth.css"

function Connexion() {

    const navigate = useNavigate();

    const [formData, setFormData] = useState({
        email: "",
        mot_de_passe: ""
    });


    const [message, setMessage] = useState("");

    const [utilisateur, setUtilisateur] = useState(null);



    const handleChange = (e) => {

        setFormData({
            ...formData,
            [e.target.name]: e.target.value
        });

    };



    const handleSubmit = async (e) => {

        e.preventDefault();


        const resultat = await login(
            formData.email,
            formData.mot_de_passe
        );


        if (resultat.success) {

            setMessage("Connexion réussie.");

            setUtilisateur(
                resultat.utilisateur
            );


            // Pour garder l'utilisateur connecté temporairement
            localStorage.setItem(
                "utilisateur",
                JSON.stringify(resultat.utilisateur)
            );

           
        navigate("/dashboard");

            


        } else {

            setMessage(
                resultat.message
            );

            setUtilisateur(null);

        }

    };



   return (

    <div className="auth-page">

        <div className="auth-card">

            <div className="auth-logo">
                NextOri
            </div>


            <h1>
                Bon retour 👋
            </h1>


            <p className="auth-description">
                Connectez-vous pour poursuivre votre orientation.
            </p>



            <form onSubmit={handleSubmit}>



                <input
                    className="auth-input"
                    type="email"
                    name="email"
                    placeholder="Email"
                    value={formData.email}
                    onChange={handleChange}
                />



                <input
                    className="auth-input"
                    type="password"
                    name="mot_de_passe"
                    placeholder="Mot de passe"
                    value={formData.mot_de_passe}
                    onChange={handleChange}
                />



                <button
                    className="auth-button"
                    type="submit"
                >
                    Se connecter
                </button>



            </form>



            {message && (

                <p className="auth-message">
                    {message}
                </p>

            )}



            <p className="auth-footer-text">
                Vous n'avez pas encore de compte ?
            </p>


            <button
                className="auth-link-button"
                type="button"
                onClick={() => navigate("/inscription")}
            >
                Créer mon compte
            </button>



        </div>


    </div>

);
}


export default Connexion;
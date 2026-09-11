import { useEffect, useState } from "react";
import { register } from "../services/AuthService";
import { useNavigate } from "react-router-dom";
import { recupererSeries } from "../services/SerieService";
import "../styles/Auth.css";

function Inscription() {

    const navigate = useNavigate();

    const [formData, setFormData] = useState({
        nom: "",
        email: "",
        mot_de_passe: "",
        pays: "",
        niveau_etude: "",
        id_serie: null
    });

    const [series, setSeries] = useState([]);
    useEffect(() => {

    const chargerSeries = async () => {

        const resultat = await recupererSeries();
        console.log("Séries récupérées :", resultat);

        setSeries(resultat);
    };

    chargerSeries();

   }, []);

    const [message, setMessage] = useState("");


    const handleChange = (e) => {

    const { name, value } = e.target;

    setFormData((ancien) => ({
        ...ancien,
        [name]: name === "id_serie"
            ? (value === "" ? null : Number(value))
            : value
    }));

    if (name === "niveau_etude" && value === "Collége") {

        setFormData((ancien) => ({
            ...ancien,
            niveau_etude: value,
            id_serie: null
        }));
    }
   };

    const handleSubmit = async (e) => {

        e.preventDefault();

        // Vérification de la série
        // pour tous les niveaux sauf Collège.
        if (
            formData.niveau_etude !== "Collége" &&
            formData.id_serie === null
        ) {

            setMessage("Veuillez sélectionner votre série.");

            return;
        }

        const resultat = await register(formData);

        if (resultat.success) {

            setMessage("Compte créé avec succès.");

            localStorage.setItem(
                "utilisateur",
                JSON.stringify(resultat.utilisateur)
            );

            navigate("/dashboard");

            setFormData({
                nom: "",
                email: "",
                mot_de_passe: "",
                pays: "",
                niveau_etude: "",
                id_serie: null
            });

        } else {

            setMessage(resultat.message);
        }
    };

    return (

        <div className="auth-page">

            <div className="auth-card">

                <div className="auth-logo">
                    NextOri
                </div>

                <h1>
                    Bienvenue sur NextOri 👋
                </h1>

                <p className="auth-description">
                    Créons votre compte pour commencer votre parcours d'orientation.
                </p>

                <form onSubmit={handleSubmit}>

                    <input
                        className="auth-input"
                        type="text"
                        name="nom"
                        placeholder="Nom complet"
                        value={formData.nom}
                        onChange={handleChange}
                    />

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

                    <select
                        className="auth-input"
                        name="pays"
                        value={formData.pays}
                        onChange={handleChange}
                    >

                        <option value="">
                            Sélectionnez votre pays
                        </option>

                        <option value="Sénégal">
                            Sénégal
                        </option>

                        <option value="Mali">
                            Mali
                        </option>

                        <option value="Côte d'Ivoire">
                            Côte d'Ivoire
                        </option>

                        <option value="Guinée">
                            Guinée
                        </option>

                        <option value="Burkina Faso">
                            Burkina Faso
                        </option>

                        <option value="Gambie">
                            Gambie
                        </option>

                        <option value="Mauritanie">
                            Mauritanie
                        </option>

                    </select>

                    <select
                        className="auth-input"
                        name="niveau_etude"
                        value={formData.niveau_etude}
                        onChange={handleChange}
                    >

                        <option value="">
                            Sélectionnez votre niveau
                        </option>

                        <option value="Collége">
                            Collège
                        </option>

                        <option value="Seconde">
                            Seconde
                        </option>

                        <option value="Première">
                            Première
                        </option>

                        <option value="Terminale">
                            Terminale
                        </option>

                        <option value="Baccalauréat">
                            Nouveau bachelier
                        </option>

                        <option value="Licence 1">
                            Licence 1
                        </option>

                        <option value="Licence 2">
                            Licence 2
                        </option>

                        <option value="Licence 3">
                            Licence 3
                        </option>

                        <option value="Master 1">
                            Master 1
                        </option>

                        <option value="Master 2">
                            Master 2
                        </option>

                        <option value="Doctorat">
                            Doctorat
                        </option>

                    </select>

                    {/* Série */}
        {formData.niveau_etude !== "" &&
      formData.niveau_etude !== "Collége" && (

    <select
        className="auth-input"
        name="id_serie"
        value={formData.id_serie ?? ""}
        onChange={handleChange}
        required
    >

        <option value="">
            Sélectionnez votre série
        </option>

        {series.map((serie) => (

            <option
                key={serie.id_serie}
                value={serie.id_serie}
            >
                {serie.nom}
            </option>

        ))}

    </select>
    )}
                    <button
                        className="auth-button"
                        type="submit"
                    >
                        Créer mon compte
                    </button>

                </form>

                {message && (

                    <p className="auth-message">
                        {message}
                    </p>

                )}

                <p className="auth-footer-text">
                    Vous avez déjà un compte ?
                </p>

                <button
                    className="auth-link-button"
                    type="button"
                    onClick={() => navigate("/connexion")}
                >
                    Se connecter
                </button>

            </div>

        </div>

    );
}

export default Inscription;
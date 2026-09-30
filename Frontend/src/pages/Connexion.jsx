import { useState } from "react";
import { login } from "../services/AuthService";
import { useNavigate } from "react-router-dom";
import { Eye, EyeOff, UserPlus } from "lucide-react";
import "../styles/Auth.css";

function Connexion() {
    const navigate = useNavigate();

    const [formData, setFormData] = useState({
        email: "",
        mot_de_passe: ""
    });

    const [showPassword, setShowPassword] = useState(false);
    const [message, setMessage] = useState("");
    const [chargement, setChargement] = useState(false);
    const [utilisateur, setUtilisateur] = useState(null);

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage("");
        setChargement(true);

        try {
            const resultat = await login(
                formData.email,
                formData.mot_de_passe
            );

            if (resultat.success) {
                setMessage("Connexion réussie.");
                setUtilisateur(resultat.utilisateur);

                // Pour garder l'utilisateur connecté
                localStorage.setItem(
                    "utilisateur",
                    JSON.stringify(resultat.utilisateur)
                );

                navigate("/dashboard");
            } else {
                setMessage(resultat.message || "Email ou mot de passe incorrect.");
                setUtilisateur(null);
            }
        } catch {
            setMessage("Impossible de contacter le serveur. Veuillez réessayer.");
            setUtilisateur(null);
        } finally {
            setChargement(false);
        }
    };

    return (
        <div className="auth-page">
            <div className="auth-card">

                <div className="auth-brand-header">
                    <img
                        src="/images/logo-nextori.jpg"
                        alt="Logo NextOri"
                        className="auth-logo-img"
                    />
                    <div className="auth-logo notranslate" translate="no">
                        NextOri
                    </div>
                </div>

                <h1>Bon retour 👋</h1>

                <p className="auth-description">
                    Connectez-vous pour poursuivre votre parcours d'orientation.
                </p>

                <form onSubmit={handleSubmit}>
                    <input
                        className="auth-input"
                        type="email"
                        name="email"
                        placeholder="Adresse email"
                        value={formData.email}
                        onChange={handleChange}
                        required
                    />

                    <div className="auth-field-group">
                        <div className="auth-input-wrapper">
                            <input
                                className="auth-input auth-input-with-icon"
                                type={showPassword ? "text" : "password"}
                                name="mot_de_passe"
                                placeholder="Mot de passe de votre compte NextOri"
                                value={formData.mot_de_passe}
                                onChange={handleChange}
                                required
                            />
                            <button
                                type="button"
                                className="auth-password-toggle"
                                onClick={() => setShowPassword(!showPassword)}
                                aria-label={showPassword ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                                tabIndex={-1}
                            >
                                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                            </button>
                        </div>
                        <p className="auth-field-hint">
                            ℹ️ Saisissez le mot de passe choisi lors de votre inscription (et non celui de votre compte Google).
                        </p>
                    </div>

                    <button
                        className="auth-button"
                        type="submit"
                        disabled={chargement}
                    >
                        {chargement ? "Connexion en cours..." : "Se connecter"}
                    </button>
                </form>

                {message && (
                    <p
                        className="auth-message"
                        style={{
                            color: "#DC2626",
                            marginTop: "14px",
                            fontWeight: "600",
                            fontSize: "14px"
                        }}
                    >
                        {message}
                    </p>
                )}

                <div className="auth-divider">
                    <span>Nouveau sur NextOri ?</span>
                </div>

                <div className="auth-signup-cta">
                    <p className="auth-signup-text">
                        Découvrez votre voie et explorez vos opportunités
                    </p>
                    <button
                        className="auth-signup-btn-captivating"
                        type="button"
                        onClick={() => navigate("/inscription")}
                    >
                        <UserPlus size={18} className="auth-signup-btn-icon" />
                        <span>Créer un compte</span>
                    </button>
                </div>

            </div>
        </div>
    );
}

export default Connexion;
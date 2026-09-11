import { useEffect, useState } from "react";
import { register, verifyCode, resendCode } from "../services/AuthService";
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
    const [message, setMessage] = useState("");
    const [messageType, setMessageType] = useState(""); // "error" ou "success"
    const [chargement, setChargement] = useState(false);

    // États du flux de vérification par email
    const [enAttenteVerification, setEnAttenteVerification] = useState(false);
    const [verificationToken, setVerificationToken] = useState("");
    const [codeOtp, setCodeOtp] = useState("");
    const [timerRenvoi, setTimerRenvoi] = useState(0);

    useEffect(() => {
        const chargerSeries = async () => {
            const resultat = await recupererSeries();
            setSeries(resultat);
        };
        chargerSeries();
    }, []);

    // Compte à rebours pour le renvoi de code
    useEffect(() => {
        if (timerRenvoi > 0) {
            const timer = setTimeout(() => setTimerRenvoi(timerRenvoi - 1), 1000);
            return () => clearTimeout(timer);
        }
    }, [timerRenvoi]);

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

    // 1. Soumission du formulaire initial d'inscription
    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage("");

        // Validation syntaxique email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
        if (!formData.email || !emailRegex.test(formData.email.trim())) {
            setMessage("Veuillez saisir une adresse email valide.");
            setMessageType("error");
            return;
        }

        // Domaines temporaires / jetables non autorisés
        const domaine = formData.email.trim().split("@")[1]?.toLowerCase();
        const domainesInterdits = [
            "yopmail.com", "mailinator.com", "tempmail.com", "guerrillamail.com",
            "10minutemail.com", "trashmail.com", "fake.com", "test.com", "example.com"
        ];
        if (domainesInterdits.includes(domaine)) {
            setMessage("Les adresses emails temporaires ou fictives ne sont pas autorisées.");
            setMessageType("error");
            return;
        }

        // Validation mot de passe (au moins 6 caractères)
        if (!formData.mot_de_passe || formData.mot_de_passe.length < 6) {
            setMessage("Le mot de passe doit contenir au moins 6 caractères.");
            setMessageType("error");
            return;
        }

        // Vérification de la série pour tous les niveaux sauf Collège
        if (formData.niveau_etude !== "Collége" && formData.id_serie === null) {
            setMessage("Veuillez sélectionner votre série.");
            setMessageType("error");
            return;
        }

        setChargement(true);

        try {
            const resultat = await register(formData);

            if (resultat.success && resultat.pendingVerification) {
                // Passage à l'écran de vérification OTP
                setVerificationToken(resultat.verificationToken);
                setEnAttenteVerification(true);
                setMessage(resultat.message || "Un code à 6 chiffres a été envoyé à votre adresse email.");
                setMessageType("success");
                setTimerRenvoi(60);
            } else if (resultat.success && resultat.utilisateur) {
                // Rétrocompatibilité si jamais vérification directe
                localStorage.setItem("utilisateur", JSON.stringify(resultat.utilisateur));
                navigate("/dashboard");
            } else {
                setMessage(resultat.message || "Erreur lors de l'inscription.");
                setMessageType("error");
            }
        } catch {
            setMessage("Impossible de contacter le serveur. Veuillez réessayer.");
            setMessageType("error");
        } finally {
            setChargement(false);
        }
    };

    // 2. Validation du code OTP saisi
    const handleValiderCode = async (e) => {
        e.preventDefault();
        setMessage("");

        if (!codeOtp || codeOtp.trim().length !== 6) {
            setMessage("Veuillez saisir le code complet à 6 chiffres.");
            setMessageType("error");
            return;
        }

        setChargement(true);

        try {
            const resultat = await verifyCode(codeOtp.trim(), verificationToken);

            if (resultat.success) {
                setMessage("Email vérifié avec succès ! Connexion en cours...");
                setMessageType("success");

                localStorage.setItem("utilisateur", JSON.stringify(resultat.utilisateur));

                setTimeout(() => {
                    navigate("/dashboard");
                }, 800);
            } else {
                setMessage(resultat.message || "Code incorrect ou expiré.");
                setMessageType("error");
            }
        } catch {
            setMessage("Erreur de connexion. Veuillez réessayer.");
            setMessageType("error");
        } finally {
            setChargement(false);
        }
    };

    // 3. Demande de renvoi d'un nouveau code
    const handleRenvoyerCode = async () => {
        if (timerRenvoi > 0 || chargement) return;

        setChargement(true);
        setMessage("");

        try {
            const resultat = await resendCode(verificationToken);

            if (resultat.success) {
                setVerificationToken(resultat.verificationToken);
                setTimerRenvoi(60);
                setMessage("Nouveau code envoyé ! Vérifiez votre boîte de réception.");
                setMessageType("success");
            } else {
                setMessage(resultat.message || "Impossible de renvoyer le code.");
                setMessageType("error");
            }
        } catch {
            setMessage("Erreur lors du renvoi du code.");
            setMessageType("error");
        } finally {
            setChargement(false);
        }
    };

    // ========================================================
    // VUE 1 : ÉCRAN DE SAISIE DU CODE OTP DE VÉRIFICATION
    // ========================================================
    if (enAttenteVerification) {
        return (
            <div className="auth-page">
                <div className="auth-card">
                    
                    {/* Logo officiel NextOri */}
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

                    <span className="auth-otp-badge">
                        ✉️ Vérification de votre email
                    </span>

                    <h1>Code de confirmation</h1>

                    <p className="auth-description">
                        Nous avons envoyé un code de sécurité à 6 chiffres à l'adresse :<br />
                        <strong style={{ color: "#0D1B2A", wordBreak: "break-all" }}>{formData.email}</strong>
                    </p>

                    <form onSubmit={handleValiderCode}>
                        <input
                            className="auth-otp-input"
                            type="text"
                            inputMode="numeric"
                            autoComplete="one-time-code"
                            maxLength={6}
                            placeholder="••••••"
                            value={codeOtp}
                            onChange={(e) => setCodeOtp(e.target.value.replace(/\D/g, ""))}
                            autoFocus
                        />

                        <button
                            className="auth-button"
                            type="submit"
                            disabled={chargement}
                        >
                            {chargement ? "Vérification en cours..." : "Confirmer mon compte"}
                        </button>
                    </form>

                    {message && (
                        <p
                            className="auth-message"
                            style={{
                                color: messageType === "success" ? "#16A34A" : "#DC2626",
                                marginTop: "14px",
                                fontWeight: "600",
                                fontSize: "14px"
                            }}
                        >
                            {message}
                        </p>
                    )}

                    <div className="auth-resend-row">
                        <span style={{ color: "#64748B" }}>Vous n'avez rien reçu ?</span>
                        {timerRenvoi > 0 ? (
                            <span style={{ color: "#94A3B8", fontWeight: "600" }}>
                                Renvoyer dans {timerRenvoi}s
                            </span>
                        ) : (
                            <button
                                type="button"
                                className="auth-link-button"
                                onClick={handleRenvoyerCode}
                                disabled={chargement}
                            >
                                Renvoyer un code
                            </button>
                        )}
                    </div>

                    <button
                        type="button"
                        className="auth-back-link"
                        onClick={() => {
                            setEnAttenteVerification(false);
                            setCodeOtp("");
                            setMessage("");
                        }}
                    >
                        ← Modifier mon adresse email ou mes informations
                    </button>

                </div>
            </div>
        );
    }

    // ========================================================
    // VUE 2 : FORMULAIRE D'INSCRIPTION INITIAL
    // ========================================================
    return (
        <div className="auth-page">
            <div className="auth-card">

                {/* Logo officiel NextOri */}
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

                <h1>
                    Bienvenue sur <span className="notranslate" translate="no">NextOri</span> 👋
                </h1>

                <p className="auth-description">
                    Créez votre compte pour commencer votre parcours d'orientation.
                </p>

                <form onSubmit={handleSubmit}>
                    <input
                        className="auth-input"
                        type="text"
                        name="nom"
                        placeholder="Nom complet"
                        value={formData.nom}
                        onChange={handleChange}
                        required
                    />

                    <input
                        className="auth-input"
                        type="email"
                        name="email"
                        placeholder="Adresse email (ex: prenom@gmail.com)"
                        value={formData.email}
                        onChange={handleChange}
                        required
                    />

                    <input
                        className="auth-input"
                        type="password"
                        name="mot_de_passe"
                        placeholder="Mot de passe (au moins 6 caractères)"
                        value={formData.mot_de_passe}
                        onChange={handleChange}
                        required
                    />

                    <select
                        className="auth-input"
                        name="pays"
                        value={formData.pays}
                        onChange={handleChange}
                        required
                    >
                        <option value="">Sélectionnez votre pays</option>
                        <option value="Sénégal">Sénégal</option>
                        <option value="Mali">Mali</option>
                        <option value="Côte d'Ivoire">Côte d'Ivoire</option>
                        <option value="Guinée">Guinée</option>
                        <option value="Burkina Faso">Burkina Faso</option>
                        <option value="Gambie">Gambie</option>
                        <option value="Mauritanie">Mauritanie</option>
                    </select>

                    <select
                        className="auth-input"
                        name="niveau_etude"
                        value={formData.niveau_etude}
                        onChange={handleChange}
                        required
                    >
                        <option value="">Sélectionnez votre niveau</option>
                        <option value="Collége">Collège</option>
                        <option value="Seconde">Seconde</option>
                        <option value="Première">Première</option>
                        <option value="Terminale">Terminale</option>
                        <option value="Baccalauréat">Nouveau bachelier</option>
                        <option value="Licence 1">Licence 1</option>
                        <option value="Licence 2">Licence 2</option>
                        <option value="Licence 3">Licence 3</option>
                        <option value="Master 1">Master 1</option>
                        <option value="Master 2">Master 2</option>
                        <option value="Doctorat">Doctorat</option>
                    </select>

                    {/* Série */}
                    {formData.niveau_etude !== "" && formData.niveau_etude !== "Collége" && (
                        <select
                            className="auth-input"
                            name="id_serie"
                            value={formData.id_serie ?? ""}
                            onChange={handleChange}
                            required
                        >
                            <option value="">Sélectionnez votre série</option>
                            {series.map((serie) => (
                                <option key={serie.id_serie} value={serie.id_serie}>
                                    {serie.nom}
                                </option>
                            ))}
                        </select>
                    )}

                    <button
                        className="auth-button"
                        type="submit"
                        disabled={chargement}
                    >
                        {chargement ? "Envoi du code en cours..." : "Continuer et recevoir mon code"}
                    </button>
                </form>

                {message && (
                    <p
                        className="auth-message"
                        style={{
                            color: messageType === "success" ? "#16A34A" : "#DC2626",
                            marginTop: "14px",
                            fontWeight: "600",
                            fontSize: "14px"
                        }}
                    >
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
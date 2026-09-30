import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
    User,
    Mail,
    Globe,
    GraduationCap,
    Calendar,
    LogOut,
    ClipboardList,
    ArrowRight,
    BarChart3,
    Sparkles
} from "lucide-react";
import "../styles/Profil.css";
import FooterNavigation from "../components/FooterNavigation";
import { logout } from "../services/AuthService";

function Profil() {
    const navigate = useNavigate();

    const [utilisateur, setUtilisateur] = useState(() => {
        const user = localStorage.getItem("utilisateur");
        return user ? JSON.parse(user) : null;
    });

    const [nombreTests, setNombreTests] = useState(0);
    const [chargementTests, setChargementTests] = useState(true);

    const handleLogout = async () => {
        try {
            await logout();
        } finally {
            localStorage.removeItem("utilisateur");
            localStorage.removeItem("aDejaTeste");
            setUtilisateur(null);
            navigate("/connexion");
        }
    };

    useEffect(() => {
        const recupererNombreTests = async () => {
            try {
                let idUserQuery = "";
                try {
                    const u = JSON.parse(localStorage.getItem("utilisateur") || "{}");
                    if (u?.id_user) idUserQuery = `?id_user=${u.id_user}`;
                } catch (_) {}

                const response = await fetch(
                    `${API_ROUTES_URL}/historique-tests${idUserQuery}`,
                    { credentials: "include" }
                );

                const data = await response.json();
                if (data.success) {
                    setNombreTests(
                        Array.isArray(data.data) ? data.data.length : 0
                    );
                }
            } catch (error) {
                console.error("Erreur récupération nombre de tests :", error);
            } finally {
                setChargementTests(false);
            }
        };

        recupererNombreTests();
    }, []);

    const getInitiales = (nom) => {
        if (!nom) return "NO";
        const noms = nom.trim().split(" ");
        if (noms.length === 1) return noms[0].slice(0, 2).toUpperCase();
        const premier = noms[0][0];
        const dernier = noms[noms.length - 1][0];
        return (premier + dernier).toUpperCase();
    };

    const formatDate = (dateStr) => {
        if (!dateStr) return "Récemment";
        try {
            const d = new Date(dateStr);
            if (isNaN(d.getTime())) return dateStr;
            return d.toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" });
        } catch (_) {
            return dateStr;
        }
    };

    if (!utilisateur) {
        return (
            <div className="non-connecte-profil-page">
                <div className="profil-non-connecte">
                    <div className="profil-non-connecte-icon">?</div>
                    <h1>Profil utilisateur</h1>
                    <p>Vous devez être connecté pour accéder à votre espace profil.</p>
                    <button
                        className="profil-login-button"
                        onClick={() => navigate("/connexion")}
                    >
                        Se connecter
                    </button>
                </div>
                <FooterNavigation />
            </div>
        );
    }

    return (
        <div className="profile-page">
            <div className="profile-container">

                {/* En-tête profil compact & prestigieux */}
                <section className="profile-header">
                    <div className="profile-header-main">
                        <div className="profile-avatar">
                            {getInitiales(utilisateur.nom)}
                        </div>

                        <div className="profile-header-info">
                            <div className="profile-header-title-row">
                                <h1>{utilisateur.nom}</h1>
                                {utilisateur.niveau_etude && (
                                    <span className="profile-level-badge">
                                        <GraduationCap size={13} />
                                        <span>{utilisateur.niveau_etude}</span>
                                    </span>
                                )}
                            </div>

                            <p className="profile-header-email">
                                <Mail size={13} />
                                <span>{utilisateur.email}</span>
                            </p>

                            <div className="profile-header-meta">
                                {utilisateur.pays && (
                                    <span className="profile-meta-chip">
                                        <Globe size={12} />
                                        <span>{utilisateur.pays}</span>
                                    </span>
                                )}
                                <span className="profile-meta-chip">
                                    <Calendar size={12} />
                                    <span>Inscrit le {formatDate(utilisateur.date_creation)}</span>
                                </span>
                            </div>
                        </div>
                    </div>
                </section>

                {/* Informations personnelles compactes en grille 2 colonnes */}
                <section className="profile-section">
                    <div className="profile-section-header">
                        <div className="profile-section-icon">
                            <User size={20} />
                        </div>
                        <div>
                            <span className="profile-section-badge">Compte</span>
                            <h2>Informations personnelles</h2>
                        </div>
                    </div>

                    <div className="profile-info-grid">
                        <div className="info-card">
                            <div className="info-card-icon">
                                <User size={18} />
                            </div>
                            <div className="info-card-body">
                                <span className="info-card-label">Nom complet</span>
                                <strong className="info-card-value">{utilisateur.nom}</strong>
                            </div>
                        </div>

                        <div className="info-card">
                            <div className="info-card-icon">
                                <Mail size={18} />
                            </div>
                            <div className="info-card-body">
                                <span className="info-card-label">Adresse email</span>
                                <strong className="info-card-value">{utilisateur.email}</strong>
                            </div>
                        </div>

                        <div className="info-card">
                            <div className="info-card-icon">
                                <Globe size={18} />
                            </div>
                            <div className="info-card-body">
                                <span className="info-card-label">Pays de résidence</span>
                                <strong className="info-card-value">{utilisateur.pays || "Non renseigné"}</strong>
                            </div>
                        </div>

                        <div className="info-card">
                            <div className="info-card-icon">
                                <GraduationCap size={18} />
                            </div>
                            <div className="info-card-body">
                                <span className="info-card-label">Niveau d'étude</span>
                                <strong className="info-card-value">{utilisateur.niveau_etude || "Non renseigné"}</strong>
                            </div>
                        </div>

                        <div className="info-card info-card-full">
                            <div className="info-card-icon">
                                <Calendar size={18} />
                            </div>
                            <div className="info-card-body">
                                <span className="info-card-label">Date d'inscription</span>
                                <strong className="info-card-value">{formatDate(utilisateur.date_creation)}</strong>
                            </div>
                        </div>
                    </div>
                </section>

                {/* Historique des tests (au même standing de design) */}
                <section className="profil-tests-history">
                    <div className="profil-tests-history-header">
                        <div className="profil-tests-history-title">
                            <div className="profil-tests-history-icon">
                                <ClipboardList size={22} />
                            </div>
                            <div>
                                <span>Orientation</span>
                                <h2>Mes tests d'orientation</h2>
                            </div>
                        </div>

                        <div className="profil-tests-history-count">
                            <strong>{chargementTests ? "—" : nombreTests}</strong>
                            <span>{nombreTests === 1 ? "test effectué" : "tests effectués"}</span>
                        </div>
                    </div>

                    <div className="profil-tests-history-content">
                        <div className="profil-tests-history-description">
                            <BarChart3 size={20} />
                            <p>
                                Retrouvez vos résultats détaillés, vos scores RIASEC et l'évolution de vos recommandations.
                            </p>
                        </div>

                        <button
                            className="profil-tests-history-button"
                            onClick={() => navigate("/historique-tests")}
                        >
                            <span>Voir l'historique</span>
                            <ArrowRight size={17} />
                        </button>
                    </div>
                </section>

                {/* Déconnexion */}
                <button
                    className="logout-button"
                    onClick={handleLogout}
                >
                    <LogOut size={17} />
                    <span>Se déconnecter de mon compte</span>
                </button>

            </div>

            <FooterNavigation />
        </div>
    );
}

export default Profil;

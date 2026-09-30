import { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { X, ArrowLeft, ArrowRight, Home, Compass, BarChart2, Sparkles, Zap, Star, Heart, Trophy } from "lucide-react";

import {
    getQuestions,
    getPropositions,
    envoyerReponses
} from "../services/api";

import "../styles/Test.css";

import { enregistrerAction } from "../services/historiqueService";


/* =====================================================================
   MESSAGES D'ENCOURAGEMENT
===================================================================== */

const ENCOURAGEMENTS = [
    { icon: <Zap size={15} />,    texte: "Super ! Continue comme ça 🚀" },
    { icon: <Star size={15} />,   texte: "Tu avances très bien !" },
    { icon: <Heart size={15} />,  texte: "Chaque réponse te rapproche de ton profil !" },
    { icon: <Sparkles size={15} />, texte: "Réponse enregistrée ✓" },
    { icon: <Trophy size={15} />, texte: "Tu es sur la bonne voie !" },
    { icon: <Zap size={15} />,    texte: "Parfait ! Presque là !" },
];

const MILESTONES = [
    { seuil: 25, texte: "25 % complété — bon départ !", icon: <Zap size={15} /> },
    { seuil: 50, texte: "Mi-chemin atteint ! Tu assures 💪", icon: <Star size={15} /> },
    { seuil: 75, texte: "Plus que quelques questions !", icon: <Sparkles size={15} /> },
    { seuil: 100, texte: "Félicitations ! Test terminé 🎉", icon: <Trophy size={15} /> },
];


function Test() {

    const [questions, setQuestions]             = useState([]);
    const [propositions, setPropositions]       = useState([]);
    const [index, setIndex]                     = useState(0);
    const [reponses, setReponses]               = useState([]);
    const [loading, setLoading]                 = useState(true);
    const [analyseEnCours, setAnalyseEnCours]   = useState(false);
    const [etapeAnalyse, setEtapeAnalyse]       = useState(1);
    const [notification, setNotification]       = useState(null);
    const [notifVisible, setNotifVisible]       = useState(false);
    const [animDirection, setAnimDirection]     = useState("next"); // "next" | "prev"
    const [animating, setAnimating]             = useState(false);
    const milestoneRef                          = useRef(new Set());
    const notifTimerRef                         = useRef(null);
    const navigate = useNavigate();


    /* =========================
       RÉCUPÉRATION DES QUESTIONS
    ========================= */

    useEffect(() => {
        getQuestions()
            .then((data) => {
                setQuestions(data);
                setLoading(false);
            })
            .catch((error) => {
                console.error(error);
                setLoading(false);
            });
    }, []);


    /* =========================
       RÉCUPÉRATION DES PROPOSITIONS
    ========================= */

    useEffect(() => {
        if (questions.length > 0) {
            getPropositions(questions[index].id_question)
                .then((data) => setPropositions(data))
                .catch(console.error);
        }
    }, [index, questions]);


    /* =========================
       AFFICHER UNE NOTIFICATION
    ========================= */

    function afficherNotification(notif) {
        if (notifTimerRef.current) clearTimeout(notifTimerRef.current);

        setNotification(notif);
        setNotifVisible(true);

        notifTimerRef.current = setTimeout(() => {
            setNotifVisible(false);
        }, 2400);
    }


    /* =========================
       VÉRIFIER LES JALONS
    ========================= */

    function verifierJalons(progression) {
        for (const m of MILESTONES) {
            if (progression >= m.seuil && !milestoneRef.current.has(m.seuil)) {
                milestoneRef.current.add(m.seuil);
                afficherNotification(m);
                return;
            }
        }
    }


    /* =========================
       ÉTAT DE CHARGEMENT
    ========================= */

    if (loading) {
        return (
            <div className="nxt-test nextori-test-loading">
                <div className="nextori-test-loading-card">
                    <div className="nextori-test-loading-spinner"></div>
                    <p>Préparation de ton test...</p>
                </div>
            </div>
        );
    }


    /* =========================
       ANALYSE DU RÉSULTAT
    ========================= */

    if (analyseEnCours) {
        const pourcentageProgress =
            etapeAnalyse === 1 ? 25 :
            etapeAnalyse === 2 ? 50 :
            etapeAnalyse === 3 ? 75 :
            etapeAnalyse === 4 ? 90 : 100;

        return (
            <div className="nextori-analysis-page">
                <div className="nextori-analysis-card">
                    <div className="nextori-analysis-icon">
                        <div className="nextori-analysis-spinner"></div>
                    </div>

                    <span className="nextori-analysis-eyebrow">
                        NEXTORI · ANALYSE
                    </span>

                    <h1>Analyse de tes réponses...</h1>

                    <p>
                        Nous étudions tes réponses pour identifier
                        les tendances de ton profil et préparer
                        ta restitution personnalisée.
                    </p>

                    <div className="nextori-analysis-progress">
                        <div className="nextori-analysis-progress-track">
                            <div
                                className="nextori-analysis-progress-fill"
                                style={{
                                    width: `${pourcentageProgress}%`,
                                    transition: "width 0.45s ease"
                                }}
                            ></div>
                        </div>
                    </div>

                    <div className="nextori-analysis-steps">

                        {/* Étape 1 */}
                        <div className={`nextori-analysis-step ${etapeAnalyse > 1 ? "completed" : "active"}`}>
                            {etapeAnalyse > 1 ? (
                                <span>✓</span>
                            ) : (
                                <span><span className="nextori-analysis-dot"></span></span>
                            )}
                            <p>Réponses enregistrées</p>
                        </div>

                        {/* Étape 2 */}
                        <div className={`nextori-analysis-step ${etapeAnalyse > 2 ? "completed" : etapeAnalyse === 2 ? "active" : ""}`}>
                            {etapeAnalyse > 2 ? (
                                <span>✓</span>
                            ) : etapeAnalyse === 2 ? (
                                <span><span className="nextori-analysis-dot"></span></span>
                            ) : (
                                <span><span className="nextori-analysis-dot-pending"></span></span>
                            )}
                            <p>Analyse de ton profil RIASEC</p>
                        </div>

                        {/* Étape 3 */}
                        <div className={`nextori-analysis-step ${etapeAnalyse > 3 ? "completed" : etapeAnalyse === 3 ? "active" : ""}`}>
                            {etapeAnalyse > 3 ? (
                                <span>✓</span>
                            ) : etapeAnalyse === 3 ? (
                                <span><span className="nextori-analysis-dot"></span></span>
                            ) : (
                                <span><span className="nextori-analysis-dot-pending"></span></span>
                            )}
                            <p>Identification des métiers</p>
                        </div>

                        {/* Étape 4 */}
                        <div className={`nextori-analysis-step ${etapeAnalyse >= 5 ? "completed" : etapeAnalyse === 4 ? "active" : ""}`}>
                            {etapeAnalyse >= 5 ? (
                                <span>✓</span>
                            ) : etapeAnalyse === 4 ? (
                                <span><span className="nextori-analysis-dot"></span></span>
                            ) : (
                                <span><span className="nextori-analysis-dot-pending"></span></span>
                            )}
                            <p>Préparation de tes résultats</p>
                        </div>

                    </div>

                    <small>Cela peut prendre quelques instants.</small>

                </div>
            </div>
        );
    }


    if (!questions.length) {
        return (
            <div className="nxt-test nextori-test-empty">
                <div className="nextori-test-empty-card">
                    <Compass size={40} />
                    <h2>Le test n'est pas disponible</h2>
                    <p>Impossible de charger les questions pour le moment.</p>
                    <button
                        className="nextori-test-home-button"
                        onClick={() => navigate("/dashboard")}
                    >
                        <Home size={18} />
                        Retour à l'accueil
                    </button>
                </div>
            </div>
        );
    }


    const question   = questions[index];
    const total      = questions.length;
    const progression = Math.round(((index + 1) / total) * 100);
    const reponseActuelle = reponses[index]?.id_proposition ?? null;


    /* =========================
       CHOIX D'UNE RÉPONSE
    ========================= */

    function choisirReponse(idProposition) {

        const dejaRepondu = reponseActuelle !== null;

        const nouvellesReponses = [...reponses];
        nouvellesReponses[index] = {
            id_question: question.id_question,
            id_proposition: idProposition
        };
        setReponses(nouvellesReponses);

        // Encouragement aléatoire (pas si déjà répondu à cette question)
        if (!dejaRepondu) {
            const randomIndex = Math.floor(Math.random() * ENCOURAGEMENTS.length);
            afficherNotification(ENCOURAGEMENTS[randomIndex]);
        }
    }


    /* =========================
       QUESTION SUIVANTE
    ========================= */

    function suivant() {

        if (reponseActuelle === null) {
            afficherNotification({ icon: <Zap size={15} />, texte: "Sélectionne une réponse avant de continuer !" });
            return;
        }

        if (index < total - 1) {

            const nouvelIndex = index + 1;
            const prog = Math.round(((nouvelIndex + 1) / total) * 100);

            setAnimDirection("next");
            setAnimating(true);

            setTimeout(() => {
                setIndex(nouvelIndex);
                setAnimating(false);

                // Vérifier les jalons après changement
                verifierJalons(prog);
            }, 200);

        } else {

            // Dernier jalon
            verifierJalons(100);

            setAnalyseEnCours(true);
            setEtapeAnalyse(1);

            const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

            const executerAnalyse = async () => {
                try {
                    const apiPromise = envoyerReponses(reponses);

                    await sleep(400);
                    setEtapeAnalyse(2);

                    await sleep(700);
                    setEtapeAnalyse(3);

                    const resultat = await apiPromise;

                    setEtapeAnalyse(4);
                    await sleep(600);

                    setEtapeAnalyse(5);
                    await sleep(300);

                    await enregistrerAction("METIERS_CONSULTES");

                    navigate("/result", { state: { data: resultat } });

                } catch (error) {
                    console.error(error);
                    setAnalyseEnCours(false);
                    setEtapeAnalyse(1);
                    alert("Erreur lors du calcul.");
                }
            };

            executerAnalyse();
        }
    }


    /* =========================
       QUESTION PRÉCÉDENTE
    ========================= */

    function precedent() {
        if (index > 0) {
            setAnimDirection("prev");
            setAnimating(true);
            setTimeout(() => {
                setIndex(index - 1);
                setAnimating(false);
            }, 200);
        }
    }


    return (
        <div className="nxt-test">

            {/* ==========================================
                NOTIFICATION FLOTTANTE
            ========================================== */}

            <div className={`nxt-notif ${notifVisible ? "nxt-notif--visible" : ""}`}>
                {notification && (
                    <>
                        <span className="nxt-notif__icon">{notification.icon}</span>
                        <span className="nxt-notif__texte">{notification.texte}</span>
                    </>
                )}
            </div>


            {/* ==========================================
                HEADER
            ========================================== */}

            <header className="nxt-header">

                <button
                    type="button"
                    className="nxt-header__back"
                    onClick={() => navigate("/dashboard")}
                >
                    <ArrowLeft size={16} />
                    <span>Accueil</span>
                </button>

                <div className="nxt-header__brand">
                    <div className="nxt-header__logo">
                        <Compass size={18} />
                    </div>
                    <strong>NextOri</strong>
                </div>

                <div className="nxt-header__badge">
                    Test RIASEC
                </div>

            </header>


            {/* ==========================================
                BARRE DE PROGRESSION
            ========================================== */}

            <div className="nxt-progress-bar">
                <div
                    className="nxt-progress-bar__fill"
                    style={{ width: `${progression}%` }}
                />
            </div>


            {/* ==========================================
                CORPS PRINCIPAL (layout 2 colonnes)
            ========================================== */}

            <main className="nxt-main">

                {/* ---- COLONNE GAUCHE : Question ---- */}
                <div className={`nxt-question-col ${animating ? `nxt-question-col--${animDirection}` : ""}`}>

                    {/* Compteur */}
                    <div className="nxt-counter">
                        <span className="nxt-counter__num">{index + 1}</span>
                        <span className="nxt-counter__sep">/</span>
                        <span className="nxt-counter__total">{total}</span>
                        <span className="nxt-counter__pct">· {progression}%</span>
                    </div>

                    {/* Texte de la question */}
                    <h2 className="nxt-question__text">
                        {question.texte}
                    </h2>

                    <p className="nxt-question__hint">
                        Choisis la réponse qui te correspond le mieux.
                    </p>

                    {/* Navigation desktop */}
                    <div className="nxt-nav nxt-nav--desktop">
                        <button
                            type="button"
                            className="nxt-btn nxt-btn--secondary"
                            onClick={precedent}
                            disabled={index === 0}
                        >
                            <ArrowLeft size={16} />
                            Précédent
                        </button>

                        <button
                            type="button"
                            className="nxt-btn nxt-btn--primary"
                            onClick={suivant}
                            disabled={analyseEnCours}
                        >
                            {index === total - 1 ? (
                                <>
                                    <BarChart2 size={16} />
                                    Voir mes résultats
                                </>
                            ) : (
                                <>
                                    Question suivante
                                    <ArrowRight size={16} />
                                </>
                            )}
                        </button>
                    </div>

                </div>


                {/* ---- COLONNE DROITE : Réponses ---- */}
                <div className={`nxt-answers-col ${animating ? `nxt-answers-col--${animDirection}` : ""}`}>

                    {propositions.map((proposition, i) => {
                        const estActive = reponseActuelle === proposition.id_proposition;
                        return (
                            <button
                                key={proposition.id_proposition}
                                type="button"
                                className={`nxt-answer ${estActive ? "nxt-answer--active" : ""}`}
                                onClick={() => choisirReponse(proposition.id_proposition)}
                                style={{ animationDelay: `${i * 0.06}s` }}
                            >
                                <span className="nxt-answer__letter">
                                    {proposition.lettre}
                                </span>
                                <span className="nxt-answer__text">
                                    {proposition.libelle}
                                </span>
                                <span className="nxt-answer__check">
                                    {estActive && <span>✓</span>}
                                </span>
                            </button>
                        );
                    })}

                </div>


                {/* Navigation mobile */}
                <div className="nxt-nav nxt-nav--mobile">
                    <button
                        type="button"
                        className="nxt-btn nxt-btn--secondary"
                        onClick={precedent}
                        disabled={index === 0}
                    >
                        <ArrowLeft size={16} />
                        Précédent
                    </button>

                    <button
                        type="button"
                        className="nxt-btn nxt-btn--primary"
                        onClick={suivant}
                        disabled={analyseEnCours}
                    >
                        {index === total - 1 ? (
                            <>
                                <BarChart2 size={16} />
                                Résultats
                            </>
                        ) : (
                            <>
                                Suivant
                                <ArrowRight size={16} />
                            </>
                        )}
                    </button>
                </div>

            </main>

        </div>
    );

}


export default Test;
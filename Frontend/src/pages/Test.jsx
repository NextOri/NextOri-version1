import { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, Compass, BarChart2, Zap, Star, Heart, Sparkles, Trophy, Home } from "lucide-react";

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
    { icon: "⚡", texte: "Super ! Continue comme ça 🚀" },
    { icon: "⭐", texte: "Tu avances très bien !" },
    { icon: "💙", texte: "Chaque réponse te rapproche de ton profil !" },
    { icon: "✨", texte: "Réponse enregistrée ✓" },
    { icon: "🏆", texte: "Tu es sur la bonne voie !" },
    { icon: "🔥", texte: "Parfait ! Presque là !" },
];

const MILESTONES = [
    { seuil: 25,  texte: "25 % complété — bon départ !",        icon: "⚡" },
    { seuil: 50,  texte: "Mi-chemin atteint ! Tu assures 💪",   icon: "⭐" },
    { seuil: 75,  texte: "Plus que quelques questions !",        icon: "✨" },
    { seuil: 100, texte: "Félicitations ! Test terminé 🎉",      icon: "🏆" },
];


function Test() {

    const [questions, setQuestions]           = useState([]);
    const [propositions, setPropositions]     = useState([]);
    const [index, setIndex]                   = useState(0);
    const [reponses, setReponses]             = useState([]);
    const [loading, setLoading]               = useState(true);
    const [analyseEnCours, setAnalyseEnCours] = useState(false);
    const [etapeAnalyse, setEtapeAnalyse]     = useState(1);
    const [notification, setNotification]     = useState(null);
    const [notifVisible, setNotifVisible]     = useState(false);

    /* Animation : "idle" | "out" | "in" */
    const [animPhase, setAnimPhase]           = useState("idle");

    const milestoneRef  = useRef(new Set());
    const notifTimer    = useRef(null);
    const navigate      = useNavigate();


    /* =========================
       CHARGEMENT DES QUESTIONS
    ========================= */

    useEffect(() => {
        getQuestions()
            .then((data) => { setQuestions(data); setLoading(false); })
            .catch(() => setLoading(false));
    }, []);


    /* =========================
       CHARGEMENT DES PROPOSITIONS
       — déclenché uniquement par index
    ========================= */

    useEffect(() => {
        if (!questions.length) return;

        // On ne charge PAS si on est en phase "out" (on attend la fin de l'anim)
        if (animPhase === "out") return;

        getPropositions(questions[index].id_question)
            .then((data) => {
                setPropositions(data);
                // Après chargement, passer en phase "in" pour l'animation d'entrée
                if (animPhase === "idle-pending") {
                    setAnimPhase("in");
                    setTimeout(() => setAnimPhase("idle"), 320);
                }
            })
            .catch(console.error);

    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [index, questions]);


    /* =========================
       NOTIFICATION
    ========================= */

    function afficherNotif(notif) {
        if (notifTimer.current) clearTimeout(notifTimer.current);
        setNotification(notif);
        setNotifVisible(true);
        notifTimer.current = setTimeout(() => setNotifVisible(false), 2600);
    }

    /* Vérifie les jalons SAUF 100% (géré dans soumettre) */
    function verifierJalons(nbRepondues, total) {
        const pct = Math.round((nbRepondues / total) * 100);
        for (const m of MILESTONES) {
            if (m.seuil === 100) continue;               // réservé à soumettre()
            if (pct >= m.seuil && !milestoneRef.current.has(m.seuil)) {
                milestoneRef.current.add(m.seuil);
                afficherNotif(m);
                return;
            }
        }
    }


    /* =========================
       ÉTAT DE CHARGEMENT INITIAL
    ========================= */

    if (loading) {
        return (
            <div className="nxt-test nxt-test--center">
                <div className="nxt-card-center">
                    <div className="nxt-spinner"></div>
                    <p>Préparation de ton test...</p>
                </div>
            </div>
        );
    }

    if (!questions.length) {
        return (
            <div className="nxt-test nxt-test--center">
                <div className="nxt-card-center">
                    <Compass size={40} />
                    <h2>Le test n'est pas disponible</h2>
                    <p>Impossible de charger les questions pour le moment.</p>
                    <button className="nxt-btn nxt-btn--primary" onClick={() => navigate("/dashboard")}>
                        <Home size={16} /> Retour à l'accueil
                    </button>
                </div>
            </div>
        );
    }


    /* =========================
       ANALYSE EN COURS
    ========================= */

    if (analyseEnCours) {
        const pct =
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
                    <span className="nextori-analysis-eyebrow">NEXTORI · ANALYSE</span>
                    <h1>Analyse de tes réponses...</h1>
                    <p>Nous étudions tes réponses pour identifier les tendances de ton profil et préparer ta restitution personnalisée.</p>
                    <div className="nextori-analysis-progress">
                        <div className="nextori-analysis-progress-track">
                            <div className="nextori-analysis-progress-fill" style={{ width: `${pct}%`, transition: "width 0.45s ease" }}></div>
                        </div>
                    </div>
                    <div className="nextori-analysis-steps">
                        {[
                            "Réponses enregistrées",
                            "Analyse de ton profil RIASEC",
                            "Identification des métiers",
                            "Préparation de tes résultats"
                        ].map((label, i) => {
                            const etape = i + 1;
                            const statut = etapeAnalyse > etape ? "completed" : etapeAnalyse === etape ? "active" : "";
                            return (
                                <div key={i} className={`nextori-analysis-step ${statut}`}>
                                    <span>
                                        {etapeAnalyse > etape ? "✓" : (
                                            <span className={etapeAnalyse === etape ? "nextori-analysis-dot" : "nextori-analysis-dot-pending"}></span>
                                        )}
                                    </span>
                                    <p>{label}</p>
                                </div>
                            );
                        })}
                    </div>
                    <small>Cela peut prendre quelques instants.</small>
                </div>
            </div>
        );
    }


    const question        = questions[index];
    const total           = questions.length;
    const reponseActuelle = reponses[index]?.id_proposition ?? null;

    /* Progression = nombre de questions RÉPONDUES / total */
    const nbRepondues = reponses.filter(Boolean).length;
    const progression = Math.round((nbRepondues / total) * 100);


    /* =========================
       CHOISIR UNE RÉPONSE
    ========================= */

    function choisirReponse(idProposition) {
        const dejaRepondu = reponseActuelle !== null;

        const nouvellesReponses = [...reponses];
        nouvellesReponses[index] = {
            id_question: question.id_question,
            id_proposition: idProposition
        };
        setReponses(nouvellesReponses);

        if (!dejaRepondu) {
            const r = ENCOURAGEMENTS[Math.floor(Math.random() * ENCOURAGEMENTS.length)];
            afficherNotif(r);
        }
    }


    /* =========================
       NAVIGATION ANIMÉE
       Séquence : out → changer index → in
    ========================= */

    function naviguer(nouvelIndex) {
        // Masquer toute notification en cours avant la transition
        setNotifVisible(false);
        if (notifTimer.current) clearTimeout(notifTimer.current);

        // 1. Phase "out" + vider les propositions pour éviter le flash
        setAnimPhase("out");
        setPropositions([]);

        setTimeout(() => {
            // 2. Changer l'index — le useEffect charge les nouvelles propositions
            setIndex(nouvelIndex);
            setAnimPhase("idle-pending");
        }, 220);
    }


    /* =========================
       SUIVANT / PRÉCÉDENT
    ========================= */

    function suivant() {
        if (reponseActuelle === null) {
            afficherNotif({ icon: "👆", texte: "Sélectionne une réponse avant de continuer !" });
            return;
        }

        if (index < total - 1) {
            const nouvelIndex = index + 1;
            /* Vérifier les jalons APRÈS avoir enregistré la réponse actuelle */
            const nbAprès = reponses.filter(Boolean).length;
            verifierJalons(nbAprès, total);
            naviguer(nouvelIndex);
        } else {
            /* Dernière question : afficher le message de fin PUIS lancer l'analyse */
            soumettre();
        }
    }

    function precedent() {
        if (index > 0) naviguer(index - 1);
    }


    /* =========================
       SOUMISSION FINALE
    ========================= */

    function soumettre() {
        const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

        (async () => {
            try {
                /* 1. Afficher le message "Test terminé" sur la page de test */
                if (!milestoneRef.current.has(100)) {
                    milestoneRef.current.add(100);
                    afficherNotif({ icon: "🏆", texte: "Félicitations ! Test terminé 🎉" });
                }

                /* 2. Laisser la notification visible un instant */
                await sleep(1600);

                /* 3. Basculer vers l'écran d'analyse */
                setAnalyseEnCours(true);
                setEtapeAnalyse(1);

                const apiPromise = envoyerReponses(reponses);
                await sleep(400); setEtapeAnalyse(2);
                await sleep(700); setEtapeAnalyse(3);
                const resultat = await apiPromise;
                setEtapeAnalyse(4);
                await sleep(600);
                setEtapeAnalyse(5);
                await sleep(300);
                await enregistrerAction("METIERS_CONSULTES");
                navigate("/result", { state: { data: resultat } });
            } catch (err) {
                console.error(err);
                setAnalyseEnCours(false);
                setEtapeAnalyse(1);
                alert("Erreur lors du calcul.");
            }
        })();
    }


    /* =========================
       CLASSE D'ANIMATION
    ========================= */

    const animClass =
        animPhase === "out" ? "nxt-anim--out" :
        animPhase === "in"  ? "nxt-anim--in"  : "";


    return (
        <div className="nxt-test">

            {/* ---- NOTIFICATION FLOTTANTE ---- */}
            <div className={`nxt-notif ${notifVisible ? "nxt-notif--visible" : ""}`}>
                {notification && (
                    <>
                        <span>{notification.icon}</span>
                        <span>{notification.texte}</span>
                    </>
                )}
            </div>


            {/* ---- HEADER ---- */}
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
                    <div className="nxt-header__logo"><Compass size={18} /></div>
                    <strong>NextOri</strong>
                </div>

                <span className="nxt-header__badge">Test RIASEC</span>
            </header>


            {/* ---- BARRE DE PROGRESSION ---- */}
            <div className="nxt-progress-bar">
                <div className="nxt-progress-bar__fill" style={{ width: `${progression}%` }} />
            </div>


            {/* ---- CORPS PRINCIPAL ---- */}
            <main className="nxt-main">

                {/* Zone animée : question + réponses */}
                <div className={`nxt-content ${animClass}`}>

                    {/* QUESTION */}
                    <div className="nxt-question">
                        <div className="nxt-question__meta">
                            <span className="nxt-question__label">
                                Question <strong>{index + 1}</strong>
                                <span className="nxt-question__total"> sur {total}</span>
                            </span>
                            <span className="nxt-question__pct">
                                {nbRepondues} répondu{nbRepondues > 1 ? "es" : nbRepondues === 1 ? "e" : ""}
                            </span>
                        </div>

                        <h2 className="nxt-question__text">{question.texte}</h2>
                    </div>


                    {/* RÉPONSES */}
                    <div className="nxt-answers">
                        {propositions.map((prop, i) => {
                            const actif = reponseActuelle === prop.id_proposition;
                            return (
                                <button
                                    key={prop.id_proposition}
                                    type="button"
                                    className={`nxt-answer ${actif ? "nxt-answer--active" : ""}`}
                                    onClick={() => choisirReponse(prop.id_proposition)}
                                >
                                    <span className="nxt-answer__letter">{prop.lettre}</span>
                                    <span className="nxt-answer__text">{prop.libelle}</span>
                                    {actif && <span className="nxt-answer__check">✓</span>}
                                </button>
                            );
                        })}
                    </div>

                </div>


                {/* NAVIGATION */}
                <div className="nxt-nav">
                    <button
                        type="button"
                        className="nxt-btn nxt-btn--secondary"
                        onClick={precedent}
                        disabled={index === 0 || animPhase !== "idle"}
                    >
                        <ArrowLeft size={16} />
                        <span>Précédent</span>
                    </button>

                    <button
                        type="button"
                        className="nxt-btn nxt-btn--primary"
                        onClick={suivant}
                        disabled={analyseEnCours || animPhase !== "idle"}
                    >
                        {index === total - 1 ? (
                            <><BarChart2 size={16} /> Voir mes résultats</>
                        ) : (
                            <>Suivant <ArrowRight size={16} /></>
                        )}
                    </button>
                </div>

            </main>

        </div>
    );

}


export default Test;
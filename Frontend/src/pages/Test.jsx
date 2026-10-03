import { useEffect, useState, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, Compass, BarChart2, Home } from "lucide-react";

import {
    getQuestions,
    getPropositions,
    envoyerReponses
} from "../services/api";

import "../styles/Test.css";

import { enregistrerAction } from "../services/historiqueService";


/* =====================================================================
   MESSAGES D'ENCOURAGEMENT  (affichés après validation "Suivant")
===================================================================== */

const ENCOURAGEMENTS = [
    { icon: "⚡", texte: "Super ! Continue comme ça 🚀" },
    { icon: "⭐", texte: "Tu avances très bien !" },
    { icon: "💙", texte: "Chaque réponse te rapproche de ton profil !" },
    { icon: "✨", texte: "Bonne réponse enregistrée !" },
    { icon: "🔥", texte: "Parfait ! Continue !" },
    { icon: "💪", texte: "Tu gères vraiment bien !" },
];

/* Jalons : déclenchés uniquement lors du clic Suivant, jamais à l'affichage */
const MILESTONES = [
    { seuil: 25, texte: "25 % accompli — bon départ !", icon: "⚡" },
    { seuil: 50, texte: "Mi-chemin atteint ! Tu assures 💪", icon: "⭐" },
    { seuil: 75, texte: "Presque fini, continue !", icon: "✨" },
];
/* Le seuil 100 est géré séparément dans soumettre() */


function Test() {

    const [questions, setQuestions] = useState([]);
    const [propositions, setPropositions] = useState([]);
    const [index, setIndex] = useState(0);
    const [reponses, setReponses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [analyseEnCours, setAnalyseEnCours] = useState(false);
    const [etapeAnalyse, setEtapeAnalyse] = useState(1);
    const [notification, setNotification] = useState(null);
    const [notifVisible, setNotifVisible] = useState(false);
    const [finMessage, setFinMessage] = useState(false); // popup 100% avant analyse

    /* "idle" | "out" | "idle-pending" | "in" */
    const [animPhase, setAnimPhase] = useState("idle");

    const milestoneRef = useRef(new Set());
    const notifTimer = useRef(null);
    const pendingNotifRef = useRef(null); // notif à afficher APRÈS la transition
    const navigate = useNavigate();


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
       Déclenché par changement d'index.
       Après chargement → phase "in" + affiche la notif en attente.
    ========================= */

    useEffect(() => {
        if (!questions.length) return;
        if (animPhase === "out") return; // on attend la fin de l'anim out

        getPropositions(questions[index].id_question)
            .then((data) => {
                setPropositions(data);

                // Passer en phase "in" (entrée animée)
                if (animPhase === "idle-pending") {
                    setAnimPhase("in");
                    setTimeout(() => {
                        setAnimPhase("idle");

                        // Afficher la notif EN ATTENTE maintenant que la nouvelle question est là
                        if (pendingNotifRef.current) {
                            afficherNotif(pendingNotifRef.current);
                            pendingNotifRef.current = null;
                        }
                    }, 300);
                }
            })
            .catch(console.error);

        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [index, questions]);


    /* =========================
       NOTIFICATION
    ========================= */

    const afficherNotif = useCallback((notif) => {
        if (notifTimer.current) clearTimeout(notifTimer.current);
        setNotification(notif);
        setNotifVisible(true);
        notifTimer.current = setTimeout(() => setNotifVisible(false), 2600);
    }, []);


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
       MESSAGE DE FIN (🎉 100%)
       Affiché brièvement avant l'écran d'analyse
    ========================= */

    if (finMessage) {
        return (
            <div className="nxt-test nxt-test--center">
                <div className="nxt-card-fin">
                    <div className="nxt-card-fin__emoji">🎉</div>
                    <h2>Félicitations !</h2>
                    <p>Tu as répondu à toutes les questions.<br />Analyse de ton profil en cours…</p>
                    <div className="nxt-spinner nxt-spinner--gold"></div>
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
                    <h1>Analyse de tes réponses…</h1>
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


    /* =========================
       DONNÉES DE LA QUESTION EN COURS
    ========================= */

    const question = questions[index];
    const total = questions.length;

    /* Progression = réponses validées / total (commence à 0%) */
    const nbRepondues = reponses.filter(Boolean).length;
    const progression = Math.round((nbRepondues / total) * 100);

    const reponseActuelle = reponses[index]?.id_proposition ?? null;


    /* =========================
       CHOISIR UNE RÉPONSE
       — PAS de notification ici, seulement à la validation (Suivant)
    ========================= */

    function choisirReponse(idProposition) {
        const nouvellesReponses = [...reponses];
        nouvellesReponses[index] = {
            id_question: question.id_question,
            id_proposition: idProposition
        };
        setReponses(nouvellesReponses);
    }


    /* =========================
       NAVIGATION ANIMÉE
       out (220ms) → changer index → in
       La notif est stockée et affichée APRÈS la transition
    ========================= */

    function naviguer(nouvelIndex, notifApres) {
        // Stocker la notif à afficher après la transition
        pendingNotifRef.current = notifApres ?? null;

        // 1. Sortie animée + vider les propositions (pas de flash)
        setAnimPhase("out");
        setPropositions([]);

        setTimeout(() => {
            setIndex(nouvelIndex);
            setAnimPhase("idle-pending");
        }, 220);
    }


    /* =========================
       VÉRIFIER LES JALONS
       Renvoie la notif milestone si franchie, sinon un encouragement
    ========================= */

    function choisirNotifSuivant(nbReponduesApres) {
        const prog = Math.round((nbReponduesApres / total) * 100);

        for (const m of MILESTONES) {
            if (prog >= m.seuil && !milestoneRef.current.has(m.seuil)) {
                milestoneRef.current.add(m.seuil);
                return m;
            }
        }

        // Pas de milestone → encouragement aléatoire
        return ENCOURAGEMENTS[Math.floor(Math.random() * ENCOURAGEMENTS.length)];
    }


    /* =========================
       SUIVANT
    ========================= */

    function suivant() {
        if (reponseActuelle === null) {
            afficherNotif({ icon: "👆", texte: "Sélectionne une réponse avant de continuer !" });
            return;
        }

        // Nombre de réponses après validation de cette question
        const nbApres = nbRepondues + (reponses[index] ? 0 : 1);

        if (index < total - 1) {
            // Choisir la notification à afficher après la transition
            const notif = choisirNotifSuivant(nbApres);
            naviguer(index + 1, notif);
        } else {
            // Dernière question → afficher le message de fin puis analyser
            soumettre();
        }
    }

    function precedent() {
        if (index > 0) naviguer(index - 1, null);
    }


    /* =========================
       SOUMISSION FINALE
       1. Affiche brièvement le message 🎉
       2. Lance l'analyse
    ========================= */

    function soumettre() {
        // Afficher l'écran de félicitations 1,5 s
        setFinMessage(true);

        const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

        (async () => {
            try {
                // Lancer l'appel API en parallèle
                const apiPromise = envoyerReponses(reponses);

                // Attendre 1,5s pour que l'utilisateur voit le message 🎉
                await sleep(1500);

                // Basculer vers l'écran d'analyse
                setFinMessage(false);
                setAnalyseEnCours(true);
                setEtapeAnalyse(1);

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
                setFinMessage(false);
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
            animPhase === "in" ? "nxt-anim--in" : "";


    return (
        <div className="nxt-test">

            {/* ---- NOTIFICATION FLOTTANTE ---- */}
            <div className={`nxt-notif ${notifVisible ? "nxt-notif--visible" : ""}`}>
                {notification && (
                    <>
                        <span className="nxt-notif__icon">{notification.icon}</span>
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


            {/* ---- BARRE DE PROGRESSION (basée sur réponses validées) ---- */}
            <div className="nxt-progress-bar">
                <div className="nxt-progress-bar__fill" style={{ width: `${progression}%` }} />
            </div>


            {/* ---- CORPS PRINCIPAL ---- */}
            <main className="nxt-main">

                {/* Zone animée */}
                <div className={`nxt-content ${animClass}`}>

                    {/* QUESTION */}
                    <div className="nxt-question">

                        <div className="nxt-question__meta">
                            {/* Compteur : Q. 3 / 20 */}
                            <div className="nxt-question__counter">
                                <span className="nxt-question__counter-label">Question.</span>
                                <span className="nxt-question__counter-num">{index + 1}</span>
                                <span className="nxt-question__counter-sep">/</span>
                                <span className="nxt-question__counter-tot">{total}</span>
                            </div>

                            {/* Progression */}
                            <span className="nxt-question__pct">{progression}%</span>
                        </div>

                        <h2 className="nxt-question__text">{question.texte}</h2>
                    </div>


                    {/* RÉPONSES */}
                    <div className="nxt-answers">
                        {propositions.map((prop) => {
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
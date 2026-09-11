import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { X, ArrowLeft, ArrowRight, Home, Compass } from "lucide-react";

import {
    getQuestions,
    getPropositions,
    envoyerReponses
} from "../services/api";

import "../styles/Test.css";

import { enregistrerAction } from "../services/historiqueService";


function Test() {

    const [questions, setQuestions] = useState([]);
    const [propositions, setPropositions] = useState([]);
    const [index, setIndex] = useState(0);
    const [reponses, setReponses] = useState([]);
    const [choix, setChoix] = useState(null);
    const [loading, setLoading] = useState(true);
    const [afficherInformation, setAfficherInformation] = useState(true);

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
       RÉCUPÉRATION DES RÉPONSES
    ========================= */

    useEffect(() => {

        if (questions.length > 0) {

            getPropositions(
                questions[index].id_question
            )
                .then((data) => {

                    setPropositions(data);

                })
                .catch((error) => {

                    console.error(error);

                });

        }

    }, [index, questions]);


    /* =========================
       ÉTAT DE CHARGEMENT
    ========================= */

    if (loading) {

        return (
            <div className="nextori-test-page nextori-test-loading">

                <div className="nextori-test-loading-card">

                    <div className="nextori-test-loading-spinner"></div>

                    <p>
                        Préparation de ton test...
                    </p>

                </div>

            </div>
        );

    }


    if (!questions.length) {

        return (
            <div className="nextori-test-page nextori-test-empty">

                <div className="nextori-test-empty-card">

                    <Compass size={40} />

                    <h2>
                        Le test n'est pas disponible
                    </h2>

                    <p>
                        Impossible de charger les questions pour le moment.
                    </p>

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


    const question = questions[index];

    const progression = Math.round(
        ((index + 1) / questions.length) * 100
    );


    /* =========================
       CHOIX D'UNE RÉPONSE
    ========================= */

    function choisirReponse(idProposition) {

        setChoix(idProposition);

        const nouvellesReponses = [...reponses];

        nouvellesReponses[index] = {
            id_question: question.id_question,
            id_proposition: idProposition
        };

        setReponses(nouvellesReponses);

    }


    /* =========================
       QUESTION SUIVANTE
    ========================= */

    function suivant() {

        if (choix === null) {

            alert("Veuillez choisir une réponse.");

            return;

        }


        if (index < questions.length - 1) {

            setIndex(index + 1);

            const prochaineReponse = reponses[index + 1];

            setChoix(
                prochaineReponse
                    ? prochaineReponse.id_proposition
                    : null
            );

        } else {

            envoyerReponses(reponses)

                .then(async (resultat) => {

                    await enregistrerAction(
                        "METIERS_CONSULTES"
                    );

                    navigate("/result", {
                        state: {
                            data: resultat
                        }
                    });

                })

                .catch((error) => {

                    console.error(error);

                    alert("Erreur lors du calcul.");

                });

        }

    }


    /* =========================
       QUESTION PRÉCÉDENTE
    ========================= */

    function precedent() {

        if (index > 0) {

            const nouvelIndex = index - 1;

            setIndex(nouvelIndex);

            const ancienneReponse =
                reponses[nouvelIndex];

            setChoix(
                ancienneReponse
                    ? ancienneReponse.id_proposition
                    : null
            );

        }

    }


    return (

        <div className="nextori-test-page">

            {/* =========================
                HEADER
            ========================= */}

            <header className="nextori-test-header">

                <div className="nextori-test-header-left">

                    <button
                        type="button"
                        className="nextori-test-home-link"
                        onClick={() => navigate("/dashboard")}
                    >
                        <ArrowLeft size={17} />

                        <span>
                            Retour à l'accueil
                        </span>
                    </button>

                </div>


                <div className="nextori-test-brand">

                    <div className="nextori-test-brand-mark">
                        <Compass size={20} />
                    </div>

                    <div>

                        <strong>
                            NextOri
                        </strong>

                        <span>
                            Orientation
                        </span>

                    </div>

                </div>


                <div className="nextori-test-header-right">

                    <span>
                        Test RIASEC
                    </span>

                </div>

            </header>


            {/* =========================
                CONTENU PRINCIPAL
            ========================= */}

            <main className="nextori-test-main">


                {/* INTRODUCTION COMPACTE */}

                <section className="nextori-test-intro">

                    <div className="nextori-test-intro-icon">
                        <Compass size={23} />
                    </div>

                    <div className="nextori-test-intro-content">

                        <span className="nextori-test-eyebrow">
                            TON ORIENTATION
                        </span>

                        <h1>
                            Découvre ton profil professionnel
                        </h1>

                        <p>
                            Réponds spontanément aux questions pour
                            découvrir les domaines et métiers qui
                            correspondent le mieux à tes intérêts.
                        </p>

                    </div>

                </section>


                {/* =========================
                    INFORMATION
                ========================= */}

                {afficherInformation && (

                    <div className="nextori-test-information">

                        <div className="nextori-test-information-icon">
                            ✓
                        </div>

                        <div className="nextori-test-information-content">

                            <strong>
                                Réponds naturellement
                            </strong>

                            <span>
                                Il n'y a pas de bonne ou de mauvaise réponse.
                                Choisis simplement ce qui te correspond le mieux.
                            </span>

                        </div>

                        <button
                            type="button"
                            className="nextori-test-information-close"
                            onClick={() =>
                                setAfficherInformation(false)
                            }
                            aria-label="Fermer l'information"
                        >
                            <X size={17} />
                        </button>

                    </div>

                )}


                {/* =========================
                    PROGRESSION
                ========================= */}

                <section className="nextori-test-progress">

                    <div className="nextori-test-progress-top">

                        <div>

                            <span className="nextori-test-progress-label">
                                Question
                            </span>

                            <strong>
                                {index + 1}
                            </strong>

                            <span>
                                / {questions.length}
                            </span>

                        </div>

                        <strong className="nextori-test-progress-percent">
                            {progression}%
                        </strong>

                    </div>


                    <div className="nextori-test-progress-track">

                        <div
                            className="nextori-test-progress-fill"
                            style={{
                                width: `${progression}%`
                            }}
                        />

                    </div>

                </section>


                {/* =========================
                    QUESTION
                ========================= */}

                <section className="nextori-test-question-card">

                    <div className="nextori-test-question-number">

                        {String(index + 1).padStart(2, "0")}

                    </div>

                    <div className="nextori-test-question-content">

                        <span className="nextori-test-question-label">
                            QUESTION {index + 1}
                        </span>

                        <h2>
                            {question.texte}
                        </h2>

                        <p className="nextori-test-question-helper">
                            Sélectionne la réponse qui te ressemble le plus.
                        </p>

                    </div>

                </section>


                {/* =========================
                    RÉPONSES
                ========================= */}

                <section className="nextori-test-answers">

                    {propositions.map((proposition) => {

                        const estActive =
                            reponses[index]?.id_proposition ===
                            proposition.id_proposition;

                        return (

                            <button
                                key={proposition.id_proposition}
                                type="button"
                                className={`nextori-test-answer ${
                                    estActive
                                        ? "nextori-test-answer-active"
                                        : ""
                                }`}
                                onClick={() =>
                                    choisirReponse(
                                        proposition.id_proposition
                                    )
                                }
                            >

                                <span className="nextori-test-answer-letter">
                                    {proposition.lettre}
                                </span>

                                <span className="nextori-test-answer-text">
                                    {proposition.libelle}
                                </span>

                                <span className="nextori-test-answer-check">
                                    ✓
                                </span>

                            </button>

                        );

                    })}

                </section>


                {/* =========================
                    NAVIGATION
                ========================= */}

                <div className="nextori-test-navigation">

                    <button
                        type="button"
                        className="nextori-test-previous"
                        onClick={precedent}
                        disabled={index === 0}
                    >

                        <ArrowLeft size={17} />

                        <span>
                            Précédent
                        </span>

                    </button>


                    <span className="nextori-test-navigation-status">

                        {index + 1} / {questions.length}

                    </span>


                    <button
                        type="button"
                        className="nextori-test-next"
                        onClick={suivant}
                    >

                        <span>
                            {index === questions.length - 1
                                ? "Voir mes résultats"
                                : "Question suivante"}
                        </span>

                        <ArrowRight size={18} />

                    </button>

                </div>

            </main>

        </div>

    );

}


export default Test;
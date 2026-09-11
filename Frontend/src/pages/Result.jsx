import { API_ROUTES_URL } from "../config/api";
import Confetti from "react-confetti";
import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "../styles/Result.css";
import { enregistrerAction } from "../services/historiqueService";

import {
    FaTrophy,
    FaChartBar,
    FaFolderOpen,
    FaGraduationCap,
    FaMoneyBillWave,
    FaHome,
    FaRedo,
    FaArrowRight,
    FaFileAlt,
    FaStar,
    FaCheckCircle,
    FaCompass,
    FaLightbulb,
    FaBullseye,
    FaSearch,
    FaUniversity
} from "react-icons/fa";


function Result(){

    /* =========================================================
       ETAT CONFETTIS
    ========================================================= */

    const [showConfetti, setShowConfetti] = useState(true);

    useEffect(() => {

        const timer = setTimeout(() => {
            setShowConfetti(false);
        }, 4000);

        return () => clearTimeout(timer);

    }, []);


    /* =========================================================
       NAVIGATION
    ========================================================= */

    const location = useLocation();
    const navigate = useNavigate();


    /* =========================================================
       RECUPERATION DU RESULTAT
    ========================================================= */

    const resultatInitial =
        location.state?.data?.data ??
        location.state?.data;


    console.log("STATE RESULT :", location.state);
    console.log("DATA RESULT :", resultatInitial);


    const [resultat, setResultat] = useState(resultatInitial);
    const [chargement, setChargement] = useState(!resultatInitial);


    /* =========================================================
       RECUPERATION DU RESULTAT DEPUIS L'API
    ========================================================= */

    useEffect(() => {

        if (!resultat) {

            setChargement(true);

            fetch(
                `${API_ROUTES_URL}/resultats.php`,
                {
                    credentials: "include"
                }
            )
            .then(async response => {

                const data = await response.json();

                if (response.status === 401) {

                    localStorage.removeItem("utilisateur");

                    navigate("/connexion", {
                        replace: true
                    });

                    return null;
                }

                return data;
            })
            .then(data => {

                if (!data) return;

                if (data.success) {
                    setResultat(data.data);
                }

                setChargement(false);

            })
            .catch(error => {

                console.error(
                    "Erreur récupération résultat :",
                    error
                );

                setChargement(false);

            });

        }

    }, [resultat, navigate]);


    /* =========================================================
       COMPATIBILITE METIER
    ========================================================= */

    function afficherCompatibilite(score){

        const pourcentage =
            Math.round((score / 8) * 95);

        let badge = "";
        let couleur = "";

        if(pourcentage >= 85){

            badge = "Très compatible";
            couleur = "#0D1B2A";

        } else if(pourcentage >= 55){

            badge = "Compatible";
            couleur = "#1E3A8A";

        } else {

            badge = "À explorer";
            couleur = "#98A2B3";
        }

        return {
            pourcentage,
            badge,
            couleur
        };
    }


    /* =========================================================
       PROFILS RIASEC
    ========================================================= */

    const profils = {

        RI: {
            nom: "Réaliste - Investigateur",
            description:
                "Vous aimez comprendre comment les choses fonctionnent, résoudre des problèmes et travailler sur des activités concrètes qui demandent de la réflexion."
        },

        RA: {
            nom: "Réaliste - Artistique",
            description:
                "Vous combinez votre goût pour les activités concrètes avec votre créativité et votre capacité à imaginer de nouvelles solutions."
        },

        RS: {
            nom: "Réaliste - Social",
            description:
                "Vous appréciez les activités pratiques tout en accordant une importance particulière à l'aide, à l'accompagnement et au contact avec les autres."
        },

        RE: {
            nom: "Réaliste - Entreprenant",
            description:
                "Vous aimez agir concrètement, prendre des initiatives et transformer vos idées en résultats."
        },

        RC: {
            nom: "Réaliste - Conventionnel",
            description:
                "Vous appréciez les activités pratiques, structurées et organisées qui demandent de la précision."
        },

        IR: {
            nom: "Investigateur - Réaliste",
            description:
                "Vous aimez analyser les problèmes tout en recherchant des solutions concrètes et applicables."
        },

        IA: {
            nom: "Investigateur - Artistique",
            description:
                "Vous combinez curiosité intellectuelle, réflexion approfondie et créativité."
        },

        IS: {
            nom: "Investigateur - Social",
            description:
                "Vous aimez comprendre, analyser et utiliser vos connaissances pour aider ou accompagner les autres."
        },

        IE: {
            nom: "Investigateur - Entreprenant",
            description:
                "Vous aimez analyser les situations, développer des stratégies et prendre des décisions."
        },

        IC: {
            nom: "Investigateur - Conventionnel",
            description:
                "Vous appréciez l'analyse, la logique, la précision et les environnements structurés."
        },

        AR: {
            nom: "Artistique - Réaliste",
            description:
                "Vous combinez créativité et capacité à concrétiser vos idées."
        },

        AI: {
            nom: "Artistique - Investigateur",
            description:
                "Vous aimez créer, explorer de nouvelles idées et comprendre les phénomènes qui vous entourent."
        },

        AS: {
            nom: "Artistique - Social",
            description:
                "Vous êtes attiré par les activités créatives qui permettent également d'exprimer votre sensibilité et de contribuer aux autres."
        },

        AE: {
            nom: "Artistique - Entreprenant",
            description:
                "Vous aimez créer, convaincre et transformer vos idées en projets."
        },

        AC: {
            nom: "Artistique - Conventionnel",
            description:
                "Vous combinez créativité, organisation et souci du détail."
        },

        SR: {
            nom: "Social - Réaliste",
            description:
                "Vous aimez aider les autres tout en privilégiant les activités concrètes et pratiques."
        },

        SI: {
            nom: "Social - Investigateur",
            description:
                "Vous êtes attiré par la compréhension des personnes et par les activités permettant d'apporter des solutions."
        },

        SA: {
            nom: "Social - Artistique",
            description:
                "Vous combinez empathie, créativité et intérêt pour les relations humaines."
        },

        SE: {
            nom: "Social - Entreprenant",
            description:
                "Vous aimez travailler avec les autres, prendre des responsabilités et mobiliser les personnes autour d'un objectif."
        },

        SC: {
            nom: "Social - Conventionnel",
            description:
                "Vous appréciez les environnements organisés dans lesquels vous pouvez accompagner et aider les autres."
        },

        ER: {
            nom: "Entreprenant - Réaliste",
            description:
                "Vous aimez prendre des initiatives et obtenir des résultats concrets."
        },

        EI: {
            nom: "Entreprenant - Investigateur",
            description:
                "Vous combinez esprit d'initiative, analyse et capacité à prendre des décisions."
        },

        EA: {
            nom: "Entreprenant - Artistique",
            description:
                "Vous aimez entreprendre, convaincre et exprimer votre créativité."
        },

        ES: {
            nom: "Entreprenant - Social",
            description:
                "Vous aimez diriger, communiquer et travailler avec les autres pour atteindre des objectifs."
        },

        EC: {
            nom: "Entreprenant - Conventionnel",
            description:
                "Vous appréciez la prise de décision, l'organisation et les environnements structurés."
        },

        CR: {
            nom: "Conventionnel - Réaliste",
            description:
                "Vous aimez travailler avec précision dans des activités concrètes et structurées."
        },

        CI: {
            nom: "Conventionnel - Investigateur",
            description:
                "Vous appréciez la logique, l'analyse et les environnements nécessitant rigueur et organisation."
        },

        CA: {
            nom: "Conventionnel - Artistique",
            description:
                "Vous combinez organisation, précision et créativité."
        },

        CS: {
            nom: "Conventionnel - Social",
            description:
                "Vous aimez les environnements organisés dans lesquels vous pouvez aider et accompagner les autres."
        },

        CE: {
            nom: "Conventionnel - Entreprenant",
            description:
                "Vous combinez organisation, rigueur et capacité à prendre des initiatives."
        }

    };


    /* =========================================================
       ACTIONS
    ========================================================= */

    const consulterProfil = async () => {

        await enregistrerAction("PROFIL_CONSULTE");

        navigate("/profil-riasec", {
            state: {
                resultat: resultat
            }
        });

    };


    const consulterFormation = async (
        metier,
        resultatActuel
    ) => {

        await enregistrerAction(
            `METIER_CONSULTE: ${metier.nom}`
        );

        await enregistrerAction(
            "FORMATION_CONSULTEE"
        );

        navigate("/formations", {
            state: {
                metier: metier,
                resultat: resultatActuel
            }
        });

    };


    /* =========================================================
       SALAIRE
    ========================================================= */

    function afficherSalaire(min, max){

        return `${Number(min).toLocaleString()} FCFA - ${Number(max).toLocaleString()} FCFA`;

    }


    /* =========================================================
       CHARGEMENT
    ========================================================= */

    if (chargement) {

        return (

            <div className="result-v1-loading-page">

                <div className="result-v1-loading-card">

                    <div className="result-v1-loading-icon">
                        <FaChartBar />
                    </div>

                    <h1>
                        Analyse de votre profil...
                    </h1>

                    <p>
                        NextOri prépare votre restitution
                        d'orientation personnalisée.
                    </p>

                    <div className="result-v1-loading-line">
                        <span></span>
                    </div>

                </div>

            </div>

        );

    }


    /* =========================================================
       AUCUN RESULTAT
    ========================================================= */

    if(!resultat){

        return (

            <div className="result-v1-empty-page">

                <div className="result-v1-empty-card">

                    <div className="result-v1-empty-icon">
                        <FaCompass />
                    </div>

                    <h1>
                        Aucun résultat disponible
                    </h1>

                    <p>
                        Vous n'avez pas encore effectué
                        votre test d'orientation.
                    </p>

                    <button
                        className="result-v1-start-test-button"
                        onClick={() => navigate("/test")}
                    >
                        <FaRedo />
                        Faire le test
                        <FaArrowRight />
                    </button>

                </div>

            </div>

        );

    }


    /* =========================================================
       INFORMATIONS DU PROFIL
    ========================================================= */

    const profil = resultat.profil;

    const profilInfo =
        profils[profil.principal] || {

            nom: "Profil RIASEC",

            description:
                "Votre profil professionnel a été identifié selon vos réponses."

        };


    const principaux =
        resultat.recommandations?.principaux || [];

    const secondaires =
        resultat.recommandations?.secondaires || [];


    /* =========================================================
       RENDU
    ========================================================= */

    return (

        <div className="result-v1-page">

            {/* =================================================
                CONFETTIS
            ================================================= */}

            {showConfetti && (

                <Confetti
                    numberOfPieces={250}
                    recycle={false}
                    colors={[
                        "#0D1B2A",
                        "#F4B400",
                        "#1E3A8A",
                        "#F2F4F7"
                    ]}
                />

            )}


            {/* =================================================
                HERO
            ================================================= */}

            <header className="result-v1-hero">

                <div className="result-v1-hero-content">

                    <div className="result-v1-success-badge">
                        <FaCheckCircle />
                        Analyse terminée
                    </div>

                    <p className="result-v1-eyebrow">
                        VOTRE RESTITUTION NEXTORI
                    </p>

                    <h1>
                        Votre avenir commence
                        par une meilleure
                        compréhension de vous-même.
                    </h1>

                    <p className="result-v1-hero-description">

                        Nous avons analysé vos réponses afin
                        d'identifier vos principales tendances
                        professionnelles et de vous proposer
                        des pistes de carrière adaptées à votre profil.

                    </p>

                    <div className="result-v1-analysis-steps">

                        <div className="result-v1-analysis-step">

                            <span>
                                <FaCheckCircle />
                            </span>

                            <div>
                                <strong>
                                    Réponses analysées
                                </strong>

                                <small>
                                    Votre questionnaire a été étudié.
                                </small>
                            </div>

                        </div>


                        <div className="result-v1-analysis-step">

                            <span>
                                <FaCheckCircle />
                            </span>

                            <div>
                                <strong>
                                    Profil RIASEC identifié
                                </strong>

                                <small>
                                    Vos principales tendances ont été déterminées.
                                </small>
                            </div>

                        </div>


                        <div className="result-v1-analysis-step">

                            <span>
                                <FaCheckCircle />
                            </span>

                            <div>
                                <strong>
                                    Métiers sélectionnés
                                </strong>

                                <small>
                                    Les pistes les plus pertinentes ont été recherchées.
                                </small>
                            </div>

                        </div>

                    </div>

                </div>

            </header>


            <main className="result-v1-main">


                {/* =================================================
                    INTRODUCTION
                ================================================= */}

                <section className="result-v1-introduction">

                    <div className="result-v1-section-icon">
                        <FaLightbulb />
                    </div>

                    <div>

                        <span className="result-v1-section-kicker">
                            VOTRE ANALYSE
                        </span>

                        <h2>
                            Nous avons commencé à comprendre
                            ce qui peut vous correspondre.
                        </h2>

                        <p>

                            Votre résultat ne se limite pas à une lettre.
                            Il constitue un point de départ pour mieux
                            comprendre vos centres d'intérêt, vos préférences
                            professionnelles et les environnements dans lesquels
                            vous pourriez vous épanouir.

                        </p>

                    </div>

                </section>


                {/* =================================================
                    PROFIL RIASEC
                ================================================= */}

                <section className="result-v1-profile-result result-v1-premium-result-card">

                    <div className="result-v1-profile-result-top">

                        <div className="result-v1-profile-result-label">
                            <FaCompass />
                            Votre profil professionnel
                        </div>

                        <span className="result-v1-profile-result-number">
                            01
                        </span>

                    </div>


                    <div className="result-v1-profile-result-content">

                        <div className="result-v1-profile-code-wrapper">

                            <span className="result-v1-profile-code-label">
                                PROFIL
                            </span>

                            <div className="result-v1-profile-code">
                                {profil.principal}
                            </div>

                        </div>


                        <div className="result-v1-profile-result-text">

                            <span className="result-v1-profile-introduction">
                                Votre profil dominant
                            </span>

                            <h2>
                                {profilInfo.nom}
                            </h2>

                            <p className="result-v1-profile-description">
                                {profilInfo.description}
                            </p>

                            <p className="result-v1-profile-explication">

                                Ce profil a été déterminé à partir
                                de vos réponses au questionnaire RIASEC.
                                Il permet de mettre en évidence les types
                                d'activités et d'environnements professionnels
                                qui correspondent le mieux à vos préférences.

                            </p>

                            <button
                                className="result-v1-profile-button"
                                onClick={consulterProfil}
                            >
                                Comprendre mon profil
                                <FaArrowRight />
                            </button>

                        </div>

                    </div>

                </section>


                {/* =================================================
                    SCORES
                ================================================= */}

                <section className="result-v1-scores-section result-v1-premium-result-card">

                    <div className="result-v1-section-heading">

                        <div>

                            <span className="result-v1-section-kicker">
                                02 · VOTRE PROFIL EN CHIFFRES
                            </span>

                            <h2>
                                Ce que vos réponses révèlent
                            </h2>

                            <p>
                                Voici la répartition de vos préférences
                                selon les six dimensions du modèle RIASEC.
                            </p>

                        </div>

                        <div className="result-v1-section-heading-icon">
                            <FaChartBar />
                        </div>

                    </div>


                    <div className="result-v1-scores-list">

                        {
                            Object.entries(profil.scores)
                                .sort(
                                    ([, scoreA], [, scoreB]) =>
                                        scoreB - scoreA
                                )
                                .map(
                                    ([lettre, score]) => {

                                        const pourcentage =
                                            Math.round(
                                                (Number(score) / 10) * 100
                                            );

                                        return (

                                            <div
                                                className="result-v1-score-item"
                                                key={lettre}
                                            >

                                                <div className="result-v1-score-header">

                                                    <div className="result-v1-score-letter">
                                                        {lettre}
                                                    </div>

                                                    <strong>
                                                        {pourcentage}%
                                                    </strong>

                                                </div>

                                                <div className="result-v1-score-bar">

                                                    <div
                                                        className="result-v1-score-progress"
                                                        style={{
                                                            width:
                                                                `${pourcentage}%`
                                                        }}
                                                    />

                                                </div>

                                            </div>

                                        );

                                    }
                                )
                        }

                    </div>


                    <div className="result-v1-scores-conclusion">

                        <FaBullseye />

                        <p>

                            Vos tendances les plus fortes permettent
                            à NextOri d'affiner les recommandations
                            professionnelles présentées ci-dessous.

                        </p>

                    </div>

                </section>


                {/* =================================================
                    EXPLICATION DE L'ANALYSE
                ================================================= */}

                <section className="result-v1-analysis-explanation">

                    <div className="result-v1-analysis-explanation-icon">
                        <FaSearch />
                    </div>

                    <div>

                        <span className="result-v1-section-kicker">
                            COMMENT LIRE VOTRE RÉSULTAT ?
                        </span>

                        <h2>
                            Votre profil devient maintenant
                            une direction.
                        </h2>

                        <p>

                            Nous avons croisé votre profil avec les
                            caractéristiques des métiers disponibles
                            dans NextOri afin d'identifier les pistes
                            présentant la meilleure correspondance.

                        </p>

                    </div>

                </section>


                {/* =================================================
                    METIERS
                ================================================= */}

                <section className="result-v1-jobs-section">


                    <div className="result-v1-jobs-section-header">

                        <div>

                            <span className="result-v1-section-kicker">
                                03 · VOS OPPORTUNITÉS
                            </span>

                            <h2>
                                Les métiers qui vous correspondent
                                le mieux
                            </h2>

                            <p>

                                À partir de votre profil, nous avons
                                sélectionné les carrières qui présentent
                                les meilleures correspondances.

                            </p>

                        </div>

                        <div className="result-v1-jobs-section-icon">
                            <FaTrophy />
                        </div>

                    </div>


                    {/* =================================================
                        METIERS PRINCIPAUX
                    ================================================= */}

                    <div className="result-v1-recommendation-category">

                        <div className="result-v1-category-title-wrapper">

                            <div className="result-v1-category-title-icon">
                                <FaTrophy />
                            </div>

                            <div>

                                <span>
                                    PRIORITÉ
                                </span>

                                <h3>
                                    Vos recommandations principales
                                </h3>

                                <p>
                                    Les pistes présentant la plus forte
                                    compatibilité avec votre profil.
                                </p>

                            </div>

                        </div>


                        <div className="result-v1-jobs-list">

                            {

                                principaux.map((metier, index) => {

                                    const compatibilite =
                                        afficherCompatibilite(
                                            metier.score_compatibilite
                                        );

                                    return (

                                        <article
                                            className="result-v1-job-card result-v1-premium-job-card"
                                            key={metier.id_metier}
                                        >

                                            <div className="result-v1-job-rank">
                                                0{index + 1}
                                            </div>


                                            <div className="result-v1-job-header">

                                                <div className="result-v1-job-title-area">

                                                    <span className="result-v1-job-recommendation-label">
                                                        MÉTIER RECOMMANDÉ
                                                    </span>

                                                    <h3>
                                                        {metier.nom}
                                                    </h3>

                                                </div>


                                                <div
                                                    className="result-v1-compatibilite"
                                                    style={{
                                                        backgroundColor:
                                                            compatibilite.couleur
                                                    }}
                                                >

                                                    <span>
                                                        {compatibilite.badge}
                                                    </span>

                                                    <strong>
                                                        {compatibilite.pourcentage}%
                                                    </strong>

                                                </div>

                                            </div>


                                            <div className="result-v1-job-description-box">

                                                <FaFileAlt />

                                                <p>
                                                    {metier.description}
                                                </p>

                                            </div>


                                            <div className="result-v1-job-information">

                                                <p>

                                                    <FaFolderOpen />

                                                    <strong>
                                                        Secteur :
                                                    </strong>

                                                    <span>
                                                        {metier.secteur}
                                                    </span>

                                                </p>


                                                <p>

                                                    <FaGraduationCap />

                                                    <strong>
                                                        Niveau d'étude :
                                                    </strong>

                                                    <span>
                                                        {metier.niveau_etude}
                                                    </span>

                                                </p>


                                                <p>

                                                    <FaMoneyBillWave />

                                                    <strong>
                                                        Salaire :
                                                    </strong>

                                                    <span>
                                                        {afficherSalaire(
                                                            metier.salaire_min,
                                                            metier.salaire_max
                                                        )}
                                                    </span>

                                                </p>

                                            </div>


                                            <div className="result-v1-job-footer">

                                                <span>
                                                    Découvrez le parcours
                                                    pour accéder à ce métier.
                                                </span>

                                                <button
                                                    className="result-v1-job-button"
                                                    onClick={() =>
                                                        consulterFormation(
                                                            metier,
                                                            resultat
                                                        )
                                                    }
                                                >

                                                    Explorer cette carrière

                                                    <FaArrowRight />

                                                </button>

                                            </div>

                                        </article>

                                    );

                                })

                            }

                        </div>

                    </div>


                    {/* =================================================
                        METIERS SECONDAIRES
                    ================================================= */}

                    <div className="result-v1-recommendation-category result-v1-secondary-category">

                        <div className="result-v1-category-title-wrapper">

                            <div className="result-v1-category-title-icon">
                                <FaStar />
                            </div>

                            <div>

                                <span>
                                    À EXPLORER
                                </span>

                                <h3>
                                    D'autres pistes pourraient vous correspondre
                                </h3>

                                <p>
                                    Des alternatives intéressantes à considérer
                                    dans votre exploration professionnelle.
                                </p>

                            </div>

                        </div>


                        {

                            secondaires.length > 0 ? (

                                <div className="result-v1-jobs-list">

                                    {

                                        secondaires.map((metier) => {

                                            const compatibilite =
                                                afficherCompatibilite(
                                                    metier.score_compatibilite
                                                );

                                            return (

                                                <article
                                                    className="result-v1-job-card result-v1-secondary-card"
                                                    key={metier.id_metier}
                                                >

                                                    <div className="result-v1-job-header">

                                                        <div className="result-v1-job-title-area">

                                                            <span className="result-v1-job-recommendation-label">
                                                                PISTE À EXPLORER
                                                            </span>

                                                            <h3>
                                                                {metier.nom}
                                                            </h3>

                                                        </div>


                                                        <div
                                                            className="result-v1-compatibilite"
                                                            style={{
                                                                backgroundColor:
                                                                    compatibilite.couleur
                                                            }}
                                                        >

                                                            <span>
                                                                {compatibilite.badge}
                                                            </span>

                                                            <strong>
                                                                {compatibilite.pourcentage}%
                                                            </strong>

                                                        </div>

                                                    </div>


                                                    <div className="result-v1-job-description-box">

                                                        <FaFileAlt />

                                                        <p>
                                                            {metier.description}
                                                        </p>

                                                    </div>


                                                    <div className="result-v1-job-information">

                                                        <p>

                                                            <FaFolderOpen />

                                                            <strong>
                                                                Secteur :
                                                            </strong>

                                                            <span>
                                                                {metier.secteur}
                                                            </span>

                                                        </p>


                                                        <p>

                                                            <FaGraduationCap />

                                                            <strong>
                                                                Niveau d'étude :
                                                            </strong>

                                                            <span>
                                                                {metier.niveau_etude}
                                                            </span>

                                                        </p>


                                                        <p>

                                                            <FaMoneyBillWave />

                                                            <strong>
                                                                Salaire :
                                                            </strong>

                                                            <span>
                                                                {afficherSalaire(
                                                                    metier.salaire_min,
                                                                    metier.salaire_max
                                                                )}
                                                            </span>

                                                        </p>

                                                    </div>


                                                    <div className="result-v1-job-footer">

                                                        <span>
                                                            Cette piste mérite
                                                            également votre attention.
                                                        </span>

                                                        <button
                                                            className="result-v1-job-button"
                                                            onClick={() =>
                                                                consulterFormation(
                                                                    metier,
                                                                    resultat
                                                                )
                                                            }
                                                        >

                                                            Explorer cette carrière

                                                            <FaArrowRight />

                                                        </button>

                                                    </div>

                                                </article>

                                            );

                                        })

                                    }

                                </div>

                            ) : (

                                <div className="result-v1-no-secondary">

                                    <FaCompass />

                                    <h3>
                                        Continuons votre exploration
                                    </h3>

                                    <p>
                                        Aucun métier secondaire n'a été identifié
                                        pour votre profil.
                                    </p>

                                    <span>
                                        Les recommandations principales
                                        constituent vos meilleures pistes actuelles.
                                    </span>

                                </div>

                            )

                        }

                    </div>

                </section>


                {/* =================================================
                    TRANSITION VERS LES FORMATIONS
                ================================================= */}

                <section className="result-v1-next-step-section">

                    <div className="result-v1-next-step-content">

                        <div className="result-v1-next-step-number">
                            04
                        </div>

                        <div className="result-v1-next-step-icon">
                            <FaGraduationCap />
                        </div>

                        <span className="result-v1-section-kicker">
                            PROCHAINE ÉTAPE
                        </span>

                        <h2>
                            Un métier vous intéresse ?
                            Découvrez maintenant comment y accéder.
                        </h2>

                        <p>

                            Votre résultat vous donne une direction.
                            NextOri peut maintenant vous guider vers les
                            formations et les établissements qui peuvent
                            vous rapprocher des carrières qui vous intéressent.

                        </p>


                        <div className="result-v1-orientation-path">

                            <div className="result-v1-orientation-step">

                                <span>
                                    01
                                </span>

                                <FaBullseye />

                                <strong>
                                    Votre profil
                                </strong>

                            </div>


                            <FaArrowRight className="result-v1-orientation-arrow" />


                            <div className="result-v1-orientation-step">

                                <span>
                                    02
                                </span>

                                <FaBriefcaseIconFallback />

                                <strong>
                                    Votre métier
                                </strong>

                            </div>


                            <FaArrowRight className="result-v1-orientation-arrow" />


                            <div className="result-v1-orientation-step">

                                <span>
                                    03
                                </span>

                                <FaGraduationCap />

                                <strong>
                                    Votre formation
                                </strong>

                            </div>


                            <FaArrowRight className="result-v1-orientation-arrow" />


                            <div className="result-v1-orientation-step">

                                <span>
                                    04
                                </span>

                                <FaUniversity />

                                <strong>
                                    Votre établissement
                                </strong>

                            </div>

                        </div>

                    </div>

                </section>


                {/* =================================================
                    MESSAGE FINAL
                ================================================= */}

                <section className="result-v1-final-message">

                    <div className="result-v1-final-icon">
                        <FaCompass />
                    </div>

                    <span className="result-v1-section-kicker">
                        VOTRE PARCOURS NEXTORI
                    </span>

                    <h2>
                        Votre résultat est une première direction,
                        pas une destination.
                    </h2>

                    <p>

                        Prenez le temps d'explorer les métiers proposés,
                        de comprendre les formations nécessaires et de
                        comparer les établissements. Votre orientation
                        se construit étape par étape.

                    </p>

                </section>


                {/* =================================================
                    ACTIONS FINALES
                ================================================= */}

                <section className="result-v1-actions-section">

                    <div className="result-v1-actions-heading">

                        <span className="result-v1-section-kicker">
                            CONTINUEZ VOTRE EXPLORATION
                        </span>

                        <h2>
                            Que souhaitez-vous faire maintenant ?
                        </h2>

                    </div>


                    <div className="result-v1-actions">

                        <button
                            className="result-v1-retry-button"
                            onClick={() => navigate("/test")}
                        >

                            <FaRedo />

                            Refaire le test

                        </button>


                        <button
                            className="result-v1-home-button"
                            onClick={() => navigate("/dashboard")}
                        >

                            <FaHome />

                            Retour à l'accueil

                        </button>

                    </div>

                </section>


            </main>

        </div>

    );

}


/* =============================================================
   ICÔNE DE SECOURS POUR LE PARCOURS
   On utilise une petite icône inline pour éviter d'ajouter
   une dépendance ou de modifier le fonctionnement existant.
============================================================= */

function FaBriefcaseIconFallback(){

    return (
        <FaFolderOpen />
    );

}


export default Result;

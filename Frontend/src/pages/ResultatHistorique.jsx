import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";

import {
    FaArrowLeft,
    FaArrowRight,
    FaChartBar,
    FaTrophy,
    FaGraduationCap,
    FaTag,
    FaClock,
    FaUniversity,
    FaStar,
    FaLightbulb,
    FaBullseye,
    FaRedo,
    FaCalendarAlt,
    FaBriefcase,
    FaCheckCircle,
    FaCompass,
    FaInfoCircle
} from "react-icons/fa";

import "../styles/ResultatHistorique.css";
import FooterNavigation from "../components/FooterNavigation";


function ResultatHistorique() {

    const { id_test } = useParams();
    const navigate = useNavigate();
    console.log("ID TEST REÇU PAR RESULTAT HISTORIQUE :", id_test);

    const [test, setTest] = useState(null);
    const [chargement, setChargement] = useState(true);
    const [erreur, setErreur] = useState("");


    // =========================================================
    // CHARGEMENT DU TEST
    // =========================================================

    useEffect(() => {

        const chargerTest = async () => {

            try {

                setChargement(true);
                setErreur("");

                const response = await fetch(
                    `${API_ROUTES_URL}/historique-test-detail.php?id_test=${id_test}`,
                    {
                        credentials: "include"
                    }
                );

                if (!response.ok) {
                    throw new Error("Erreur lors du chargement du test.");
                }

                const data = await response.json();

console.log("RÉSULTAT API HISTORIQUE :", data);

if (!data.success) {
    throw new Error(
        data.message || "Impossible de récupérer les résultats."
    );
}

console.log("TEST REÇU PAR REACT :", data.data);

setTest(data.data);

            } catch (error) {

                console.error(
                    "Erreur chargement résultat historique :",
                    error
                );

                setErreur(
                    error.message ||
                    "Une erreur est survenue lors du chargement."
                );

            } finally {

                setChargement(false);

            }
        };

        chargerTest();

    }, [id_test]);


    // =========================================================
    // PROFILS RIASEC
    // =========================================================

    const profils = {

        RI: {
            nom: "Réaliste – Investigateur",
            description:
                "Vous êtes une personne pratique, curieuse et analytique. Vous aimez comprendre comment les choses fonctionnent, résoudre des problèmes et travailler sur des situations concrètes."
        },

        RA: {
            nom: "Réaliste – Artistique",
            description:
                "Vous combinez un esprit pratique avec une sensibilité créative. Vous appréciez les activités concrètes qui vous permettent également d'exprimer votre imagination."
        },

        RS: {
            nom: "Réaliste – Social",
            description:
                "Vous aimez les activités concrètes tout en appréciant le contact et l'aide aux autres. Vous pouvez être à l'aise dans des métiers pratiques avec une dimension humaine."
        },

        RE: {
            nom: "Réaliste – Entreprenant",
            description:
                "Vous associez pragmatisme et esprit d'initiative. Vous aimez agir, prendre des responsabilités et obtenir des résultats concrets."
        },

        RC: {
            nom: "Réaliste – Conventionnel",
            description:
                "Vous appréciez les activités pratiques, organisées et structurées. Vous êtes à l'aise lorsque les tâches suivent des méthodes précises."
        },


        IR: {
            nom: "Investigateur – Réaliste",
            description:
                "Vous êtes analytique tout en appréciant les applications concrètes. Vous aimez comprendre les problèmes puis rechercher des solutions pratiques."
        },

        IA: {
            nom: "Investigateur – Artistique",
            description:
                "Vous combinez curiosité intellectuelle et créativité. Vous aimez explorer les idées, comprendre les phénomènes et trouver des solutions originales."
        },

        IS: {
            nom: "Investigateur – Social",
            description:
                "Vous aimez comprendre les problèmes et utiliser vos connaissances pour aider les autres. La recherche, l'analyse et la transmission peuvent vous correspondre."
        },

        IE: {
            nom: "Investigateur – Entreprenant",
            description:
                "Vous associez analyse et esprit d'initiative. Vous aimez comprendre les situations, prendre des décisions et transformer les idées en résultats."
        },

        IC: {
            nom: "Investigateur – Conventionnel",
            description:
                "Vous êtes analytique, méthodique et organisé. Vous appréciez les environnements où les informations doivent être étudiées avec précision."
        },


        AR: {
            nom: "Artistique – Réaliste",
            description:
                "Vous associez créativité et sens pratique. Vous aimez créer tout en gardant une approche concrète et orientée vers la réalisation."
        },

        AI: {
            nom: "Artistique – Investigateur",
            description:
                "Vous combinez imagination et curiosité intellectuelle. Vous aimez explorer les idées et produire des solutions créatives."
        },

        AS: {
            nom: "Artistique – Social",
            description:
                "Vous êtes créatif et sensible aux besoins des autres. Vous pouvez apprécier les métiers permettant d'exprimer votre créativité tout en ayant une dimension humaine."
        },

        AE: {
            nom: "Artistique – Entreprenant",
            description:
                "Vous associez créativité et leadership. Vous aimez développer des idées, convaincre et transformer vos projets en réalisations."
        },

        AC: {
            nom: "Artistique – Conventionnel",
            description:
                "Vous combinez créativité et organisation. Vous appréciez les environnements où vous pouvez créer tout en respectant une certaine structure."
        },


        SR: {
            nom: "Social – Réaliste",
            description:
                "Vous aimez aider les autres tout en appréciant les activités concrètes. Vous pouvez être à l'aise dans des métiers pratiques ayant une utilité humaine."
        },

        SI: {
            nom: "Social – Investigateur",
            description:
                "Vous aimez comprendre les situations humaines et aider les autres grâce à vos connaissances. Vous pouvez apprécier l'analyse, la recherche et l'accompagnement."
        },

        SA: {
            nom: "Social – Artistique",
            description:
                "Vous êtes tourné vers les autres et appréciez l'expression créative. Vous pouvez vous épanouir dans des métiers combinant relation humaine et créativité."
        },

        SE: {
            nom: "Social – Entreprenant",
            description:
                "Vous aimez travailler avec les autres et prendre des initiatives. Vous pouvez être à l'aise dans les métiers de communication, de gestion et d'accompagnement."
        },

        SC: {
            nom: "Social – Conventionnel",
            description:
                "Vous aimez aider les autres dans un environnement organisé et structuré. Vous appréciez la précision, la méthode et le sens du service."
        },


        ER: {
            nom: "Entreprenant – Réaliste",
            description:
                "Vous combinez esprit d'initiative et pragmatisme. Vous aimez agir, prendre des responsabilités et obtenir des résultats concrets."
        },

        EI: {
            nom: "Entreprenant – Investigateur",
            description:
                "Vous associez esprit d'initiative et analyse. Vous aimez comprendre les situations, prendre des décisions et développer des solutions."
        },

        EA: {
            nom: "Entreprenant – Artistique",
            description:
                "Vous combinez leadership et créativité. Vous aimez défendre vos idées, convaincre et développer des projets originaux."
        },

        ES: {
            nom: "Entreprenant – Social",
            description:
                "Vous êtes dynamique, sociable et orienté vers l'action. Vous aimez convaincre, coordonner et travailler avec les autres."
        },

        EC: {
            nom: "Entreprenant – Conventionnel",
            description:
                "Vous combinez leadership, organisation et sens des responsabilités. Vous appréciez les environnements structurés où vous pouvez prendre des initiatives."
        },


        CR: {
            nom: "Conventionnel – Réaliste",
            description:
                "Vous êtes organisé et pratique. Vous appréciez les tâches structurées, précises et concrètes."
        },

        CI: {
            nom: "Conventionnel – Investigateur",
            description:
                "Vous êtes méthodique et analytique. Vous appréciez les informations précises, la recherche et les environnements structurés."
        },

        CA: {
            nom: "Conventionnel – Artistique",
            description:
                "Vous associez organisation et créativité. Vous aimez structurer vos activités tout en conservant une certaine liberté d'expression."
        },

        CS: {
            nom: "Conventionnel – Social",
            description:
                "Vous êtes organisé, précis et attentif aux autres. Vous appréciez les environnements structurés avec une dimension humaine."
        },

        CE: {
            nom: "Conventionnel – Entreprenant",
            description:
                "Vous combinez organisation et esprit d'initiative. Vous appréciez la gestion, la coordination et les environnements structurés."
        }
    };


    // =========================================================
    // PROFIL PRINCIPAL
    // =========================================================

    const profilPrincipal =
        test?.profil?.principal ||
        test?.profil_dominant ||
        "";

    const profilInfo =
        profils[profilPrincipal] || {
            nom: "Profil RIASEC",
            description:
                "Votre profil permet d'identifier les environnements professionnels qui peuvent correspondre à vos intérêts."
        };


    // =========================================================
    // SCORES RIASEC
    // =========================================================

    const scores = test
        ? [
            {
                lettre: "R",
                nom: "Réaliste",
                score:
                    test.profil?.scores?.R ??
                    test.score_R ??
                    0
            },
            {
                lettre: "I",
                nom: "Investigateur",
                score:
                    test.profil?.scores?.I ??
                    test.score_I ??
                    0
            },
            {
                lettre: "A",
                nom: "Artistique",
                score:
                    test.profil?.scores?.A ??
                    test.score_A ??
                    0
            },
            {
                lettre: "S",
                nom: "Social",
                score:
                    test.profil?.scores?.S ??
                    test.score_S ??
                    0
            },
            {
                lettre: "E",
                nom: "Entreprenant",
                score:
                    test.profil?.scores?.E ??
                    test.score_E ??
                    0
            },
            {
                lettre: "C",
                nom: "Conventionnel",
                score:
                    test.profil?.scores?.C ??
                    test.score_C ??
                    0
            }
        ]
            .map((score) => ({
                ...score,
                pourcentage: Math.round(
                    (Number(score.score) / 10) * 100
                )
            }))
            .sort(
                (a, b) =>
                    b.pourcentage - a.pourcentage
            )
        : [];


    // =========================================================
    // RECOMMANDATIONS
    // =========================================================

    const metiersPrincipaux =
        test?.recommandations?.principaux || [];

    const metiersSecondaires =
        test?.recommandations?.secondaires || [];


    // =========================================================
    // FORMATIONS D'UN MÉTIER
    // =========================================================

    const afficherFormations = (metier) => {

        if (
            !metier.filieres ||
            metier.filieres.length === 0
        ) {
            return (
                <div className="resultat-historique-no-formation">
                    <FaInfoCircle />
                    <p>
                        Aucune formation associée n'est
                        disponible pour ce métier pour le moment.
                    </p>
                </div>
            );
        }

        return (
            <div className="resultat-historique-formations">

                <div className="resultat-historique-subsection-title">

                    <div className="resultat-historique-subsection-icon">
                        <FaGraduationCap />
                    </div>

                    <div>
                        <span>Étape suivante</span>
                        <h4>Formations associées</h4>
                    </div>

                </div>


                <div className="resultat-historique-formations-list">

                    {metier.filieres.map(
                        (formation, index) => {

                            const filiere =
                                formation.filiere ||
                                formation;

                            const universites =
                                formation.universites ||
                                [];

                            return (
                                <div
                                    className="resultat-historique-formation"
                                    key={
                                        filiere.id_filiere ||
                                        index
                                    }
                                >

                                    <div className="resultat-historique-formation-header">

                                        <div className="resultat-historique-formation-icon">
                                            <FaGraduationCap />
                                        </div>

                                        <div>

                                            <h5>
                                                {filiere.nom}
                                            </h5>

                                            <div className="resultat-historique-formation-meta">

                                                {filiere.domaine && (
                                                    <span>
                                                        <FaTag />
                                                        {filiere.domaine}
                                                    </span>
                                                )}

                                                {filiere.duree && (
                                                    <span>
                                                        <FaClock />
                                                        {filiere.duree}
                                                    </span>
                                                )}

                                            </div>

                                        </div>

                                    </div>


                                    <div className="resultat-historique-universites">

                                        <div className="resultat-historique-universites-title">

                                            <FaUniversity />

                                            <span>
                                                Universités disponibles
                                            </span>

                                        </div>


                                        {universites.length > 0 ? (

                                            <div className="resultat-historique-universites-list">

                                                {universites.map(
                                                    (
                                                        universite,
                                                        universityIndex
                                                    ) => (

                                                        <button
                                                            key={
                                                                universite.id_universite ||
                                                                universityIndex
                                                            }
                                                            className="resultat-historique-universite-button"
                                                            onClick={() =>
                                                                navigate(
                                                                    `/universite-catalogue/${universite.id_universite}`
                                                                )
                                                            }
                                                        >

                                                            <span>

                                                                <FaUniversity />

                                                                {universite.nom}

                                                            </span>

                                                            <FaArrowRight />

                                                        </button>

                                                    )
                                                )}

                                            </div>

                                        ) : (

                                            <p className="resultat-historique-no-universite">
                                                Aucune université
                                                disponible pour cette
                                                formation.
                                            </p>

                                        )}

                                    </div>

                                </div>
                            );
                        }
                    )}

                </div>

            </div>
        );
    };


    // =========================================================
    // AFFICHAGE DES MÉTIERS
    // =========================================================

    const afficherMetiers = (
        metiers,
        type
    ) => {

        if (!metiers || metiers.length === 0) {

            return (
                <div className="resultat-historique-no-metier">

                    <FaInfoCircle />

                    <p>
                        Aucune recommandation disponible
                        dans cette catégorie.
                    </p>

                </div>
            );
        }


        return (
            <div className="resultat-historique-metiers-list">

                {metiers.map(
                    (metier, index) => {

                        const principal =
                            type === "principal";

                        return (
                            <details
                                className={`resultat-historique-metier ${
                                    principal
                                        ? "principal"
                                        : "secondaire"
                                }`}
                                key={
                                    metier.id_metier ||
                                    index
                                }
                            >

                                <summary>

                                    <div className="resultat-historique-metier-summary">

                                        <div
                                            className={`resultat-historique-metier-badge ${
                                                principal
                                                    ? "principal"
                                                    : "secondaire"
                                            }`}
                                        >

                                            {principal ? (
                                                <>
                                                    <FaStar />
                                                    Métier recommandé
                                                </>
                                            ) : (
                                                <>
                                                    <FaLightbulb />
                                                    Autre piste
                                                </>
                                            )}

                                        </div>


                                        <div className="resultat-historique-metier-title-row">

                                            <div className="resultat-historique-metier-icon">
                                                <FaBriefcase />
                                            </div>

                                            <div>

                                                <h3>
                                                    {metier.nom}
                                                </h3>

                                                <p>
                                                    Découvrez ce métier,
                                                    les formations associées
                                                    et les universités
                                                    disponibles.
                                                </p>

                                            </div>

                                        </div>

                                    </div>


                                    <div className="resultat-historique-metier-arrow">

                                        <FaArrowRight />

                                    </div>

                                </summary>


                                <div className="resultat-historique-metier-details">

                                    {metier.description && (

                                        <div className="resultat-historique-description">

                                            <div className="resultat-historique-description-icon">
                                                <FaInfoCircle />
                                            </div>

                                            <div>

                                                <span>
                                                    À propos du métier
                                                </span>

                                                <h4>
                                                    Présentation
                                                </h4>

                                                <p>
                                                    {metier.description}
                                                </p>

                                            </div>

                                        </div>

                                    )}


                                    {afficherFormations(metier)}

                                </div>

                            </details>
                        );
                    }
                )}

            </div>
        );
    };


    // =========================================================
    // CHARGEMENT
    // =========================================================

    if (chargement) {

        return (
            <div className="resultat-historique-page">

                <div className="resultat-historique-loading">

                    <div className="resultat-historique-loading-spinner"></div>

                    <FaCompass />

                    <h2>
                        Chargement de votre orientation...
                    </h2>

                    <p>
                        Nous préparons les résultats de votre
                        parcours d'orientation.
                    </p>

                </div>

                <FooterNavigation />

            </div>
        );
    }


    // =========================================================
    // ERREUR
    // =========================================================

    if (erreur || !test) {

        return (
            <div className="resultat-historique-page">

                <div className="resultat-historique-error">

                    <div className="resultat-historique-error-icon">
                        <FaInfoCircle />
                    </div>

                    <h2>
                        Impossible d'afficher ce résultat
                    </h2>

                    <p>
                        {erreur ||
                            "Le résultat demandé est introuvable."}
                    </p>

                    <button
                        className="resultat-historique-error-button"
                        onClick={() =>
                            navigate("/historique-tests")
                        }
                    >
                        <FaArrowLeft />
                        Retour à mon historique
                    </button>

                </div>

                <FooterNavigation />

            </div>
        );
    }


    // =========================================================
    // PAGE PRINCIPALE
    // =========================================================

    return (
        <div className="resultat-historique-page">


            {/* =====================================================
                HEADER
            ====================================================== */}

            <header className="resultat-historique-header">

                <div className="resultat-historique-header-content">

                    <div className="resultat-historique-header-title">

                        <div className="resultat-historique-header-icon">
                            <FaChartBar />
                        </div>

                        <div>

                            <span className="resultat-historique-label">
                                Mon orientation
                            </span>

                            <h1>
                                Résultat de mon test
                            </h1>

                            <p>
                                <FaCalendarAlt />

                                Test effectué le{" "}

                                {new Date(
                                    test.date_test
                                ).toLocaleDateString(
                                    "fr-FR",
                                    {
                                        day: "2-digit",
                                        month: "long",
                                        year: "numeric"
                                    }
                                )}

                            </p>

                        </div>

                    </div>


                    <button
                        className="resultat-historique-retour-top"
                        onClick={() =>
                            navigate("/historique-tests")
                        }
                    >

                        <FaArrowLeft />

                        Retour à mon historique

                    </button>

                </div>


                <span className="resultat-historique-test-id">

                    Test #{test.numero_test}

                </span>

            </header>


            {/* =====================================================
                RÉSUMÉ DU PARCOURS
            ====================================================== */}

            <section className="resultat-historique-resume">

                <div className="resultat-historique-resume-header">

                    <div className="resultat-historique-resume-icon">
                        <FaCompass />
                    </div>

                    <div>

                        <span>
                            Votre parcours
                        </span>

                        <h2>
                            De votre profil à votre avenir
                        </h2>

                        <p>
                            Explorez progressivement votre profil,
                            les métiers recommandés, les formations
                            associées et les universités disponibles.
                        </p>

                    </div>

                </div>


                <div className="resultat-historique-parcours">

                    <div className="resultat-parcours-item active">

                        <div className="resultat-parcours-icon">
                            <FaBullseye />
                        </div>

                        <div>

                            <span>
                                Étape 01
                            </span>

                            <strong>
                                Profil
                            </strong>

                        </div>

                    </div>


                    <div className="resultat-parcours-line"></div>


                    <div className="resultat-parcours-item">

                        <div className="resultat-parcours-icon">
                            <FaBriefcase />
                        </div>

                        <div>

                            <span>
                                Étape 02
                            </span>

                            <strong>
                                Métiers
                            </strong>

                        </div>

                    </div>


                    <div className="resultat-parcours-line"></div>


                    <div className="resultat-parcours-item">

                        <div className="resultat-parcours-icon">
                            <FaGraduationCap />
                        </div>

                        <div>

                            <span>
                                Étape 03
                            </span>

                            <strong>
                                Formations
                            </strong>

                        </div>

                    </div>


                    <div className="resultat-parcours-line"></div>


                    <div className="resultat-parcours-item">

                        <div className="resultat-parcours-icon">
                            <FaUniversity />
                        </div>

                        <div>

                            <span>
                                Étape 04
                            </span>

                            <strong>
                                Universités
                            </strong>

                        </div>

                    </div>

                </div>

            </section>


            {/* =====================================================
                PROFIL DOMINANT
            ====================================================== */}

            <section className="resultat-historique-profil">

                <div className="resultat-historique-profil-label">

                    <FaTrophy />

                    Votre profil dominant

                </div>


                <div className="resultat-historique-profil-content">

                    <div className="resultat-historique-code">

                        {profilPrincipal}

                    </div>


                    <div className="resultat-historique-profil-text">

                        <span>
                            Profil RIASEC
                        </span>

                        <h2>
                            {profilInfo.nom}
                        </h2>

                        <p>
                            {profilInfo.description}
                        </p>

                    </div>

                </div>

            </section>


            {/* =====================================================
                SCORES RIASEC
            ====================================================== */}

            <section className="resultat-historique-scores">

                <div className="resultat-historique-section-title">

                    <div className="resultat-historique-section-title-icon">
                        <FaChartBar />
                    </div>

                    <div>

                        <span>
                            Étape 01 · Comprendre
                        </span>

                        <h2>
                            Vos scores RIASEC
                        </h2>

                        <p>
                            Voici les six dimensions qui composent
                            votre profil professionnel.
                        </p>

                    </div>

                </div>


                <div className="resultat-scores-list">

                    {scores.map(
                        (score) => (

                            <div
                                className="resultat-score-item"
                                key={score.lettre}
                            >

                                <div className="resultat-score-header">

                                    <div className="resultat-score-letter">
                                        {score.lettre}
                                    </div>

                                    <strong>
                                        {score.nom}
                                    </strong>

                                    <b>
                                        {score.pourcentage}%
                                    </b>

                                </div>


                                <div className="resultat-score-bar">

                                    <div
                                        className="resultat-score-progress"
                                        style={{
                                            width: `${score.pourcentage}%`
                                        }}
                                    />

                                </div>

                            </div>

                        )
                    )}

                </div>

            </section>


            {/* =====================================================
                BLOC DE CONFIANCE
            ====================================================== */}

            <section className="resultat-historique-confiance">

                <div className="resultat-historique-confiance-icon">
                    <FaBullseye />
                </div>

                <div>

                    <span>
                        Comprendre votre orientation
                    </span>

                    <h3>
                        Pourquoi ces recommandations ?
                    </h3>

                    <p>
                        Les métiers présentés ci-dessous sont proposés
                        à partir des tendances identifiées dans votre
                        profil RIASEC. Ils constituent des pistes
                        d'exploration pour vous aider à construire
                        progressivement votre projet d'orientation.
                    </p>

                </div>

            </section>


            {/* =====================================================
                MÉTIERS
            ====================================================== */}

            <section className="resultat-historique-recommandations">

                <div className="resultat-historique-section-header">

                    <div className="resultat-historique-section-header-icon">
                        <FaBriefcase />
                    </div>

                    <div>

                        <span>
                            Étape 02 · Découvrir
                        </span>

                        <h2>
                            Métiers recommandés
                        </h2>

                        <p>
                            Découvrez les métiers qui peuvent correspondre
                            à votre profil et explorez leur parcours de formation.
                        </p>

                    </div>

                </div>


                {/* MÉTIERS PRINCIPAUX */}

                <div className="resultat-historique-category">

                    <div className="resultat-historique-category-heading">

                        <div className="resultat-historique-category-icon principal">
                            <FaStar />
                        </div>

                        <div>

                            <span>
                                Vos meilleures correspondances
                            </span>

                            <h3>
                                Métiers principaux
                            </h3>

                        </div>

                    </div>


                    {afficherMetiers(
                        metiersPrincipaux,
                        "principal"
                    )}

                </div>


                {/* MÉTIERS SECONDAIRES */}

                <div className="resultat-historique-category secondaire">

                    <div className="resultat-historique-category-heading">

                        <div className="resultat-historique-category-icon secondaire">
                            <FaLightbulb />
                        </div>

                        <div>

                            <span>
                                D'autres possibilités
                            </span>

                            <h3>
                                Autres pistes à explorer
                            </h3>

                        </div>

                    </div>


                    <p className="resultat-historique-secondary-intro">

                        Ces métiers constituent d'autres possibilités
                        compatibles avec votre profil. Prenez le temps
                        de les découvrir avant de faire votre choix.

                    </p>


                    {afficherMetiers(
                        metiersSecondaires,
                        "secondaire"
                    )}

                </div>

            </section>
            {/* =====================================================
                PROCHAINE ÉTAPE
            ====================================================== */}

            <section className="resultat-historique-next-step">

                <div className="resultat-historique-next-step-icon">
                    <FaGraduationCap />
                </div>

                <div className="resultat-historique-next-step-content">

                    <span>
                        Étape 03 · Construire
                    </span>

                    <h2>
                        Votre orientation ne s'arrête pas ici
                    </h2>

                    <p>
                        Un métier est le début de votre réflexion.
                        Explorez les formations associées et découvrez
                        les établissements où vous pourriez poursuivre
                        vos études.
                    </p>

                </div>

            </section>


            {/* =====================================================
                RÉSUMÉ FINAL DU PARCOURS
            ====================================================== */}

            <section className="resultat-historique-parcours-final">

                <div className="resultat-historique-final-title">

                    <div className="resultat-historique-final-icon">
                        <FaCompass />
                    </div>

                    <div>

                        <span>
                            Votre prochaine démarche
                        </span>

                        <h2>
                            Construisez votre projet
                        </h2>

                    </div>

                </div>


                <div className="resultat-historique-final-steps">

                    <div className="resultat-final-step">

                        <div className="resultat-final-step-number">
                            01
                        </div>

                        <div>

                            <FaBriefcase />

                            <strong>
                                Explorez les métiers
                            </strong>

                            <p>
                                Découvrez les métiers qui correspondent
                                le mieux à votre profil.
                            </p>

                        </div>

                    </div>


                    <div className="resultat-final-step">

                        <div className="resultat-final-step-number">
                            02
                        </div>

                        <div>

                            <FaGraduationCap />

                            <strong>
                                Comparez les formations
                            </strong>

                            <p>
                                Identifiez les filières permettant
                                d'accéder aux métiers qui vous intéressent.
                            </p>

                        </div>

                    </div>


                    <div className="resultat-final-step">

                        <div className="resultat-final-step-number">
                            03
                        </div>

                        <div>

                            <FaUniversity />

                            <strong>
                                Découvrez les universités
                            </strong>

                            <p>
                                Consultez les établissements proposant
                                les formations adaptées à votre projet.
                            </p>

                        </div>

                    </div>

                </div>

            </section>


            {/* =====================================================
                MESSAGE FINAL
            ====================================================== */}

            <section className="resultat-historique-message-final">

                <FaCheckCircle />

                <div>

                    <h3>
                        Vous avez maintenant une première direction.
                    </h3>

                    <p>
                        Prenez le temps d'explorer les différentes
                        possibilités. Votre choix d'orientation se
                        construit progressivement, en fonction de vos
                        intérêts, de vos objectifs et de votre projet.
                    </p>

                </div>

            </section>


            {/* =====================================================
                ACTIONS FINALES
            ====================================================== */}

            <div className="resultat-historique-actions">

                <button
                    className="resultat-historique-action-retour"
                    onClick={() =>
                        navigate("/historique-tests")
                    }
                >

                    <FaArrowLeft />

                    Retour à mon historique

                </button>


                <button
                    className="resultat-historique-action-test"
                    onClick={() =>
                        navigate("/test")
                    }
                >

                    <FaRedo />

                    Refaire un test

                    <FaArrowRight />

                </button>

            </div>


            {/* =====================================================
                FOOTER
            ====================================================== */}

            <FooterNavigation />

        </div>
    );
}

export default ResultatHistorique;

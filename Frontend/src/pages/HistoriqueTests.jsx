import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

import {
    FaClipboardList,
    FaArrowLeft,
    FaArrowRight,
    FaCalendarAlt,
    FaTrophy,
    FaChartBar,
    FaHistory,
    FaRedo
} from "react-icons/fa";

import "../styles/HistoriqueTests.css";
import FooterNavigation from "../components/FooterNavigation";


function HistoriqueTests() {

    const navigate = useNavigate();

    const [tests, setTests] = useState([]);
    const [chargement, setChargement] = useState(true);
    const [erreur, setErreur] = useState("");


    /* ==================================================
       RÉCUPÉRATION DE L'HISTORIQUE
    ================================================== */

    useEffect(() => {

        fetch(
            `${API_ROUTES_URL}/historique-tests.php`,
            {
                credentials: "include"
            }
        )
            .then(async (response) => {

                const data = await response.json();

                if (!response.ok) {

                    throw new Error(
                        data.message ||
                        "Erreur lors de la récupération."
                    );

                }

                return data;

            })
            .then((data) => {

                if (data.success) {

                    setTests(data.data || []);

                } else {

                    setErreur(
                        data.message ||
                        "Impossible de récupérer l'historique."
                    );

                }

            })
            .catch((error) => {

                console.error(
                    "Erreur historique tests :",
                    error
                );

                setErreur(
                    "Impossible de charger votre historique."
                );

            })
            .finally(() => {

                setChargement(false);

            });

    }, []);


    /* ==================================================
       CHARGEMENT
    ================================================== */

    if (chargement) {

        return (

            <div className="historique-tests-page">

                <div className="historique-tests-loading">

                    <div className="historique-tests-loading-icon">
                        <FaHistory />
                    </div>

                    <h2>
                        Chargement de votre historique...
                    </h2>

                    <p>
                        Nous récupérons vos tests d'orientation.
                    </p>

                </div>

                <FooterNavigation />

            </div>

        );

    }


    /* ==================================================
       ERREUR
    ================================================== */

    if (erreur) {

        return (

            <div className="historique-tests-page">

                <div className="historique-tests-error">

                    <div className="historique-tests-error-icon">
                        <FaHistory />
                    </div>

                    <h1>
                        Historique des tests
                    </h1>

                    <p>
                        {erreur}
                    </p>

                    <button
                        onClick={() => window.location.reload()}
                    >
                        <FaRedo />
                        Réessayer
                    </button>

                </div>

                <FooterNavigation />

            </div>

        );

    }


    /* ==================================================
       NUMÉROTATION DES TESTS
    ================================================== */

    const getNumeroTest = (index) => {

        return tests.length - index;

    };


    /* ==================================================
       AFFICHAGE
    ================================================== */

    return (

        <div className="historique-tests-page">


            {/* ==================================================
                HEADER
            ================================================== */}

            <header className="historique-tests-header">

                <div className="historique-tests-header-content">

                    <div className="historique-tests-title">

                        <div className="historique-tests-title-icon">
                            <FaClipboardList />
                        </div>

                        <div>

                            <p className="historique-tests-label">
                                Mon orientation
                            </p>

                            <h1>
                                Historique de mes tests
                            </h1>

                            <p className="historique-tests-description">
                                Retrouvez les tests d'orientation que vous
                                avez effectués et consultez vos résultats.
                            </p>

                        </div>

                    </div>


                    {/* RETOUR AUX RÉSULTATS */}

                    <button
                        className="historique-resultats-button"
                        onClick={() => navigate("/profil")}
                    >
                        <FaArrowLeft />
                        Retour à mon profil
                    </button>

                </div>


                {/* COMPTEUR */}

                <div className="historique-tests-summary">

                    <div className="historique-summary-icon">
                        <FaChartBar />
                    </div>

                    <div>

                        <strong>
                            {tests.length}
                        </strong>

                        <span>
                            test{tests.length > 1 ? "s" : ""} effectué
                            {tests.length > 1 ? "s" : ""}
                        </span>

                    </div>

                </div>

            </header>


            {/* ==================================================
                CONTENU PRINCIPAL
            ================================================== */}

            <main className="historique-tests-content">


                {/* ==================================================
                    AUCUN TEST
                ================================================== */}

                {tests.length === 0 ? (

                    <section className="historique-tests-empty">

                        <div className="historique-empty-icon">
                            <FaClipboardList />
                        </div>

                        <h2>
                            Aucun test effectué
                        </h2>

                        <p>
                            Vous n'avez pas encore effectué de test
                            d'orientation. Commencez votre parcours pour
                            découvrir votre profil professionnel.
                        </p>

                        <button
                            className="historique-first-test-button"
                            onClick={() => navigate("/test")}
                        >
                            <FaArrowRight />
                            Faire mon premier test
                        </button>

                    </section>

                ) : (

                    <>

                        {/* ==================================================
                            INTRODUCTION
                        ================================================== */}

                        <section className="historique-tests-introduction">

                            <div className="historique-introduction-icon">
                                <FaHistory />
                            </div>

                            <div>

                                <h2>
                                    Vos tests précédents
                                </h2>

                                <p>
                                    Consultez vos différents résultats
                                    pour suivre l'évolution de votre
                                    orientation.
                                </p>

                            </div>

                        </section>


                        {/* ==================================================
                            LISTE DES TESTS
                        ================================================== */}

                        <section className="historique-tests-list">

                            {tests.map((test, index) => {

                                const numeroTest =
                                    getNumeroTest(index);

                                return (

                                    <article
                                        key={test.id_test}
                                        className="historique-test-card"
                                    >


                                        {/* EN-TÊTE DE LA CARTE */}

                                        <div className="historique-test-card-header">

                                            <div className="historique-test-number">

                                                <span>
                                                    Test
                                                </span>

                                                <strong>
                                                    #{numeroTest}
                                                </strong>

                                            </div>


                                            <div className="historique-test-card-title">

                                                <h2>
                                                    Test d'orientation
                                                </h2>

                                                <p>
                                                    <FaCalendarAlt />

                                                    <span>
                                                        Effectué le{" "}
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
                                                    </span>

                                                </p>

                                            </div>


                                            {/* PROFIL DOMINANT */}

                                            <div className="historique-test-profile">

                                                <span>
                                                    Profil dominant
                                                </span>

                                                <strong>
                                                    {test.profil_dominant}
                                                </strong>

                                            </div>

                                        </div>


                                        {/* SÉPARATION */}

                                        <div className="historique-test-divider"></div>


                                        {/* SCORES RIASEC */}

                                        <div className="historique-test-scores-section">

                                            <div className="historique-test-scores-title">

                                                <FaTrophy />

                                                <span>
                                                    Scores RIASEC
                                                </span>

                                            </div>


                                            <div className="historique-test-scores">

                                                <div className="historique-score-item">

                                                    <span>R</span>

                                                    <strong>
                                                        {test.score_R}
                                                    </strong>

                                                </div>


                                                <div className="historique-score-item">

                                                    <span>I</span>

                                                    <strong>
                                                        {test.score_I}
                                                    </strong>

                                                </div>


                                                <div className="historique-score-item">

                                                    <span>A</span>

                                                    <strong>
                                                        {test.score_A}
                                                    </strong>

                                                </div>


                                                <div className="historique-score-item">

                                                    <span>S</span>

                                                    <strong>
                                                        {test.score_S}
                                                    </strong>

                                                </div>


                                                <div className="historique-score-item">

                                                    <span>E</span>

                                                    <strong>
                                                        {test.score_E}
                                                    </strong>

                                                </div>


                                                <div className="historique-score-item">

                                                    <span>C</span>

                                                    <strong>
                                                        {test.score_C}
                                                    </strong>

                                                </div>

                                            </div>

                                        </div>


                                        {/* PIED DE CARTE */}

                                        <div className="historique-test-card-footer">

                                            <div className="historique-test-status">

                                                <FaClipboardList />

                                                <span>
                                                    Résultat enregistré
                                                </span>

                                            </div>


                                            <button
                                                className="historique-result-button"
                                                onClick={() => {

                                                    navigate(
                                                        `/resultat-test/${test.id_test}`
                                                    );

                                                }}
                                            >
                                                Voir mon résultat
                                                <FaArrowRight />
                                            </button>

                                        </div>

                                    </article>

                                );

                            })}

                        </section>

                    </>

                )}


                {/* ==================================================
                    RETOUR AU PROFIL
                ================================================== */}

                <div className="historique-tests-bottom-navigation">

                    <button
                        className="historique-retour-button"
                        onClick={() => navigate("/profil")}
                    >
                        <FaArrowLeft />
                        Retour au profil
                    </button>

                </div>

            </main>


            {/* ==================================================
                FOOTER
            ================================================== */}

            <FooterNavigation />

        </div>

    );

}


export default HistoriqueTests;

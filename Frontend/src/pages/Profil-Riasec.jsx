import { useLocation, useNavigate } from "react-router-dom";

import "../styles/Profil-Riasec.css";

import profilsRiasec from "../data/profilsRiasec";

import {
    FaStar,
    FaBrain,
    FaBuilding,
    FaHome,
    FaArrowLeft
} from "react-icons/fa";


function ProfilRiasec() {

    const location = useLocation();

    const navigate = useNavigate();

    const resultat = location.state?.resultat;


    /*
        Si aucun résultat n'est disponible
    */

    if (!resultat) {

        return (

            <div className="nextori-riasec-profile-empty">

                <div className="nextori-riasec-profile-empty-card">

                    <div className="nextori-riasec-profile-empty-icon">
                        <FaBrain />
                    </div>

                    <h1>
                        Aucun profil disponible
                    </h1>

                    <p>
                        Vous devez effectuer le test RIASEC
                        avant de consulter votre profil.
                    </p>

                    <button
                        className="nextori-riasec-profile-start-button"
                        onClick={() => navigate("/test")}
                    >
                        Faire le test
                    </button>

                </div>

            </div>

        );

    }


    const codeProfil = resultat.profil.principal;

    const profil = profilsRiasec[codeProfil];


    /*
        Sécurité si le profil n'existe pas
    */

    if (!profil) {

        return (

            <div className="nextori-riasec-profile-empty">

                <div className="nextori-riasec-profile-empty-card">

                    <div className="nextori-riasec-profile-empty-icon">
                        <FaBrain />
                    </div>

                    <h1>
                        Profil introuvable
                    </h1>

                    <p>
                        Une erreur est survenue lors du chargement
                        de votre profil RIASEC.
                    </p>

                </div>

            </div>

        );

    }


    return (

        <div className="nextori-riasec-profile-page">


            {/* =====================================================
                EN-TÊTE
            ===================================================== */}

            <header className="nextori-riasec-profile-header">

                <div className="nextori-riasec-profile-header-content">

                    <span className="nextori-riasec-profile-eyebrow">
                        ANALYSE DE VOTRE PROFIL
                    </span>

                    <h1>
                        Votre profil RIASEC
                    </h1>

                    <p>
                        Découvrez votre personnalité professionnelle,
                        vos forces naturelles et les environnements
                        dans lesquels vous pouvez vous épanouir.
                    </p>

                </div>

            </header>


            {/* =====================================================
                IDENTITÉ DU PROFIL
            ===================================================== */}

            <main className="nextori-riasec-profile-main">

                <section className="nextori-riasec-profile-identity">

                    <div className="nextori-riasec-profile-code-wrapper">

                        <span className="nextori-riasec-profile-code-label">
                            VOTRE CODE
                        </span>

                        <div className="nextori-riasec-profile-code">
                            {codeProfil}
                        </div>

                    </div>


                    <div className="nextori-riasec-profile-identity-content">

                        <span className="nextori-riasec-profile-identity-kicker">
                            Votre profil dominant
                        </span>

                        <h2>
                            {profil.nom}
                        </h2>

                        <p className="nextori-riasec-profile-description">
                            {profil.description}
                        </p>

                    </div>

                </section>


                {/* =================================================
                    POINTS FORTS
                ================================================= */}

                <section className="nextori-riasec-profile-section">

                    <div className="nextori-riasec-profile-section-heading">

                        <div className="nextori-riasec-profile-section-icon">
                            <FaStar />
                        </div>

                        <div>
                            <span className="nextori-riasec-profile-section-kicker">
                                CE QUI VOUS CARACTÉRISE
                            </span>

                            <h2>
                                Vos points forts
                            </h2>
                        </div>

                    </div>


                    <div className="nextori-riasec-profile-list">

                        {
                            profil.forces.map(
                                (force, index) => (

                                    <div
                                        key={index}
                                        className="nextori-riasec-profile-item"
                                    >

                                        <span className="nextori-riasec-profile-item-marker">
                                            <FaStar />
                                        </span>

                                        <span>
                                            {force}
                                        </span>

                                    </div>

                                )
                            )
                        }

                    </div>

                </section>


                {/* =================================================
                    COMPÉTENCES NATURELLES
                ================================================= */}

                <section className="nextori-riasec-profile-section">

                    <div className="nextori-riasec-profile-section-heading">

                        <div className="nextori-riasec-profile-section-icon">
                            <FaBrain />
                        </div>

                        <div>
                            <span className="nextori-riasec-profile-section-kicker">
                                VOS APTITUDES
                            </span>

                            <h2>
                                Vos compétences naturelles
                            </h2>
                        </div>

                    </div>


                    <div className="nextori-riasec-profile-list">

                        {
                            profil.competences.map(
                                (competence, index) => (

                                    <div
                                        key={index}
                                        className="nextori-riasec-profile-item"
                                    >

                                        <span className="nextori-riasec-profile-item-marker">
                                            <FaBrain />
                                        </span>

                                        <span>
                                            {competence}
                                        </span>

                                    </div>

                                )
                            )
                        }

                    </div>

                </section>


                {/* =================================================
                    ENVIRONNEMENTS PROFESSIONNELS
                ================================================= */}

                <section className="nextori-riasec-profile-section">

                    <div className="nextori-riasec-profile-section-heading">

                        <div className="nextori-riasec-profile-section-icon">
                            <FaBuilding />
                        </div>

                        <div>
                            <span className="nextori-riasec-profile-section-kicker">
                                VOTRE CADRE IDÉAL
                            </span>

                            <h2>
                                Environnements professionnels adaptés
                            </h2>
                        </div>

                    </div>


                    <div className="nextori-riasec-profile-list">

                        {
                            profil.environnements.map(
                                (environnement, index) => (

                                    <div
                                        key={index}
                                        className="nextori-riasec-profile-item"
                                    >

                                        <span className="nextori-riasec-profile-item-marker">
                                            <FaBuilding />
                                        </span>

                                        <span>
                                            {environnement}
                                        </span>

                                    </div>

                                )
                            )
                        }

                    </div>

                </section>


                {/* =================================================
                    ACTIONS
                ================================================= */}

                <section className="nextori-riasec-profile-actions">

                    <button
                        className="nextori-riasec-profile-back-button"
                        onClick={() =>
                            navigate("/result", {
                                state: {
                                    data: resultat
                                }
                            })
                        }
                    >

                        <FaArrowLeft />

                        <span>
                            Retour aux résultats
                        </span>

                    </button>


                    <button
                        className="nextori-riasec-profile-home-button"
                        onClick={() => navigate("/dashboard")}
                    >

                        <FaHome />

                        <span>
                            Retour à l'accueil
                        </span>

                    </button>

                </section>


            </main>

        </div>

    );

}


export default ProfilRiasec;
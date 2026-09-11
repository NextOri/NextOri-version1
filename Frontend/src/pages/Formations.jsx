import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";

import {
    useLocation,
    useNavigate
} from "react-router-dom";

import "../styles/Formations.css";

import {
    FaBullseye,
    FaGraduationCap,
    FaClock,
    FaArrowLeft,
    FaArrowRight,
    FaUniversity,
    FaLayerGroup,
    FaInfoCircle,
    FaExclamationCircle
} from "react-icons/fa";

import { MdCategory } from "react-icons/md";

import { enregistrerAction } from "../services/historiqueService";


function Formations() {

    const navigate = useNavigate();

    const location = useLocation();


    /*
    =====================================
    DONNEES RECUES DEPUIS LA PAGE RESULTAT
    =====================================
    */

    const metier = location.state?.metier;

    const resultat = location.state?.resultat;

    const nomMetier = metier?.nom || "ce métier";


    /*
    =====================================
    ETATS
    =====================================
    */

    const [formations, setFormations] = useState([]);

    const [chargement, setChargement] = useState(true);

    const [erreur, setErreur] = useState("");


    /*
    =====================================
    RECUPERATION DES FORMATIONS
    =====================================
    */

    useEffect(() => {

        const chargerFormations = async () => {

            try {

                if (!metier) {

                    setErreur(
                        "Aucun métier n'a été sélectionné."
                    );

                    setChargement(false);

                    return;
                }


                const reponse = await fetch(
                    `${API_ROUTES_URL}/filieres.php?id_metier=${metier.id_metier}`
                );


                const data = await reponse.json();


                if (data.success) {

                    setFormations(
                        data.formations || []
                    );

                } else {

                    setErreur(
                        data.message ||
                        "Impossible de récupérer les formations."
                    );

                }


            } catch (error) {

                console.error(
                    "Erreur lors du chargement des formations :",
                    error
                );

                setErreur(
                    "Une erreur est survenue lors du chargement des formations."
                );


            } finally {

                setChargement(false);

            }

        };


        chargerFormations();


    }, [metier]);


    /*
    =====================================
    CONSULTER LES UNIVERSITES
    =====================================
    */

    const consulterUniversite = async (
        formation,
        metier,
        resultat
    ) => {

        // Progression / badges
        await enregistrerAction(
            "UNIVERSITES_CONSULTEES"
        );


        // Historique détaillé
        await enregistrerAction(
            `FORMATION_CONSULTEE: ${formation.nom}`
        );


        navigate("/universites", {

            state: {
                filiere: formation,
                metier,
                resultat
            }

        });

    };


    /*
    =====================================
    RETOUR AUX RESULTATS
    =====================================
    */

    const retournerAuxResultats = () => {

        navigate("/result", {

            state: {
                data: resultat
            }

        });

    };


    /*
    =====================================
    AFFICHAGE
    =====================================
    */

    return (

        <div className="formations-page">


            {/* =====================================
                BOUTON RETOUR
            ===================================== */}

            <div className="formations-navigation">

                <button
                    className="formations-back-button"
                    onClick={retournerAuxResultats}
                >

                    <FaArrowLeft />

                    <span>
                        Retour aux résultats
                    </span>

                </button>

            </div>


            {/* =====================================
                HERO / EN-TETE
            ===================================== */}

            <header className="formations-header">


                <div className="formations-header-icon">

                    <FaBullseye />

                </div>


                <div className="formations-header-content">

                    <span className="formations-eyebrow">

                        PARCOURS D'ORIENTATION

                    </span>


                    <h1>
    Quoi étudier pour accéder au métier de{" "}
    <span className="metier-title">
        {nomMetier}
    </span>
    <span className="question-mark"> ?</span>
</h1>


                    <p>

                        Découvrez les formations recommandées
                        pour accéder à ce métier, puis explorez
                        les universités qui les proposent.

                    </p>

                </div>


            </header>


            {/* =====================================
                CONTEXTE DU METIER
            ===================================== */}

            {metier && (

                <section className="metier-context">


                    <div className="metier-context-icon">

                        <FaGraduationCap />

                    </div>


                    <div className="metier-context-content">

                        <span>

                            MÉTIER SÉLECTIONNÉ

                        </span>


                        <strong>

                            {nomMetier}

                        </strong>


                    </div>


                </section>

            )}


            {/* =====================================
                CONTENU PRINCIPAL
            ===================================== */}

            <main className="formations-content">


                {/* =====================================
                    TITRE SECTION
                ===================================== */}

                <div className="formations-section-header">


                    <div>

                        <span className="section-eyebrow">

                            FORMATIONS RECOMMANDÉES

                        </span>


                        <h2>

                            Les parcours à envisager

                        </h2>


                        <p>

                            Comparez les différentes filières
                            qui peuvent vous préparer à cette carrière.

                        </p>

                    </div>


                    {!chargement && !erreur && formations.length > 0 && (

                        <div className="formations-count">

                            <FaLayerGroup />

                            <span>

                                {formations.length}

                            </span>

                            <small>

                                {formations.length > 1
                                    ? "formations trouvées"
                                    : "formation trouvée"
                                }

                            </small>

                        </div>

                    )}

                </div>


                {/* =====================================
                    CHARGEMENT
                ===================================== */}

                {chargement && (

                    <div className="formations-state formations-loading">


                        <div className="formations-loading-spinner"></div>


                        <h3>

                            Chargement des formations...

                        </h3>


                        <p>

                            Nous recherchons les parcours
                            adaptés à ce métier.

                        </p>

                    </div>

                )}


                {/* =====================================
                    ERREUR
                ===================================== */}

                {!chargement && erreur && (

                    <div className="formations-state formations-error">


                        <div className="formations-state-icon">

                            <FaExclamationCircle />

                        </div>


                        <h3>

                            Impossible de charger les formations

                        </h3>


                        <p>

                            {erreur}

                        </p>


                        <button
                            className="formations-back-button"
                            onClick={retournerAuxResultats}
                        >

                            <FaArrowLeft />

                            Retour aux résultats

                        </button>

                    </div>

                )}


                {/* =====================================
                    AUCUNE FORMATION
                ===================================== */}

                {!chargement &&
                    !erreur &&
                    formations.length === 0 && (

                        <div className="formations-state formations-empty">


                            <div className="formations-state-icon">

                                <FaInfoCircle />

                            </div>


                            <h3>

                                Aucune formation trouvée

                            </h3>


                            <p>

                                Nous n'avons pas encore identifié
                                de formation associée à ce métier.

                            </p>


                            <button
                                className="formations-back-button"
                                onClick={retournerAuxResultats}
                            >

                                <FaArrowLeft />

                                Retour aux recommandations

                            </button>

                        </div>

                    )}


                {/* =====================================
                    LISTE DES FORMATIONS
                ===================================== */}

                {!chargement &&
                    !erreur &&
                    formations.length > 0 && (

                        <div className="formations-list">


                            {formations.map((formation) => (

                                <article
                                    className="formation-card"
                                    key={formation.id_filiere}
                                >


                                    {/* En-tête formation */}

                                    <div className="formation-card-header">


                                        <div className="formation-card-icon">

                                            <FaGraduationCap />

                                        </div>


                                        <div className="formation-card-title">

                                            <span>

                                                FILIÈRE

                                            </span>


                                            <h3>

                                                {formation.nom}

                                            </h3>

                                        </div>

                                    </div>


                                    {/* Informations */}

                                    <div className="formation-info">


                                        <div className="formation-info-item">

                                            <MdCategory />

                                            <div>

                                                <span>

                                                    Domaine

                                                </span>

                                                <strong>

                                                    {formation.domaine}

                                                </strong>

                                            </div>

                                        </div>


                                        <div className="formation-info-item">

                                            <FaClock />

                                            <div>

                                                <span>

                                                    Durée

                                                </span>

                                                <strong>

                                                    {formation.duree}

                                                </strong>

                                            </div>

                                        </div>


                                    </div>


                                    {/* Description */}

                                    {formation.description && (

                                        <div className="formation-description">


                                            <div className="formation-description-icon">

                                                <FaInfoCircle />

                                            </div>


                                            <p>

                                                {formation.description}

                                            </p>

                                        </div>

                                    )}


                                    {/* Action */}

                                    <div className="formation-card-action">


                                        <button
                                            className="university-button"
                                            onClick={() =>
                                                consulterUniversite(
                                                    formation,
                                                    metier,
                                                    resultat
                                                )
                                            }
                                        >

                                            <FaUniversity />

                                            <span>

                                                Voir les universités

                                            </span>

                                            <FaArrowRight />

                                        </button>


                                    </div>


                                </article>

                            ))}


                        </div>

                    )}

            </main>


            {/* =====================================
                NAVIGATION BAS DE PAGE
            ===================================== */}

            {!chargement && (

                <footer className="formations-footer">


                    <div className="formations-footer-content">


                        <FaGraduationCap />


                        <p>

                            Choisissez une formation qui correspond
                            à votre projet, puis découvrez où l'étudier.

                        </p>

                    </div>


                    <button
                        className="back-result-button"
                        onClick={retournerAuxResultats}
                    >

                        <FaArrowLeft />

                        Retour aux résultats

                    </button>


                </footer>

            )}


        </div>

    );

}


export default Formations;

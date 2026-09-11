import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";

import { useLocation, useNavigate } from "react-router-dom";

import {
    FaArrowLeft,
    FaUniversity,
    FaGlobe,
    FaMapMarkerAlt,
    FaHome,
    FaInfoCircle
} from "react-icons/fa";

import { MdLocationCity } from "react-icons/md";

import "../styles/Universites.css";

import { enregistrerAction } from "../services/historiqueService";


function Universites() {

    const navigate = useNavigate();

    const location = useLocation();


    /*
        Données reçues depuis Formations.jsx
    */

    const filiere = location.state?.filiere;

    const metier = location.state?.metier;

    const resultat = location.state?.resultat;


    const nomFiliere = filiere?.nom || "cette formation";

    const afficherTypeUniversite = (type) => {
    if (type === "privee") {
        return "Privée";
    }

    if (type === "publique") {
        return "Publique";
    }

    return type || "Non renseigné";
    };


    /*
        Etats
    */

    const [universites, setUniversites] = useState([]);

    const [chargement, setChargement] = useState(true);

    const [erreur, setErreur] = useState(null);


    /*
        Vérification de sécurité
    */

    if (!filiere) {

        return (

            <div className="universites-empty">

                <div className="universites-empty-icon">
                    <FaUniversity />
                </div>

                <h1>
                    Aucune formation sélectionnée
                </h1>

                <p>
                    Veuillez d'abord choisir une formation.
                </p>

                <button
                    className="empty-back-button"
                    onClick={() => navigate("/formations")}
                >
                    <FaArrowLeft />
                    Retour aux formations
                </button>

            </div>

        );

    }


    /*
        Chargement des universités
    */

    useEffect(() => {

        const chargerUniversites = async () => {

            try {

                const reponse = await fetch(
                    `${API_ROUTES_URL}/universites.php?id_filiere=${filiere.id_filiere}`
                );


                const data = await reponse.json();


                console.log("Universités reçues :", data);


                if (data.success) {

                    setUniversites(data.universites);

                }

                else {

                    setErreur(data.message);

                }

            }

            catch (error) {

                console.error(error);

                setErreur(
                    "Erreur lors du chargement des universités."
                );

            }

            finally {

                setChargement(false);

            }

        };


        chargerUniversites();

    }, [filiere]);


    /*
        Chargement
    */

    if (chargement) {

        return (

            <div className="universites-loading">

                <div className="universites-loading-spinner"></div>

                <h2>
                    Chargement des universités...
                </h2>

                <p>
                    Veuillez patienter quelques instants.
                </p>

            </div>

        );

    }


    /*
        Gestion des erreurs
    */

    if (erreur) {

        return (

            <div className="universites-error">

                <div className="universites-state-icon">
                    <FaInfoCircle />
                </div>

                <h2>
                    {erreur}
                </h2>

                <p>
                    Une erreur est survenue lors du chargement
                    des établissements.
                </p>

                <button
                    className="back-formation-button"
                    onClick={() =>
                        navigate("/formations", {
                            state: {
                                filiere,
                                metier,
                                resultat
                            }
                        })
                    }
                >
                    <FaArrowLeft />
                    Retour aux formations
                </button>

            </div>

        );

    }


    return (

        <div className="universites-page">


            {/* =====================================================
                NAVIGATION
            ===================================================== */}

            <nav className="universites-navigation">

                <button
                    className="universites-back-button"
                    onClick={() =>
                        navigate("/formations", {
                            state: {
                                filiere,
                                metier,
                                resultat
                            }
                        })
                    }
                >

                    <FaArrowLeft />

                    Retour aux formations

                </button>

            </nav>


            {/* =====================================================
                HERO
            ===================================================== */}

            <header className="universites-header">

                <div className="universites-header-icon">

                    <FaUniversity />

                </div>


                <div className="universites-header-content">

                    <span className="universites-eyebrow">
                        ÉTABLISSEMENTS DE FORMATION
                    </span>


                    <h1>

                        Où étudier la filière{" "}

                        <span className="filiere-title">
                            {nomFiliere}
                        </span>
                        {" "}
                        ?

                    </h1>


                    <p>
                        Découvrez les établissements qui proposent
                        cette formation et explorez leurs informations
                        pour préparer votre parcours universitaire.
                    </p>

                </div>

            </header>


            {/* =====================================================
                FILIERE SELECTIONNEE
            ===================================================== */}

            <section className="filiere-context">

                <div className="filiere-context-icon">

                    <FaUniversity />

                </div>


                <div className="filiere-context-content">

                    <span>
                        FORMATION SÉLECTIONNÉE
                    </span>

                    <strong>
                        {nomFiliere}
                    </strong>

                </div>

            </section>


            {/* =====================================================
                CONTENU PRINCIPAL
            ===================================================== */}

            <main className="universites-content">


                <div className="universites-section-header">

                    <div>

                        <span className="section-eyebrow">
                            ÉTABLISSEMENTS DISPONIBLES
                        </span>

                        <h2>
                            Universités proposant cette formation
                        </h2>

                        <p>
                            Consultez les établissements disponibles
                            et accédez directement à leur site officiel.
                        </p>

                    </div>


                    <div className="universites-count">

                        <FaUniversity />

                        <span>
                            {universites.length}
                        </span>

                        <small>
                            établissement{universites.length > 1 ? "s" : ""} trouvé{universites.length > 1 ? "s" : ""}
                        </small>

                    </div>

                </div>


                {/* =================================================
                    LISTE DES UNIVERSITES
                ================================================= */}

                {universites.length === 0 ? (

                    <div className="universites-empty">

                        <div className="universites-empty-icon">
                            <FaUniversity />
                        </div>

                        <h2>
                            Aucun établissement trouvé
                        </h2>

                        <p>
                            Aucune université ne propose actuellement
                            cette formation dans notre catalogue.
                        </p>

                    </div>

                ) : (

                    <section className="universites-list">

                        {universites.map((universite) => (

                            <article
                                className="universite-card"
                                key={universite.id_universite}
                            >


                                {/* En-tête carte */}

                                <div className="universite-card-header">

                                    <div className="universite-card-icon">

                                        <FaUniversity />

                                    </div>


                                    <div className="universite-card-title">

                                        <span>
                                            ÉTABLISSEMENT
                                        </span>

                                        <h3>
                                            {universite.nom}
                                        </h3>

                                    </div>

                                </div>


                                {/* Informations */}

                                <div className="universite-info">


                                    <div className="universite-info-item">

                                        <FaMapMarkerAlt />

                                        <div>

                                            <span>
                                                Ville
                                            </span>

                                            <strong>
                                                {universite.ville || "Non renseignée"}
                                            </strong>

                                        </div>

                                    </div>


                                    <div className="universite-info-item">

                                        <MdLocationCity />

                                        <div>

                                            <span>
                                                Pays
                                            </span>

                                            <strong>
                                                {universite.pays || "Non renseigné"}
                                            </strong>

                                        </div>

                                    </div>


                                    <div className="universite-info-item">

                                        <FaUniversity />

                                        <div>

                                            <span>
                                                Type
                                            </span>

                                            <strong>
                                 {afficherTypeUniversite(universite.type)}
                                          </strong>

                                        </div>

                                    </div>


                                </div>


                                {/* Description */}

                                {universite.description && (

                                    <div className="universite-description">

                                        <FaInfoCircle />

                                        <p>
                                            {universite.description}
                                        </p>

                                    </div>

                                )}


                                {/* Action */}

                                {universite.site_web && (

                                    <div className="universite-card-action">

                                        <a
                                            href={universite.site_web}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            className="site-button"
                                            onClick={() =>
                                                enregistrerAction(
                                                    `UNIVERSITE_CONSULTEE: ${universite.nom}`
                                                )
                                            }
                                        >

                                            <FaGlobe />

                                            Visiter le site officiel

                                        </a>

                                    </div>

                                )}

                            </article>

                        ))}

                    </section>

                )}

            </main>


            {/* =====================================================
                FOOTER / ACTIONS
            ===================================================== */}

            <footer className="universites-footer">

                <div className="universites-footer-content">

                    <FaUniversity />

                    <p>
                        Comparez les établissements et choisissez
                        celui qui correspond le mieux à votre projet.
                    </p>

                </div>


                <div className="universites-actions">

                    <button
                        className="back-formation-button"
                        onClick={() =>
                            navigate("/formations", {
                                state: {
                                    filiere,
                                    metier,
                                    resultat
                                }
                            })
                        }
                    >

                        <FaArrowLeft />

                        Retour aux formations

                    </button>


                    <button
                        className="home-button"
                        onClick={() => navigate("/dashboard")}
                    >

                        <FaHome />

                        Retour à l'accueil

                    </button>

                </div>

            </footer>


        </div>

    );

}


export default Universites;

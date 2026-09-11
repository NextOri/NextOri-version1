import { API_ROUTES_URL } from "../config/api";
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import FooterNavigation from "../components/FooterNavigation";
import {
    FaGraduationCap,
    FaFolderOpen,
    FaClock,
    FaBriefcase,
    FaUniversity,
    FaArrowLeft,
    FaTools
} from "react-icons/fa";
import "../styles/FiliereDetail.css";

function FiliereDetail() {

    const { id_filiere } = useParams();

    const navigate = useNavigate();

    const [filiere, setFiliere] = useState(null);
    const [loading, setLoading] = useState(true);
    const [metiers, setMetiers] = useState([]);
    const [universites, setUniversites] = useState([]);

    useEffect(() => {

        fetch(
            `${API_ROUTES_URL}/filiere_details.php?id_filiere=${id_filiere}`
        )

        .then(response => response.json())

        .then(data => {

            if (data.success) {

                setFiliere(data.data);

                setMetiers(
                    Array.isArray(data.metiers)
                        ? data.metiers
                        : []
                );

                setUniversites(
                    Array.isArray(data.universites)
                        ? data.universites
                        : []
                );

            }

            setLoading(false);

        })

        .catch(error => {

            console.error(
                "Erreur récupération filière :",
                error
            );

            setLoading(false);

        });

    }, [id_filiere]);


    /*
     * État de chargement
     */
    if (loading) {

        return (

            <div className="loading-container">

                <div className="loading-spinner"></div>

                <p>Chargement de la filière...</p>

            </div>

        );

    }


    /*
     * Filière introuvable
     */
    if (!filiere) {

        return (

            <div className="filiere-introuvable">

                <FaGraduationCap className="introuvable-icon" />

                <h2>Filière introuvable</h2>

                <p>
                    Cette filière n'existe pas ou n'est plus disponible.
                </p>

                <button
                    className="retour-btn"
                    onClick={() => navigate("/filieres")}
                >

                    <FaArrowLeft />

                    <span>Retour aux filières</span>

                </button>

            </div>

        );

    }


    return (

        <div className="filiere-detail-page">


            {/* ================================
                EN-TÊTE
            ================================= */}

            <div className="filiere-detail-header">

                <div className="filiere-title-container">

                    <FaGraduationCap className="filiere-main-icon" />

                    <h1>{filiere.nom}</h1>

                </div>


                <div className="header-infos">

                    <span>

                        <FaFolderOpen />

                        {filiere.domaine}

                    </span>

                    <span>

                        <FaClock />

                        {filiere.duree}

                    </span>

                </div>

            </div>



            {/* ================================
                PRÉSENTATION
            ================================= */}

            <section className="detail-section">

                <h2>
                    <FaGraduationCap />
                    Présentation
                </h2>

                <p>
                    {filiere.presentation}
                </p>

            </section>



            {/* ================================
                COMPÉTENCES
            ================================= */}

            <section className="detail-section">

                <h2>
                    <FaTools />
                    Compétences développées
                </h2>

                <div className="competences-container">

                    {
                        filiere.competences_developpees
                            ? filiere.competences_developpees
                                .split(",")
                                .map((competence, index) => (

                                    <span
                                        key={index}
                                        className="competence-badge"
                                    >

                                        {competence.trim()}

                                    </span>

                                ))
                            : (
                                <p>
                                    Aucune compétence renseignée.
                                </p>
                            )
                    }

                </div>

            </section>



            {/* ================================
                MÉTIERS
            ================================= */}

            <section className="detail-section">

                <h2>
                    <FaBriefcase />
                    Métiers accessibles après cette filière
                </h2>


                {
                    metiers.length > 0 ? (

                        <div className="filiere-metiers-container">

                            {
                                metiers.map((metier) => (

                                    <button
                                        key={metier.id_metier}
                                        className="filiere-metier-card"
                                        onClick={() =>
                                            navigate(
                                                `/metiers/${metier.id_metier}`
                                            )
                                        }
                                    >

                                        <FaBriefcase />

                                        <span>
                                            {metier.nom}
                                        </span>

                                    </button>

                                ))
                            }

                        </div>

                    ) : (

                        <p className="empty-message">
                            Aucun métier associé à cette filière.
                        </p>

                    )
                }

            </section>



            {/* ================================
                UNIVERSITÉS
            ================================= */}

            <section className="detail-section">

                <h2>
                    <FaUniversity />
                    Universités proposant cette filière
                </h2>


                {
                    universites.length > 0 ? (

                        <div className="filiere-universites-container">

                            {
                                universites.map((universite) => (

                                    <button
                                        key={universite.id_universite}
                                        className="filiere-universite-card"
                                        onClick={() =>
                                            navigate(
                                                `/universite-catalogue/${universite.id_universite}`
                                            )
                                        }
                                    >

                                        <div className="universite-icon-container">

                                            <FaUniversity />

                                        </div>

                                        <div className="universite-info">

                                            <h3>
                                                {universite.nom}
                                            </h3>

                                            {
                                                universite.ville && (

                                                    <span>
                                                        {universite.ville}
                                                    </span>

                                                )
                                            }

                                        </div>

                                    </button>

                                ))
                            }

                        </div>

                    ) : (

                        <p className="empty-message">
                            Aucune université associée à cette filière.
                        </p>

                    )
                }

            </section>



            {/* ================================
                RETOUR
            ================================= */}

            <button
                className="retour-btn"
                onClick={() => navigate("/filieres")}
            >

                <FaArrowLeft />

                <span>Retour aux filières</span>

            </button>


            <FooterNavigation />

        </div>

    );

}

export default FiliereDetail;

import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";

import FooterNavigation from "../components/FooterNavigation";

import "../styles/universite-detail.css";

import { afficherTypeUniversite } from "../utils/universiteUtils";
import { enregistrerAction } from "../services/historiqueService";

import {
    FaUniversity,
    FaMapMarkerAlt,
    FaGlobe,
    FaGraduationCap,
    FaBookOpen,
    FaFileAlt,
    FaGift,
    FaArrowLeft,
    FaExternalLinkAlt,
    FaClock,
    FaPhone,
    FaEnvelope,
} from "react-icons/fa";


function UniversiteDetail() {

    const { id_universite } = useParams();

    const navigate = useNavigate();

    const [universite, setUniversite] = useState(null);
    const [detail, setDetail] = useState(null);
    const [filieres, setFilieres] = useState([]);
    const [chargement, setChargement] = useState(true);


    useEffect(() => {

        fetch(
            `${API_ROUTES_URL}/universite-detail.php?id_universite=${id_universite}`
        )
            .then((reponse) => reponse.json())

            .then((data) => {

                if (data.success) {

                    setUniversite(data.universite);
                    setDetail(data.detail);
                    setFilieres(data.filieres);

                }

                setChargement(false);

            })

            .catch((erreur) => {

                console.error(erreur);

                setChargement(false);

            });

    }, [id_universite]);


    /*
     * ================================
     * CHARGEMENT
     * ================================
     */

    if (chargement) {

        return (

            <div className="no-universite-detail-loading">

                <div className="no-universite-detail-spinner"></div>

                <FaUniversity className="no-universite-detail-loading-icon" />

                <p>Chargement de l'université...</p>

            </div>

        );

    }


    /*
     * ================================
     * UNIVERSITÉ INTROUVABLE
     * ================================
     */

    if (!universite) {

        return (

            <div className="no-universite-detail-not-found">

                <FaUniversity className="no-universite-detail-not-found-icon" />

                <h2>Université introuvable</h2>

                <p>
                    Cette université n'existe pas ou n'est plus disponible.
                </p>

                <button
                    className="no-universite-detail-retour-button"
                    onClick={() => navigate("/universite-catalogue")}
                >

                    <FaArrowLeft />

                    <span>Retour aux universités</span>

                </button>

            </div>

        );

    }


    return (

        <div className="no-universite-detail-page">


            {/* =========================================
                HEADER
            ========================================= */}

            <header className="no-universite-detail-header">

                <div className="no-universite-detail-logo-container">

                    <img
                        src={universite.logo}
                        alt={`Logo ${universite.nom}`}
                        className="no-universite-detail-logo"
                    />

                </div>


                <div className="no-universite-detail-title">

                    <div className="no-universite-detail-title-icon">

                        

                    </div>

                   <strong> <h2>{universite.description}</h2> </ strong>

                </div>


                <span className="no-universite-detail-type">

                    <FaGraduationCap />

                    {afficherTypeUniversite(universite.type)}

                </span>


                

            </header>



            {/* =========================================
                CONTENU
            ========================================= */}

            <main className="no-universite-detail-content">


                {/* ================= PRÉSENTATION ================= */}

                <section className="no-universite-detail-presentation">

                    <div className="no-universite-detail-section-title">

                        <div className="no-universite-detail-section-icon">
                            <FaBookOpen />
                        </div>

                        <div>
                            <span>À propos</span>
                            <h2>Présentation</h2>
                        </div>

                    </div>


                    <div className="no-universite-detail-text">

                        <p>
                            {detail?.presentation ||
                                "Aucune présentation disponible pour cette université."}
                        </p>

                    </div>

                </section>



                {/* ================= INFORMATIONS ================= */}

                <section className="no-universite-detail-informations">

                    <div className="no-universite-detail-section-title">

                        <div className="no-universite-detail-section-icon">
                            <FaUniversity />
                        </div>

                        <div>
                            <span>En bref</span>
                            <h2>Informations</h2>
                        </div>

                    </div>


                    <div className="no-universite-detail-info-grid">

                        <div className="no-universite-detail-info-item">

                            <FaMapMarkerAlt />

                            <div>
                                <span>Ville</span>
                                <strong>{universite.ville}</strong>
                            </div>

                        </div>


                        <div className="no-universite-detail-info-item">

                            <FaMapMarkerAlt />

                            <div>
                                <span>Région</span>
                                <strong>{universite.region}</strong>
                            </div>

                        </div>

                        {
    universite.adresse && (

        <div className="no-universite-detail-info-item">

            <FaMapMarkerAlt />

            <div>
                <span>Adresse</span>
                <strong>{universite.adresse}</strong>
            </div>

        </div>

    )
      }

                    </div>


                    
                </section>


                {/* ================= CONTACT ================= */}

<section className="no-universite-detail-contact">

    <div className="no-universite-detail-section-title">

        <div className="no-universite-detail-section-icon">
            <FaPhone />
        </div>

        <div>
            <span>Nous contacter</span>
            <h2>Contact</h2>
        </div>

    </div>


    <div className="no-universite-detail-info-grid">

        {
            universite.telephone && (

                <div className="no-universite-detail-info-item">

                    <FaPhone />

                    <div>
                        <span>Téléphone</span>

                        <a href={`tel:${universite.telephone}`}>
                            {universite.telephone}
                        </a>
                    </div>

                </div>

            )
        }


        {
            universite.email && (

                <div className="no-universite-detail-info-item">

                    <FaEnvelope />

                    <div>
                        <span>Email</span>

                        <a href={`mailto:${universite.email}`}>
                            {universite.email}
                        </a>
                    </div>

                </div>

            )
        }

    </div>


    {/* ================= SITE OFFICIEL ================= */}

    {
        universite.site_web && (

            <a
                href={universite.site_web}
                target="_blank"
                rel="noopener noreferrer"
                className="no-universite-detail-site-button"
                onClick={() =>
                    enregistrerAction(
                        `UNIVERSITE_CONSULTEE: ${universite.nom}`
                    )
                }
            >

                <FaGlobe />

                <span>Visiter le site officiel</span>

                <FaExternalLinkAlt className="external-icon" />

            </a>

        )
    }

</section>



                {/* ================= ADMISSION ================= */}

                <section className="no-universite-detail-admission">

                    <div className="no-universite-detail-section-title">

                        <div className="no-universite-detail-section-icon">
                            <FaFileAlt />
                        </div>

                        <div>
                            <span>Intégrer l'établissement</span>
                            <h2>Conditions d'admission</h2>
                        </div>

                    </div>


                    <div className="no-universite-detail-text">

                        <p>
                            {detail?.conditions_admission ||
                                "Aucune information sur les conditions d'admission n'est disponible."}
                        </p>

                    </div>

                </section>



                {/* ================= BOURSES ================= */}

                <section className="no-universite-detail-bourses">

                    <div className="no-universite-detail-section-title">

                        <div className="no-universite-detail-section-icon">
                            <FaGift />
                        </div>

                        <div>
                            <span>Financement</span>
                            <h2>Bourses et aides</h2>
                        </div>

                    </div>


                    <div className="no-universite-detail-text">

                        <p>
                            {detail?.bourses ||
                                "Aucune information sur les bourses n'est disponible."}
                        </p>

                    </div>

                </section>



                {/* ================= FILIÈRES ================= */}

                <section className="no-universite-detail-filieres">

                    <div className="no-universite-detail-section-title">

                        <div className="no-universite-detail-section-icon">
                            <FaGraduationCap />
                        </div>

                        <div>
                            <span>Parcours académiques</span>
                            <h2>Filières proposées</h2>
                        </div>

                    </div>


                    {
                        filieres.length > 0 ? (

                            <div className="no-universite-detail-filieres-grid">

                                {
                                    filieres.map((filiere) => (

                                        <article
                                            key={filiere.id_filiere}
                                            className="no-universite-detail-filiere-card"
                                        >

                                            <div className="no-universite-detail-filiere-icon">

                                                <FaGraduationCap />

                                            </div>


                                            <div className="no-universite-detail-filiere-content">

                                                <h3>
                                                    {filiere.nom}
                                                </h3>

                                                <div className="no-universite-detail-filiere-meta">

                                                    <span>
                                                        <FaBookOpen />
                                                        {filiere.domaine}
                                                    </span>

                                                    <span>
                                                        <FaClock />
                                                        {filiere.duree}
                                                    </span>

                                                </div>

                                            </div>


                                            <button
                                                className="no-universite-detail-button"
                                                onClick={async () => {

                                                    await enregistrerAction(
                                                        `FORMATION_CONSULTEE: ${filiere.nom}`
                                                    );

                                                    navigate(
                                                        `/filieres/${filiere.id_filiere}`
                                                    );

                                                }}
                                            >

                                                <span>Voir la filière</span>

                                                <FaArrowLeft className="arrow-right" />

                                            </button>

                                        </article>

                                    ))
                                }

                            </div>

                        ) : (

                            <div className="no-universite-detail-empty">

                                <FaGraduationCap />

                                <p>
                                    Aucune filière n'est actuellement renseignée
                                    pour cette université.
                                </p>

                            </div>

                        )
                    }

                </section>

            </main>



            {/* =========================================
                RETOUR
            ========================================= */}

            <div className="no-universite-detail-retour">

                <button
                    onClick={() =>
                        navigate("/universite-catalogue")
                    }
                    className="no-universite-detail-retour-button"
                >

                    <FaArrowLeft />

                    <span>Retour aux universités</span>

                </button>

            </div>


            <FooterNavigation />

        </div>

    );

}

export default UniversiteDetail;

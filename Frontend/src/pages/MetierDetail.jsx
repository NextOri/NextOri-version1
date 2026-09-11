import { API_ROUTES_URL } from "../config/api";
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "../styles/MetierDetail.css";
import FooterNavigation from "../components/FooterNavigation";

import {
    FaChartLine,
    FaGraduationCap,
    FaMoneyBillWave,
    FaArrowLeft,
    FaBriefcase,
    FaBookOpen,
    FaCircleInfo
    
} from "react-icons/fa6";


function MetierDetail() {


    const { id_metier } = useParams();

    const navigate = useNavigate();


    const [metier, setMetier] = useState(null);

    const [loading, setLoading] = useState(true);



    useEffect(() => {


        fetch(
            `${API_ROUTES_URL}/metiers_details.php?id_metier=${id_metier}`
        )

        .then((response) => response.json())

        .then((data) => {


            if(data.success){

                setMetier(data.data);

            }


            setLoading(false);


        })

        .catch((error) => {


            console.error(
                "Erreur récupération détail métier :",
                error
            );


            setLoading(false);


        });



    }, [id_metier]);




    if (loading) {

    return (

        <div className="loading-container">

            <div className="loading-spinner"></div>

            <p>Chargement du métier...</p>

        </div>

     );

    }



    if(!metier){

    return(

        <div className="metier-introuvable">

            <h2><FaCircleInfo /> Métier introuvable</h2>

            <p>

                Le métier demandé n'existe pas ou n'est plus disponible.

            </p>

            <button
                className="retour-btn"
                onClick={()=>navigate("/metiers")}
            >

                <FaArrowLeft /> Retour aux métiers

            </button>

        </div>

     );

    }



    return (

        <div className="metier-detail-page">


            {/* En-tête */}

            <div className="metier-detail-header">


                <h1>{metier.nom}</h1>


                <div className="metier-tendance">

                    <FaChartLine /> {metier.tendance}

                </div>


                <p className="metier-secteur">

        <FaBriefcase />

        {metier.secteur}

     </p>


            </div>




            {/* Présentation */}

            <section className="detail-section">


                <h2>
                    <FaBookOpen /> Présentation du métier</h2>


                <p>
                    {metier.presentation}
                </p>


            </section>





            {/* Compétences */}

            <section className="detail-section">


                <h2><FaBriefcase /> Compétences nécessaires</h2>


                <div className="competences-container">

         {
        metier.competences
        .split(",")
        .map((competence, index) => (

            <span
                key={index}
                className="competence-badge"
            >
                {competence.trim()}
            </span>

        ))
       }

        </div>


            </section>





            {/* Informations */}

            <section className="detail-section">


                <h2><FaCircleInfo /> Informations</h2>


                <div className="infos-grid">


                    <div className="info-item">

    <FaGraduationCap />

    <span>
        Niveau d'étude
    </span>

    <strong>
        {metier.niveau_etude}
    </strong>

</div>


<div className="info-item">

    <FaMoneyBillWave />

    <span>
        Salaire minimum
    </span>

    <strong>
        {metier.salaire_min} FCFA
    </strong>

</div>


<div className="info-item">

    <FaMoneyBillWave />

    <span>
        Salaire maximum
    </span>

    <strong>
        {metier.salaire_max} FCFA
    </strong>

</div>


                </div>


            </section>





            {/* Filières */}

            <section className="detail-section">


                <h2><FaGraduationCap /> Filières liées</h2>



                <div className="filieres-container">


                    {
                        metier.filieres.map((filiere)=>(
                            
                            <button
    key={filiere.id_filiere}
    className="metier-filiere-card"
    onClick={() => navigate(`/filieres/${filiere.id_filiere}`)}
>
    <FaGraduationCap />

    <span>
        {filiere.nom}
    </span>
       </button>

                        ))
                    }


                </div>


            </section>





            <button
                className="retour-btn"
                onClick={()=>navigate("/metiers")}
            >

                <FaArrowLeft /> Retour aux métiers

            </button>

            

              <FooterNavigation />



        </div>

    );

}



export default MetierDetail;

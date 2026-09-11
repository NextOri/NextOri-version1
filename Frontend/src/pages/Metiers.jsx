import { API_ROUTES_URL } from "../config/api";
import React, { useState, useEffect } from "react";
import "../styles/Metiers.css";
import FooterNavigation from "../components/FooterNavigation";

import { useNavigate } from "react-router-dom";
import { enregistrerAction } from "../services/historiqueService";

import {
    FaBriefcase,
    FaBuilding,
    FaGraduationCap,
    FaMoneyBillWave,
    FaRocket,
    FaChartLine,
    FaArrowTrendUp,
    FaMinus,
    FaArrowTrendDown,
    FaChartBar,
    FaFaceFrown
} from "react-icons/fa6";

import { FaSearch } from "react-icons/fa";


function Metiers() {
     
    const navigate = useNavigate();
    // 1) États
    const [metiers, setMetiers] = useState([]);
    const [recherche, setRecherche] = useState(
    () => sessionStorage.getItem("metiers_recherche") || "");
    const [secteur, setSecteur] = useState(
    () => sessionStorage.getItem("metiers_secteur") || "Tous");
    const [niveauEtude, setNiveauEtude] = useState("Tous");
    const [chargement, setChargement] = useState(true);


   
  

    // 2) Récupération des métiers depuis le backend
    useEffect(() => {

    fetch(`${API_ROUTES_URL}/metiers.php`)

        .then((response) => response.json())

        .then((data) => {

            if (data.success) {

                setMetiers(data.data);

            }

        })

        .catch((error) => {

            console.error(
                "Erreur récupération métiers :",
                error
            );

        })

        .finally(() => {

            setChargement(false);

        });

}, []);



useEffect(() => {

    sessionStorage.setItem(
        "metiers_recherche",
        recherche
    );

}, [recherche]);


useEffect(() => {

    sessionStorage.setItem(
        "metiers_secteur",
        secteur
    );

}, [secteur]);


useEffect(() => {

    sessionStorage.setItem(
        "metiers_niveau",
        niveauEtude
    );

}, [niveauEtude]);


     const getTendanceIcon = (tendance) => {

    switch (tendance) {

        case "Très forte croissance":
            return <FaRocket />;

        case "Forte croissance":
            return <FaChartLine />;

        case "En croissance":
            return <FaArrowTrendUp />;

        case "Stable":
            return <FaMinus />;

        case "En baisse":
            return <FaArrowTrendDown />;

        default:
            return <FaChartBar />;
    }

};

     const getTendanceClass = (tendance) => {

    switch (tendance) {

        case "Très forte croissance":
            return "tendance-tres-forte";

        case "Forte croissance":
            return "tendance-forte";

        case "En croissance":
            return "tendance-croissance";

        case "Stable":
            return "tendance-stable";

        case "En baisse":
            return "tendance-baisse";

        default:
            return "";
    }

    };



    const secteurs = [
        "Tous",
        ...new Set(metiers.map((metier) => metier.secteur))
    ];


    const niveaux = [
        "Tous",
        ...new Set(metiers.map((metier) => metier.niveau_etude))
    ];

  
    const normaliserTexte = (texte) => {

    return texte
        .normalize("NFD") 
        .replace(/[\u0300-\u036f]/g, "")
        .toLowerCase()
        .trim();

    };

    const resultats = metiers.filter((metier) => {


        const rechercheOK =
    normaliserTexte(metier.nom)
        .includes(
            normaliserTexte(recherche)
        );


        const secteurOK =
            secteur === "Tous" ||
            metier.secteur === secteur;


        const niveauOK =
            niveauEtude === "Tous" ||
            metier.niveau_etude === niveauEtude;



        return rechercheOK && secteurOK && niveauOK;


    });

   






    return (

        <div className="metiers-page">


            <div className="metiers-header">

                <h1>
                    <FaBriefcase 
                    className="metiers-header-icon"
                    /> Catalogue des métiers
                </h1>


                <p>
                    Découvrez les métiers, leurs secteurs,
                    niveaux d'études, salaires et tendances.
                </p>

            </div>



          <div className="metiers-filtres">

    <div className="filtre-item">

        <label>

            <FaSearch/>
             Rechercher

        </label>

        <input

            className="metiers-search"

            type="text"

            placeholder="Ex : Développeur Web..."

            value={recherche}

            onChange={(e)=>setRecherche(e.target.value)}

        />

    </div>



    <div className="filtre-item">

        <label>

            <FaBuilding/>
             Secteur

        </label>

        <select

            value={secteur}

            onChange={(e)=>setSecteur(e.target.value)}

        >

            {

                secteurs.map((item)=>(

                    <option
                        key={item}
                        value={item}
                    >

                        {item}

                    </option>

                ))

            }

        </select>

    </div>



    <div className="filtre-item">

        <label>

            <FaGraduationCap/>
             Niveau d'étude

        </label>

        <select

            value={niveauEtude}

            onChange={(e)=>setNiveauEtude(e.target.value)}

        >

            {

                niveaux.map((item)=>(

                    <option
                        key={item}
                        value={item}
                    >

                        {item}

                    </option>

                ))

            }

        </select>

    </div>

</div>

           <div className="metiers-count">

             {resultats.length} métier{resultats.length > 1 ? "s" : ""} trouvé{resultats.length > 1 ? "s" : ""}

           </div>

      <div className="metiers-list">

    {
        chargement ? (

            <div className="metiers-loading">

                <div className="metiers-loading-spinner"></div>

                <h2>
                    Chargement des métiers...
                </h2>

                <p>
                    Veuillez patienter quelques instants.
                </p>

            </div>

        ) : resultats.length > 0 ? (

            resultats.map((metier) => (

                <div
                    className="metier-card"
                    key={metier.id_metier}
                >

                    <h2>
                        {metier.nom}
                    </h2>

                    <div className="metier-top-bar"></div>

                    <p>
                        {metier.description}
                    </p>

                    <p>
                        <strong>
                            <FaBuilding/> Secteur :
                        </strong>{" "}
                        {metier.secteur}
                    </p>

                    <p>
                        <strong>
                            <FaGraduationCap/> Niveau d'étude :
                        </strong>{" "}
                        {metier.niveau_etude}
                    </p>

                    <p>
                        <strong>
                            <FaMoneyBillWave/> Salaire :
                        </strong>{" "}

                        {metier.salaire_min.toLocaleString("fr-FR")}
                        {" à "}
                        {metier.salaire_max.toLocaleString("fr-FR")}
                        {" FCFA"}
                    </p>

                    <p>

                        <strong>
                            Tendance :
                        </strong>

                        <span
                            className={`tendance-badge ${getTendanceClass(metier.tendance)}`}
                        >

                            {getTendanceIcon(metier.tendance)}
                            {" "}
                            {metier.tendance}

                        </span>

                    </p>

                    <button
                        className="metier-button"
                        onClick={async () => {

                            await enregistrerAction(
                                `METIER_CONSULTE: ${metier.nom}`
                            );

                            navigate(
                                `/metiers/${metier.id_metier}`
                            );

                        }}
                    >
                        Voir détails →
                    </button>

                </div>

            ))

        ) : (

            <div className="aucun-metier">

                <h2>
                    <FaFaceFrown/> Aucun métier trouvé
                </h2>

                <p>
                    Essayez un autre mot-clé,
                    un autre secteur
                    ou un autre niveau d'étude.
                </p>

            </div>

        )

    }

</div>



<FooterNavigation />


        </div>

    );



}



export default Metiers;

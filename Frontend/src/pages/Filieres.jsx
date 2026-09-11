import { API_ROUTES_URL } from "../config/api";
import React, { useState, useEffect } from "react";
import "../styles/Filieres.css";
import FooterNavigation from "../components/FooterNavigation";

import { useNavigate } from "react-router-dom";
import { enregistrerAction } from "../services/historiqueService";

import {
    FaSearch,
    FaTag,
    FaClock,
    FaArrowRight,
    FaFrown,
    FaGraduationCap
} from "react-icons/fa";


function Filieres() {

    const navigate = useNavigate();

    const [filieres, setFilieres] = useState([]);

const [recherche, setRecherche] = useState(
    () => sessionStorage.getItem("filieres_recherche") || ""
);

const [domaine, setDomaine] = useState(
    () => sessionStorage.getItem("filieres_domaine") || "Tous"
);

const [duree, setDuree] = useState(
    () => sessionStorage.getItem("filieres_duree") || "Tous"
);

const [chargement, setChargement] = useState(true);


    useEffect(() => {

        fetch(`${API_ROUTES_URL}/filiere.php`)

            .then((response) => response.json())

            .then((data) => {

                if (data.success) {

                    setFilieres(data.data);

                }

            })

            .catch((error) => {

                console.error(
                    "Erreur récupération filières :",
                    error
                );

            })
            .finally(() => {

                setChargement(false);

            });

    }, []);


    useEffect(() => {

    sessionStorage.setItem(
        "filieres_recherche",
        recherche
    );

}, [recherche]);


useEffect(() => {

    sessionStorage.setItem(
        "filieres_domaine",
        domaine
    );

}, [domaine]);


useEffect(() => {

    sessionStorage.setItem(
        "filieres_duree",
        duree
    );

}, [duree]);


    const domaines = [

        "Tous",

        ...new Set(

            filieres.map((filiere) => filiere.domaine)

        )

    ];


    const durees = [

        "Tous",

        ...new Set(

            filieres.map((filiere) => filiere.duree)

        )

    ];


    const normaliserTexte = (texte) => {

        return texte
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .toLowerCase()
            .trim();

    };


    const resultats = filieres.filter((filiere) => {

        const rechercheOK =
            normaliserTexte(filiere.nom)
                .includes(
                    normaliserTexte(recherche)
                );


        const domaineOK =
            domaine === "Tous"
                ? true
                : filiere.domaine === domaine;


        const dureeOK =
            duree === "Tous"
                ? true
                : filiere.duree === duree;


        return rechercheOK && domaineOK && dureeOK;

    });


    return (

        <div className="filieres-page">


            <div className="filieres-header">

                <h1>
                    <FaGraduationCap className="filiere-header-icon" />
                    Catalogue des filières
                </h1>

                <p>
                    Découvrez les différentes filières,
                    leurs domaines et leurs durées.
                </p>

            </div>


            <div className="filieres-filtres">


                <div className="filtre-item">

                    <label>
                        <FaSearch />
                        Rechercher
                    </label>

                    <input
                        type="text"
                        className="filieres-search"
                        placeholder="Ex : Informatique..."
                        value={recherche}
                        onChange={(e) =>
                            setRecherche(e.target.value)
                        }
                    />

                </div>


                <div className="filtre-item">

                    <label>
                        <FaTag />
                        Domaine
                    </label>

                    <select
                        value={domaine}
                        onChange={(e) =>
                            setDomaine(e.target.value)
                        }
                    >

                        {
                            domaines.map((item) => (

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
                        <FaClock />
                        Durée
                    </label>

                    <select
                        value={duree}
                        onChange={(e) =>
                            setDuree(e.target.value)
                        }
                    >

                        {
                            durees.map((item) => (

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


            <div className="filieres-count">

                {resultats.length}
                {" "}
                filière
                {resultats.length > 1 ? "s" : ""}
                {" "}
                trouvée
                {resultats.length > 1 ? "s" : ""}

            </div>


            <div className="filieres-list">

    {

        chargement ? (

            <div className="filieres-loading">

                <div className="filieres-loading-spinner"></div>

                <h2>
                    Chargement des filières...
                </h2>

                <p>
                    Veuillez patienter quelques instants.
                </p>

            </div>

        ) : resultats.length > 0 ? (

            resultats.map((filiere) => (

                <div
                    className="filiere-card"
                    key={filiere.id_filiere}
                >

                    <h2>
                        {filiere.nom}
                    </h2>

                    <div className="filiere-top-bar"></div>

                    <p>
                        {filiere.description}
                    </p>

                    <p>

                        <strong>
                            <FaTag />
                            Domaine :
                        </strong>

                        {" "}

                        {filiere.domaine}

                    </p>

                    <p>

                        <strong>
                            <FaClock />
                            Durée :
                        </strong>

                        {" "}

                        {filiere.duree}

                    </p>

                    <button
                        className="filiere-button"
                        onClick={async () => {

                            await enregistrerAction(
                                `FORMATION_CONSULTEE: ${filiere.nom}`
                            );

                            navigate(
                                `/filieres/${filiere.id_filiere}`
                            );

                        }}
                    >

                        Voir détails

                        <FaArrowRight />

                    </button>

                </div>

            ))

        ) : (

            <div className="aucune-filiere">

                <h2>

                    <FaFrown />
                    Aucune filière trouvée

                </h2>

                <p>

                    Essayez un autre mot-clé,
                    un autre domaine
                    ou une autre durée.

                </p>

            </div>

        )

    }

</div>

            <FooterNavigation />

        </div>

    );

}


export default Filieres;

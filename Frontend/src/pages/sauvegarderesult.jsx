import { API_ROUTES_URL } from "../config/api";
import React, { useState, useEffect } from "react";
import "../styles/Metiers.css";


function Metiers() {


    // 1) États
    const [metiers, setMetiers] = useState([]);

    const [recherche, setRecherche] = useState("");

    const [secteur, setSecteur] = useState("Tous");

    const [niveauEtude, setNiveauEtude] = useState("Tous");



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

            });


    }, []);




    // 3) Fonctions (icônes tendance, filtres...)
    
    const getTendanceIcon = (tendance) => {
        ...
    };


    const getTendanceClass = (tendance) => {
        ...
    };


    const secteurs = [
        "Tous",
        ...new Set(metiers.map((metier) => metier.secteur))
    ];


    const niveaux = [
        "Tous",
        ...new Set(metiers.map((metier) => metier.niveau_etude))
    ];



    const resultats = metiers.filter((metier) => {

        ...
        
    });



    // 4) Affichage
    return (

        <div className="metiers-page">

            ...

        </div>

    );

}


export default Metiers;

<?php

require_once "../services/FiliereService.php";


$service = new FiliereService();



$metiers = [

    [
        "id_metier" => 1,
        "nom" => "Développeur Web"
    ],

    [
        "id_metier" => 2,
        "nom" => "Data Scientist"
    ],

    [
        "id_metier" => 8,
        "nom" => "Administrateur Réseau"
    ]

];



$resultat =
    $service->rechercherFilieresCompatibles($metiers);



echo "<pre>";

print_r($resultat);

echo "</pre>";
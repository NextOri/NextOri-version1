<?php

require_once "../services/UniversiteService.php";

$service = new UniversiteService();

$filieres = [

    [
        "id_filiere" => 1,
        "nom" => "Informatique"
    ],

    [
        "id_filiere" => 7,
        "nom" => "Marketing"
    ]

];

$resultat = $service->rechercherUniversitesCompatibles($filieres);

echo "<pre>";
print_r($resultat);
echo "</pre>";
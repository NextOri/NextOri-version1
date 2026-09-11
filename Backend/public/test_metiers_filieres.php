<?php

require_once "../services/MetierService.php";
require_once "../services/FiliereService.php";


// Profil utilisateur

$profil = "IS";



// Recherche métiers

$metierService = new MetierService();

$recommandations =
    $metierService->obtenirRecommandations($profil);



// Recherche filières

$filiereService = new FiliereService();

$filieres =
    $filiereService->obtenirFilieresDepuisRecommandations(
        $recommandations
    );



echo "<h2>Métiers recommandés</h2>";

echo "<pre>";

print_r($recommandations);

echo "</pre>";



echo "<h2>Filières recommandées</h2>";

echo "<pre>";

print_r($filieres);

echo "</pre>";
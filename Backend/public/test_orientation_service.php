<?php

require_once "../services/OrientationService.php";


$service = new OrientationService();


// ================================
// 1. Création du test
// ================================

$idTest = $service->demarrerTest(
    1, // id_user
    1  // id_questionnaire
);


// ================================
// 2. Réponses de l'utilisateur
// ================================

$reponses = [

    ["id_proposition" => 1],
    ["id_proposition" => 7],
    ["id_proposition" => 13],
    ["id_proposition" => 19],
    ["id_proposition" => 25]

];


// ================================
// 3. Enregistrer les réponses
// ================================

$service->enregistrerReponses(
    $idTest,
    $reponses
);


// ================================
// 4. Calcul du profil RIASEC
// ================================

$resultatRiasec = $service->calculerProfil($idTest);


// Affichage scores + profil

echo "<h2>Résultat RIASEC</h2>";

echo "<pre>";

print_r($resultatRiasec);

echo "</pre>";



// ================================
// 5. Recherche des métiers
// ================================

$profil = $resultatRiasec["profil"]["profil_principal"];

$metiers = $service->rechercherMetiers($profil);


echo "<h2>Métiers recommandés</h2>";

echo "<pre>";

print_r($metiers);

echo "</pre>";


// ================================
// 5. Recherche des filières
// ================================

$filieres = $service->rechercherFilieres($metiers);

echo "<h2>Filières recommandées</h2>";

echo "<pre>";

print_r($filieres);

echo "</pre>";


// ================================
// 5. Recherche des universités
// ================================

$universites = $service->rechercherUniversites($filieres);

echo "<h2>Universités recommandées</h2>";

echo "<pre>";

print_r($universites);

echo "</pre>";



// ================================
// Information test
// ================================

echo "<h3>ID du test créé : $idTest</h3>";
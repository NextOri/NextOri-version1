<?php

require_once "../services/MetierService.php";
require_once "../repositories/TestRepository.php";


$metierService = new MetierService();
$testRepository = new TestRepository();


// ID du test transmis pour les tests
$idTest = isset($_GET['id_test'])
    ? (int) $_GET['id_test']
    : null;


// Profil RIASEC de test
$profil = "IS";


// Série de l'utilisateur
$idSerie = null;

if ($idTest !== null) {

    $idSerie =
        $testRepository->recupererSerieParTest($idTest);

}


// Génération des recommandations
$resultat =
    $metierService->formaterRecommandations(
        $profil,
        $idSerie
    );


header('Content-Type: application/json');


echo json_encode(
    $resultat,
    JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE
);
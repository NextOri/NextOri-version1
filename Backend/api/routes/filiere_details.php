<?php

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../../Services/FilieresService.php";

try {

    if (!isset($_GET["id_filiere"])) {

        throw new Exception("ID filière manquant.");

    }

    $idFiliere = (int) $_GET["id_filiere"];

    $filieresService = new FilieresService();

    $filiere = $filieresService->getById($idFiliere);

    if (!$filiere) {

        throw new Exception("Filière introuvable.");

    }

    $metiers = $filieresService->getMetiersByFiliere($idFiliere);

    $universites = $filieresService->getUniversitesByFiliere($idFiliere);

    echo json_encode([
        "success" => true,
        "data" => $filiere,
        "metiers" => $metiers,
        "universites" => $universites
    ]);

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);

}
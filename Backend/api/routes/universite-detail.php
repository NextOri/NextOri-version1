<?php
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . "/../../config/database.php";
require_once __DIR__ . "/../../services/UniversiteCatalogueService.php";

try {

    if (!isset($_GET["id_universite"]) || empty($_GET["id_universite"])) {

        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "Le paramètre id_universite est obligatoire."
        ]);

        exit;
    }

    $idUniversite = (int) $_GET["id_universite"];

    
    $service = new UniversiteCatalogueService();

    $universite = $service->getUniversiteById($idUniversite);

    if (!$universite) {

        http_response_code(404);

        echo json_encode([
            "success" => false,
            "message" => "Université introuvable."
        ]);

        exit;
    }

    $detail = $service->getUniversiteDetail($idUniversite);

    $filieres = $service->getFilieresByUniversite($idUniversite);

    echo json_encode([
        "success" => true,
        "universite" => $universite,
        "detail" => $detail,
        "filieres" => $filieres
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
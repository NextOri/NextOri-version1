<?php

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json");


if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {

    http_response_code(200);
    exit();

}


require_once __DIR__ . "/../../services/UniversiteCatalogueService.php";


try {

    $universiteCatalogueService = new UniversiteCatalogueService();


    $universites = $universiteCatalogueService->getAllUniversites();


    echo json_encode([
        "success" => true,
        "data" => $universites
    ]);


} catch (Exception $e) {


    http_response_code(500);


    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);


}
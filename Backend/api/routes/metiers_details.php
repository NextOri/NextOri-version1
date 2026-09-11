<?php

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Content-Type: application/json");


require_once __DIR__ . "/../../services/MetiersService.php";


try {


    if (!isset($_GET['id_metier'])) {

        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "ID métier manquant"
        ]);

        exit;
    }



    $idMetier = intval($_GET['id_metier']);



    $metiersService = new MetiersService();



    $metier = $metiersService->getMetierById($idMetier);



    if (!$metier) {

        http_response_code(404);

        echo json_encode([
            "success" => false,
            "message" => "Métier introuvable"
        ]);

        exit;
    }



    echo json_encode([
        "success" => true,
        "data" => $metier
    ]);



} catch (Exception $e) {


    http_response_code(500);


    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);

}
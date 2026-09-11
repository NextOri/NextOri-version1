<?php

header("Content-Type: application/json");

header("Access-Control-Allow-Origin: http://localhost:5173");

header("Access-Control-Allow-Headers: Content-Type");

header("Access-Control-Allow-Methods: GET, POST, OPTIONS");



require_once __DIR__ . "/../../services/MetiersService.php";


try {


    $metiersService = new MetiersService();


    $metiers = $metiersService->getAllMetiers();



    echo json_encode([

        "success" => true,

        "data" => $metiers

    ]);



} catch (Exception $e) {


    http_response_code(500);


    echo json_encode([

        "success" => false,

        "message" => $e->getMessage()

    ]);

}
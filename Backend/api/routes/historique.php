<?php

header("Content-Type: application/json");

header("Access-Control-Allow-Origin: http://localhost:5173");

header("Access-Control-Allow-Credentials: true");

header("Access-Control-Allow-Methods: POST, OPTIONS");

header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

session_start();


require_once __DIR__ . "/../../controllers/HistoriqueController.php";


try {


    $controller = new HistoriqueController();


    $controller->enregistrer();



} catch(Exception $e) {


    echo json_encode([

        "success" => false,

        "message" => $e->getMessage()

    ]);

}
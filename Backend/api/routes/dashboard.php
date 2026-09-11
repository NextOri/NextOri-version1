<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");
session_start();

error_log(
    "SESSION DASHBOARD : " . print_r($_SESSION, true)
);

require_once __DIR__ . "/../../Controllers/DashboardController.php";

try {

    
   if (!isset($_SESSION["id_user"])) {
    http_response_code(401);

    echo json_encode([
        "success" => false,
        "message" => "Utilisateur non connecté."
    ]);

    exit;
    }

    $idUser = (int) $_SESSION["id_user"];
    $controller = new DashboardController();

    $resultat = $controller->recupererDashboard($idUser);

    echo json_encode($resultat);

} catch (Exception $e) {

    echo json_encode([

        "success" => false,
        "message" => $e->getMessage()

    ]);

}
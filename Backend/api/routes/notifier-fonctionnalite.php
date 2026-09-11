<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(204);
    exit;
}

session_start();

require_once __DIR__ . "/../../Controllers/FonctionnaliteController.php";

try {

    if (!isset($_SESSION["id_user"])) {

        http_response_code(401);

        echo json_encode([
            "success" => false,
            "message" => "Utilisateur non connecté."
        ]);

        exit;
    }

    $donnees = json_decode(
        file_get_contents("php://input"),
        true
    );

    if (
        !isset($donnees["fonctionnalite"]) ||
        empty($donnees["fonctionnalite"])
    ) {

        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "Fonctionnalité non renseignée."
        ]);

        exit;
    }

    $idUser = (int) $_SESSION["id_user"];

    $fonctionnalite = trim(
        $donnees["fonctionnalite"]
    );

    $controller = new FonctionnaliteController();

    $resultat = $controller->inscrire(
        $idUser,
        $fonctionnalite
    );

    echo json_encode(
        $resultat,
        JSON_UNESCAPED_UNICODE
    );
} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}

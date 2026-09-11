<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

session_start();

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit;
}

require_once __DIR__ . "/../../Controllers/AvisController.php";

try {

    // Vérifier la connexion de l'utilisateur
    if (!isset($_SESSION["id_user"])) {

        http_response_code(401);

        echo json_encode([
            "success" => false,
            "message" => "Utilisateur non connecté."
        ]);

        exit;
    }

    // Récupérer l'utilisateur depuis la session
    $idUser = (int) $_SESSION["id_user"];

    // Vérifier la méthode HTTP
    if ($_SERVER["REQUEST_METHOD"] !== "POST") {

        http_response_code(405);

        echo json_encode([
            "success" => false,
            "message" => "Méthode non autorisée."
        ]);

        exit;
    }

    // Lire les données JSON
    $donnees = json_decode(
        file_get_contents("php://input"),
        true
    );

    if (!is_array($donnees)) {

        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "Données invalides."
        ]);

        exit;
    }

    // Récupérer les données
    $note = isset($donnees["note"])
        ? (int) $donnees["note"]
        : 0;

    $commentaire = isset($donnees["commentaire"])
        ? trim($donnees["commentaire"])
        : "";

    $afficher = isset($donnees["afficher"])
        ? (bool) $donnees["afficher"]
        : false;

    // Vérifier la note
    if ($note < 1 || $note > 5) {

        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "La note doit être comprise entre 1 et 5."
        ]);

        exit;
    }

    // Vérifier le commentaire
    if ($commentaire === "") {

        http_response_code(400);

        echo json_encode([
            "success" => false,
            "message" => "Veuillez écrire un commentaire."
        ]);

        exit;
    }

    // Enregistrer l'avis
    $controller = new AvisController();

    $resultat = $controller->enregistrerAvis(
        $idUser,
        $note,
        $commentaire,
        $afficher
    );

    echo json_encode([
        "success" => true,
        "message" => "Merci pour ton avis !",
        "data" => $resultat
    ]);
} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => "Une erreur est survenue lors de l'enregistrement de l'avis."
    ]);

    error_log("Erreur avis : " . $e->getMessage());
}

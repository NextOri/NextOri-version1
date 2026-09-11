<?php

require_once __DIR__ . "/../../Services/UserService.php";

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Content-Type: application/json; charset=UTF-8");


if ($_SERVER["REQUEST_METHOD"] !== "GET") {

    http_response_code(405);

    echo json_encode([
        "success" => false,
        "message" => "Méthode non autorisée."
    ]);

    exit();

}


if (!isset($_GET["id_user"])) {

    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "ID utilisateur manquant."
    ]);

    exit();

}


$idUser = intval($_GET["id_user"]);


$userService = new UserService();


$utilisateur = $userService->getUserById($idUser);


if ($utilisateur) {

    echo json_encode([
        "success" => true,
        "utilisateur" => $utilisateur
    ]);

} else {

    http_response_code(404);

    echo json_encode([
        "success" => false,
        "message" => "Utilisateur introuvable."
    ]);

}
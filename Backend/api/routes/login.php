<?php

require_once __DIR__ . "/../../services/UserService.php";

session_set_cookie_params([
    "lifetime" => 60 * 60 * 24 * 7,
    "path" => "/",
    "secure" => false,
    "httponly" => true,
    "samesite" => "Lax"
]);

session_start();

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Credentials: true");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] !== "POST") {

    http_response_code(405);

    echo json_encode([
        "success" => false,
        "message" => "Méthode non autorisée."
    ]);

    exit();
}

$donnees = json_decode(
    file_get_contents("php://input"),
    true
);

if (
    empty($donnees["email"]) ||
    empty($donnees["mot_de_passe"])
) {

    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Veuillez renseigner l'email et le mot de passe."
    ]);

    exit();
}

$userService = new UserService();

$utilisateur = $userService->login(
    $donnees["email"],
    $donnees["mot_de_passe"]
);

if ($utilisateur) {

    $idUser = (int) $utilisateur["id_user"];

    // Créer la session utilisateur
    $_SESSION["id_user"] = $idUser;

    

    echo json_encode([
        "success" => true,
        "message" => "Connexion réussie.",
        "utilisateur" => $utilisateur
    ]);

} else {

    http_response_code(401);

    echo json_encode([
        "success" => false,
        "message" => "Email ou mot de passe incorrect."
    ]);

}
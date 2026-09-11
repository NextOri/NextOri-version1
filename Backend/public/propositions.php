<?php

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../config/database.php";

try {

    if (!isset($_GET["id_question"])) {

        throw new Exception("id_question manquant.");

    }

    $db = new Database();

    $connexion = $db->connect();

    $sql = "

        SELECT

            id_proposition,

            lettre,

            libelle,

            type_riasec

        FROM proposition

        WHERE id_question = :id_question

        ORDER BY lettre

    ";

    $requete = $connexion->prepare($sql);

    $requete->execute([$_GET["id_question"]]);

    echo json_encode([

        "success" => true,

        "data" => $requete->fetchAll(PDO::FETCH_ASSOC)

    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

}
catch(Throwable $e){

    http_response_code(500);

    echo json_encode([

        "success"=>false,

        "message"=>$e->getMessage()

    ]);

}
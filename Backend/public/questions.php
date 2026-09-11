<?php

header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}





require_once __DIR__ . "/../config/database.php";


try {


    $db = new Database();

    $connexion = $db->connect();



    $sql = "

    SELECT

        id_question,

        texte,

        ordre

    FROM question

    WHERE id_questionnaire = 1

    ORDER BY ordre

  ";



    $requete = $connexion->prepare($sql);

    $requete->execute();



    $questions = $requete->fetchAll(PDO::FETCH_ASSOC);



    echo json_encode([

        "success" => true,

        "data" => $questions

    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {


    http_response_code(500);


    echo json_encode([

        "success" => false,

        "message" => $e->getMessage()

    ]);
}

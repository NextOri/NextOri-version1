<?php

header("Access-Control-Allow-Origin: http://localhost:5173");

header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

header("Access-Control-Allow-Headers: Content-Type, Authorization");

header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {

    http_response_code(200);

    exit();

}


require_once "../../config/database.php";

$database = new Database();

$connection = $database->connect();


/*
    Récupération de l'id métier
*/

$id_metier = $_GET["id_metier"] ?? null;



if(!$id_metier){


    echo json_encode([

        "success"=>false,

        "message"=>"Aucun métier fourni."

    ]);


    exit;

}

try {


    $sql = "
        SELECT 
            f.id_filiere,
            f.nom,
            f.description,
            f.domaine,
            f.duree

        FROM filiere f

        INNER JOIN metier_filiere mf

        ON f.id_filiere = mf.id_filiere

        WHERE mf.id_metier = ?

    ";



   $stmt = $connection->prepare($sql);



    $stmt->execute([

        $id_metier

    ]);



    $formations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([

        "success" => true,

        "formations" => $formations

    ]);



} catch(PDOException $e) {



    echo json_encode([

        "success" => false,

        "message" => "Erreur lors du chargement des formations.",

        "error" => $e->getMessage()

    ]);

}


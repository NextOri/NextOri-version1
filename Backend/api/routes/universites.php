<?php

header("Access-Control-Allow-Origin: http://localhost:5173");

header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

header("Access-Control-Allow-Headers: Content-Type, Authorization");

header("Content-Type: application/json; charset=UTF-8");


if($_SERVER["REQUEST_METHOD"]==="OPTIONS"){

    http_response_code(200);

    exit();

}


require_once "../../config/database.php";


$database = new Database();

$connection = $database->connect();



/*
    Récupération de l'identifiant de la filière
*/

$id_filiere = $_GET["id_filiere"] ?? null;



if(!$id_filiere){

    echo json_encode([

        "success"=>false,

        "message"=>"Aucune filière fournie."

    ]);

    exit();

}

try{


    $sql = "

        SELECT

            u.id_universite,

            u.nom,

            u.description,

            u.type,

            u.pays,

            u.ville,

            u.site_web

        FROM universite u

        INNER JOIN universite_filiere uf

        ON u.id_universite = uf.id_universite

        WHERE uf.id_filiere = ?

    ";



    $stmt = $connection->prepare($sql);



    $stmt->execute([

        $id_filiere

    ]);



    $universites = $stmt->fetchAll(PDO::FETCH_ASSOC);

     echo json_encode([

        "success" => true,

        "universites" => $universites

    ]);



} catch(PDOException $e) {



    echo json_encode([

        "success" => false,

        "message" => "Erreur lors du chargement des universités.",

        "error" => $e->getMessage()

    ]);

}
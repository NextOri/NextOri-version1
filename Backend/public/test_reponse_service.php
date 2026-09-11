<?php

require_once "../services/ReponseService.php";

$service = new ReponseService();

/*
 * Simulation de réponses d'un utilisateur.
 * Chaque id_proposition doit exister dans la base.
 */
$reponses = [

    ["id_proposition" => 1],
    ["id_proposition" => 7],
    ["id_proposition" => 13],
    ["id_proposition" => 19],
    ["id_proposition" => 25]

];

$service->enregistrerReponses(3, $reponses);

echo "Les réponses ont été enregistrées avec succès.";

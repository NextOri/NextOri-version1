<?php

require_once "../services/OrientationService.php";

$service = new OrientationService();

$reponses = [

    ["id_proposition" => 1],
    ["id_proposition" => 7],
    ["id_proposition" => 13],
    ["id_proposition" => 19],
    ["id_proposition" => 25]

];

$resultat = $service->executerOrientation(

    1,      // id_user

    1,      // id_questionnaire

    $reponses

);

echo "<pre>";

print_r($resultat);

echo "</pre>";
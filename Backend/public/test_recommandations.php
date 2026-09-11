<?php

require_once "../services/MetierService.php";


$service = new MetierService();


$resultat = $service->obtenirRecommandations("IS");


echo "<pre>";

print_r($resultat);

echo "</pre>";
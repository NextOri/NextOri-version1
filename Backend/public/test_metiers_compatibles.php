<?php

require_once "../services/MetierService.php";

$service = new MetierService();

$resultats = $service->rechercherMetiersCompatibles("IS");

echo "<pre>";

print_r($resultats);

echo "</pre>";
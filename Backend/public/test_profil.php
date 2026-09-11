<?php

require_once "../services/RiasecService.php";


$service = new RiasecService();


$resultat = $service->analyserTest(1);

echo "<h2>Résultat du test</h2>";

echo "<pre>";

print_r($resultat);

echo "</pre>";

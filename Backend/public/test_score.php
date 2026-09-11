<?php

require_once "../services/RiasecService.php";


$service = new RiasecService();

$types = [

"I",
"I",
"R",
"S",
"I",
"A",
"C",
"I"

];

$resultat = $service->calculerScores($types);

echo "<pre>";

print_r($resultat);

echo "</pre>";
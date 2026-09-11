<?php

require_once "../services/TestService.php";

$service = new TestService();

$idTest = $service->creerTest(1, 1);

echo "<h2>Nouveau test créé</h2>";

echo "ID du test : " . $idTest;
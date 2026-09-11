<?php

require_once __DIR__ . "/../services/MetierService.php";

$service = new MetierService();

$profil = "EC";
$idSerie = 1; // à remplacer par un id_serie existant

$resultat = $service->formaterRecommandations(
    $profil,
    $idSerie
);

echo "<h2>Profil : $profil</h2>";
echo "<h3>Série ID : $idSerie</h3>";

echo "<h2>Métiers principaux</h2>";

foreach ($resultat["metiers_principaux"] as $metier) {
    echo "<p>";
    echo $metier["id"] . " - ";
    echo htmlspecialchars($metier["nom"]);
    echo " | Profil : " . $metier["profil_riasec"];
    echo " | Score : " . $metier["score"];
    echo "</p>";
}

echo "<h2>Métiers secondaires</h2>";

foreach ($resultat["metiers_secondaires"] as $metier) {
    echo "<p>";
    echo $metier["id"] . " - ";
    echo htmlspecialchars($metier["nom"]);
    echo " | Profil : " . $metier["profil_riasec"];
    echo " | Score : " . $metier["score"];
    echo "</p>";
}
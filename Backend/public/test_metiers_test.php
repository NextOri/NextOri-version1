<?php

require_once __DIR__ . "/../services/MetierService.php";

$service = new MetierService();

$resultat = $service->rechercherMetiersCompatibles("AS", null);

echo "<h2>Test MetierService</h2>";
echo "<p>Total de métiers retournés : " . count($resultat) . "</p>";

echo "<ol>";

foreach ($resultat as $metier) {
    echo "<li>";
    echo htmlspecialchars($metier["nom"]);
    echo " — Score : " . $metier["score_compatibilite"];
    echo "</li>";
}

echo "</ol>";

echo "<h2>Test ciblé AC → ICA</h2>";

$metiers = $service->rechercherMetiersCompatibles("AC", null);

foreach ($metiers as $metier) {

    if ($metier["profil_riasec"] === "ICA") {

        echo "Métier : " . htmlspecialchars($metier["nom"]) . "<br>";
        echo "Profil : " . $metier["profil_riasec"] . "<br>";
        echo "Score : " . $metier["score_compatibilite"] . "<br>";
    }

    $resultat = $service->obtenirRecommandations("IC", null);

echo "<pre>";
print_r($resultat);
echo "</pre>";
}
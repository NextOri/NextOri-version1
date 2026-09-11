<?php

require_once "../repositories/UniversiteRepository.php";

$repository = new UniversiteRepository();

/*
 * Remplace 1 par l'id d'une filière
 * qui possède plusieurs universités.
 */
$resultat = $repository->recupererParFiliere(1);

echo "<pre>";
print_r($resultat);
echo "</pre>";
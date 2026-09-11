<?php

require_once "../repositories/FiliereRepository.php";


$repository = new FiliereRepository();

$resultat = $repository->recupererFilieresParMetier(2);


echo "<pre>";

print_r($resultat);

echo "</pre>";
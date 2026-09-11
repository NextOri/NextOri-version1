<?php

require_once "../repositories/MetierRepository.php";

$repository = new MetierRepository();

$metiers = $repository->recupererTousLesMetiers();

echo "<pre>";
print_r($metiers);
echo "</pre>";
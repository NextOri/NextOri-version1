<?php

require_once "../repositories/ReponseRepository.php";

$repository = new ReponseRepository();

$types = $repository->recupererTypesRiasec(1);

echo "<pre>";

print_r($types);

echo "</pre>";
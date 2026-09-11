<?php

require_once __DIR__ . "/Services/UserService.php";

$userService = new UserService();

$utilisateur = $userService->login(
    "laurent.test@gmail.com",
    "12345678"
);

if ($utilisateur) {

    echo "<pre>";

    print_r($utilisateur);

    echo "</pre>";

} else {

    echo "Échec de la connexion";

}
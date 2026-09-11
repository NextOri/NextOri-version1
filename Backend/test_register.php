<?php

require_once __DIR__ . "/services/UserService.php";


$userService = new UserService();


$resultat = $userService->register(
    "Laurent Test",
    "laurent.test@gmail.com",
    "12345678",
    "Sénégal",
    "Licence 2"
);


if ($resultat) {

    echo "Utilisateur créé avec succès";

} else {

    echo "Échec création utilisateur";

}
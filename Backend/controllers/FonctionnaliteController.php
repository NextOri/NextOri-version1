<?php

require_once __DIR__ . "/../Services/FonctionnaliteService.php";

class FonctionnaliteController
{
    private FonctionnaliteService $service;

    public function __construct()
    {
        $this->service = new FonctionnaliteService();
    }

    public function inscrire(
        int $idUser,
        string $fonctionnalite
    ): array {

        return $this->service->inscrireUtilisateur(
            $idUser,
            $fonctionnalite
        );
    }
}
<?php

require_once __DIR__ . "/../Services/AvisService.php";

class AvisController
{
    private AvisService $avisService;

    public function __construct()
    {
        $this->avisService = new AvisService();
    }

    public function enregistrerAvis(
        int $idUser,
        int $note,
        string $commentaire,
        bool $afficher
    ): array {

        return $this->avisService->enregistrerAvis(
            $idUser,
            $note,
            $commentaire,
            $afficher
        );
    }

    public function recupererTemoignages(): array
    {
        return $this->avisService->recupererTemoignages();
    }
}

<?php

require_once __DIR__ . "/../repositories/ReponseRepository.php";

class ReponseService
{
    private ReponseRepository $reponseRepository;

    public function __construct()
    {
        $this->reponseRepository = new ReponseRepository();
    }

    /**
     * Enregistre toutes les réponses d'un utilisateur
     */
    public function enregistrerReponses(
        int $idTest,
        array $reponses
    ): void
    {
        foreach ($reponses as $reponse) {

            $this->reponseRepository->enregistrerReponse(
                $idTest,
                $reponse["id_proposition"]
            );

        }
    }
}
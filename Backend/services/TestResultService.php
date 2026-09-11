<?php

require_once __DIR__ . "/../repositories/TestResultRepository.php";

class TestResultService
{
    private TestResultRepository $repository;

    public function __construct()
    {
        $this->repository = new TestResultRepository();
    }

    public function mettreAJourResultat(
        int $idTest,
        array $scores,
        string $profil
    ): bool {

        return $this->repository->mettreAJourResultat(
            $idTest,
            $scores,
            $profil
        );
    }
}
<?php

require_once __DIR__ . "/../repositories/TestRepository.php";

class TestService
{
    private TestRepository $testRepository;

    public function __construct()
    {
        $this->testRepository = new TestRepository();
    }

   /**
 * Crée un nouveau test
 */
public function creerTest(
    int $idUser,
    int $idQuestionnaire
): int
{
    return $this->testRepository->creerTest(
        $idUser,
        $idQuestionnaire
    );
}


/**
 * Retourne le dernier test effectué par un utilisateur.
 */
public function obtenirDernierTestUtilisateur(
    int $idUser
): ?array
{

    return $this->testRepository
                ->obtenirDernierTestUtilisateur(
                    $idUser
                );

}


/**
 * Retourne un test précis par son identifiant.
 */
public function obtenirTestParId(
    int $idTest,
    int $idUser
): ?array
{
    return $this->testRepository->obtenirTestParId(
        $idTest,
        $idUser
    );
}

/**
  * Retourne le numéro du test pour un utilisateur.
  */
public function obtenirNumeroTestUtilisateur(
    int $idTest,
    int $idUser
): ?int
{
    return $this->testRepository
                ->obtenirNumeroTestUtilisateur(
                    $idTest,
                    $idUser
                );
}

/**
 * Retourne tous les tests effectués par un utilisateur.
 */
public function obtenirTousLesTestsUtilisateur(
    int $idUser
): array
{
    return $this->testRepository
                ->obtenirTousLesTestsUtilisateur(
                    $idUser
                );
}
}
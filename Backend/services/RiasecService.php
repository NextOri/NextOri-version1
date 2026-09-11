<?php

require_once __DIR__ . '/../repositories/ReponseRepository.php';
require_once __DIR__ . '/../repositories/TestResultRepository.php';

class RiasecService
{
    private ReponseRepository $reponseRepository;
    private TestResultRepository $testResultRepository;

    public function __construct()
    {
        $this->reponseRepository = new ReponseRepository();
        $this->testResultRepository = new TestResultRepository();
    }

    /**
     * Calcule les scores RIASEC d'un test.
     */
    public function calculerScores(int $idTest): array
    {
        $types = $this->reponseRepository->recupererTypesRiasec($idTest);

        $scores = [
            "R" => 0,
            "I" => 0,
            "A" => 0,
            "S" => 0,
            "E" => 0,
            "C" => 0
        ];

        foreach ($types as $type) {

            if (isset($scores[$type])) {
                $scores[$type]++;
            }

        }

        return $scores;
    }

    /**
     * Détermine le profil RIASEC à partir des scores.
     */
    public function determinerProfil(array $scores): array
    {
        arsort($scores);

        $types = array_keys($scores);

        $profilPrincipal = $types[0] . $types[1];

        $profilComplet = implode("", $types);

        return [
            "profil_principal" => $profilPrincipal,
            "profil_complet" => $profilComplet,
            "scores" => $scores
        ];
    }
    /**
 * Analyse complètement un test RIASEC.
 */
public function analyserTest(int $idTest): array
{

    // 1. Calcul des scores
    $scores = $this->calculerScores($idTest);


    // 2. Détermination du profil
    $resultat = $this->determinerProfil($scores);


    // 3. Sauvegarde dans la base
    $this->testResultRepository->mettreAJourResultat(

        $idTest,

        $resultat["scores"],

        $resultat["profil_principal"]

    );


    return $resultat;

}

}
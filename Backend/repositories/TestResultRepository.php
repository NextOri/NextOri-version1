<?php

require_once __DIR__ . '/../config/Database.php';


class TestResultRepository
{

    private PDO $connection;


    public function __construct()
    {
        $database = new Database();

        $this->connection = $database->connect();
    }



    public function mettreAJourResultat(
        int $idTest,
        array $scores,
        string $profil
    ): bool
    {

        $sql = "
            UPDATE test_riasec

            SET

            score_R = :R,
            score_I = :I,
            score_A = :A,
            score_S = :S,
            score_E = :E,
            score_C = :C,
            profil_dominant = :profil

            WHERE id_test = :idTest
        ";


        $statement = $this->connection->prepare($sql);


        return $statement->execute([

            ":R" => $scores["R"],
            ":I" => $scores["I"],
            ":A" => $scores["A"],
            ":S" => $scores["S"],
            ":E" => $scores["E"],
            ":C" => $scores["C"],

            ":profil" => $profil,

            ":idTest" => $idTest

        ]);

    }

}
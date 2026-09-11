<?php

require_once __DIR__ . '/../config/Database.php';

class ReponseRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    /**
     * Enregistre une réponse d'un utilisateur.
     */
    public function enregistrerReponse(
        int $idTest,
        int $idProposition
    ): bool
    {
        $sql = "
            INSERT INTO reponse
            (
                id_test,
                id_proposition
            )
            VALUES
            (
                :test,
                :proposition
            )
        ";

        $statement = $this->connection->prepare($sql);

        $resultat = $statement->execute([
    ":test" => $idTest,
    ":proposition" => $idProposition
]);


if (!$resultat) {

    throw new Exception(
        implode(" | ", $statement->errorInfo())
    );

}

return $resultat;
    }

    public function recupererTypesRiasec(int $idTest): array
{

    $sql = "
        SELECT p.type_riasec
        FROM reponse r
        INNER JOIN proposition p
            ON r.id_proposition = p.id_proposition
        WHERE r.id_test = :idTest
    ";

    $statement = $this->connection->prepare($sql);

    $statement->execute([
        ":idTest" => $idTest
    ]);

    return $statement->fetchAll(PDO::FETCH_COLUMN);

}
}
<?php

require_once __DIR__ . '/../config/Database.php';

class PropositionRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }


    /**
     * Récupérer les propositions d'une question
     */
    public function getPropositionsByQuestion(int $idQuestion): array
    {
        $sql = "
            SELECT
                id_proposition,
                lettre,
                libelle,
                type_riasec
            FROM proposition
            WHERE id_question = :id
            ORDER BY lettre ASC
        ";


        $statement = $this->connection->prepare($sql);

        $statement->bindParam(":id", $idQuestion);

        $statement->execute();


        return $statement->fetchAll();
    }
}
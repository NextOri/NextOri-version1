<?php

require_once __DIR__ . '/../config/Database.php';

class QuestionRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    /**
     * Retourne toutes les questions d'un questionnaire.
     */
    public function getQuestionsByQuestionnaire(int $idQuestionnaire): array
    {
        $sql = "
            SELECT
                id_question,
                texte,
                ordre
            FROM question
            WHERE id_questionnaire = :id
            ORDER BY ordre ASC
        ";

        $statement = $this->connection->prepare($sql);

        $statement->bindParam(":id", $idQuestionnaire);

        $statement->execute();

        return $statement->fetchAll();
    }
}

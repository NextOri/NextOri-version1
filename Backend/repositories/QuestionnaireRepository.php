<?php

require_once __DIR__ . '/../config/Database.php';

class QuestionnaireRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    /**
     * Retourne le questionnaire actif.
     */
    public function getQuestionnaireActif()
    {
        $sql = "
            SELECT *
            FROM questionnaire
            WHERE actif = 1
            LIMIT 1
        ";

        $statement = $this->connection->prepare($sql);
        $statement->execute();

        return $statement->fetch();
    }
}

<?php

require_once __DIR__ . "/../config/Database.php";

class SerieRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    /**
     * Retourne toutes les séries.
     */
    public function recupererToutesLesSeries(): array
    {
        $sql = "
            SELECT
                id_serie,
                nom
            FROM serie
            ORDER BY id_serie
        ";

        $statement = $this->connection->query($sql);

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }
}
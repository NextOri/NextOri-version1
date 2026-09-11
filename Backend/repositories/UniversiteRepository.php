<?php

require_once __DIR__ . "/../config/Database.php";

class UniversiteRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    /**
     * Récupère toutes les universités proposant une filière
     */
    public function recupererParFiliere(int $idFiliere): array
    {
        $sql = "
            SELECT
                u.id_universite,
                u.nom,
                u.description,
                u.type,
                u.pays,
                u.ville,
                u.site_web
            FROM universite u

            INNER JOIN universite_filiere uf
                ON u.id_universite = uf.id_universite

            WHERE uf.id_filiere = :id_filiere

            ORDER BY u.nom
        ";

        $statement = $this->connection->prepare($sql);

        $statement->execute([
            "id_filiere" => $idFiliere
        ]);

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }
}
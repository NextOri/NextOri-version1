<?php

require_once __DIR__ . "/../config/Database.php";


class FiliereRepository
{

    private PDO $connection;


    public function __construct()
    {
        $database = new Database();

        $this->connection = $database->connect();
    }



    /**
     * Récupérer les filières liées à un métier
     */
    public function recupererFilieresParMetier(int $idMetier): array
    {

        $sql = "
            SELECT 
                f.id_filiere,
                f.nom,
                f.description,
                f.domaine,
                f.duree

            FROM filiere f

            INNER JOIN metier_filiere mf
            ON f.id_filiere = mf.id_filiere

            WHERE mf.id_metier = :id_metier
        ";


        $statement = $this->connection->prepare($sql);


        $statement->execute([
            "id_metier" => $idMetier
        ]);


        return $statement->fetchAll(PDO::FETCH_ASSOC);

    }



        /**
     * Récupérer une filière avec ses critères d'hésitation.
     */
    public function recupererFiliereAvecCriteres(int $idFiliere): ?array
    {
        $sql = "
            SELECT
                f.id_filiere,
                f.nom,
                f.description,
                f.presentation,
                f.domaine,
                f.duree,
                f.competences_developpees
            FROM filiere f
            WHERE f.id_filiere = :id_filiere
            LIMIT 1
        ";

        $statement = $this->connection->prepare($sql);

        $statement->execute([
            ":id_filiere" => $idFiliere
        ]);

        $filiere = $statement->fetch(PDO::FETCH_ASSOC);

        if (!$filiere) {
            return null;
        }

        $sqlCriteres = "
            SELECT
                hc.id_critere,
                hc.code,
                hc.nom,
                hc.categorie,
                fc.valeur
            FROM filiere_critere fc
            INNER JOIN hesitation_critere hc
                ON hc.id_critere = fc.id_critere
            WHERE fc.id_filiere = :id_filiere
              AND hc.actif = 1
            ORDER BY hc.id_critere ASC
        ";

        $statementCriteres =
            $this->connection->prepare($sqlCriteres);

        $statementCriteres->execute([
            ":id_filiere" => $idFiliere
        ]);

        $filiere["criteres"] =
            $statementCriteres->fetchAll(PDO::FETCH_ASSOC);

        return $filiere;
    }
}
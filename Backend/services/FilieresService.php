<?php

require_once __DIR__ . "/../config/database.php";

class FilieresService
{

    private PDO $connexion;


    public function __construct()
    {
        $database = new Database();
        $this->connexion = $database->connect();
    }



    public function getAllFilieres(): array
    {

        $sql = "
            SELECT
                id_filiere,
                nom,
                description,
                domaine,
                duree
            FROM filiere
            ORDER BY nom ASC
        ";


        $requete = $this->connexion->prepare($sql);


        $requete->execute();


        return $requete->fetchAll(PDO::FETCH_ASSOC);

    }



    public function getById(int $idFiliere): ?array
    {

        $sql = "
            SELECT
                id_filiere,
                nom,
                presentation,
                domaine,
                duree,
                competences_developpees
            FROM filiere
            WHERE id_filiere = :id_filiere
        ";

        $requete = $this->connexion->prepare($sql);

        $requete->bindValue(
            ":id_filiere",
            $idFiliere,
            PDO::PARAM_INT
        );

        $requete->execute();

        $resultat = $requete->fetch(PDO::FETCH_ASSOC);

        return $resultat ?: null;

    }



    public function getMetiersByFiliere(int $idFiliere): array
    {

        $sql = "
            SELECT
                m.id_metier,
                m.nom
            FROM metier m

            INNER JOIN metier_filiere mf

            ON m.id_metier = mf.id_metier

            WHERE mf.id_filiere = :id_filiere

            ORDER BY m.nom ASC
        ";

        $requete = $this->connexion->prepare($sql);

        $requete->bindValue(
            ":id_filiere",
            $idFiliere,
            PDO::PARAM_INT
        );

        $requete->execute();

        return $requete->fetchAll(PDO::FETCH_ASSOC);

    }



    public function getUniversitesByFiliere(int $idFiliere): array
    {

        $sql = "
            SELECT
                u.id_universite,
                u.nom,
                u.ville
            FROM universite u

            INNER JOIN universite_filiere uf

            ON u.id_universite = uf.id_universite

            WHERE uf.id_filiere = :id_filiere

            ORDER BY u.nom ASC
        ";

        $requete = $this->connexion->prepare($sql);

        $requete->bindValue(
            ":id_filiere",
            $idFiliere,
            PDO::PARAM_INT
        );

        $requete->execute();

        return $requete->fetchAll(PDO::FETCH_ASSOC);

    }

}
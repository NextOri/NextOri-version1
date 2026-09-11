<?php

require_once __DIR__ . "/../config/database.php";


class UniversiteCatalogueService
{

    private PDO $connexion;


    public function __construct()
    {

        $database = new Database();

        $this->connexion = $database->connect();

    }



    public function getAllUniversites(): array
    {

        $sql = "
            SELECT
                id_universite,
                nom,
                description,
                type,
                pays,
                ville,
                region,
                site_web,
                logo
            FROM universite
            ORDER BY nom ASC
        ";


        $requete = $this->connexion->prepare($sql);

        $requete->execute();


        return $requete->fetchAll(PDO::FETCH_ASSOC);

    }

    public function getUniversiteById(int $idUniversite): ?array
   {
    $sql = "
        SELECT
            id_universite,
            nom,
            description,
            type,
            ville,
            region,
            adresse,
            telephone,
            email,
            pays,
            site_web,
            logo
        FROM universite
        WHERE id_universite = :id_universite
    ";

    $requete = $this->connexion->prepare($sql);
    $requete->bindValue(':id_universite', $idUniversite, PDO::PARAM_INT);
    $requete->execute();

    $resultat = $requete->fetch(PDO::FETCH_ASSOC);

    return $resultat ?: null;
   }

   public function getUniversiteDetail(int $idUniversite): ?array
    {
    $sql = "
        SELECT
            presentation,
            conditions_admission,
            bourses
        FROM universite_detail
        WHERE id_universite = :id_universite
    ";

    $requete = $this->connexion->prepare($sql);
    $requete->bindValue(':id_universite', $idUniversite, PDO::PARAM_INT);
    $requete->execute();

    $resultat = $requete->fetch(PDO::FETCH_ASSOC);

    return $resultat ?: null;
    }

    public function getFilieresByUniversite(int $idUniversite): array
   {
    $sql = "
        SELECT
            f.id_filiere,
            f.nom,
            f.description,
            f.domaine,
            f.duree
        FROM filiere f
        INNER JOIN universite_filiere uf
            ON f.id_filiere = uf.id_filiere
        WHERE uf.id_universite = :id_universite
        ORDER BY f.nom ASC
    ";

    $requete = $this->connexion->prepare($sql);
    $requete->bindValue(':id_universite', $idUniversite, PDO::PARAM_INT);
    $requete->execute();

    return $requete->fetchAll(PDO::FETCH_ASSOC);
   }

}
<?php

require_once __DIR__ . "/../config/database.php";


class MetiersService
{

    private PDO $connexion;


    public function __construct()
    {
        $database = new Database();

        $this->connexion = $database->connect();
    }



    /**
     * Récupérer tous les métiers du catalogue
     */
    public function getAllMetiers(): array
    {

        $sql = "
            SELECT
                id_metier,
                nom,
                description,
                secteur,
                niveau_etude,
                salaire_min,
                salaire_max,
                tendance
            FROM metier
            ORDER BY nom ASC
        ";


        $requete = $this->connexion->prepare($sql);

        $requete->execute();


        return $requete->fetchAll(PDO::FETCH_ASSOC);

    }


    public function getMetierById(int $idMetier): ?array
   {

    // Récupération des informations du métier

    $sql = "
        SELECT
            id_metier,
            nom,
            presentation,
            competences,
            secteur,
            niveau_etude,
            salaire_min,
            salaire_max,
            tendance
        FROM metier
        WHERE id_metier = :id_metier
    ";


    $requete = $this->connexion->prepare($sql);


    $requete->execute([
        "id_metier" => $idMetier
    ]);


    $metier = $requete->fetch(PDO::FETCH_ASSOC);



    if (!$metier) {

        return null;

    }



    // Récupération des filières liées au métier

    $sqlFilieres = "
        SELECT
            f.id_filiere,
            f.nom
        FROM filiere f
        INNER JOIN metier_filiere mf
            ON f.id_filiere = mf.id_filiere
        WHERE mf.id_metier = :id_metier
    ";


    $requeteFilieres = $this->connexion->prepare($sqlFilieres);


    $requeteFilieres->execute([
        "id_metier" => $idMetier
    ]);



    $metier["filieres"] = $requeteFilieres->fetchAll(PDO::FETCH_ASSOC);



    return $metier;

   }

}
<?php

require_once __DIR__ . "/../config/Database.php";

class MetierRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    /**
     * Retourne tous les métiers.
     */
    public function recupererTousLesMetiers(): array
    {
        $sql = "
            SELECT
                id_metier,
                nom,
                description,
                secteur,
                niveau_etude,
                profil_riasec,
                salaire_min,
                salaire_max
            FROM metier
        ";

        $statement = $this->connection->query($sql);

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }


   /**
 * Retourne les métiers accessibles au test et compatibles
 * avec une série donnée.
 */
public function recupererMetiersParSerie(int $idSerie): array
   {
    $sql = "
        SELECT DISTINCT
            m.id_metier,
            m.nom,
            m.description,
            m.secteur,
            m.niveau_etude,
            m.profil_riasec,
            m.salaire_min,
            m.salaire_max
        FROM metier m
        INNER JOIN metier_serie ms
            ON ms.id_metier = m.id_metier
        WHERE ms.id_serie = :id_serie
          AND m.accessible_test = 1
    ";

    $statement = $this->connection->prepare($sql);

    $statement->execute([
        ':id_serie' => $idSerie
    ]);

    return $statement->fetchAll(PDO::FETCH_ASSOC);
    }


    /**
 * Retourne tous les métiers accessibles au test.
 */
public function recupererMetiersAccessiblesAuTest(): array
{
    $sql = "
        SELECT
            id_metier,
            nom,
            description,
            secteur,
            niveau_etude,
            profil_riasec,
            salaire_min,
            salaire_max
        FROM metier
        WHERE accessible_test = 1
    ";

    $statement = $this->connection->query($sql);

    return $statement->fetchAll(PDO::FETCH_ASSOC);
}


    /**
     * Récupérer un métier avec ses critères d'hésitation.
     */
    public function recupererMetierAvecCriteres(int $idMetier): ?array
    {
        $sql = "
            SELECT
                m.id_metier,
                m.nom,
                m.description,
                m.presentation,
                m.competences,
                m.secteur,
                m.niveau_etude,
                m.salaire_min,
                m.salaire_max,
                m.profil_riasec,
                m.tendance,
                m.accessible_test
            FROM metier m
            WHERE m.id_metier = :id_metier
            LIMIT 1
        ";

        $statement = $this->connection->prepare($sql);

        $statement->execute([
            ":id_metier" => $idMetier
        ]);

        $metier = $statement->fetch(PDO::FETCH_ASSOC);

        if (!$metier) {
            return null;
        }

        $sqlCriteres = "
            SELECT
                hc.id_critere,
                hc.code,
                hc.nom,
                hc.categorie,
                mc.valeur
            FROM metier_critere mc
            INNER JOIN hesitation_critere hc
                ON hc.id_critere = mc.id_critere
            WHERE mc.id_metier = :id_metier
              AND hc.actif = 1
            ORDER BY hc.id_critere ASC
        ";

        $statementCriteres =
            $this->connection->prepare($sqlCriteres);

        $statementCriteres->execute([
            ":id_metier" => $idMetier
        ]);

        $metier["criteres"] =
            $statementCriteres->fetchAll(PDO::FETCH_ASSOC);

        return $metier;
    }
}
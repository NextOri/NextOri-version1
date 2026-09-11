// backend/repositories/HesitationRepository.php

<?php

require_once __DIR__ . "/../config/Database.php";

class HesitationRepository
{
    private PDO $connection;

    public function __construct()
    {
        $database = new Database();
        $this->connection = $database->connect();
    }

    public function recupererQuestionsAvecReponses(): array
    {
        $sql = "
            SELECT
                q.id_question,
                q.question,
                q.ordre AS ordre_question,
                r.id_reponse,
                r.texte,
                r.code,
                r.ordre AS ordre_reponse
            FROM hesitation_question q
            INNER JOIN hesitation_reponse r
                ON r.id_question = q.id_question
            WHERE q.actif = 1
            ORDER BY q.ordre ASC, r.ordre ASC
        ";

        $statement = $this->connection->query($sql);
        $lignes = $statement->fetchAll(PDO::FETCH_ASSOC);

        $questions = [];

        foreach ($lignes as $ligne) {
            $idQuestion = (int) $ligne["id_question"];

            if (!isset($questions[$idQuestion])) {
                $questions[$idQuestion] = [
                    "id_question" => $idQuestion,
                    "question" => $ligne["question"],
                    "ordre" => (int) $ligne["ordre_question"],
                    "reponses" => []
                ];
            }

            $questions[$idQuestion]["reponses"][] = [
                "id_reponse" => (int) $ligne["id_reponse"],
                "texte" => $ligne["texte"],
                "code" => $ligne["code"],
                "ordre" => (int) $ligne["ordre_reponse"]
            ];
        }

        return array_values($questions);
    }

    public function recupererCriteresActifs(): array
    {
        $sql = "
            SELECT
                id_critere,
                code,
                nom,
                categorie
            FROM hesitation_critere
            WHERE actif = 1
            ORDER BY id_critere ASC
        ";

        $statement = $this->connection->query($sql);

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }

    public function recupererCriteresMetiers(array $idsMetiers): array
    {
        if (empty($idsMetiers)) {
            return [];
        }

        $placeholders = implode(
            ",",
            array_fill(0, count($idsMetiers), "?")
        );

        $sql = "
            SELECT
                mc.id_metier,
                c.id_critere,
                c.code,
                c.nom,
                c.categorie,
                mc.valeur
            FROM metier_critere mc
            INNER JOIN hesitation_critere c
                ON c.id_critere = mc.id_critere
            WHERE mc.id_metier IN ($placeholders)
              AND c.actif = 1
            ORDER BY mc.id_metier ASC, c.id_critere ASC
        ";

        $statement = $this->connection->prepare($sql);
        $statement->execute(array_values($idsMetiers));

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }

    public function recupererCriteresFilieres(array $idsFilieres): array
    {
        if (empty($idsFilieres)) {
            return [];
        }

        $placeholders = implode(
            ",",
            array_fill(0, count($idsFilieres), "?")
        );

        $sql = "
            SELECT
                fc.id_filiere,
                c.id_critere,
                c.code,
                c.nom,
                c.categorie,
                fc.valeur
            FROM filiere_critere fc
            INNER JOIN hesitation_critere c
                ON c.id_critere = fc.id_critere
            WHERE fc.id_filiere IN ($placeholders)
              AND c.actif = 1
            ORDER BY fc.id_filiere ASC, c.id_critere ASC
        ";

        $statement = $this->connection->prepare($sql);
        $statement->execute(array_values($idsFilieres));

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }

    public function recupererMetiersParIds(array $idsMetiers): array
    {
        if (empty($idsMetiers)) {
            return [];
        }

        $placeholders = implode(
            ",",
            array_fill(0, count($idsMetiers), "?")
        );

        $sql = "
            SELECT
                id_metier,
                nom,
                description,
                presentation,
                competences,
                secteur,
                niveau_etude,
                salaire_min,
                salaire_max,
                profil_riasec,
                tendance,
                accessible_test
            FROM metier
            WHERE id_metier IN ($placeholders)
            ORDER BY FIELD(id_metier, $placeholders)
        ";

        $statement = $this->connection->prepare($sql);

        $statement->execute([
            ...array_values($idsMetiers),
            ...array_values($idsMetiers)
        ]);

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }

    public function recupererFilieresParIds(array $idsFilieres): array
    {
        if (empty($idsFilieres)) {
            return [];
        }

        $placeholders = implode(
            ",",
            array_fill(0, count($idsFilieres), "?")
        );

        $sql = "
            SELECT
                id_filiere,
                nom,
                description,
                presentation,
                domaine,
                duree,
                competences_developpees
            FROM filiere
            WHERE id_filiere IN ($placeholders)
            ORDER BY FIELD(id_filiere, $placeholders)
        ";

        $statement = $this->connection->prepare($sql);

        $statement->execute([
            ...array_values($idsFilieres),
            ...array_values($idsFilieres)
        ]);

        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }
}
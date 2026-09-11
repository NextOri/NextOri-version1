<?php

require_once __DIR__ . "/../config/database.php";

class AvisService
{
    private PDO $db;

    public function __construct()
    {
        $database = new Database();
        $this->db = $database->connect();
    }

    public function enregistrerAvis(
        int $idUser,
        int $note,
        string $commentaire,
        bool $afficher
    ): array {

        $sql = "INSERT INTO avis (
                    id_user,
                    note,
                    commentaire,
                    afficher
                ) VALUES (
                    :id_user,
                    :note,
                    :commentaire,
                    :afficher
                )";

        $stmt = $this->db->prepare($sql);

        $stmt->execute([
            ":id_user" => $idUser,
            ":note" => $note,
            ":commentaire" => $commentaire,
            ":afficher" => $afficher ? 1 : 0
        ]);

        return [
            "id_avis" => (int) $this->db->lastInsertId(),
            "id_user" => $idUser,
            "note" => $note,
            "commentaire" => $commentaire,
            "afficher" => $afficher
        ];
    }

    public function recupererTemoignages(): array
{
    $sql = "
        SELECT
            a.id_avis,
            a.note,
            a.commentaire,
            a.date_creation,
            u.nom AS nom_utilisateur
        FROM avis a
        INNER JOIN utilisateur u
            ON a.id_user = u.id_user
        WHERE a.afficher = TRUE
          AND a.approuve = TRUE
        ORDER BY a.date_creation DESC
    ";

    $stmt = $this->db->prepare($sql);
    $stmt->execute();

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

}

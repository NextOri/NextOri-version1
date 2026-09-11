<?php

require_once __DIR__ . "/../config/database.php";

class FonctionnaliteService
{
    private PDO $connexion;

    public function __construct()
    {
        $database = new Database();
        $this->connexion = $database->connect();
    }

    public function inscrireUtilisateur(
    int $idUser,
    string $fonctionnalite
): array {

    // Vérifier si l'utilisateur est déjà inscrit
    $sql = "
        SELECT id_attente
        FROM attente_fonctionnalite
        WHERE id_user = ?
        AND fonctionnalite = ?
        LIMIT 1
    ";

    $requete = $this->connexion->prepare($sql);

    $requete->execute([
        $idUser,
        $fonctionnalite
    ]);

    $dejaInscrit = $requete->fetchColumn();

    // Déjà inscrit
    if ($dejaInscrit) {

        return [
            "success" => true,
            "nouvelle_inscription" => false,
            "message" => "Vous êtes déjà inscrit pour recevoir cette notification."
        ];
    }

    // Nouvelle inscription
    $sql = "
        INSERT INTO attente_fonctionnalite
            (id_user, fonctionnalite)
        VALUES
            (:id_user, :fonctionnalite)
    ";

    $requete = $this->connexion->prepare($sql);

    $requete->execute([
        ":id_user" => $idUser,
        ":fonctionnalite" => $fonctionnalite
    ]);

    return [
        "success" => true,
        "nouvelle_inscription" => true,
        "message" => "Vous serez averti dès que cette fonctionnalité sera disponible."
    ];
}
}
<?php

require_once __DIR__ . "/../config/Database.php";


class HistoriqueService
{

    private PDO $connexion;


    public function __construct()
    {

        $database = new Database();

        $this->connexion = $database->connect();

    }



   public function enregistrerAction(int $idUser, string $action): bool
{

    $sql = "
        INSERT INTO historique
        (id_user, action, date_action)

        VALUES
        (?, ?, NOW())
    ";


    $requete = $this->connexion->prepare($sql);


    return $requete->execute([
        $idUser,
        $action
    ]);

}
}
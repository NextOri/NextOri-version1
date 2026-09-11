<?php

require_once __DIR__ . "/../config/database.php";


class UserService
{

    private PDO $connection;


    public function __construct()
    {

        $database = new Database();

        $this->connection = $database->connect();

    }




    public function emailExiste(string $email): bool
    {

     $sql = "SELECT COUNT(*) FROM utilisateur WHERE email = :email";
  
     $stmt = $this->connection->prepare($sql);

     $stmt->bindParam(":email", $email);

     $stmt->execute();

     return $stmt->fetchColumn() > 0;

    }



    public function register(
    string $nom,
    string $email,
    string $motDePasse,
    string $pays,
    string $niveauEtude,
    ?int $idSerie = null
): array|bool
{

    // Vérifier si l'email existe déjà
    if ($this->emailExiste($email)) {

        return false;

    }


    // Sécuriser le mot de passe
    $motDePasseHash = password_hash(
        $motDePasse,
        PASSWORD_DEFAULT
    );


    // Préparer l'insertion
    $sql = "
        INSERT INTO utilisateur
        (
            nom,
            email,
            mot_de_passe,
            pays,
            niveau_etude,
            id_serie
        )
        VALUES
        (
            :nom,
            :email,
            :mot_de_passe,
            :pays,
            :niveau_etude,
            :id_serie
        )
    ";


    $stmt = $this->connection->prepare($sql);


    $stmt->bindParam(":nom", $nom);
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":mot_de_passe", $motDePasseHash);
    $stmt->bindParam(":pays", $pays);
    $stmt->bindParam(":niveau_etude", $niveauEtude);
    $stmt->bindParam(
    ":id_serie",
    $idSerie,
    $idSerie === null ? PDO::PARAM_NULL : PDO::PARAM_INT
    );


    if ($stmt->execute()) {

    $idUser = $this->connection->lastInsertId();

    return $this->getUserById($idUser);

   }

      return false;

    }


    public function login(
    string $email,
    string $motDePasse
   ): ?array
   {

    $sql = "
        SELECT *
        FROM utilisateur
        WHERE email = :email
        LIMIT 1
    ";

    $stmt = $this->connection->prepare($sql);

    $stmt->bindParam(":email", $email);

    $stmt->execute();

    $utilisateur = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$utilisateur) {

        return null;

    }

    if (!password_verify($motDePasse, $utilisateur["mot_de_passe"])) {

        return null;

    }

    unset($utilisateur["mot_de_passe"]);

    return $utilisateur;

  }

  

  public function getUserById(int $idUser): ?array
  {

    $sql = "
        SELECT 
            id_user,
            nom,
            email,
            pays,
            niveau_etude,
            id_serie,
            date_creation
        FROM utilisateur
        WHERE id_user = :id_user
        LIMIT 1
    ";


    $stmt = $this->connection->prepare($sql);


    $stmt->bindParam(
        ":id_user",
        $idUser,
        PDO::PARAM_INT
    );


    $stmt->execute();


    $utilisateur = $stmt->fetch(PDO::FETCH_ASSOC);


    if (!$utilisateur) {

        return null;

    }


    return $utilisateur;

   }

   

}
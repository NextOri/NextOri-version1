<?php

require_once __DIR__ . "/../services/OrientationService.php";
require_once __DIR__ . "/../utils/ApiResponse.php";

class OrientationController
{
    private OrientationService $orientationService;

    public function __construct()
    {
        $this->orientationService = new OrientationService();
    }

    /**
     * Point d'entrée de l'API Orientation
     */
    public function executer(): void
    {
        header("Access-Control-Allow-Origin: http://localhost:5173");
        header("Access-Control-Allow-Credentials: true");
        header("Access-Control-Allow-Methods: POST, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type");
        if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
            http_response_code(200);
            exit();
        }
        header("Content-Type: application/json; charset=UTF-8");

        try {

            session_start();

            if (!isset($_SESSION["id_user"])) {
                ApiResponse::error(
                    401,
                    "Utilisateur non connecté."
                );

                return;
            }

            $idUser = (int) $_SESSION["id_user"];

            // Lecture des données JSON envoyées
            $json = file_get_contents("php://input");

            $donnees = json_decode($json, true);

            // Vérification de la validité du JSON
            if ($donnees === null) {

                http_response_code(400);

                echo json_encode([
                    "success" => false,
                    "message" => "Aucune donnée JSON reçue."
                ]);

                return;
            }

            // Vérification des paramètres obligatoires
         
         if (
         !isset($donnees["id_questionnaire"]) ||
         !isset($donnees["reponses"])
         ) {

                ApiResponse::error(
                    400,
                    "Paramètres manquants."
                );

                return;
            }

            // Validation des données
            $erreur = $this->validerDonnees($donnees);

            if ($erreur !== null) {

                ApiResponse::error(
                    400,
                    $erreur
                );

                return;
            }

            // Exécution du moteur NextOri
            $resultat = $this->orientationService->executerOrientation(

                $idUser,

                (int)$donnees["id_questionnaire"],

                $donnees["reponses"]

            );

            // Réponse API standardisée

            ApiResponse::success(
                [
                    "id_test" => $resultat["id_test"],

                    "profil" => [
                        "principal" =>
                        $resultat["profil"]["profil"]["profil_principal"],

                        "complet" =>
                        $resultat["profil"]["profil"]["profil_complet"],

                        "scores" =>
                        $resultat["profil"]["scores"]
                    ],

                    "recommandations" =>
                    $resultat["recommandations"]
                ],
                "Orientation réalisée avec succès."
            );
        } catch (Throwable $e) {

            ApiResponse::error(

                $e->getMessage(),
                500
            );
        }
    }
    /**
     * Vérifie les données reçues par l'API.
     */
    private function validerDonnees(array $donnees): ?string
    {
        

        // id_questionnaire
        if (!is_int($donnees["id_questionnaire"]) || $donnees["id_questionnaire"] <= 0) {
            return "id_questionnaire invalide.";
        }

        // réponses
        if (!is_array($donnees["reponses"])) {
            return "Le champ reponses doit être un tableau.";
        }

        if (count($donnees["reponses"]) === 0) {
            return "Aucune réponse envoyée.";
        }

        foreach ($donnees["reponses"] as $reponse) {

            if (!isset($reponse["id_proposition"])) {
                return "Une réponse ne possède pas id_proposition.";
            }

            if (!is_int($reponse["id_proposition"]) || $reponse["id_proposition"] <= 0) {
                return "id_proposition invalide.";
            }
        }

        return null;
    }

    /**
     * Retourne le dernier résultat d'orientation d'un utilisateur.
     */
    public function recupererDernierResultat(): void
    {



        header("Access-Control-Allow-Origin: http://localhost:5173");
        header("Access-Control-Allow-Credentials: true");
        header("Content-Type: application/json; charset=UTF-8");

        session_start();

        try {

            if (!isset($_SESSION["id_user"])) {
                ApiResponse::error(
                    "Utilisateur non connecté.",
                    401
                    
                );

                return;
            }

            $idUser = (int) $_SESSION["id_user"];

            $resultat = $this->orientationService
                ->recupererDernierResultat($idUser);

            if ($resultat === null) {

                ApiResponse::error(
                    404,
                    "Aucun résultat disponible."
                );

                return;
            }

            ApiResponse::success(
                $resultat,
                "Dernier résultat récupéré avec succès."
            );
        } catch (Throwable $e) {

            ApiResponse::error(
                500,
                $e->getMessage()
            );
        }
    }


    /**
 * Retourne un test précis de l'historique.
 */
public function recupererTestParId(): void
{
    header("Access-Control-Allow-Origin: http://localhost:5173");
    header("Access-Control-Allow-Credentials: true");
    header("Access-Control-Allow-Methods: GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header("Content-Type: application/json; charset=UTF-8");

    if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
        http_response_code(200);
        return;
    }

    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    try {

        if (!isset($_SESSION["id_user"])) {

            ApiResponse::error(
                "Utilisateur non connecté.",
                401
            );

            return;
        }

        $idUser = (int) $_SESSION["id_user"];

        if (!isset($_GET["id_test"])) {

            ApiResponse::error(
                "Identifiant du test manquant.",
                400
            );

            return;
        }

        $idTest = filter_var(
            $_GET["id_test"],
            FILTER_VALIDATE_INT
        );

        if ($idTest === false || $idTest <= 0) {

            ApiResponse::error(
                "Identifiant du test invalide.",
                400
            );

            return;
        }

        $test = $this->orientationService
            ->obtenirTestParId(
                $idTest,
                $idUser
            );

            

        if ($test === null) {

            ApiResponse::error(
                "Test introuvable.",
                404
            );

            return;
        }

        $numeroTest =
    $this->orientationService
        ->obtenirNumeroTestUtilisateur(
            $idTest,
            $idUser
        );

        $test["numero_test"] = $numeroTest;

        ApiResponse::success(
            $test,
            "Test historique récupéré avec succès."
        );

    } catch (Throwable $e) {

        ApiResponse::error(
            $e->getMessage(),
            500
        );
    }
}


    /**
 * Retourne l'historique des tests d'un utilisateur.
 */
public function recupererHistoriqueTests(): void
{
    header("Access-Control-Allow-Origin: http://localhost:5173");
    header("Access-Control-Allow-Credentials: true");
    header("Content-Type: application/json; charset=UTF-8");

    if (session_status() === PHP_SESSION_NONE) {
    session_start();
    }

    try {

        if (!isset($_SESSION["id_user"])) {

            ApiResponse::error(
                "Utilisateur non connecté.",
                401
            );

            return;
        }

        $idUser = (int) $_SESSION["id_user"];

        $tests = $this->orientationService
            ->obtenirHistoriqueTests($idUser);

        ApiResponse::success(
            $tests,
            "Historique des tests récupéré avec succès."
        );

    } catch (Throwable $e) {

        ApiResponse::error(
            500,
            $e->getMessage()
        );
    }
}
}

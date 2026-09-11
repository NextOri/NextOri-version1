<?php

require_once __DIR__ . "/../services/HistoriqueService.php";


class HistoriqueController
{

    private HistoriqueService $historiqueService;


    public function __construct()
    {

        $this->historiqueService = new HistoriqueService();

    }



    public function enregistrer()
    {

    
     

     if (!isset($_SESSION["id_user"])) {
    http_response_code(401);

    echo json_encode([
        "success" => false,
        "message" => "Utilisateur non connecté."
    ]);

    return;
}

$idUser = (int) $_SESSION["id_user"];

        $data = json_decode(
            file_get_contents("php://input"),
            true
        );


        $resultat = $this->historiqueService->enregistrerAction(
            $idUser,
            $data["action"]
        );


        echo json_encode([

            "success" => $resultat,

            "message" => $resultat
                ? "Action enregistrée"
                : "Erreur"

        ]);

    }

}
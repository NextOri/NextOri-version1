// backend/controllers/HesitationController.php

<?php

require_once __DIR__ . "/../services/HesitationService.php";

class HesitationController
{
    private HesitationService $service;

    public function __construct()
    {
        $this->service = new HesitationService();
    }

    public function questions(): void
    {
        $this->json(
            $this->service->recupererQuestions()
        );
    }

    public function criteres(): void
    {
        $this->json(
            $this->service->recupererCriteres()
        );
    }

    public function comparer(): void
    {
        try {
            $data = $this->lireJson();

            $typeChoix = $data["type_choix"] ?? null;
            $idsOptions = $data["ids_options"] ?? [];
            $reponses = $data["reponses"] ?? [];

            if (
                !in_array($typeChoix, ["metier", "filiere"], true)
            ) {
                $this->json([
                    "message" => "type_choix doit être metier ou filiere."
                ], 400);

                return;
            }

            if (!is_array($idsOptions) || count($idsOptions) < 2) {
                $this->json([
                    "message" => "Au moins deux options sont nécessaires."
                ], 400);

                return;
            }

            if (!is_array($reponses)) {
                $this->json([
                    "message" => "Les réponses sont invalides."
                ], 400);

                return;
            }

            $resultat = $this->service->comparer(
                $typeChoix,
                array_map("intval", $idsOptions),
                $reponses
            );

            $this->json($resultat);
        } catch (Throwable $exception) {
            $this->json([
                "message" => "Erreur lors de la comparaison.",
                "error" => $exception->getMessage()
            ], 500);
        }
    }

    private function lireJson(): array
    {
        $contenu = file_get_contents("php://input");

        if (!$contenu) {
            return [];
        }

        $data = json_decode($contenu, true);

        return is_array($data) ? $data : [];
    }

    private function json(
        mixed $data,
        int $status = 200
    ): void {

        http_response_code($status);

        header(
            "Content-Type: application/json; charset=utf-8"
        );

        echo json_encode(
            $data,
            JSON_UNESCAPED_UNICODE |
            JSON_UNESCAPED_SLASHES
        );
    }
}
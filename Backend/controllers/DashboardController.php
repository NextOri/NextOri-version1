<?php

require_once __DIR__ . "/../Services/DashboardService.php";

class DashboardController
{
    private DashboardService $dashboardService;

    public function __construct()
    {
        $this->dashboardService = new DashboardService();
    }

    public function recupererDashboard(int $idUser): array
    {
        $dashboard = $this->dashboardService->recupererDashboard($idUser);

        if ($dashboard === null) {

            return [
                "success" => false,
                "message" => "Utilisateur introuvable."
            ];

        }

        return [

            "success" => true,

            "data" => $dashboard

        ];
    }
}
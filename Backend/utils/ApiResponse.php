<?php

class ApiResponse
{
    /**
     * Réponse de succès
     */
    public static function success(
        array $data = [],
        string $message = "Succès",
        int $code = 200
    ): void
    {

        http_response_code($code);

        header("Content-Type: application/json; charset=UTF-8");

        echo json_encode([

            "success" => true,

            "message" => $message,

            "data" => $data

        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    }

    /**
     * Réponse d'erreur
     */
    public static function error(
        string $message,
        int $code = 400
    ): void
    {

        http_response_code($code);

        header("Content-Type: application/json; charset=UTF-8");

        echo json_encode([

            "success" => false,

            "message" => $message

        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    }
}
<?php

require_once __DIR__ . "/../../controllers/HesitationController.php";

$controller = new HesitationController();

$method = $_SERVER["REQUEST_METHOD"] ?? "GET";

$uri = parse_url(
    $_SERVER["REQUEST_URI"] ?? "",
    PHP_URL_PATH
);

$uri = rtrim($uri, "/");

/*
 * Les deux formes sont acceptées :
 *
 * /api/hesitation/questions
 * /api/routes/hesitation.php/questions
 */

if (
    $method === "GET" &&
    (
        $uri === "/api/hesitation/questions" ||
        str_ends_with($uri, "/hesitation.php/questions")
    )
) {
    $controller->questions();
    exit;
}


if (
    $method === "GET" &&
    (
        $uri === "/api/hesitation/criteres" ||
        str_ends_with($uri, "/hesitation.php/criteres")
    )
) {
    $controller->criteres();
    exit;
}


if (
    $method === "POST" &&
    (
        $uri === "/api/hesitation/comparer" ||
        str_ends_with($uri, "/hesitation.php/comparer")
    )
) {
    $controller->comparer();
    exit;
}


http_response_code(404);

header(
    "Content-Type: application/json; charset=utf-8"
);

echo json_encode(
    [
        "success" => false,
        "message" => "Route Hésitation introuvable",
        "method" => $method,
        "uri" => $uri
    ],
    JSON_UNESCAPED_UNICODE |
    JSON_UNESCAPED_SLASHES
);
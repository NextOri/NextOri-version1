<?php

require_once "../controllers/TestController.php";

try {

    $controller = new TestController();

    $ok = $controller->enregistrerReponse(
        1, // id_test
        2  // id_proposition
    );

    if ($ok) {
        echo "✅ Réponse enregistrée avec succès.";
    } else {
        echo "❌ Impossible d'enregistrer la réponse.";
    }

} catch (Exception $e) {

    echo "Erreur : " . $e->getMessage();

}
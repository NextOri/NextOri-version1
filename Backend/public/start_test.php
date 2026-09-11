<?php

require_once "../controllers/TestController.php";


try {

    $controller = new TestController();


    $idTest = $controller->commencerTest(
        1,
        1
    );


    echo "Test créé avec succès !";

    echo "<br>";

    echo "ID du test : " . $idTest;


} catch(Exception $e) {

    echo "Erreur : " . $e->getMessage();

}
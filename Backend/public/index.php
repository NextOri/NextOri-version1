<?php

require_once "../controllers/TestController.php";

try {

    $controller = new TestController();

    $questionnaire = $controller->afficherQuestionnaire();

    echo "<h2>";
    echo $questionnaire['nom'];
    echo "</h2>";

    echo "<hr>";

    $questions = $controller->afficherQuestions(
        $questionnaire['id_questionnaire']
    );

    foreach ($questions as $question) {

    echo "<h3>";
    echo $question['ordre'] . ". " . $question['texte'];
    echo "</h3>";

    $propositions = $controller->afficherPropositions(
        $question['id_question']
    );

    foreach ($propositions as $proposition) {

        echo $proposition['lettre'] . ". ";

        echo $proposition['libelle'];

        echo "<br>";

    }

    echo "<hr>";
}
} catch (Exception $e) {

    echo $e->getMessage();
}

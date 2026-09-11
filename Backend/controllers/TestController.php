<?php

require_once __DIR__ . '/../repositories/QuestionnaireRepository.php';
require_once __DIR__ . '/../repositories/QuestionRepository.php';
require_once __DIR__ . '/../repositories/PropositionRepository.php';
require_once __DIR__ . '/../repositories/TestRepository.php';
require_once __DIR__ . '/../repositories/ReponseRepository.php';

class TestController
{
    private QuestionnaireRepository $questionnaireRepository;
    private QuestionRepository $questionRepository;
    private PropositionRepository $propositionRepository;
    private TestRepository $testRepository;
    private ReponseRepository $reponseRepository;

    public function __construct()
    {
        $this->questionnaireRepository = new QuestionnaireRepository();
        $this->questionRepository = new QuestionRepository();
        $this->propositionRepository = new PropositionRepository();
        $this->testRepository = new TestRepository();
        $this->reponseRepository = new ReponseRepository();
    }

    public function afficherQuestionnaire()
    {
        return $this->questionnaireRepository->getQuestionnaireActif();
    }

    public function afficherQuestions(int $idQuestionnaire)
    {
        return $this->questionRepository
            ->getQuestionsByQuestionnaire($idQuestionnaire);
    }
    public function afficherPropositions(int $idQuestion)
    {
        return $this->propositionRepository
            ->getPropositionsByQuestion($idQuestion);
    }
    public function commencerTest(
    int $idUser,
    int $idQuestionnaire)
    {
    return $this->testRepository
                ->creerTest(
                    $idUser,
                    $idQuestionnaire
                );
    }
    public function enregistrerReponse(
    int $idTest,
    int $idProposition)
    {
    return $this->reponseRepository
                ->enregistrerReponse(
                    $idTest,
                    $idProposition
                );
    }
}

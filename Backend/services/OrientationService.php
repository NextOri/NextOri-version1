<?php

require_once __DIR__ . "/TestService.php";
require_once __DIR__ . "/ReponseService.php";
require_once __DIR__ . "/RiasecService.php";
require_once __DIR__ . "/TestResultService.php";
require_once __DIR__ . "/MetierService.php";
require_once __DIR__ . "/FiliereService.php";
require_once __DIR__ . "/UniversiteService.php";
require_once __DIR__ . "/UserService.php";


class OrientationService
{

    private TestService $testService;
    private ReponseService $reponseService;
    private RiasecService $riasecService;
    private TestResultService $testResultService;
    private MetierService $metierService;
    private FiliereService $filiereService;
    private UniversiteService $universiteService;
    private UserService $userService;
    



    public function __construct()
    {

        $this->testService = new TestService();

        $this->reponseService = new ReponseService();

        $this->riasecService = new RiasecService();

        $this->testResultService = new TestResultService();

        $this->metierService = new MetierService();

        $this->filiereService = new FiliereService();

        $this->universiteService = new UniversiteService();

        $this->userService = new UserService();

    }




    public function demarrerTest(
        int $idUser,
        int $idQuestionnaire
    ): int
    {

        return $this->testService->creerTest(
            $idUser,
            $idQuestionnaire
        );

    }


    

    public function enregistrerReponses(
        int $idTest,
        array $reponses
    ): void
    {
      
   
        $this->reponseService->enregistrerReponses(
            $idTest,
            $reponses
        );

    }





    public function calculerProfil(
        int $idTest
    ): array
    {

        $scores =
            $this->riasecService->calculerScores($idTest);


        $profil =
            $this->riasecService->determinerProfil($scores);



        return [

            "scores" => $scores,

            "profil" => $profil

        ];

    }





    /**
     * Nouvelle méthode :
     * Ajoute filières et universités à chaque métier
     */
    private function enrichirMetiersAvecFormations(
        array $metiers
    ): array
    {

        $resultat = [];



        foreach ($metiers as $metier) {


            $filieres = 
                $this->filiereService
                     ->rechercherFilieresCompatibles(
                         [$metier]
                     );



            $filieresCompletes = [];



            foreach ($filieres as $filiere) {


                $universites =
                    $this->universiteService
                         ->rechercherUniversitesCompatibles(
                             [$filiere]
                         );



                $filieresCompletes[] = [


                    "filiere" => $filiere,


                    "universites" => $universites


                ];

            }




            $metier["filieres"] =
                $filieresCompletes;



            $resultat[] = $metier;

        }



        return $resultat;

    }



    /**
 * Récupère le dernier test effectué par un utilisateur.
 */
   public function recupererDernierResultat(
    int $idUser
): ?array
{

    // 1. Récupérer le dernier test
    $test = $this->testService
                 ->obtenirDernierTestUtilisateur(
                     $idUser
                 );


    if ($test === null) {

        return null;

    }

    $utilisateur =
    $this->userService->getUserById($idUser);

     $idSerie =
    $utilisateur["id_serie"] ?? null;


    // 2. Récupérer le profil enregistré

    $profilPrincipal = $test["profil_dominant"];



    $scores = [

        "R" => $test["score_R"],
        "I" => $test["score_I"],
        "A" => $test["score_A"],
        "S" => $test["score_S"],
        "E" => $test["score_E"],
        "C" => $test["score_C"]

    ];



    // 3. Rechercher les métiers comme dans executerOrientation

    $metiers =
        $this->metierService
             ->obtenirRecommandations(
                 $profilPrincipal,
                    $idSerie
             );



    // 4. Ajouter formations + universités

    $metiersPrincipaux =
        $this->enrichirMetiersAvecFormations(
            $metiers["principaux"]
        );


    $metiersSecondaires =
        $this->enrichirMetiersAvecFormations(
            $metiers["secondaires"]
        );



    // 5. Retour même structure que executerOrientation

    return [

        "id_test" => $test["id_test"],


        "profil" => [

            "principal" => $profilPrincipal,

            "scores" => $scores

        ],


        "recommandations" => [

            "principaux" => $metiersPrincipaux,

            "secondaires" => $metiersSecondaires

        ]

    ];

}

/**
 * Retourne un test précis avec son profil
 * et ses recommandations.
 */
public function obtenirTestParId(
    int $idTest,
    int $idUser
): ?array
{
    // 1. Récupérer le test précis
    $test = $this->testService->obtenirTestParId(
        $idTest,
        $idUser
    );

    if ($test === null) {
        return null;
    }


    // 2. Récupérer l'utilisateur
    $utilisateur = $this->userService->getUserById($idUser);

    $idSerie = $utilisateur["id_serie"] ?? null;


    // 3. Profil dominant enregistré dans le test
    $profilPrincipal = $test["profil_dominant"];


    // 4. Récupérer les scores du test
    $scores = [

        "R" => $test["score_R"],
        "I" => $test["score_I"],
        "A" => $test["score_A"],
        "S" => $test["score_S"],
        "E" => $test["score_E"],
        "C" => $test["score_C"]

    ];


    // 5. Rechercher les métiers recommandés
    // exactement comme pour le dernier résultat
    $metiers =
        $this->metierService
             ->obtenirRecommandations(
                 $profilPrincipal,
                 $idSerie
             );


    // 6. Ajouter les filières et universités
    $metiersPrincipaux =
        $this->enrichirMetiersAvecFormations(
            $metiers["principaux"]
        );


    $metiersSecondaires =
        $this->enrichirMetiersAvecFormations(
            $metiers["secondaires"]
        );


    // 7. Retourner la même structure que le résultat normal
    return [

        "id_test" => $test["id_test"],

        "date_test" => $test["date_test"],

        "profil" => [

            "principal" => $profilPrincipal,

            "scores" => $scores

        ],

        "recommandations" => [

            "principaux" => $metiersPrincipaux,

            "secondaires" => $metiersSecondaires

        ]

    ];
}

/**
  * Retourne le numéro du test pour l'utilisateur.
  */
public function obtenirNumeroTestUtilisateur(
    int $idTest,
    int $idUser
): ?int
{
    return $this->testService
                ->obtenirNumeroTestUtilisateur(
                    $idTest,
                    $idUser
                );
}


/**
 * Retourne tous les tests effectués par un utilisateur.
 */
public function obtenirHistoriqueTests(
    int $idUser
): array
{
    return $this->testService
                ->obtenirTousLesTestsUtilisateur(
                    $idUser
                );
}



    /**
     * Processus complet NextOri
     */
    public function executerOrientation(
        int $idUser,
        int $idQuestionnaire,
        array $reponses
    ): array
    {



        // 1 Création test

        $idTest =
            $this->demarrerTest(
                $idUser,
                $idQuestionnaire
            );




        // 2 Enregistrement réponses

        $this->enregistrerReponses(
            $idTest,
            $reponses
        );





        // 3 Calcul profil

        $profil =
            $this->calculerProfil($idTest);

        
            $this->testResultService->mettreAJourResultat(
             $idTest,
             $profil["scores"],
             $profil["profil"]["profil_principal"]
            );




        // Profil principal

        $profilPrincipal =
            $profil["profil"]["profil_principal"];

            $utilisateur =
    $this->userService->getUserById($idUser);

$idSerie =
    $utilisateur["id_serie"] ?? null;







        // 4 Recherche métiers

        $metiers =
            $this->metierService
                 ->obtenirRecommandations(
                     $profilPrincipal,
                        $idSerie
                 );






        // 5 Ajouter filières + universités

        $metiersPrincipaux = 
            $this->enrichirMetiersAvecFormations(
                $metiers["principaux"]
            );



        $metiersSecondaires = 
            $this->enrichirMetiersAvecFormations(
                $metiers["secondaires"]
            );







        return [


            "id_test" => $idTest,



            "profil" => $profil,



            "recommandations" => [


                "principaux" => $metiersPrincipaux,


                "secondaires" => $metiersSecondaires


            ]


        ];

    }

}
<?php

require_once __DIR__ . "/../repositories/MetierRepository.php";



class MetierService
{
    private MetierRepository $metierRepository;


    public function __construct()
    {
        $this->metierRepository = new MetierRepository();
    }



    /**
     * Recherche les métiers compatibles avec un profil RIASEC utilisateur
     */
    public function rechercherMetiersCompatibles(
        string $profil,
        ?int $idSerie = null
    ): array {
        // Si l'utilisateur possède une série,
        // on ne travaille que sur les métiers compatibles.
        if ($idSerie !== null) {

            $metiers =
                $this->metierRepository
                ->recupererMetiersParSerie($idSerie);
        } else {

            // Collégien ou utilisateur sans série :
            // tous les métiers restent disponibles.
            $metiers =
                $this->metierRepository
                ->recupererMetiersAccessiblesAuTest();
        }

        foreach ($metiers as &$metier) {


            $profilMetier = $metier["profil_riasec"];


            // Calcul du score de compatibilité

            $metier["score_compatibilite"] =
                $this->calculerCompatibilite(
                    $profil,
                    $profilMetier
                );


            // Nombre de lettres communes

            $metier["nombre_correspondances"] =
                $this->compterCorrespondances(
                    $profil,
                    $profilMetier
                );
        }


        unset($metier);



        /**
         * Tri :
         * 1 - Score de compatibilité décroissant
         * 2 - Nombre de correspondances décroissant
         */

        usort($metiers, function ($a, $b) {


            if ($a["score_compatibilite"] != $b["score_compatibilite"]) {

                return $b["score_compatibilite"]
                    <=>
                    $a["score_compatibilite"];
            }


            return $b["nombre_correspondances"]
                <=>
                $a["nombre_correspondances"];
        });



        return $metiers;
    }






    /**
     * Calcule la compatibilité entre le profil RIASEC
     * de l'utilisateur et celui du métier.
     *
     * Logique NextOri V1 :
     *
     * Première lettre utilisateur :
     * position 1 = 4 points
     * position 2 = 2 points
     * position 3 = 1 point
     *
     * Deuxième lettre utilisateur :
     * position 2 = 4 points
     * position 1 = 2 points
     * position 3 = 1 point
     */
    private function calculerCompatibilite(
        string $profilUtilisateur,
        string $profilMetier
    ): int {
        $profilUtilisateur = strtoupper(trim($profilUtilisateur));
        $profilMetier = strtoupper(trim($profilMetier));

        if ($profilUtilisateur === '' || $profilMetier === '') {
            return 0;
        }

        $score = 0;

        /*
     * Première lettre du profil utilisateur
     */
        if (isset($profilUtilisateur[0])) {

            $lettre = $profilUtilisateur[0];

            $position = strpos($profilMetier, $lettre);

            if ($position === 0) {
                $score += 4;
            } elseif ($position === 1) {
                $score += 2;
            } elseif ($position === 2) {
                $score += 1;
            }
        }

        /*
     * Deuxième lettre du profil utilisateur
     */
        if (isset($profilUtilisateur[1])) {

            $lettre = $profilUtilisateur[1];

            $position = strpos($profilMetier, $lettre);

            if ($position === 1) {
                $score += 2;
            } elseif ($position === 0) {
                $score += 2;
            } elseif ($position === 2) {
                $score += 1;
            }
        }

        return $score;
    }







    /**
     * Compte le nombre de lettres du profil
     * présentes dans le profil métier
     */

    private function compterCorrespondances(
        string $profilUtilisateur,
        string $profilMetier
    ): int {


        $nombre = 0;



        if (strpos($profilMetier, $profilUtilisateur[0]) !== false) {

            $nombre++;
        }



        if (strpos($profilMetier, $profilUtilisateur[1]) !== false) {

            $nombre++;
        }



        return $nombre;
    }
    /**
     * Retourne les métiers principaux et secondaires
     */
    public function obtenirRecommandations(
        string $profil,
        ?int $idSerie = null
    ): array {
        $metiers =
            $this->rechercherMetiersCompatibles(
                $profil,
                $idSerie
            );

        // Suppression des métiers incompatibles
        $metiers = $this->filtrerMetiersCompatibles($metiers);

        // Séparation en principaux et secondaires
        return $this->separerMetiers($metiers);
    }
    /**
     * Prépare les données finales pour le frontend
     */
    public function formaterRecommandations(
        string $profil,
        ?int $idSerie = null
    ): array {
        $recommandations =
            $this->obtenirRecommandations(
                $profil,
                $idSerie
            );

        return [

            "profil" => $profil,

            "metiers_principaux" =>
            $this->formaterMetiers(
                $recommandations["principaux"]
            ),

            "metiers_secondaires" =>
            $this->formaterMetiers(
                $recommandations["secondaires"]
            )
        ];
    }



    /**
     * Nettoie les informations envoyées au frontend
     */
    private function formaterMetiers(array $metiers): array
    {

        $resultat = [];


        foreach ($metiers as $metier) {


            $resultat[] = [

                "id" => $metier["id_metier"],

                "nom" => $metier["nom"],

                "profil_riasec" =>
                $metier["profil_riasec"],

                "score" =>
                $metier["score_compatibilite"]

            ];
        }


        return $resultat;
    }
    /**
     * Supprime les métiers dont la compatibilité est nulle.
     */
    private function filtrerMetiersCompatibles(array $metiers): array
    {
        $resultat = [];

        foreach ($metiers as $metier) {

            if ($metier["score_compatibilite"] > 0) {

                $resultat[] = $metier;
            }
        }

        return $resultat;
    }
    /**
     * Sépare les métiers en principaux et secondaires
     * selon leur compatibilité relative avec le meilleur score.
     */
    /**
     * Sépare les métiers en principaux et secondaires.
     */
    private function separerMetiers(array $metiers): array
    {
        return [

            "principaux" => array_slice($metiers, 0, 5),

            "secondaires" => array_slice($metiers, 5, 5)

        ];
    }
    /**
     * Construit la recommandation complète :
     * Métier → Filières → Universités
     */
    public function construireDetailsMetiers(
        array $metiers
    ): array {

        $resultat = [];


        foreach ($metiers as $metier) {


            $filieres = [];



            $listeFilieres =
                (new FiliereService())
                ->rechercherFilieresParMetier(
                    $metier["id_metier"]
                );



            foreach ($listeFilieres as $filiere) {


                $universites =
                    (new UniversiteService())
                    ->rechercherUniversitesParFiliere(
                        $filiere["id_filiere"]
                    );



                $filieres[] = [

                    "id_filiere" =>
                    $filiere["id_filiere"],

                    "nom" =>
                    $filiere["nom"],

                    "description" =>
                    $filiere["description"],

                    "domaine" =>
                    $filiere["domaine"],

                    "duree" =>
                    $filiere["duree"],

                    "universites" =>
                    $universites

                ];
            }



            $resultat[] = [

                "metier" => $metier,

                "filieres" => $filieres

            ];
        }


        return $resultat;
    }
}

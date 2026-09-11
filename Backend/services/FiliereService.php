<?php

require_once __DIR__ . "/../repositories/FiliereRepository.php";


class FiliereService
{

    private FiliereRepository $filiereRepository;



    public function __construct()
    {
        $this->filiereRepository = new FiliereRepository();
    }





    /**
     * Recherche les filières liées aux métiers recommandés
     */
    public function rechercherFilieresCompatibles(array $metiers): array
    {

        $filieres = [];



        foreach ($metiers as $metier) {


            $idMetier = $metier["id_metier"];



            $resultats =
                $this->filiereRepository
                     ->recupererFilieresParMetier($idMetier);



            foreach ($resultats as $filiere) {


                $filieres[] = $filiere;

            }

        }



        return $this->supprimerDoublons($filieres);

    }





    /**
     * Supprime les filières répétées
     */
    private function supprimerDoublons(array $filieres): array
    {

        $filieresUniques = [];


        $ids = [];



        foreach ($filieres as $filiere) {


            if (!in_array($filiere["id_filiere"], $ids)) {


                $ids[] = $filiere["id_filiere"];


                $filieresUniques[] = $filiere;

            }

        }



        return $filieresUniques;

    }
    /**
 * Recherche les filières à partir des recommandations métiers
 */
public function obtenirFilieresDepuisRecommandations(array $recommandations): array
{

    $metiers = [];



    // Récupérer les métiers principaux

    foreach ($recommandations["principaux"] as $metier) {

        $metiers[] = $metier;

    }



    // Ajouter les métiers secondaires

    foreach ($recommandations["secondaires"] as $metier) {

        $metiers[] = $metier;

    }



    return $this->rechercherFilieresCompatibles($metiers);

}
/**
 * Retourne les filières liées à un métier précis
 */
public function rechercherFilieresParMetier(
    int $idMetier
): array
{

    return $this->filiereRepository
                ->recupererFilieresParMetier($idMetier);

}



}
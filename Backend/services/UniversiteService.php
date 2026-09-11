<?php

require_once __DIR__ . "/../repositories/UniversiteRepository.php";

class UniversiteService
{
    private UniversiteRepository $universiteRepository;

    public function __construct()
    {
        $this->universiteRepository = new UniversiteRepository();
    }

    /**
     * Recherche les universités correspondant aux filières
     */
    public function rechercherUniversitesCompatibles(array $filieres): array
    {
        $universites = [];

        foreach ($filieres as $filiere) {

            $idFiliere = $filiere["id_filiere"];

            $resultats = $this->universiteRepository
                              ->recupererParFiliere($idFiliere);

            foreach ($resultats as $universite) {
                $universites[] = $universite;
            }
        }

        return $this->supprimerDoublons($universites);
    }

    /**
     * Supprime les universités en double
     */
    private function supprimerDoublons(array $universites): array
    {
        $universitesUniques = [];
        $ids = [];

        foreach ($universites as $universite) {

            if (!in_array($universite["id_universite"], $ids)) {

                $ids[] = $universite["id_universite"];
                $universitesUniques[] = $universite;
            }
        }

        return $universitesUniques;
    }
    /**
 * Retourne les universités liées à une filière précise
 */
    public function rechercherUniversitesParFiliere(
    int $idFiliere
   ): array
   {

    return $this->universiteRepository
                ->recupererParFiliere($idFiliere);

   }
}
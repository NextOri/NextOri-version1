<?php

require_once __DIR__ . "/../config/database.php";

class DashboardService
{
    private PDO $connexion;

    public function __construct()
    {
        $database = new Database();
        $this->connexion = $database->connect();
    }

    private function calculerPoints(int $idUser): int
    {
        $points = 0;

        // 1. Profil créé (+20)
        $sql = "SELECT COUNT(*) FROM utilisateur WHERE id_user = ?";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 20;
        }

        // 2. Test RIASEC terminé (+50)
        $sql = "SELECT COUNT(*) FROM test_riasec WHERE id_user = ?";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 50;
        }

        // 3. Profil consulté (+20)
        $sql = "SELECT COUNT(*) FROM historique WHERE id_user = ? AND action = 'PROFIL_CONSULTE'";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 20;
        }

        // 4. Métiers consultés (+20)
        $sql = "SELECT COUNT(*) FROM historique WHERE id_user = ? AND action = 'METIERS_CONSULTES'";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 20;
        }

        // 5. Formation consultée (+10)
        $sql = "SELECT COUNT(*) FROM historique WHERE id_user = ? AND action = 'FORMATION_CONSULTEE'";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 10;
        }

        // 6. Université consultée (+10)
        $sql = "SELECT COUNT(*) FROM historique WHERE id_user = ? AND action = 'UNIVERSITES_CONSULTEES'";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 10;
        }

        // 7. Avis donné (+20)
        $sql = "SELECT COUNT(*) FROM historique WHERE id_user = ? AND action = 'AVIS_DONNE'";
        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {
            $points += 20;
        }

        // 8. Connexions quotidiennes (+5 points par jour)
        $sql = "
         SELECT COUNT(*)
         FROM connexion_utilisateur
         WHERE id_user = ?
         ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        $nombreConnexions = (int) $requete->fetchColumn();

        $points += $nombreConnexions * 5;


        // 9. Points des badges obtenus
        $sql = "
    SELECT COALESCE(SUM(b.points), 0)
    FROM badge_utilisateur bu
    INNER JOIN badge b
        ON b.id_badge = bu.id_badge
    WHERE bu.id_user = ?
";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        $points += (int) $requete->fetchColumn();

        return $points;
    }

    private function verifierBadges(
        int $idUser,
        int $serie
    ): void {
        // 1. Premier Pas
        $this->attribuerBadge(
            $idUser,
            "PREMIER_PAS"
        );

        // 2. Explorateur
        $sql = "
        SELECT COUNT(*)
        FROM test_riasec
        WHERE id_user = ?
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ((int) $requete->fetchColumn() > 0) {
            $this->attribuerBadge(
                $idUser,
                "EXPLORATEUR"
            );
        }


        // 3. Connaissance de soi
        $sql = "
        SELECT COUNT(*)
        FROM historique
        WHERE id_user = ?
        AND action = 'PROFIL_CONSULTE'
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ((int) $requete->fetchColumn() > 0) {
            $this->attribuerBadge(
                $idUser,
                "CONNAISSANCE_SOI"
            );
        }


        // 4. Découvreur de métiers
        $sql = "
        SELECT COUNT(*)
        FROM historique
        WHERE id_user = ?
        AND action = 'METIERS_CONSULTES'
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ((int) $requete->fetchColumn() > 0) {
            $this->attribuerBadge(
                $idUser,
                "DECOUVREUR_METIERS"
            );
        }


        // 5. Choix de carrière
        $sql = "
        SELECT COUNT(*)
        FROM historique
        WHERE id_user = ?
        AND action = 'FORMATION_CONSULTEE'
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ((int) $requete->fetchColumn() > 0) {
            $this->attribuerBadge(
                $idUser,
                "CHOIX_CARRIERE"
            );
        }


        // 6. Prêt pour l'université
        $sql = "
        SELECT COUNT(*)
        FROM historique
        WHERE id_user = ?
        AND action = 'UNIVERSITES_CONSULTEES'
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ((int) $requete->fetchColumn() > 0) {
            $this->attribuerBadge(
                $idUser,
                "PRET_UNIVERSITE"
            );
        }


        // 7. Contributeur
        $sql = "
    SELECT COUNT(*)
    FROM historique
    WHERE id_user = ?
    AND action = 'AVIS_DONNE'
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ((int) $requete->fetchColumn() > 0) {
            $this->attribuerBadge(
                $idUser,
                "CONTRIBUTEUR"
            );
        }

        // 8. Série de 5 jours
        if ($serie >= 5) {
            $this->attribuerBadge(
                $idUser,
                "SERIE_5_JOURS"
            );
        }

        // 9. Série de 7 jours
        if ($serie >= 7) {
            $this->attribuerBadge(
                $idUser,
                "SERIE_7_JOURS"
            );
        }

        // 10. Série de 15 jours
        if ($serie >= 15) {
            $this->attribuerBadge(
                $idUser,
                "SERIE_15_JOURS"
            );
        }

        // 11. Série de 30 jours
        if ($serie >= 30) {
            $this->attribuerBadge(
                $idUser,
                "SERIE_30_JOURS"
            );
        }
    }


    private function attribuerBadge(
        int $idUser,
        string $code
    ): void {
        // Récupérer le badge
        $sql = "
        SELECT id_badge
        FROM badge
        WHERE code = ?
        LIMIT 1
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$code]);

        $idBadge = $requete->fetchColumn();

        if (!$idBadge) {
            return;
        }

        // Attribuer le badge une seule fois
        $sql = "
        INSERT INTO badge_utilisateur
        (
            id_user,
            id_badge,
            date_obtention
        )
        VALUES
        (
            ?,
            ?,
            CURDATE()
        )
        ON DUPLICATE KEY UPDATE
            id_badge_utilisateur = id_badge_utilisateur
    ";

        $requete = $this->connexion->prepare($sql);

        $requete->execute([
            $idUser,
            $idBadge
        ]);
    }


    private function recupererBadgesUtilisateur(int $idUser): array
    {
        $sql = "
        SELECT
            b.nom,
            b.icone,
            b.description
        FROM badge_utilisateur bu
        INNER JOIN badge b
            ON b.id_badge = bu.id_badge
        WHERE bu.id_user = ?
        ORDER BY bu.date_obtention ASC
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        return $requete->fetchAll(PDO::FETCH_ASSOC);
    }



    private function calculerNiveau(int $points): array
    {
        // Niveau 1 : Explorateur
        if ($points < 100) {
            return [
                "nom" => "Explorateur",
                "numero" => 1,
                "progression" => intval(($points / 100) * 100)
            ];
        }

        // Niveau 2 : Découvreur
        elseif ($points < 200) {
            return [
                "nom" => "Découvreur",
                "numero" => 2,
                "progression" => intval((($points - 100) / 100) * 100)
            ];
        }

        // Niveau 3 : Visionnaire
        elseif ($points < 300) {
            return [
                "nom" => "Visionnaire",
                "numero" => 3,
                "progression" => intval((($points - 200) / 100) * 100)
            ];
        }

        // Niveau 4 : Expert
        elseif ($points < 500) {
            return [
                "nom" => "Expert",
                "numero" => 4,
                "progression" => intval((($points - 300) / 200) * 100)
            ];
        }

        // Niveau 5 : Maître
        elseif ($points < 750) {
            return [
                "nom" => "Maître",
                "numero" => 5,
                "progression" => intval((($points - 500) / 250) * 100)
            ];
        }

        // Niveau 6 : Ambassadeur
        elseif ($points < 1000) {
            return [
                "nom" => "Ambassadeur",
                "numero" => 6,
                "progression" => intval((($points - 750) / 250) * 100)
            ];
        }

        // Niveau 7 : Mentor
        elseif ($points < 1500) {
            return [
                "nom" => "Mentor",
                "numero" => 7,
                "progression" => intval((($points - 1000) / 500) * 100)
            ];
        }

        // Niveau 8 : Légende
        return [
            "nom" => "Légende",
            "numero" => 8,
            "progression" => 100
        ];
    }

    private function calculerSerie(int $idUser): int
    {
        $sql = "
        SELECT date_connexion
        FROM connexion_utilisateur
        WHERE id_user = ?
        ORDER BY date_connexion DESC
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        $dates = $requete->fetchAll(PDO::FETCH_COLUMN);

        if (empty($dates)) {
            return 0;
        }

        $serie = 1;

        $dateActuelle = new DateTimeImmutable($dates[0]);

        for ($i = 1; $i < count($dates); $i++) {

            $datePrecedente = new DateTimeImmutable($dates[$i]);

            $difference = $dateActuelle->diff($datePrecedente)->days;

            if ($difference === 1) {

                $serie++;

                $dateActuelle = $datePrecedente;
            } else {

                break;
            }
        }

        return $serie;
    }


    private function calculerParcours(int $idUser): array
    {

        // =========================
        // 1. PROFIL CRÉÉ
        // =========================

        $profil = false;

        $sql = "SELECT COUNT(*) FROM utilisateur WHERE id_user = ?";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {

            $profil = true;
        }


        // =========================
        // 2. TEST RIASEC TERMINÉ
        // =========================

        $test = false;

        $sql = "SELECT COUNT(*) FROM test_riasec WHERE id_user = ?";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        if ($requete->fetchColumn() > 0) {

            $test = true;
        }


        // =========================
        // 3. HISTORIQUE
        // =========================

        $actions = [];


        $sql = "
        SELECT action 
        FROM historique 
        WHERE id_user = ?
    ";


        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);


        while ($ligne = $requete->fetch(PDO::FETCH_ASSOC)) {

            $actions[] = $ligne['action'];
        }



        return [

            "profil" => $profil,

            "test" => $test,

            "profilConsulte" => in_array(
                "PROFIL_CONSULTE",
                $actions
            ),


            "metiersConsultes" => in_array(
                "METIERS_CONSULTES",
                $actions
            ),


            "formationConsultee" => in_array(
                "FORMATION_CONSULTEE",
                $actions
            ),


            "universitesConsultees" => in_array(
                "UNIVERSITES_CONSULTEES",
                $actions
            ),

            "avisDonne" => in_array(
                "AVIS_DONNE",
                $actions
            )

        ];
    }


    private function enregistrerVisiteDuJour(int $idUser): void
    {
        $sql = "
        INSERT INTO connexion_utilisateur
        (
            id_user,
            date_connexion
        )
        VALUES
        (
            :id_user,
            CURDATE()
        )
        ON DUPLICATE KEY UPDATE
            id_connexion = id_connexion
    ";

        $requete = $this->connexion->prepare($sql);

        $requete->execute([
            ":id_user" => $idUser
        ]);
    }


    public function recupererDashboard(int $idUser): ?array
    {
        $sql = "
        SELECT nom
        FROM utilisateur
        WHERE id_user = ?
    ";

        $requete = $this->connexion->prepare($sql);
        $requete->execute([$idUser]);

        $utilisateur = $requete->fetch(PDO::FETCH_ASSOC);

        if (!$utilisateur) {
            return null;
        }

        // Enregistrer la visite du jour
        $this->enregistrerVisiteDuJour($idUser);

        $serie = $this->calculerSerie($idUser);

        // Vérifier et attribuer les badges
        $this->verifierBadges($idUser, $serie);

        // Calculer les points
        $points = $this->calculerPoints($idUser);
        // Calculer le niveau
        $niveau = $this->calculerNiveau($points);

        // Récupérer les badges permanents
        $badges = $this->recupererBadgesUtilisateur($idUser);

        // Calculer le parcours
        $parcours = $this->calculerParcours($idUser);

        return [
            "utilisateur" => [
                "nom" => $utilisateur["nom"]
            ],

            "niveau" => $niveau,

            "statistiques" => [
                "points" => $points,
                "serie" => $serie,
                "badges" => count($badges)
            ],

            "parcours" => $parcours,

            "liste_badges" => $badges
        ];
    }
}

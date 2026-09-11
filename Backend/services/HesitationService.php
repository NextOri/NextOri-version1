// backend/services/HesitationService.php

<?php

require_once __DIR__ . "/../repositories/HesitationRepository.php";

class HesitationService
{
    private HesitationRepository $repository;

    private array $correspondances = [
        "ATTIRANCE_CONTENU" => [
            "critere" => "contenu",
            "poids" => 3
        ],
        "ATTIRANCE_SENS" => [
            "critere" => "sens",
            "poids" => 3
        ],
        "ATTIRANCE_OPPORTUNITES" => [
            "critere" => "debouches",
            "poids" => 3
        ],
        "ATTIRANCE_CADRE" => [
            "critere" => "conditions",
            "poids" => 3
        ],
        "ATTIRANCE_DEFI" => [
            "critere" => "progression",
            "poids" => 3
        ],

        "FORCE_ANALYSER" => [
            "critere" => "analyse",
            "poids" => 3
        ],
        "FORCE_CREER" => [
            "critere" => "creation",
            "poids" => 3
        ],
        "FORCE_AIDER" => [
            "critere" => "relation",
            "poids" => 3
        ],
        "FORCE_ORGANISER" => [
            "critere" => "organisation",
            "poids" => 3
        ],
        "FORCE_AGIR" => [
            "critere" => "action",
            "poids" => 3
        ],

        "CRITERE_INTERET" => [
            "critere" => "interet",
            "poids" => 5
        ],
        "CRITERE_CAPACITES" => [
            "critere" => "capacites",
            "poids" => 5
        ],
        "CRITERE_DEBOUCHES" => [
            "critere" => "debouches",
            "poids" => 5
        ],
        "CRITERE_CONDITIONS" => [
            "critere" => "conditions",
            "poids" => 5
        ],
        "CRITERE_STABILITE" => [
            "critere" => "stabilite",
            "poids" => 5
        ]
    ];

    public function __construct()
    {
        $this->repository = new HesitationRepository();
    }

    public function recupererQuestions(): array
    {
        return $this->repository->recupererQuestionsAvecReponses();
    }

    public function recupererCriteres(): array
    {
        return $this->repository->recupererCriteresActifs();
    }

    public function comparer(
        string $typeChoix,
        array $idsOptions,
        array $reponses
    ): array {

        $criteresActifs = $this->construireCriteresActifs($reponses);

        if ($typeChoix === "metier") {
            $options = $this->repository->recupererMetiersParIds($idsOptions);

            $valeurs = $this->repository->recupererCriteresMetiers($idsOptions);

            $cleId = "id_metier";
        } elseif ($typeChoix === "filiere") {
            $options = $this->repository->recupererFilieresParIds($idsOptions);

            $valeurs = $this->repository->recupererCriteresFilieres($idsOptions);

            $cleId = "id_filiere";
        } else {
            throw new InvalidArgumentException(
                "typeChoix doit être 'metier' ou 'filiere'."
            );
        }

        $index = [];

        foreach ($valeurs as $ligne) {
            $id = (int) $ligne[$cleId];
            $index[$id][$ligne["code"]] = (float) $ligne["valeur"];
        }

        $comparaison = [];

        foreach ($options as $option) {
            $id = (int) $option[$cleId];

            $total = 0;
            $maximum = 0;
            $details = [];

            foreach ($criteresActifs as $critere) {
                $code = $critere["critere"];
                $poids = $critere["poids"];

                $valeur = $index[$id][$code] ?? null;

                if ($valeur === null) {
                    continue;
                }

                $total += $valeur * $poids;
                $maximum += 5 * $poids;

                $details[] = [
                    "code" => $code,
                    "valeur" => $valeur,
                    "poids" => $poids
                ];
            }

            $score = $maximum > 0
                ? round(($total / $maximum) * 100)
                : null;

            $comparaison[] = [
                ...$option,
                "score" => $score,
                "score_brut" => $total,
                "criteres" => $details
            ];
        }

        usort(
            $comparaison,
            function ($a, $b) {
                if ($a["score"] === null) {
                    return 1;
                }

                if ($b["score"] === null) {
                    return -1;
                }

                return $b["score"] <=> $a["score"];
            }
        );

        return [
            "type_choix" => $typeChoix,
            "criteres_actifs" => $criteresActifs,
            "comparaison" => $comparaison,
            "meilleure_option" => $comparaison[0] ?? null
        ];
    }

    private function construireCriteresActifs(
        array $reponses
    ): array {

        $criteres = [];

        foreach ($reponses as $reponse) {
            $code = $reponse["code"] ?? null;

            if (!$code || !isset($this->correspondances[$code])) {
                continue;
            }

            $correspondance = $this->correspondances[$code];
            $critere = $correspondance["critere"];
            $poids = $correspondance["poids"];

            if (!isset($criteres[$critere])) {
                $criteres[$critere] = [
                    "critere" => $critere,
                    "poids" => $poids
                ];
            } else {
                $criteres[$critere]["poids"] += $poids / 2;
            }
        }

        return array_values($criteres);
    }
}
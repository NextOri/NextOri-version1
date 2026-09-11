<?php

require_once __DIR__ . "/../repositories/SerieRepository.php";

class SerieService
{
    private SerieRepository $serieRepository;

    public function __construct()
    {
        $this->serieRepository = new SerieRepository();
    }

    public function recupererToutesLesSeries(): array
    {
        return $this->serieRepository
            ->recupererToutesLesSeries();
    }
}
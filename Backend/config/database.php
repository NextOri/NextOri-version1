<?php

class Database
{
    private string $host = "";
    private string $dbName = "";
    private string $username = "";
    private string $password = "";

    private ?PDO $connection = null;

    /**
     * Retourne une connexion PDO Ã  la base de donnÃ©es.
     */
    public function connect(): PDO
    {
        $this->host = getenv("DB_HOST") ?: "localhost";
        $this->dbName = getenv("DB_NAME") ?: "nextori_db_V2";
        $this->username = getenv("DB_USER") ?: "root";
        $this->password = getenv("DB_PASSWORD") ?: "";
        if ($this->connection === null) {

            $dsn = "mysql:host={$this->host};dbname={$this->dbName};charset=utf8mb4";

            $this->connection = new PDO(
                $dsn,
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
        }

        return $this->connection;
    }
}


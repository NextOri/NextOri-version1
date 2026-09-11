-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 02 juil. 2026 à 20:50
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */
;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */
;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */
;
/*!40101 SET NAMES utf8mb4 */
;
--
-- Base de données : `nextori_db_v1`
--

-- --------------------------------------------------------
--
-- Structure de la table `favori`
--

CREATE TABLE `favori` (
  `id_favori` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_metier` int(11) NOT NULL,
  `date_ajout` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `filiere`
--

CREATE TABLE `filiere` (
  `id_filiere` int(11) NOT NULL,
  `nom` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `domaine` varchar(100) NOT NULL,
  `duree` varchar(50) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `historique`
--

CREATE TABLE `historique` (
  `id_historique` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `date_action` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `metier`
--

CREATE TABLE `metier` (
  `id_metier` int(11) NOT NULL,
  `nom` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `secteur` varchar(100) NOT NULL,
  `niveau_etude` varchar(100) NOT NULL,
  `salaire_min` decimal(12, 2) DEFAULT NULL,
  `salaire_max` decimal(12, 2) DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `metier_filiere`
--

CREATE TABLE `metier_filiere` (
  `id_metier` int(11) NOT NULL,
  `id_filiere` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `proposition`
--

CREATE TABLE `proposition` (
  `id_proposition` int(11) NOT NULL,
  `id_question` int(11) NOT NULL,
  `lettre` enum('A', 'B', 'C', 'D', 'E', 'F') NOT NULL,
  `libelle` varchar(255) NOT NULL,
  `type_riasec` enum('R', 'I', 'A', 'S', 'E', 'C') NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `question`
--

CREATE TABLE `question` (
  `id_question` int(11) NOT NULL,
  `id_questionnaire` int(11) NOT NULL,
  `texte` text NOT NULL,
  `ordre` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `questionnaire`
--

CREATE TABLE `questionnaire` (
  `id_questionnaire` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `version` varchar(20) NOT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `date_creation` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `recommandation`
--

CREATE TABLE `recommandation` (
  `id_recommandation` int(11) NOT NULL,
  `id_test` int(11) NOT NULL,
  `id_metier` int(11) NOT NULL,
  `compatibilite` decimal(5, 2) NOT NULL,
  `type` enum('top', 'secondaire') NOT NULL,
  `date_recommandation` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `reponse`
--

CREATE TABLE `reponse` (
  `id_reponse` int(11) NOT NULL,
  `id_test` int(11) NOT NULL,
  `id_proposition` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `test_riasec`
--

CREATE TABLE `test_riasec` (
  `id_test` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `date_test` datetime NOT NULL DEFAULT current_timestamp(),
  `score_R` int(11) NOT NULL DEFAULT 0,
  `score_I` int(11) NOT NULL DEFAULT 0,
  `score_A` int(11) NOT NULL DEFAULT 0,
  `score_S` int(11) NOT NULL DEFAULT 0,
  `score_E` int(11) NOT NULL DEFAULT 0,
  `score_C` int(11) NOT NULL DEFAULT 0,
  `profil_dominant` varchar(10) DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `universite`
--

CREATE TABLE `universite` (
  `id_universite` int(11) NOT NULL,
  `nom` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `type` enum('publique', 'privee') NOT NULL,
  `pays` varchar(100) NOT NULL,
  `ville` varchar(100) NOT NULL,
  `site_web` varchar(255) DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `universite_filiere`
--

CREATE TABLE `universite_filiere` (
  `id_universite` int(11) NOT NULL,
  `id_filiere` int(11) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- --------------------------------------------------------
--
-- Structure de la table `utilisateur`
--

CREATE TABLE `utilisateur` (
  `id_user` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `pays` varchar(100) NOT NULL,
  `niveau_etude` varchar(100) NOT NULL,
  `date_creation` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--
-- Index pour les tables déchargées
--

--
-- Index pour la table `favori`
--
ALTER TABLE `favori`
ADD PRIMARY KEY (`id_favori`),
  ADD UNIQUE KEY `uk_favori` (`id_user`, `id_metier`),
  ADD KEY `fk_favori_metier` (`id_metier`);
--
-- Index pour la table `filiere`
--
ALTER TABLE `filiere`
ADD PRIMARY KEY (`id_filiere`),
  ADD UNIQUE KEY `nom` (`nom`);
--
-- Index pour la table `historique`
--
ALTER TABLE `historique`
ADD PRIMARY KEY (`id_historique`),
  ADD KEY `fk_historique_user` (`id_user`);
--
-- Index pour la table `metier`
--
ALTER TABLE `metier`
ADD PRIMARY KEY (`id_metier`),
  ADD UNIQUE KEY `nom` (`nom`);
--
-- Index pour la table `metier_filiere`
--
ALTER TABLE `metier_filiere`
ADD PRIMARY KEY (`id_metier`, `id_filiere`),
  ADD KEY `fk_metier_filiere_filiere` (`id_filiere`);
--
-- Index pour la table `proposition`
--
ALTER TABLE `proposition`
ADD PRIMARY KEY (`id_proposition`),
  ADD KEY `fk_proposition_question` (`id_question`);
--
-- Index pour la table `question`
--
ALTER TABLE `question`
ADD PRIMARY KEY (`id_question`),
  ADD KEY `fk_question_questionnaire` (`id_questionnaire`);
--
-- Index pour la table `questionnaire`
--
ALTER TABLE `questionnaire`
ADD PRIMARY KEY (`id_questionnaire`);
--
-- Index pour la table `recommandation`
--
ALTER TABLE `recommandation`
ADD PRIMARY KEY (`id_recommandation`),
  ADD KEY `fk_recommandation_test` (`id_test`),
  ADD KEY `fk_recommandation_metier` (`id_metier`);
--
-- Index pour la table `reponse`
--
ALTER TABLE `reponse`
ADD PRIMARY KEY (`id_reponse`),
  ADD UNIQUE KEY `uk_reponse` (`id_test`, `id_proposition`),
  ADD KEY `fk_reponse_proposition` (`id_proposition`);
--
-- Index pour la table `test_riasec`
--
ALTER TABLE `test_riasec`
ADD PRIMARY KEY (`id_test`),
  ADD KEY `fk_test_user` (`id_user`);
--
-- Index pour la table `universite`
--
ALTER TABLE `universite`
ADD PRIMARY KEY (`id_universite`),
  ADD UNIQUE KEY `nom` (`nom`);
--
-- Index pour la table `universite_filiere`
--
ALTER TABLE `universite_filiere`
ADD PRIMARY KEY (`id_universite`, `id_filiere`),
  ADD KEY `fk_universite_filiere_filiere` (`id_filiere`);
--
-- Index pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `email` (`email`);
--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `favori`
--
ALTER TABLE `favori`
MODIFY `id_favori` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `filiere`
--
ALTER TABLE `filiere`
MODIFY `id_filiere` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `historique`
--
ALTER TABLE `historique`
MODIFY `id_historique` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `metier`
--
ALTER TABLE `metier`
MODIFY `id_metier` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `proposition`
--
ALTER TABLE `proposition`
MODIFY `id_proposition` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `question`
--
ALTER TABLE `question`
MODIFY `id_question` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `questionnaire`
--
ALTER TABLE `questionnaire`
MODIFY `id_questionnaire` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `recommandation`
--
ALTER TABLE `recommandation`
MODIFY `id_recommandation` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `reponse`
--
ALTER TABLE `reponse`
MODIFY `id_reponse` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `test_riasec`
--
ALTER TABLE `test_riasec`
MODIFY `id_test` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `universite`
--
ALTER TABLE `universite`
MODIFY `id_universite` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT;
--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `favori`
--
ALTER TABLE `favori`
ADD CONSTRAINT `fk_favori_metier` FOREIGN KEY (`id_metier`) REFERENCES `metier` (`id_metier`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_favori_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateur` (`id_user`) ON DELETE CASCADE;
--
-- Contraintes pour la table `historique`
--
ALTER TABLE `historique`
ADD CONSTRAINT `fk_historique_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateur` (`id_user`) ON DELETE CASCADE;
--
-- Contraintes pour la table `metier_filiere`
--
ALTER TABLE `metier_filiere`
ADD CONSTRAINT `fk_metier_filiere_filiere` FOREIGN KEY (`id_filiere`) REFERENCES `filiere` (`id_filiere`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_metier_filiere_metier` FOREIGN KEY (`id_metier`) REFERENCES `metier` (`id_metier`) ON DELETE CASCADE;
--
-- Contraintes pour la table `proposition`
--
ALTER TABLE `proposition`
ADD CONSTRAINT `fk_proposition_question` FOREIGN KEY (`id_question`) REFERENCES `question` (`id_question`) ON DELETE CASCADE;
--
-- Contraintes pour la table `question`
--
ALTER TABLE `question`
ADD CONSTRAINT `fk_question_questionnaire` FOREIGN KEY (`id_questionnaire`) REFERENCES `questionnaire` (`id_questionnaire`) ON DELETE CASCADE;
--
-- Contraintes pour la table `recommandation`
--
ALTER TABLE `recommandation`
ADD CONSTRAINT `fk_recommandation_metier` FOREIGN KEY (`id_metier`) REFERENCES `metier` (`id_metier`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_recommandation_test` FOREIGN KEY (`id_test`) REFERENCES `test_riasec` (`id_test`) ON DELETE CASCADE;
--
-- Contraintes pour la table `reponse`
--
ALTER TABLE `reponse`
ADD CONSTRAINT `fk_reponse_proposition` FOREIGN KEY (`id_proposition`) REFERENCES `proposition` (`id_proposition`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reponse_test` FOREIGN KEY (`id_test`) REFERENCES `test_riasec` (`id_test`) ON DELETE CASCADE;
--
-- Contraintes pour la table `test_riasec`
--
ALTER TABLE `test_riasec`
ADD CONSTRAINT `fk_test_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateur` (`id_user`) ON DELETE CASCADE;
--
-- Contraintes pour la table `universite_filiere`
--
ALTER TABLE `universite_filiere`
ADD CONSTRAINT `fk_universite_filiere_filiere` FOREIGN KEY (`id_filiere`) REFERENCES `filiere` (`id_filiere`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_universite_filiere_universite` FOREIGN KEY (`id_universite`) REFERENCES `universite` (`id_universite`) ON DELETE CASCADE;
COMMIT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */
;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */
;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */
;
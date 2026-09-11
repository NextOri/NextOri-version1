-- =========================
-- FILIÈRES
-- =========================

INSERT INTO filiere (nom, description, domaine, duree) VALUES
('Informatique', 'Étude des systèmes informatiques, développement et réseaux', 'Sciences & Technologies', '3 ans'),
('Génie Civil', 'Construction et infrastructures', 'Ingénierie', '3 ans'),
('Médecine', 'Études médicales et santé humaine', 'Santé', '6 à 8 ans'),
('Droit', 'Étude des lois et du système juridique', 'Sciences Juridiques', '4 ans'),
('Gestion', 'Management et administration des entreprises', 'Économie & Gestion', '3 ans'),
('Finance', 'Analyse financière et comptabilité', 'Économie & Gestion', '3 ans'),
('Marketing', 'Stratégies commerciales et communication', 'Commerce', '3 ans'),
('Électronique', 'Systèmes électroniques et embarqués', 'Technologie', '3 ans');

-- =========================
-- METIERS
-- =========================

INSERT INTO metier (nom, description, secteur, niveau_etude, salaire_min, salaire_max) VALUES
('Développeur Web', 'Création de sites et applications web', 'Informatique', 'Licence / Master', 300000, 1500000),
('Data Scientist', 'Analyse de données et intelligence artificielle', 'Informatique', 'Master', 500000, 2000000),
('Ingénieur Génie Civil', 'Construction de bâtiments et infrastructures', 'BTP', 'Master', 400000, 1800000),
('Médecin', 'Diagnostic et traitement des patients', 'Santé', 'Doctorat', 600000, 3000000),
('Avocat', 'Défense juridique et conseils', 'Droit', 'Master', 300000, 2000000),
('Comptable', 'Gestion des finances et comptabilité', 'Finance', 'Licence', 250000, 1200000),
('Marketeur', 'Stratégies marketing et communication', 'Commerce', 'Licence / Master', 250000, 1500000),
('Administrateur Réseau', 'Gestion des réseaux informatiques', 'Informatique', 'Licence / Master', 300000, 1400000);

-- =========================
-- UNIVERSITÉS
-- =========================

INSERT INTO universite (nom, description , type, pays, ville, site_web) VALUES
('UCAD', 'Université Cheikh Anta Diop de Dakar, la plus grande université du Sénégal', 'publique', 'Sénégal', 'Dakar', 'https://www.ucad.sn'),
('UGB', 'Université Gaston Berger de Saint-Louis', 'publique', 'Sénégal', 'Saint-Louis', 'https://www.ugb.sn'),
('UIDT', 'Université Iba Der Thiam de Thiès', 'publique', 'Sénégal', 'Thiès', 'https://www.uidt.sn'),
('ESP', 'École Supérieure Polytechnique de Dakar', 'publique', 'Sénégal', 'Dakar', 'https://www.esp.sn'),
('SUPDECO', 'Institut privé spécialisé en management et commerce', 'privee', 'Sénégal', 'Dakar', 'https://www.supdeco.sn');

-- =========================
-- METIER_FILIERE
-- =========================

INSERT INTO metier_filiere VALUES
(1, 1), -- Développeur Web -> Informatique
(2, 1), -- Data Scientist -> Informatique
(3, 2), -- Ingénieur Génie Civil -> Génie Civil
(4, 3), -- Médecin -> Médecine
(5, 4), -- Avocat -> Droit
(6, 5), -- Comptable -> Gestion
(7, 7), -- Marketeur -> Marketing
(8, 1); -- Admin Réseau -> Informatique

-- =========================
-- UNIVERSITE_FILIERE
-- =========================

INSERT INTO universite_filiere VALUES
(1, 1), (1, 3), (1, 4), (1, 5),
(2, 2), (2, 1), (2, 5),
(3, 1), (3, 2), (3, 4),
(4, 1), (4, 2),
(5, 5), (5, 7);

-- =========================
-- QUESTIONNAIRE
-- =========================

INSERT INTO questionnaire (nom, description, version, actif)
VALUES (
'Test RIASEC Standard',
'Questionnaire d''orientation professionnelle basé sur la théorie de John Holland et adapté au contexte africain.',
'1.0',
TRUE
);

-- =========================
-- QUESTIONS
-- =========================

INSERT INTO question (id_questionnaire, texte, ordre) VALUES

(1,'Quelle activité préfères-tu faire pendant ton temps libre ?',1),

(1,'Quel type de projet aimerais-tu réaliser ?',2),

(1,'Dans un groupe, quel rôle prends-tu naturellement ?',3),

(1,'Quel environnement de travail préfères-tu ?',4),

(1,'Quelle matière préfères-tu à l''école ?',5),

(1,'Si tu pouvais choisir un stage aujourd''hui, lequel choisirais-tu ?',6),

(1,'Quel type de défi te motive le plus ?',7),

(1,'Quel outil utiliserais-tu le plus volontiers ?',8),

(1,'Quelle activité te semble la plus utile ?',9),

(1,'Quel type de livre ou de contenu préfères-tu ?',10),

(1,'Si tu créais une entreprise, quel serait ton rôle durant la mise en place ?',11),

(1,'Quel type de travail te procure le plus de satisfaction ?',12),

(1,'Lors d''un projet scolaire, quel rôle préfères-tu ?',13),

(1,'Quelle activité te détend le plus ?',14),

(1,'Qu''est-ce qui te stresse le moins ?',15),

(1,'Quel type de réussite te rendrait le plus fier(ère) ?',16),

(1,'Comment préfères-tu apprendre ?',17),

(1,'Quelle qualité apprécies-tu le plus chez toi ?',18),

(1,'Dans 10 ans, tu te vois...',19),

(1,'Qu''est-ce qui est le plus important pour toi dans une carrière ?',20);

-- =========================
-- PROPOSITIONS QUESTION 1
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(1,'A','Réparer ou assembler des objets', 'R'),
(1,'B','Aider des personnes autour de moi', 'S'),
(1,'C','Résoudre des problèmes logiques', 'I'),
(1,'D','Ranger et organiser mes affaires', 'C'),
(1,'E','Dessiner ou créer quelque chose', 'A'),
(1,'F','Organiser une sortie ou une activité de groupe', 'E');


-- =========================
-- PROPOSITIONS QUESTION 2
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(2,'A','Créer une œuvre artistique ou visuelle', 'A'),
(2,'B','Construire ou fabriquer un objet concret', 'R'),
(2,'C','Améliorer la vie des autres', 'S'),
(2,'D','Lancer une entreprise ou un projet commercial', 'E'),
(2,'E','Analyser un problème complexe', 'I'),
(2,'F','Créer un système organisé et structuré', 'C');

-- =========================
-- PROPOSITIONS QUESTION 3
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(3,'A','Celui qui dirige et prend les décisions', 'E'),
(3,'B','Celui qui agit et fait le travail concret', 'R'),
(3,'C','Celui qui organise et structure le travail', 'C'),
(3,'D','Celui qui propose des idées créatives', 'A'),
(3,'E','Celui qui soutient et écoute les autres', 'S'),
(3,'F','Celui qui analyse et trouve les solutions', 'I');



-- =========================
-- PROPOSITIONS QUESTION 4
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES

(4,'A','Un bureau organisé et structuré', 'C'),
(4,'B','Un environnement dynamique et compétitif', 'E'),
(4,'C','Un laboratoire ou un environnement d’analyse', 'I'),
(4,'D','Un studio créatif ou artistique', 'A'),
(4,'E','Un environnement humain et collaboratif', 'S'),
(4,'F','Un atelier ou un lieu pratique', 'R');


-- =========================
-- PROPOSITIONS QUESTION 5
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(5,'A','Technologie, sciences physiques appliquées ou technique industrielle', 'R'),
(5,'B','Mathématiques, sciences physiques ou SVT', 'I'),
(5,'C','Arts plastiques, littérature ou philosophie', 'A'),
(5,'D','Sciences humaines, langues ou éducation civique', 'S'),
(5,'E','Économie, management ou sciences commerciales', 'E'),
(5,'F','Comptabilité, gestion ou droit', 'C');

-- =========================
-- PROPOSITIONS QUESTION 6
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(6,'A','Un stage en laboratoire de recherche', 'I'),
(6,'B','Un stage dans une ONG ou service social', 'S'),
(6,'C','Un stage dans un atelier technique ou industriel', 'R'),
(6,'D','Un stage en administration ou bureau organisé', 'C'),
(6,'E','Un stage dans un studio créatif ou design', 'A'),
(6,'F','Un stage en entreprise ou start-up', 'E');


-- =========================
-- PROPOSITIONS QUESTION 7
-- =========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(7,'D','Aider quelqu’un à résoudre ses difficultés', 'S'),
(7,'F','Organiser un système ou améliorer une méthode', 'C'),
(7,'A','Résoudre un problème concret ou technique', 'R'),
(7,'C','Créer quelque chose d’unique ou artistique', 'A'),
(7,'B','Comprendre un problème complexe ou scientifique', 'I'),
(7,'E','Atteindre un objectif ambitieux ou gagner', 'E');


-- ==========================
-- PROPOSITIONS QUESTION 8
-- ==========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(8,'A','Outils manuels ou machines', 'R'),
(8,'B','Outils de communication et d’aide', 'S'),
(8,'C','Ordinateur pour analyser des données', 'I'),
(8,'D','Logiciels de création graphique ou audio', 'A'),
(8,'E','Tableurs et logiciels d’organisation', 'C'),
(8,'F','Outils de gestion de projet ou business', 'E');

-- ==========================
-- PROPOSITIONS QUESTION 9
-- ==========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(9,'A','Créer un projet qui a de l’impact ou du profit', 'E'),
(9,'B','Organiser des tâches pour que tout soit efficace', 'C'),
(9,'C','Comprendre comment fonctionne un système ou une idée', 'I'),
(9,'D','Créer quelque chose d’artistique ou original', 'A'),
(9,'E','Réparer ou construire quelque chose de concret', 'R'),
(9,'F','Aider directement des personnes en difficulté', 'S');


-- ===========================
-- PROPOSITIONS QUESTION 10
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(10,'A','Guides d’organisation ou de gestion', 'C'),
(10,'B','Livres scientifiques ou d’analyse', 'I'),
(10,'C','Livres pratiques ou techniques', 'R'),
(10,'D','Histoires humaines ou sociales', 'S'),
(10,'E','Romans, art ou contenus créatifs', 'A'),
(10,'F','Livres sur la réussite et l’entrepreneuriat', 'E');


--===========================
-- PROPOSITIONS QUESTION 11
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(11,'A','Gérer les relations humaines et l’équipe', 'S'),
(11,'B','Analyser les données et stratégies', 'I'),
(11,'C','Créer l’image et le design de l’entreprise', 'A'),
(11,'D','Diriger et prendre les décisions importantes', 'E'),
(11,'E','Organiser la gestion et les procédures', 'C'),
(11,'F','Fabriquer ou produire un produit concret', 'R');

--===========================
-- PROPOSITIONS QUESTION 12
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(12,'A','Un travail avec des responsabilités et des objectifs', 'E'),
(12,'B','Un travail manuel ou technique concret', 'R'),
(12,'C','Un travail de réflexion et d’analyse', 'I'),
(12,'D','Un travail structuré et organisé', 'C'),
(12,'E','Un travail créatif et artistique', 'A'),
(12,'F','Un travail basé sur l’aide aux autres', 'S');



--============================
-- PROPOSITIONS QUESTION 13 
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(13,'A','Rechercher des informations et analyser les données', 'I'),
(13,'B','Organiser les tâches et respecter le planning', 'C'),
(13,'C','Construire ou réaliser la partie technique du projet', 'R'),
(13,'D','Diriger le groupe et prendre les décisions', 'E'),
(13,'E','Créer la présentation ou les éléments visuels', 'A'),
(13,'F','Aider et coordonner les membres du groupe', 'S');


--============================
-- PROPOSITIONS QUESTION 14
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(14,'A','Faire une activité manuelle ou sportive', 'R'),
(14,'B','Ranger ou organiser mon espace', 'C'),
(14,'C','Dessiner, écouter de la musique ou créer', 'A'),
(14,'D','Passer du temps avec des amis ou aider quelqu’un', 'S'),
(14,'E','Parler de projets ou d’idées ambitieuses', 'E'),
(14,'F','Lire ou réfléchir sur un sujet intéressant', 'I');


--============================
-- PROPOSITIONS QUESTION 15
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(15,'A','Résoudre des problèmes logiques ou scientifiques', 'I'),
(15,'B','Suivre des procédures claires et structurées', 'C'),
(15,'C','Prendre des décisions importantes', 'E'),
(15,'D','Créer ou imaginer quelque chose de nouveau', 'A'),
(15,'E','Travailler avec des personnes', 'S'),
(15,'F','Travailler avec des outils ou objets concrets', 'R');

--===========================
-- PROPOSITIONS QUESTION 16
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(16,'A','Avoir créé quelque chose d’unique et artistique', 'A'),
(16,'B','Avoir construit ou réparé quelque chose de concret', 'R'),
(16,'C','Avoir trouvé une solution à un problème complexe', 'I'),
(16,'D','Avoir organisé quelque chose parfaitement', 'C'),
(16,'E','Avoir réussi un projet ambitieux ou une entreprise', 'E'),
(16,'F','Avoir aidé beaucoup de personnes', 'S');



--===========================
-- PROPOSITIONS QUESTION 17
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(17,'A','En travaillant en groupe et en échangeant avec les autres', 'S'),
(17,'B','En pratiquant directement avec des outils ou des exercices', 'R'),
(17,'C','En étant motivé par des objectifs et des défis', 'E'),
(17,'D','En comprenant les théories et les concepts', 'I'),
(17,'E','En utilisant des méthodes créatives ou visuelles', 'A'),
(17,'F','En suivant des étapes structurées et organisées', 'C');



--============================
-- PROPOSITIONS QUESTION 18 
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(18,'A','Mon habileté manuelle ou technique', 'R'),
(18,'B','Ma capacité à analyser et résoudre des problèmes', 'I'),
(18,'C','Mon sens de l’organisation et de la rigueur', 'C'),
(18,'D','Ma créativité et mon imagination', 'A'),
(18,'E','Mon sens de l’aide et de l’écoute', 'S'),
(18,'F','Mon leadership et ma capacité à convaincre', 'E');

--============================
-- PROPOSITIONS QUESTION 19
--===========================

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(19,'A','Travaillant dans un domaine créatif ou artistique', 'A'),
(19,'B','Travaillant dans un métier manuel ou technique', 'R'),
(19,'C','Travaillant dans l’aide ou le social', 'S'),
(19,'D','Travaillant dans la recherche ou l’analyse', 'I'),
(19,'E','Dans un métier structuré et organisé', 'C'),
(19,'F','À la tête d’un projet ou d’une entreprise', 'E');


--============================
-- PROPOSITIONS QUESTION 20
--===========================   

INSERT INTO proposition (id_question, lettre, libelle, type_riasec) VALUES
(20,'A','L’organisation et la planification efficace du travail', 'C'),
(20,'B','La pratique et l’application concrète des connaissances', 'R'),
(20,'C','La réflexion et l’analyse approfondie des problèmes', 'I'),
(20,'D','La réussite et la reconnaissance dans son domaine', 'E'),
(20,'E','La créativité et l’innovation dans le travail', 'A'),
(20,'F','L’aide et le soutien aux autres dans leur travail', 'S');




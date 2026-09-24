-- NextOri - Référentiel des 30 profils RIASEC à deux lettres
-- À exécuter après 20260924_create_profil_riasec.sql.
--
-- Les informations décrivent des tendances d'intérêt. Elles ne constituent pas
-- un diagnostic et doivent toujours être accompagnées des recommandations de
-- métiers, de filières et d'établissements de NextOri.

begin;

insert into public.profil_riasec (
    code, nom, description, forces, competences, environnements, actif, date_modification
)
values
(
    'RI', 'Réaliste - Investigateur',
    'Vous aimez comprendre le fonctionnement des choses et résoudre des problèmes concrets par l''observation, l''analyse et l''expérimentation. Vous vous épanouissez lorsque la réflexion mène à une solution technique ou pratique.',
    jsonb_build_array('Analyse', 'Précision', 'Esprit logique', 'Observation'),
    jsonb_build_array('Résolution de problèmes', 'Analyse technique', 'Recherche de solutions', 'Méthodes scientifiques'),
    jsonb_build_array('Laboratoires', 'Bureaux techniques', 'Centres de recherche', 'Industries'),
    true, now()
),
(
    'RA', 'Réaliste - Artistique',
    'Vous aimez créer et réaliser des projets tangibles tout en donnant une place importante à l''imagination et au sens esthétique. Vous appréciez de transformer une idée en réalisation visible et utile.',
    jsonb_build_array('Créativité appliquée', 'Habileté pratique', 'Capacité de conception', 'Résolution de problèmes'),
    jsonb_build_array('Conception de projets', 'Création et innovation', 'Analyse technique', 'Utilisation d''outils spécialisés'),
    jsonb_build_array('Bureaux d''études', 'Ateliers de conception', 'Laboratoires', 'Structures créatives'),
    true, now()
),
(
    'RS', 'Réaliste - Social',
    'Vous appréciez les activités pratiques qui ont une utilité directe pour les autres. Vous aimez agir sur le terrain, apporter une aide concrète et contribuer à des solutions simples, humaines et efficaces.',
    jsonb_build_array('Sens pratique', 'Entraide', 'Responsabilité', 'Adaptation'),
    jsonb_build_array('Accompagnement technique', 'Communication pratique', 'Résolution de problèmes', 'Travail en équipe'),
    jsonb_build_array('Services techniques', 'Organisations sociales', 'Structures d''accompagnement', 'Entreprises de terrain'),
    true, now()
),
(
    'RE', 'Réaliste - Entreprenant',
    'Vous aimez passer à l''action, prendre des initiatives et voir des résultats concrets. Vous combinez goût du terrain, organisation et envie de faire avancer un projet ou une équipe.',
    jsonb_build_array('Leadership', 'Initiative', 'Organisation', 'Détermination'),
    jsonb_build_array('Gestion de projet', 'Prise de décision', 'Coordination', 'Planification'),
    jsonb_build_array('Entreprises', 'Chantiers', 'Organisations commerciales', 'Structures entrepreneuriales'),
    true, now()
),
(
    'RC', 'Réaliste - Conventionnel',
    'Vous aimez les activités concrètes menées avec méthode, précision et sens de l''organisation. Vous êtes à l''aise lorsque les procédures sont claires et que la qualité du travail dépend de votre rigueur.',
    jsonb_build_array('Rigueur', 'Précision', 'Organisation', 'Fiabilité'),
    jsonb_build_array('Gestion technique', 'Organisation de données', 'Application de procédures', 'Contrôle qualité'),
    jsonb_build_array('Entreprises techniques', 'Administrations', 'Services opérationnels', 'Bureaux professionnels'),
    true, now()
),
(
    'IR', 'Investigateur - Réaliste',
    'Vous êtes curieux, méthodique et attiré par la compréhension des phénomènes. Vous aimez mobiliser vos connaissances pour diagnostiquer un problème et proposer une réponse applicable dans la réalité.',
    jsonb_build_array('Curiosité', 'Esprit scientifique', 'Rigueur', 'Logique'),
    jsonb_build_array('Recherche', 'Analyse de données', 'Expérimentation', 'Diagnostic'),
    jsonb_build_array('Laboratoires', 'Centres de recherche', 'Entreprises technologiques', 'Institutions scientifiques'),
    true, now()
),
(
    'AR', 'Artistique - Réaliste',
    'Vous êtes créatif et aimez donner forme à vos idées. Vous combinez imagination, sens esthétique et capacité à concrétiser vos projets à l''aide de techniques, d''outils ou de matériaux.',
    jsonb_build_array('Imagination', 'Expression créative', 'Sens esthétique', 'Adaptation'),
    jsonb_build_array('Création artistique', 'Conception visuelle', 'Innovation', 'Réalisation de projets'),
    jsonb_build_array('Agences créatives', 'Studios', 'Ateliers artistiques', 'Entreprises de création'),
    true, now()
),
(
    'SR', 'Social - Réaliste',
    'Vous aimez aider les autres par des actions concrètes et utiles. L''écoute, l''accompagnement et le sens pratique se complètent chez vous pour répondre efficacement à des besoins réels.',
    jsonb_build_array('Empathie', 'Écoute', 'Organisation', 'Pragmatisme'),
    jsonb_build_array('Accompagnement', 'Formation', 'Gestion de situations concrètes', 'Communication'),
    jsonb_build_array('Associations', 'Établissements éducatifs', 'Services publics', 'Structures d''aide'),
    true, now()
),
(
    'ER', 'Entreprenant - Réaliste',
    'Vous êtes motivé par les défis, la coordination d''actions et l''atteinte d''objectifs visibles. Vous aimez transformer une idée en action, mobiliser les moyens nécessaires et obtenir des résultats concrets.',
    jsonb_build_array('Ambition', 'Leadership', 'Organisation', 'Esprit d''action'),
    jsonb_build_array('Management', 'Négociation', 'Gestion d''équipe', 'Développement de projets'),
    jsonb_build_array('Entreprises', 'Startups', 'Organisations commerciales', 'Structures de gestion'),
    true, now()
),
(
    'CR', 'Conventionnel - Réaliste',
    'Vous aimez organiser les informations et appliquer des méthodes fiables dans des situations concrètes. Votre sens du détail et votre méthode soutiennent la bonne exécution des activités quotidiennes.',
    jsonb_build_array('Organisation', 'Méthode', 'Attention aux détails', 'Fiabilité'),
    jsonb_build_array('Gestion administrative', 'Suivi des procédures', 'Analyse d''informations', 'Planification'),
    jsonb_build_array('Administrations', 'Entreprises', 'Services de gestion', 'Organisations structurées'),
    true, now()
),
(
    'IA', 'Investigateur - Artistique',
    'Vous aimez explorer des idées, comprendre des situations complexes et imaginer des réponses originales. Vous réunissez curiosité intellectuelle, pensée critique et créativité.',
    jsonb_build_array('Curiosité intellectuelle', 'Créativité', 'Analyse', 'Innovation'),
    jsonb_build_array('Recherche', 'Analyse de données', 'Création de solutions', 'Pensée critique'),
    jsonb_build_array('Laboratoires', 'Centres d''innovation', 'Bureaux de recherche', 'Structures créatives'),
    true, now()
),
(
    'AI', 'Artistique - Investigateur',
    'Vous aimez exprimer votre créativité tout en cherchant à comprendre les idées et les phénomènes qui vous entourent. Vous appréciez les projets qui demandent imagination, recherche et réflexion.',
    jsonb_build_array('Imagination', 'Réflexion', 'Sens de l''analyse', 'Créativité'),
    jsonb_build_array('Conception', 'Recherche', 'Analyse', 'Communication d''idées'),
    jsonb_build_array('Studios', 'Laboratoires créatifs', 'Agences', 'Centres de recherche'),
    true, now()
),
(
    'IS', 'Investigateur - Social',
    'Vous aimez comprendre les personnes et les situations afin de leur être utile. Vous vous intéressez à l''analyse, à la transmission des connaissances et à l''accompagnement fondé sur la réflexion.',
    jsonb_build_array('Analyse', 'Écoute', 'Curiosité', 'Empathie'),
    jsonb_build_array('Analyse comportementale', 'Recherche', 'Accompagnement', 'Résolution de problèmes'),
    jsonb_build_array('Établissements éducatifs', 'Centres de recherche', 'Structures sociales', 'Institutions'),
    true, now()
),
(
    'SI', 'Social - Investigateur',
    'Vous aimez accompagner les autres en vous appuyant sur l''observation, l''écoute et la compréhension des besoins. Vous recherchez des solutions utiles, adaptées et fondées sur une analyse sérieuse.',
    jsonb_build_array('Empathie', 'Analyse', 'Patience', 'Écoute'),
    jsonb_build_array('Conseil', 'Recherche', 'Formation', 'Analyse des besoins'),
    jsonb_build_array('Écoles', 'Centres sociaux', 'Institutions', 'Organisations d''aide'),
    true, now()
),
(
    'IE', 'Investigateur - Entreprenant',
    'Vous aimez analyser des problèmes complexes et utiliser vos connaissances pour faire avancer des projets. Vous êtes stimulé par l''innovation, la stratégie et la possibilité de prendre des initiatives réfléchies.',
    jsonb_build_array('Analyse stratégique', 'Autonomie', 'Innovation', 'Esprit d''initiative'),
    jsonb_build_array('Analyse de projet', 'Prise de décision', 'Recherche de solutions', 'Gestion de projet'),
    jsonb_build_array('Entreprises technologiques', 'Startups', 'Bureaux d''études', 'Organisations innovantes'),
    true, now()
),
(
    'EI', 'Entreprenant - Investigateur',
    'Vous aimez conduire des projets en vous appuyant sur l''analyse, la stratégie et la recherche d''informations. Vous êtes à l''aise pour décider, organiser et mobiliser une équipe vers un objectif.',
    jsonb_build_array('Leadership', 'Réflexion stratégique', 'Organisation', 'Initiative'),
    jsonb_build_array('Management', 'Analyse stratégique', 'Développement de projets', 'Innovation'),
    jsonb_build_array('Entreprises', 'Cabinets de conseil', 'Startups', 'Organisations professionnelles'),
    true, now()
),
(
    'IC', 'Investigateur - Conventionnel',
    'Vous aimez étudier les informations avec précision, comprendre les systèmes et travailler selon des méthodes fiables. Vous appréciez les environnements où l''analyse et l''organisation vont de pair.',
    jsonb_build_array('Rigueur', 'Analyse', 'Organisation', 'Précision'),
    jsonb_build_array('Analyse de données', 'Gestion d''informations', 'Recherche', 'Documentation'),
    jsonb_build_array('Laboratoires', 'Services d''analyse', 'Administrations', 'Entreprises'),
    true, now()
),
(
    'CI', 'Conventionnel - Investigateur',
    'Vous aimez organiser les informations et rechercher des solutions logiques, cohérentes et efficaces. Votre méthode vous aide à traiter des données complexes avec fiabilité.',
    jsonb_build_array('Méthode', 'Organisation', 'Logique', 'Fiabilité'),
    jsonb_build_array('Gestion de données', 'Analyse', 'Contrôle', 'Planification'),
    jsonb_build_array('Administrations', 'Entreprises', 'Services financiers', 'Organisations structurées'),
    true, now()
),
(
    'AS', 'Artistique - Social',
    'Vous aimez créer, communiquer et mettre votre sensibilité au service des autres. Vous appréciez les activités qui permettent d''exprimer des idées, de transmettre un message ou de soutenir un public.',
    jsonb_build_array('Créativité', 'Empathie', 'Communication', 'Expression'),
    jsonb_build_array('Création de contenus', 'Communication', 'Expression artistique', 'Accompagnement'),
    jsonb_build_array('Associations', 'Agences de communication', 'Structures culturelles', 'Organisations sociales'),
    true, now()
),
(
    'SA', 'Social - Artistique',
    'Vous aimez accompagner les personnes tout en utilisant votre créativité pour expliquer, sensibiliser ou transmettre. Les projets collectifs et les formes d''expression qui créent du lien vous conviennent particulièrement.',
    jsonb_build_array('Écoute', 'Créativité', 'Communication', 'Sensibilité'),
    jsonb_build_array('Animation', 'Formation', 'Communication', 'Création pédagogique'),
    jsonb_build_array('Écoles', 'Associations', 'Centres culturels', 'Organisations d''accompagnement'),
    true, now()
),
(
    'AE', 'Artistique - Entreprenant',
    'Vous aimez imaginer, créer et faire grandir des projets. Vous combinez créativité, autonomie et capacité à convaincre pour transformer une idée en initiative concrète.',
    jsonb_build_array('Créativité', 'Leadership', 'Innovation', 'Autonomie'),
    jsonb_build_array('Création de projets', 'Communication', 'Entrepreneuriat', 'Gestion d''idées'),
    jsonb_build_array('Startups', 'Agences créatives', 'Entreprises innovantes', 'Structures entrepreneuriales'),
    true, now()
),
(
    'EA', 'Entreprenant - Artistique',
    'Vous aimez diriger des projets créatifs, défendre une vision et développer de nouvelles idées. Vous êtes stimulé par la communication, l''innovation et la réalisation d''objectifs ambitieux.',
    jsonb_build_array('Leadership', 'Créativité', 'Ambition', 'Communication'),
    jsonb_build_array('Gestion de projets', 'Marketing', 'Négociation', 'Développement d''activités'),
    jsonb_build_array('Entreprises', 'Agences', 'Startups', 'Organisations commerciales'),
    true, now()
),
(
    'AC', 'Artistique - Conventionnel',
    'Vous aimez produire des réalisations créatives dans un cadre organisé. Vous trouvez un bon équilibre entre imagination, précision et respect des étapes nécessaires à un projet de qualité.',
    jsonb_build_array('Créativité', 'Organisation', 'Précision', 'Adaptation'),
    jsonb_build_array('Conception', 'Gestion de contenu', 'Organisation de projets', 'Présentation d''informations'),
    jsonb_build_array('Agences', 'Services de communication', 'Entreprises', 'Structures organisées'),
    true, now()
),
(
    'CA', 'Conventionnel - Artistique',
    'Vous aimez structurer les informations et apporter une touche créative pour améliorer un support, un processus ou une présentation. Vous êtes à l''aise dans les projets qui demandent à la fois méthode et sens visuel.',
    jsonb_build_array('Organisation', 'Créativité', 'Rigueur', 'Méthode'),
    jsonb_build_array('Gestion documentaire', 'Organisation visuelle', 'Analyse d''informations', 'Création de supports'),
    jsonb_build_array('Administrations', 'Entreprises', 'Services de communication', 'Organisations structurées'),
    true, now()
),
(
    'SE', 'Social - Entreprenant',
    'Vous aimez aider, conseiller et mobiliser les autres autour d''un objectif. Vous combinez sens relationnel, initiative et capacité à organiser des projets ou des équipes.',
    jsonb_build_array('Empathie', 'Leadership', 'Communication', 'Organisation'),
    jsonb_build_array('Accompagnement', 'Gestion d''équipe', 'Communication', 'Coordination de projets'),
    jsonb_build_array('Associations', 'Entreprises', 'Institutions', 'Structures éducatives'),
    true, now()
),
(
    'ES', 'Entreprenant - Social',
    'Vous aimez influencer, organiser et diriger tout en maintenant un lien fort avec les autres. Vous êtes stimulé par la communication, la coordination et la capacité à faire progresser un collectif.',
    jsonb_build_array('Leadership', 'Communication', 'Organisation', 'Motivation des autres'),
    jsonb_build_array('Management', 'Négociation', 'Gestion de projets', 'Animation d''équipe'),
    jsonb_build_array('Entreprises', 'Cabinets de conseil', 'Institutions', 'Organisations sociales'),
    true, now()
),
(
    'SC', 'Social - Conventionnel',
    'Vous aimez aider les autres dans un cadre organisé, où la méthode et le suivi sont importants. Votre sens du service s''exprime pleinement lorsque vous pouvez apporter un accompagnement fiable et structuré.',
    jsonb_build_array('Écoute', 'Organisation', 'Patience', 'Fiabilité'),
    jsonb_build_array('Gestion administrative', 'Accompagnement', 'Organisation', 'Suivi de dossiers'),
    jsonb_build_array('Administrations', 'Établissements éducatifs', 'Services sociaux', 'Institutions'),
    true, now()
),
(
    'CS', 'Conventionnel - Social',
    'Vous aimez travailler avec des informations organisées tout en contribuant au bon accueil et à l''accompagnement des personnes. Vous combinez rigueur, sens du service et responsabilité.',
    jsonb_build_array('Rigueur', 'Organisation', 'Sens du service', 'Responsabilité'),
    jsonb_build_array('Gestion de documents', 'Communication', 'Suivi administratif', 'Organisation'),
    jsonb_build_array('Administrations', 'Écoles', 'Services publics', 'Entreprises'),
    true, now()
),
(
    'EC', 'Entreprenant - Conventionnel',
    'Vous aimez atteindre des objectifs, organiser les ressources et prendre des décisions dans un cadre structuré. Vous appréciez les responsabilités qui demandent planification, efficacité et sens du résultat.',
    jsonb_build_array('Leadership', 'Organisation', 'Prise de décision', 'Efficacité'),
    jsonb_build_array('Management', 'Gestion financière', 'Planification', 'Coordination'),
    jsonb_build_array('Entreprises', 'Banques', 'Cabinets de gestion', 'Organisations commerciales'),
    true, now()
),
(
    'CE', 'Conventionnel - Entreprenant',
    'Vous aimez organiser les ressources et assurer le bon fonctionnement d''une activité. Vous combinez méthode, rigueur et initiative pour contribuer à la réalisation d''objectifs collectifs.',
    jsonb_build_array('Méthode', 'Organisation', 'Rigueur', 'Responsabilité'),
    jsonb_build_array('Gestion administrative', 'Analyse financière', 'Planification', 'Suivi d''activités'),
    jsonb_build_array('Entreprises', 'Administrations', 'Services financiers', 'Organisations structurées'),
    true, now()
)
on conflict (code) do update
set
    nom = excluded.nom,
    description = excluded.description,
    forces = excluded.forces,
    competences = excluded.competences,
    environnements = excluded.environnements,
    actif = excluded.actif,
    date_modification = now();

commit;

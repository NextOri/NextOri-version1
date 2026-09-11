Date de début: le 07 Juillet 2026    
📊 État actuel du backend

✅ Étape 1 : Connexion MySQL

✅ Étape 2 : Lire questionnaire

✅ Étape 3 : Lire questions

✅ Étape 4 : Lire propositions

✅ Étape 5 : Créer un test utilisateur

✅ Étape 6 : Enregister les réponses des utilisateurs

✅ Étape 7 : Calcul automatique des scores RIASEC
         ✅ Détermination du profil
         ✅ Sauvegarde des scores
         ✅ Sauvegarde du profil
         ✅ Ajout des profils RIASEC aux métiers
✅  Étape 8 : Rechercher les métiers compatibles

✅  Étape 9 : Rechercher les filieres 

✅ Étape 10 : Rechercher les universites

✅ Étape 11 : Construire le moteur complet de NextOri
      Ce qu'il ne fera PAS

Il ne fera pas de SQL.

Il ne calculera pas les scores.

Il ne recherchera pas les métiers.

Il ne recherchera pas les universités.

Il ne connaîtra pas les règles RIASEC.

Tout cela existe déjà.

     Ce qu'il fera
Il coordonnera les autres services.

                 OrientationService
                         │
     ┌───────────────────┼───────────────────┐
     │                   │                   │
 TestService      ReponseService      RiasecService
                                             │
                                             ▼
                                      MetierService
                                             │
                                             ▼
                                     FiliereService
                                             │
                                             ▼
                                   UniversiteService


✅ Étape 12 : Optimisation du moteur NextOri V1

Dans cette phase, nous intégrerons toutes les améliorations que nous avons identifiées :

✅ supprimer automatiquement les métiers avec un score de compatibilité de 0 ;
✅ séparer les recommandations en 5 métiers principaux et 5 métiers secondaires ;
✅ faire en sorte que les filières soient calculées uniquement à partir des métiers retenus ;
✅ faire en sorte que les universités soient calculées uniquement à partir des filières retenues ;
✅ améliorer le classement des recommandations pour qu'il soit plus pertinent.

✅ Étape 13: Preparation de l'API

NB: Les repository: Donne-moi les réponses.
    Les services: Compte les scores.
                  Trouve le profil.
                  Retourne IA.


          Vu d'ensemble de l'algorithme:

                UTILISATEUR
                      │
                      ▼
         Commence un test RIASEC
                      │
                      ▼
        Création d'un test (id_test)
                      │
                      ▼
      Répond aux 20 questions
                      │
                      ▼
 Enregistrement des 20 réponses
                      │
                      ▼
     Calcul automatique des scores
                      │
                      ▼
      Détermination du profil
                      │
                      ▼
     Recherche des métiers compatibles
                      │
                      ▼
    Recherche des filières associées
                      │
                      ▼
Recherche des universités correspondantes
                      │
                      ▼
        Affichage du résultat final



        Pseudo-code complet de l'algorithme de calcul de score V1
Début

Créer un tableau Scores

R ← 0
I ← 0
A ← 0
S ← 0
E ← 0
C ← 0

scores = {
    R : 0,
    I : 0,
    A : 0,
    S : 0,
    E : 0,
    C : 0
}

Pour chaque réponse

    type = type_riasec de la proposition

    scores[type] = scores[type] + 1

Fin Pour

Créer un tableau contenant

R = score_R

I = score_I

A = score_A

S = score_S

E = score_E

C = score_C


Trier le tableau du plus grand score au plus petit


profil_principal =
les deux premiers types


profil_complet =
les six types triés


Mettre à jour test_riasec

score_R

score_I

score_A

score_S

score_E

score_C

profil_dominant


Retourner le profil


Fin


  Matrice metier_riasec

| Métier                | R | I | A | S | E | C |
| --------------------- | - | - | - | - | - | - |
| Développeur Web       | 2 | 3 | 0 | 0 | 0 | 2 |
| Data Scientist        | 1 | 3 | 0 | 0 | 0 | 3 |
| Ingénieur Génie Civil | 3 | 2 | 0 | 0 | 0 | 2 |
| Médecin               | 1 | 3 | 0 | 3 | 0 | 0 |
| Avocat                | 0 | 2 | 0 | 2 | 3 | 0 |
| Comptable             | 0 | 2 | 0 | 0 | 1 | 3 |
| Marketeur             | 0 | 1 | 3 | 2 | 3 | 0 |
| Administrateur Réseau | 2 | 3 | 0 | 0 | 0 | 2 |


    Niveau de compatibilite metier_riasec
| Niveau | Signification  |
| ------ | -------------- |
| 3      | Très important |
| 2      | Important      |
| 1      | Complémentaire |


      Pseudo-code complet de l'algorithme de recomandation metier
 
 Début

Lire le profil utilisateur

premiereLettre = profil[0]

deuxiemeLettre = profil[1]

Lire tous les métiers

Pour chaque métier

    score = 0

    profilMetier = métier.profil_riasec

    // Première lettre

    si premiereLettre est en position 1
            score += 4

    sinon si premiereLettre est en position 2
            score += 2

    sinon si premiereLettre est en position 3
            score += 1

    // Deuxième lettre

    si deuxiemeLettre est en position 2
            score += 4

    sinon si deuxiemeLettre est en position 1
            score += 2

    sinon si deuxiemeLettre est en position 3
            score += 1

    compter le nombre de lettres du profil présentes
    (0, 1 ou 2)

    enregistrer

        métier
        score
        nombreCorrespondances

Fin Pour

Trier les métiers

1. score décroissant

2. nombreCorrespondances décroissant

Retourner

5 métiers principaux

5 métiers secondaires

Fin


Pseudo algorithme de recommandation filiere
Liste des métiers recommandés
             ↓
Chercher leurs id_metier
             ↓
Interroger metier_filiere
             ↓
Récupérer les filières
             ↓
Supprimer les doublons
             ↓
Retourner les filières à l'utilisateur


Pseudo algorithme complet de NextOri
Début

Recevoir :
    id_user
    réponses[]

Créer un nouveau test

Enregistrer toutes les réponses

Calculer les scores RIASEC

Déterminer le profil dominant

Chercher les métiers compatibles

Chercher les filières compatibles

Chercher les universités compatibles

Construire le résultat final

Retourner le résultat

Fin


Resultat apres test
1. Réception des réponses
                │
                ▼
2. Création du test
                │
                ▼
3. Enregistrement des réponses
                │
                ▼
4. Calcul des scores
                │
                ▼
5. Détermination du profil
                │
                ▼
6. Recherche des métiers
                │
                ▼
7. Recherche des filières
                │
                ▼
8. Recherche des universités
                │
                ▼
9. Construction du résultat final
                │
                ▼
10. Retour de toute le recommandations




/*
 * ============================================================
 * MOTEUR DE COMPARAISON — HÉSITATION NEXTORI
 * ============================================================
 *
 * Ce moteur ne cherche pas à dire :
 * "ce métier est fait pour toi".
 *
 * Il cherche à répondre à une question plus prudente :
 *
 * "Parmi les options que tu envisages actuellement,
 * laquelle présente le plus de cohérence avec les éléments
 * ressortis de tes réponses ?"
 *
 * Les données métiers/filières sont actuellement en dur.
 * Elles pourront ensuite venir directement de la base de données.
 */


/*
 * ============================================================
 * 1. CORRESPONDANCE DES RÉPONSES AVEC LES CRITÈRES
 * ============================================================
 */

const correspondances = {

    // Attirances
    ATTIRANCE_CONTENU: {
        critere: "interet",
        poids: 3
    },

    ATTIRANCE_SENS: {
        critere: "sens",
        poids: 3
    },

    ATTIRANCE_OPPORTUNITES: {
        critere: "debouches",
        poids: 3
    },

    ATTIRANCE_CADRE: {
        critere: "conditions",
        poids: 3
    },

    ATTIRANCE_DEFI: {
        critere: "progression",
        poids: 3
    },


    // Forces
    FORCE_ANALYSER: {
        critere: "analyse",
        poids: 3
    },

    FORCE_CREER: {
        critere: "creation",
        poids: 3
    },

    FORCE_AIDER: {
        critere: "relation",
        poids: 3
    },

    FORCE_ORGANISER: {
        critere: "organisation",
        poids: 3
    },

    FORCE_AGIR: {
        critere: "action",
        poids: 3
    },


    // Critères de décision
    CRITERE_INTERET: {
        critere: "interet",
        poids: 5
    },

    CRITERE_CAPACITES: {
        critere: "capacites",
        poids: 5
    },

    CRITERE_DEBOUCHES: {
        critere: "debouches",
        poids: 5
    },

    CRITERE_CONDITIONS: {
        critere: "conditions",
        poids: 5
    },

    CRITERE_STABILITE: {
        critere: "stabilite",
        poids: 5
    }
};


/*
 * ============================================================
 * 2. LIBELLÉS DES CRITÈRES
 * ============================================================
 */

const nomsCriteres = {

    contenu: "Contenu du métier ou de la formation",

    sens: "Sens et utilité",

    debouches: "Perspectives professionnelles",

    conditions: "Conditions de travail",

    progression: "Possibilités de progression",

    analyse: "Analyse",

    creation: "Créativité",

    relation: "Relation et accompagnement",

    organisation: "Organisation",

    action: "Initiative et passage à l'action",

    interet: "Intérêt personnel",

    capacites: "Capacités et points forts",

    stabilite: "Stabilité"
};


/*
 * ============================================================
 * 3. RÉCUPÉRER LES CODES
 * ============================================================
 */

const obtenirCodes = (reponses = []) => {

    return reponses
        .map((reponse) => reponse.code)
        .filter(Boolean);

};


/*
 * ============================================================
 * 4. CONSTRUIRE LES CRITÈRES ACTIFS
 * ============================================================
 */

const construireCriteresActifs = (codes) => {

    const criteres = [];

    codes.forEach((code) => {

        const correspondance =
            correspondances[code];

        if (!correspondance) {
            return;
        }

        const dejaPresent =
            criteres.find(
                (item) =>
                    item.critere === correspondance.critere
            );

        if (dejaPresent) {

            /*
             * Si plusieurs réponses renforcent
             * le même critère, on augmente légèrement
             * son poids.
             */

            dejaPresent.poids +=
                correspondance.poids / 2;

            return;
        }

        criteres.push({

            critere:
                correspondance.critere,

            poids:
                correspondance.poids,

            nom:
                nomsCriteres[
                    correspondance.critere
                ] || correspondance.critere

        });

    });


    /*
     * Sécurité :
     * si aucune réponse exploitable n'a été trouvée,
     * on utilise quelques critères neutres.
     */

    if (criteres.length === 0) {

        return [

            {
                critere: "analyse",
                poids: 1,
                nom: nomsCriteres.analyse
            },

            {
                critere: "creation",
                poids: 1,
                nom: nomsCriteres.creation
            },

            {
                critere: "debouches",
                poids: 1,
                nom: nomsCriteres.debouches
            }

        ];

    }

    return criteres;

};


/*
 * ============================================================
 * 5. PÉNALITÉS LIÉES AUX BLOCAGES
 * ============================================================
 */

const obtenirFacteursBlocage = (codes) => {

    const facteurs = [];

    if (codes.includes("BLOCAGE_INFORMATION")) {

        facteurs.push({

            code: "information",

            description:
                "Les informations disponibles devront être vérifiées avant de départager les options."

        });

    }

    if (codes.includes("BLOCAGE_CAPACITES")) {

        facteurs.push({

            code: "capacites",

            description:
                "La question des capacités nécessaires mérite d'être vérifiée concrètement."

        });

    }

    if (codes.includes("BLOCAGE_ERREUR")) {

        facteurs.push({

            code: "rassurance",

            description:
                "La comparaison doit surtout servir à réduire l'incertitude, pas à rechercher une certitude absolue."

        });

    }

    if (codes.includes("BLOCAGE_OPTIONS")) {

        facteurs.push({

            code: "comparaison",

            description:
                "Plusieurs options semblent déjà présenter un intérêt réel, ce qui rend la comparaison particulièrement importante."

        });

    }

    if (codes.includes("BLOCAGE_ENTOURAGE")) {

        facteurs.push({

            code: "autonomie",

            description:
                "Il peut être utile de distinguer tes propres priorités de celles exprimées par ton entourage."

        });

    }

    return facteurs;

};


/*
 * ============================================================
 * 6. CALCUL DE LA CORRESPONDANCE
 * ============================================================
 */

const calculerCorrespondance = (
    option,
    criteresActifs,
    catalogue
) => {

    const donnees =
        catalogue[option.nom];


    /*
     * Métier ou filière inconnu(e).
     */

    if (!donnees) {

        return {

            ...option,

            score: null,

            scoreBrut: 0,

            donnees: null,

            criteres: [],

            disponible: false

        };

    }


    let total = 0;

    let maximum = 0;

    const details = [];


   criteresActifs.forEach((element) => {

    const valeur =
        donnees[element.critere] !== undefined &&
        donnees[element.critere] !== null
            ? Number(donnees[element.critere])
            : null;

    const poids =
        Number(element.poids) || 1;

    details.push({

        critere: element.critere,

        nom: element.nom,

        valeur,

        poids

    });

    if (valeur !== null) {

        total += valeur * poids;

        maximum += 5 * poids;

    }

});


    const score =
        maximum > 0
            ? Math.round(
                (total / maximum) * 100
            )
            : 0;


    return {

        ...option,

        score,

        scoreBrut:
            total,

        donnees,

        criteres:
            details,

        disponible:
            true

    };

};


/*
 * ============================================================
 * 7. GÉNÉRER UNE LECTURE DE LA MEILLEURE OPTION
 * ============================================================
 */

const genererLecture = (
    meilleureOption,
    typeChoix,
    nombreOptions
) => {

    const typeTexte =
        typeChoix === "metier"
            ? "métier"
            : "filière";


    if (!meilleureOption) {

        return {

            titre:
                "Une comparaison encore à approfondir",

            texte:
                `Les ${nombreOptions} options que tu as indiquées ` +
                `ne peuvent pas encore être départagées de manière ` +
                "suffisamment fiable avec les informations disponibles."

        };

    }


    return {

        titre:
            `Une correspondance actuellement plus forte avec ${meilleureOption.nom}`,

        texte:
            `Parmi les ${nombreOptions} ${typeTexte}s que tu envisages, ` +
            `${meilleureOption.nom} présente actuellement la correspondance ` +
            `la plus forte avec les critères ressortis de tes réponses. ` +
            "Cela ne signifie pas que ce choix est nécessairement le meilleur. " +
            "Il constitue simplement une piste qui mérite d'être examinée plus attentivement."

    };

};


/*
 * ============================================================
 * 8. GÉNÉRER LES POINTS DE COMPARAISON
 * ============================================================
 */

const genererPointsComparaison = (
    comparaison
) => {

    if (!comparaison.length) {
        return [];
    }


    const meilleurScore =
        comparaison[0]?.score;


    return comparaison.map((option) => {

        let position =
            "à explorer";


        if (
            meilleurScore !== null &&
            option.score === meilleurScore
        ) {

            position =
                "correspondance forte";

        } else if (
            option.score !== null &&
            meilleurScore !== null &&
            option.score >= meilleurScore - 10
        ) {

            position =
                "correspondance proche";

        } else if (
            option.score !== null
        ) {

            position =
                "correspondance à approfondir";

        }


        return {

            nom:
                option.nom,

            score:
                option.score,

            position

        };

    });

};


/*
 * ============================================================
 * 9. MOTEUR PRINCIPAL
 * ============================================================
 */

export const genererComparaisonHesitation = ({
    typeChoix,
    metiersSelectionnes = [],
    filieresSelectionnees = [],
    reponsesHesitation = [],
    catalogue
}) => {

    const options =
        typeChoix === "metier"
            ? metiersSelectionnes
            : filieresSelectionnees;


    const codes =
        obtenirCodes(
            reponsesHesitation
        );


    const criteresActifs =
        construireCriteresActifs(
            codes
        );


    const facteursBlocage =
        obtenirFacteursBlocage(
            codes
        );


    const catalogueUtilise =
        catalogue || {};


    const comparaison =
        options
            .map((option) =>
                calculerCorrespondance(
                    option,
                    criteresActifs,
                    catalogueUtilise
                )
            )
            .sort((a, b) => {

                if (
                    a.score === null &&
                    b.score === null
                ) {
                    return 0;
                }

                if (a.score === null) {
                    return 1;
                }

                if (b.score === null) {
                    return -1;
                }

                return b.score - a.score;

            });


    const optionsDisponibles =
        comparaison.filter(
            (option) =>
                option.disponible
        );


    const meilleureOption =
        optionsDisponibles[0] || null;


    const lecture =
        genererLecture(
            meilleureOption,
            typeChoix,
            options.length
        );


    const pointsComparaison =
        genererPointsComparaison(
            comparaison
        );


    return {

        typeChoix,

        options,

        codes,

        criteresActifs,

        facteursBlocage,

        comparaison,

        meilleureOption,

        lecture,

        pointsComparaison

    };

};


/*
 * ============================================================
 * 10. EXPORT DES FONCTIONS UTILES
 * ============================================================
 */

export {
    calculerCorrespondance,
    construireCriteresActifs,
    obtenirFacteursBlocage
};
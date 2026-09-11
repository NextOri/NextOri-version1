import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

function Hesitation() {

    const navigate = useNavigate();

    const [etape, setEtape] = useState("presentation");
    const [typeChoix, setTypeChoix] = useState(null);
   const [metiersSelectionnes, setMetiersSelectionnes] = useState([]);
    const [filieresSelectionnees, setFilieresSelectionnees] = useState([]);
    const [questionActuelle, setQuestionActuelle] = useState(0);
    const [reponsesHesitation, setReponsesHesitation] = useState([]);
    const [etapeAnalyse, setEtapeAnalyse] = useState(0);
    const [analyseTerminee, setAnalyseTerminee] = useState(false);

    useEffect(() => {

    if (etape !== "analyse") {
        return;
    }

    const nombreEtapes = 6;

    if (etapeAnalyse >= nombreEtapes - 1) {
        return;
    }

    const timer = setTimeout(() => {

        setEtapeAnalyse(
            (ancienneEtape) => ancienneEtape + 1
        );

    }, 1800);

    return () => {
        clearTimeout(timer);
    };

}, [etape, etapeAnalyse]);

useEffect(() => {

    if (
        etape !== "analyse" ||
        etapeAnalyse !== 5
    ) {
        return;
    }

    const timer = setTimeout(() => {

        setEtapeAnalyse(6);

        setAnalyseTerminee(true);

    }, 2500);

    return () => clearTimeout(timer);

}, [etape, etapeAnalyse]);


    const questionsHesitation = [
    {
    id: 1,

    question:
        "Quand tu penses aux options que tu hésites à choisir, qu’est-ce qui t’attire le plus ?",

    reponses: [

        {
            id: 1,
            texte:
                "Le contenu : les activités et ce que je vais réellement faire.",
            code: "ATTIRANCE_CONTENU"
        },

        {
            id: 2,
            texte:
                "Le sens : me sentir utile et faire quelque chose qui me correspond.",
            code: "ATTIRANCE_SENS"
        },

        {
            id: 3,
            texte:
                "Les possibilités : évolution, débouchés et opportunités.",
            code: "ATTIRANCE_OPPORTUNITES"
        },

        {
            id: 4,
            texte:
                "Le cadre : environnement, conditions et façon de travailler.",
            code: "ATTIRANCE_CADRE"
        },

        {
            id: 5,
            texte:
                "Le défi : apprendre, progresser et me dépasser.",
            code: "ATTIRANCE_DEFI"
        }

    ]
},

    {
    id: 2,

    question:
        "Dans quelle situation te sens-tu généralement le plus à l’aise ?",

    reponses: [

        {
            id: 1,
            texte:
                "Résoudre : analyser un problème et trouver une solution.",
            code: "FORCE_ANALYSER"
        },

        {
            id: 2,
            texte:
                "Créer : imaginer quelque chose et proposer des idées.",
            code: "FORCE_CREER"
        },

        {
            id: 3,
            texte:
                "Aider : écouter, expliquer ou accompagner quelqu’un.",
            code: "FORCE_AIDER"
        },

        {
            id: 4,
            texte:
                "Organiser : structurer, planifier et gérer les choses.",
            code: "FORCE_ORGANISER"
        },

        {
            id: 5,
            texte:
                "Agir : prendre des initiatives et faire avancer un projet.",
            code: "FORCE_AGIR"
        }

    ]
},

    {
    id: 3,

    question:
        "Qu’est-ce qui rend ton choix le plus difficile aujourd’hui ?",

    reponses: [

        {
            id: 1,
            texte:
                "J’ai peur de me tromper.",
            code: "BLOCAGE_ERREUR"
        },

        {
            id: 2,
            texte:
                "J’ai plusieurs options qui m’intéressent réellement.",
            code: "BLOCAGE_OPTIONS"
        },

        {
            id: 3,
            texte:
                "Je manque d’informations pour comparer.",
            code: "BLOCAGE_INFORMATION"
        },

        {
            id: 4,
            texte:
                "Je ne suis pas sûr(e) d’avoir le niveau ou les capacités nécessaires.",
            code: "BLOCAGE_CAPACITES"
        },

        {
            id: 5,
            texte:
                "Mon entourage influence beaucoup mon choix.",
            code: "BLOCAGE_ENTOURAGE"
        }

    ]
},

    {
    id: 4,

    question:
        "Si tu devais aujourd’hui donner le plus de poids à un seul critère, lequel serait-ce ?",

    reponses: [

        {
            id: 1,
            texte:
                "Mon intérêt personnel.",
            code: "CRITERE_INTERET"
        },

        {
            id: 2,
            texte:
                "Mes capacités et mes points forts.",
            code: "CRITERE_CAPACITES"
        },

        {
            id: 3,
            texte:
                "Les débouchés professionnels.",
            code: "CRITERE_DEBOUCHES"
        },

        {
            id: 4,
            texte:
                "Les conditions de travail.",
            code: "CRITERE_CONDITIONS"
        },

        {
            id: 5,
            texte:
                "La stabilité et la sécurité.",
            code: "CRITERE_STABILITE"
        }

    ]
},

    {
    id: 5,

    question:
        "Qu’est-ce qui t’aiderait le plus à avancer vers une décision ?",

    reponses: [

        {
            id: 1,
            texte:
                "Mieux comprendre les différences entre mes options.",
            code: "BESOIN_COMPARAISON"
        },

        {
            id: 2,
            texte:
                "Vérifier laquelle correspond le mieux à mes forces.",
            code: "BESOIN_COMPATIBILITE"
        },

        {
            id: 3,
            texte:
                "Découvrir la réalité du métier ou de la filière.",
            code: "BESOIN_REALITE"
        },

        {
            id: 4,
            texte:
                "Vérifier les débouchés et les possibilités d’évolution.",
            code: "BESOIN_DEBOUCHES"
        },

        {
            id: 5,
            texte:
                "Me rassurer avant de faire mon choix.",
            code: "BESOIN_RASSURANCE"
        }

    ]
}
];

    /*
     * Étape 1 :
     * Présentation du modèle.
     */
    const afficherPresentation = () => {

        return (

            <div>

                <h1>
                    Tu hésites entre plusieurs choix ?
                </h1>

                <p>
                    Tu as plusieurs métiers ou plusieurs filières
                    en tête et tu ne sais pas encore lequel
                    correspond le mieux à ta situation ?
                </p>

                <p>
                    Pas besoin de choisir tout de suite.
                    NextOri va t'aider à comprendre ton hésitation,
                    tes points forts, ce qui influence ta décision
                    et les prochaines étapes qui pourraient
                    t'aider à avancer.
                </p>


                <section>

                    <h2>
                        Comment fonctionne cette analyse ?
                    </h2>

                    <div>

                        <h3>
                            1. Présente-nous tes choix
                        </h3>

                        <p>
                            Sélectionne les métiers ou les filières
                            entre lesquels tu hésites.
                        </p>

                    </div>


                    <div>

                        <h3>
                            2. Réponds à 5 questions
                        </h3>

                        <p>
                            Des questions courtes pour mieux comprendre
                            tes motivations, tes points forts,
                            tes blocages et ce qui influence ton choix.
                        </p>

                    </div>


                    <div>

                        <h3>
                            3. NextOri analyse ta situation
                        </h3>

                        <p>
                            Tes réponses et les choix que tu envisages
                            sont analysés pour construire une réflexion
                            personnalisée.
                        </p>

                    </div>


                    <div>

                        <h3>
                            4. Découvre ta prochaine direction
                        </h3>

                        <p>
                            NextOri t'explique ce qui semble cohérent
                            avec ta situation et te propose des pistes
                            concrètes pour avancer.
                        </p>

                    </div>

                </section>


                <section>

                    <h2>
                        Une analyse différente du test RIASEC
                    </h2>

                    <p>
                        Le RIASEC permet de mieux comprendre ton profil
                        professionnel.
                    </p>

                    <p>
                        Cette analyse répond à une autre question :
                    </p>

                    <strong>
                        « Parmi les choix que j'envisage aujourd'hui,
                        lequel semble le plus cohérent avec ma situation
                        et pourquoi ? »
                    </strong>

                </section>


                <button
                    type="button"
                    onClick={() => setEtape("type")}
                >
                    Commencer mon analyse
                </button>

            </div>

        );

    };


    /*
     * Étape 2 :
     * L'utilisateur indique s'il hésite
     * entre des métiers ou des filières.
     *
     * Pour l'instant, cette étape est volontairement simple.
     * Nous la compléterons ensuite.
     */
    const optionsSelectionnees =
    typeChoix === "metier"
        ? metiersSelectionnes
        : filieresSelectionnees;

const afficherChoixType = () => {

    const choisirType = (type) => {

    setTypeChoix(type);

    setEtape("options");
       

    };


    return (

        <div>

            <h1>
                Entre quoi hésites-tu ?
            </h1>

            <p>
                Choisis ce que tu souhaites explorer avec NextOri.
            </p>


            <button
                type="button"
                onClick={() => choisirType("metier")}
            >
                Métiers
            </button>


            <button
                type="button"
                onClick={() => choisirType("filiere")}
            >
                Filières
            </button>


            <button
                type="button"
                onClick={() => setEtape("presentation")}
            >
                ← Retour
            </button>

        </div>

    );

};

if (etape === "options") {

    const options = typeChoix === "metier"
        ? [
            { id: 1, nom: "Développeur web" },
            { id: 2, nom: "Data Analyst" },
            { id: 3, nom: "Designer UX/UI" },
            { id: 4, nom: "Chef de projet" }
        ]
        : [
            { id: 1, nom: "Informatique" },
            { id: 2, nom: "Mathématiques" },
            { id: 3, nom: "Design" },
            { id: 4, nom: "Gestion de projet" }
        ];


    const changerSelection = (option) => {

    if (typeChoix === "metier") {

        setMetiersSelectionnes((actuelles) => {

            const dejaSelectionnee =
                actuelles.some(
                    (item) => item.id === option.id
                );

            if (dejaSelectionnee) {

                return actuelles.filter(
                    (item) => item.id !== option.id
                );

            }

            if (actuelles.length >= 3) {
                return actuelles;
            }

            return [
                ...actuelles,
                option
            ];

        });

    } else {

        setFilieresSelectionnees((actuelles) => {

            const dejaSelectionnee =
                actuelles.some(
                    (item) => item.id === option.id
                );

            if (dejaSelectionnee) {

                return actuelles.filter(
                    (item) => item.id !== option.id
                );

            }

            if (actuelles.length >= 3) {
                return actuelles;
            }

            return [
                ...actuelles,
                option
            ];

        });

    }

};

    const continuer = () => {

        if (optionsSelectionnees.length < 2) {

            return;

        }

        setEtape("questions");

    };


    return (

        <div>

            <h1>
                {typeChoix === "metier"
                    ? "Quels métiers envisages-tu ?"
                    : "Quelles filières envisages-tu ?"
                }
            </h1>


            <p>
                Sélectionne entre 2 et 3 choix
                que tu souhaites comparer.
            </p>


            <p>
                {optionsSelectionnees.length} / 3 sélectionné(s)
            </p>


            <div>

                {options.map((option) => {

                    const selectionnee =
                        optionsSelectionnees.some(
                            (item) =>
                                item.id === option.id
                        );


                    return (

                        <button
                            key={option.id}
                            type="button"
                            onClick={() =>
                                changerSelection(option)
                            }
                        >

                            {selectionnee
                                ? "✓ "
                                : ""
                            }

                            {option.nom}

                        </button>

                    );

                })}

            </div>


            <button
                type="button"
                onClick={() => setEtape("type")}
            >
                ← Retour
            </button>


            <button
                type="button"
                disabled={
                    optionsSelectionnees.length < 2
                }
                onClick={() => {

    setQuestionActuelle(0);
    setReponsesHesitation([]);
    setEtape("questions");

}}
            >
                Continuer
            </button>

        </div>

    );

}


if (etape === "questions") {

    const question =
        questionsHesitation[questionActuelle];

    return (
        <div className="hesitation-page">

            <h1>
                Question {questionActuelle + 1} / 5
            </h1>

            <h2>
                {question.question}
            </h2>

            <div>

                {question.reponses.map((reponse) => (

    <button
        key={reponse.id}
        type="button"
        onClick={() => {

            setReponsesHesitation((anciennes) => {

                const nouvelles =
                    anciennes.filter(
                        (item) =>
                            item.id_question !== question.id
                    );

                return [
                     ...nouvelles,
         {
             id_question: question.id,
             id_reponse: reponse.id,
             code: reponse.code
         }
        ];

            });

        }}
    >
        {reponse.texte}
    </button>

    

))}

            </div>

            <button
    type="button"
    disabled={
        !reponsesHesitation.some(
            (item) =>
                item.id_question === question.id
        )
    }
    onClick={() => {

        if (
            questionActuelle <
            questionsHesitation.length - 1
        ) {

            setQuestionActuelle(
                questionActuelle + 1
            );

        } else {

            setEtape("analyse");

        }

    }}
>
    {questionActuelle ===
    questionsHesitation.length - 1
        ? "Analyser ma situation"
        : "Continuer →"
    }
</button>

        </div>
    );
}


if (etape === "analyse") {

    const etapesAnalyse = [
        "Compréhension de tes choix",
        "Analyse de tes points forts",
        "Identification de ce qui peut te bloquer",
        "Analyse des facteurs qui influencent ta décision",
        "Mise en perspective de tes choix",
        "Préparation de tes prochaines étapes"
    ];

    const etapeActuelle =
        etapesAnalyse[etapeAnalyse];

    return (

        <div className="hesitation-analyse-page">

            <div className="hesitation-analyse-card">

                <div className="hesitation-analyse-orbe">

                    <div className="hesitation-analyse-orbe-core"></div>

                </div>


                <span className="hesitation-analyse-label">
                    Analyse NextOri
                </span>


                <h1>
                    J’analyse ta situation...
                </h1>


                <p>
                    {etapeActuelle}
                </p>


                <div className="hesitation-analyse-steps">

                    {etapesAnalyse.map(
                        (etape, index) => (

                            <div
                                key={etape}
                                className={
                                    `hesitation-analyse-step ${
                                        index < etapeAnalyse
                                            ? "terminee"
                                            : index === etapeAnalyse
                                                ? "active"
                                                : ""
                                    }`
                                }
                            >

                                <span className="hesitation-analyse-step-indicator">
                                    {index < etapeAnalyse
                                        ? "✓"
                                        : index + 1
                                    }
                                </span>

                                <span>
                                    {etape}
                                </span>

                            </div>

                        )
                    )}

                </div>

                {analyseTerminee && (

    <div className="hesitation-analyse-finished">

        <h2>
            Analyse terminée
        </h2>

        <p>
            J'ai terminé l'analyse de ta situation.
        </p>

        <button
    type="button"
    onClick={() => {

    console.log("DONNÉES ENVOYÉES :", {
    typeChoix,
    metiersSelectionnes,
    filieresSelectionnees,
    reponsesHesitation
});

navigate("/resultat-hesitation", {
    state: {
        typeChoix,
        metiersSelectionnes,
        filieresSelectionnees,
        reponsesHesitation
    }
});

}}
>
    Voir mon analyse →
</button>

    </div>

)}


                <div className="hesitation-analyse-loader">

                    <span></span>
                    <span></span>
                    <span></span>

                </div>

            </div>

        </div>

    );

}

     


    /*
     * Petit routeur interne du module.
     */
    if (etape === "presentation") {

        return afficherPresentation();

    }


    if (etape === "type") {

        return afficherChoixType();

    }


    return null;
}

export default Hesitation;
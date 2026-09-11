import { useLocation, useNavigate } from "react-router-dom";
import {
    ArrowLeft,
    ArrowRight,
    Sparkles,
    Check,
    Compass,
    Target,
    Scale,
    Lightbulb,
    BadgeCheck,
    GitCompareArrows
} from "lucide-react";

import { genererComparaisonHesitation } from "../utils/moteurComparaisonHesitation";

const donneesMetiers = {
    "Développeur web": {
        analyse: 5,
        creation: 3,
        relation: 2,
        organisation: 4,
        action: 4,
        debouches: 5,
        stabilite: 4,
        contenu:
            "Concevoir, développer et faire évoluer des sites et applications web."
    },

    "Data Analyst": {
        analyse: 5,
        creation: 3,
        relation: 2,
        organisation: 5,
        action: 3,
        debouches: 5,
        stabilite: 4,
        contenu:
            "Analyser des données pour faire ressortir des tendances et aider à la prise de décision."
    },

    "Designer UX/UI": {
        analyse: 4,
        creation: 5,
        relation: 4,
        organisation: 4,
        action: 3,
        debouches: 4,
        stabilite: 3,
        contenu:
            "Concevoir des expériences numériques adaptées aux besoins des utilisateurs."
    },

    "Chef de projet": {
        analyse: 4,
        creation: 3,
        relation: 5,
        organisation: 5,
        action: 5,
        debouches: 5,
        stabilite: 4,
        contenu:
            "Piloter un projet, coordonner les acteurs et faire avancer les différentes étapes."
    }
};

const donneesFilieres = {
    Informatique: {
        analyse: 5,
        creation: 3,
        relation: 2,
        organisation: 4,
        action: 4,
        debouches: 5,
        stabilite: 4,
        contenu:
            "Une filière orientée vers les technologies, le développement et les systèmes numériques."
    },

    Mathématiques: {
        analyse: 5,
        creation: 3,
        relation: 2,
        organisation: 4,
        action: 3,
        debouches: 5,
        stabilite: 4,
        contenu:
            "Une filière développant fortement le raisonnement, l'analyse et la résolution de problèmes."
    },

    Design: {
        analyse: 4,
        creation: 5,
        relation: 4,
        organisation: 4,
        action: 3,
        debouches: 4,
        stabilite: 3,
        contenu:
            "Une filière centrée sur la conception, la créativité et l'expérience utilisateur."
    },

    "Gestion de projet": {
        analyse: 4,
        creation: 3,
        relation: 5,
        organisation: 5,
        action: 5,
        debouches: 5,
        stabilite: 4,
        contenu:
            "Une filière orientée vers l'organisation, la coordination et le pilotage de projets."
    }
};

function DepartagerHesitation() {

    const location = useLocation();
    const navigate = useNavigate();

    const {
        typeChoix,
        metiersSelectionnes = [],
        filieresSelectionnees = [],
        reponsesHesitation = []
    } = location.state || {};

    const options =
        typeChoix === "metier"
            ? metiersSelectionnes
            : filieresSelectionnees;

    const catalogue =
        typeChoix === "metier"
            ? donneesMetiers
            : donneesFilieres;

    const comparaisonAnalyse =
        genererComparaisonHesitation({
            typeChoix,
            metiersSelectionnes,
            filieresSelectionnees,
            reponsesHesitation,
            catalogue
        });

    if (!typeChoix || options.length < 2) {

        return (
            <div className="departager-hesitation-page">

                <h1>
                    Comparaison indisponible
                </h1>

                <p>
                    Nous n'avons pas suffisamment d'informations
                    pour comparer tes choix.
                </p>

                <button
                    type="button"
                    onClick={() => navigate("/hesitation")}
                >
                    <ArrowLeft size={18} />
                    Refaire mon analyse
                </button>

            </div>
        );
    }

    const {
        criteresActifs = [],
        comparaison = [],
        meilleureOption = null
    } = comparaisonAnalyse;

    return (

        <div className="departager-hesitation-page">

            {/* HERO */}

            <header className="departager-hesitation-hero">

                <button
                    type="button"
                    className="departager-hesitation-back"
                    onClick={() =>
                        navigate("/resultat-hesitation", {
                            state: location.state
                        })
                    }
                >
                    <ArrowLeft size={18} />
                    Retour à mon analyse
                </button>

                <div className="departager-hesitation-badge">
                    <Sparkles size={17} />
                    Aide à la décision NextOri
                </div>

                <p className="departager-hesitation-eyebrow">
                    J'HÉSITE · DÉPARTAGER MES CHOIX
                </p>

                <h1>
                    Mettons tes choix
                    <span> en perspective.</span>
                </h1>

                <p>
                    Tu as déjà identifié les options qui t'intéressent.
                    Maintenant, NextOri les met en regard de ce qui
                    ressort de tes réponses.
                </p>

            </header>


            {/* FIL DE RAISONNEMENT */}

            <section className="departager-hesitation-section">

                <div className="departager-hesitation-section-heading">

                    <Compass size={22} />

                    <div>
                        <p>COMMENT LIRE CETTE COMPARAISON</p>

                        <h2>
                            Il ne s'agit pas de trouver un choix parfait.
                        </h2>
                    </div>

                </div>

                <div className="departager-hesitation-intro-card">

                    <GitCompareArrows size={22} />

                    <p>
                        Cette comparaison regarde simplement quelles
                        options semblent actuellement les plus cohérentes
                        avec les éléments que tu as mis en avant.
                        Elle constitue une aide à la réflexion, pas une
                        décision automatique à ta place.
                    </p>

                </div>

            </section>


            {/* CRITERES */}

            <section className="departager-hesitation-section">

                <div className="departager-hesitation-section-heading">

                    <Target size={22} />

                    <div>
                        <p>CE QUI COMPTE POUR TOI</p>

                        <h2>
                            Les critères ressortis de tes réponses
                        </h2>
                    </div>

                </div>

                <div className="departager-hesitation-criteria">

                    {criteresActifs.map((critere) => (

                        <div
                            className="departager-hesitation-criterion"
                            key={critere.critere}
                        >
                            <Check size={16} />

                            <span>
                                {critere.nom}
                            </span>
                        </div>

                    ))}

                </div>

            </section>


            {/* COMPARAISON */}

            <section className="departager-hesitation-section">

                <div className="departager-hesitation-section-heading">

                    <Scale size={22} />

                    <div>
                        <p>COMPARAISON</p>

                        <h2>
                            Tes options sur les critères importants
                        </h2>
                    </div>

                </div>

                <div className="departager-hesitation-comparison">

                    {comparaison.map((option, index) => (

                        <article
                            className={
                                `departager-hesitation-option-card ${
                                    index === 0
                                        ? "is-best"
                                        : ""
                                }`
                            }
                            key={option.id || option.nom}
                        >

                            {index === 0 && (

                                <div className="departager-hesitation-recommended">
                                    <BadgeCheck size={24} />
                                    Correspondance actuelle la plus forte
                                </div>

                            )}

                            <div className="departager-hesitation-option-top">

                                <span>
                                    0{index + 1}
                                </span>

                                <h3>
                                    {option.nom}
                                </h3>

                            </div>

                            <p className="departager-hesitation-option-description">
                                {option.donnees?.contenu}
                            </p>

                            <div className="departager-hesitation-score">

                                <div>

                                    <span>
                                        Cohérence avec tes critères
                                    </span>

                                    <strong>
                                        {option.score ?? 0}%
                                    </strong>

                                </div>

                                <div className="departager-hesitation-score-bar">

                                    <span
                                        style={{
                                            width: `${option.score ?? 0}%`
                                        }}
                                    />

                                </div>

                            </div>

                            <div className="departager-hesitation-criterion-list">

                                {option.criteres?.map((critere) => (

                                    <div
                                        key={critere.critere}
                                        className="departager-hesitation-criterion-row"
                                    >

                                        <span>
                                            {critere.nom}
                                        </span>

                                        <strong>
                                            {critere.valeur}
                                            /5
                                        </strong>

                                    </div>

                                ))}

                            </div>

                        </article>

                    ))}

                </div>

            </section>


            {/* LECTURE */}

            <section className="departager-hesitation-section">

                <div className="departager-hesitation-section-heading">

                    <Lightbulb size={22} />

                    <div>
                        <p>LECTURE DE NEXTORI</p>

                        <h2>
                            Ce qui ressort actuellement
                        </h2>
                    </div>

                </div>

                <article className="departager-hesitation-reading">

                    <Lightbulb size={24} />

                    <div>

                        <h3>
                            {meilleureOption?.nom}
                        </h3>

                        <p>
                            Parmi les options que tu as indiquées,
                            <strong>
                                {" "}{meilleureOption?.nom}
                            </strong>
                            {" "}présente actuellement la correspondance
                            la plus forte avec les critères ressortis
                            de tes réponses.
                        </p>

                        <p>
                            Cela ne signifie pas que cette option est
                            nécessairement la meilleure pour toi.
                            Elle mérite simplement d'être regardée
                            plus attentivement à ce stade de ta réflexion.
                        </p>

                    </div>

                </article>

            </section>


            {/* ACTION */}

            <section className="departager-hesitation-final">

                <div>

                    <p>
                        PROCHAINE ÉTAPE
                    </p>

                    <h2>
                        Maintenant, vérifie cette impression avec la réalité.
                    </h2>

                    <span>
                        Découvre les informations concrètes sur chaque
                        option avant de prendre ta décision.
                    </span>

                </div>

                <button
                    type="button"
                    onClick={() => {

                        if (typeChoix === "metier") {

                            navigate("/metiers");

                        } else {

                            navigate("/filieres");

                        }

                    }}
                >
                    Explorer les{" "}
                    {typeChoix === "metier"
                        ? "métiers"
                        : "filières"
                    }

                    <ArrowRight size={18} />

                </button>

            </section>

        </div>
    );
}

export default DepartagerHesitation;
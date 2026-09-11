import { useLocation, useNavigate } from "react-router-dom";
import { Sparkles } from "lucide-react"
import { ArrowRight } from "lucide-react";
import {genererAnalyseHesitation} from "../utils/moteurHesitation";




function ResultatHesitation() {

    const location = useLocation();
    const navigate = useNavigate();

    const {
        typeChoix,
        metiersSelectionnes = [],
        filieresSelectionnees = [],
        reponsesHesitation = []
    } = location.state || {};

    console.log("RESULTAT :", {
    typeChoix,
    metiersSelectionnes,
    filieresSelectionnees,
    reponsesHesitation
});

   const options =
    typeChoix === "metier"
        ? metiersSelectionnes
        : filieresSelectionnees;

const analyse = genererAnalyseHesitation({
    typeChoix,
    metiersSelectionnes,
    filieresSelectionnees,
    reponsesHesitation
});

    if (!typeChoix) {

        return (
            <div>

                <h1>
                    Analyse introuvable
                </h1>

                <p>
                    Cette analyse n'est plus disponible.
                </p>

                <button
                    type="button"
                    onClick={() => navigate("/hesitation")}
                >
                    Refaire une analyse
                </button>

            </div>
        );

    }

   
            

    return (
    <div className="resultat-hesitation-page">

        {/* =====================================================
            HERO
        ===================================================== */}

        <header className="resultat-hesitation-hero">

            <div className="resultat-hesitation-hero-badge">
                <span className="resultat-hesitation-ai-dot"></span>
                Analyse personnalisée NextOri
            </div>

            <p className="resultat-hesitation-eyebrow">
                J'HÉSITE · RESTITUTION
            </p>

            <h1>
                Voici ce que ton hésitation
                <span> semble révéler.</span>
            </h1>

            <p className="resultat-hesitation-hero-description">
                À partir de tes choix et de tes réponses, NextOri
                a identifié plusieurs éléments qui peuvent t'aider
                à comprendre ta décision.
            </p>

        </header>


        {/* =====================================================
            CHOIX ANALYSÉS
        ===================================================== */}

        <section className="resultat-hesitation-section resultat-hesitation-options-section">

            <div className="resultat-hesitation-section-heading">

                <span className="resultat-hesitation-section-number">
                    01
                </span>

                <div>
                    <p className="resultat-hesitation-section-label">
                        TON HÉSITATION
                    </p>

                    <h2>
                        Les options que tu compares
                    </h2>
                </div>

            </div>


            <div className="resultat-hesitation-options">

                {analyse.options.map((option) => (

                    <div
                        className="resultat-hesitation-option"
                        key={option.id}
                    >

                        <span className="resultat-hesitation-option-index">
                            {String(
                                analyse.options.indexOf(option) + 1
                            ).padStart(2, "0")}
                        </span>

                        <strong>
                            {option.nom}
                        </strong>

                    </div>

                ))}

            </div>

        </section>


        {/* =====================================================
            SYNTHÈSE PRINCIPALE
        ===================================================== */}

        <section className="resultat-hesitation-section">

            <div className="resultat-hesitation-section-heading">

                <span className="resultat-hesitation-section-number">
                    02
                </span>

                <div>
                    <p className="resultat-hesitation-section-label">
                        LECTURE DE TA SITUATION
                    </p>

                    <h2>
                        Ce que ton hésitation semble indiquer
                    </h2>
                </div>

            </div>


            <article className="resultat-hesitation-synthesis-card">

                <div className="resultat-hesitation-synthesis-mark">
    <Sparkles size={24} strokeWidth={1.8} />
</div>

                <div>

                    <p>
                        {analyse.synthese}
                    </p>

                </div>

            </article>

        </section>


        {/* =====================================================
            SIGNAUX PRINCIPAUX
        ===================================================== */}

        <section className="resultat-hesitation-section">

            <div className="resultat-hesitation-section-heading">

                <span className="resultat-hesitation-section-number">
                    03
                </span>

                <div>
                    <p className="resultat-hesitation-section-label">
                        LES SIGNAUX QUI RESSORTENT
                    </p>

                    <h2>
                        Plusieurs éléments méritent ton attention
                    </h2>
                </div>

            </div>


            <div className="resultat-hesitation-signals">


                {/* Attirance */}

                {analyse.attirance && (

                    <article className="resultat-hesitation-signal-card">

                        <span className="resultat-hesitation-signal-tag">
                            Ce qui t'attire
                        </span>

                        <h3>
                            {analyse.attirance.titre}
                        </h3>

                        <p>
                            {analyse.attirance.description}
                        </p>

                    </article>

                )}


                {/* Force */}

                {analyse.pointsForts?.length > 0 && (

                    <article className="resultat-hesitation-signal-card">

                        <span className="resultat-hesitation-signal-tag">
                            Un point fort
                        </span>

                        <h3>
                            {analyse.pointsForts[0].titre}
                        </h3>

                        <p>
                            {analyse.pointsForts[0].description}
                        </p>

                    </article>

                )}


                {/* Critère */}

                {analyse.critere && (

                    <article className="resultat-hesitation-signal-card">

                        <span className="resultat-hesitation-signal-tag">
                            Ton critère important
                        </span>

                        <h3>
                            {analyse.critere.titre}
                        </h3>

                        <p>
                            {analyse.critere.description}
                        </p>

                    </article>

                )}

            </div>

        </section>


        {/* =====================================================
            POINT DE VIGILANCE
        ===================================================== */}

       <section className="resultat-hesitation-section">

    <div className="resultat-hesitation-section-heading">

        <span className="resultat-hesitation-section-number">
            04
        </span>

        <div>
            <p className="resultat-hesitation-section-label">
                POINT DE VIGILANCE
            </p>

            <h2>
                Ce qui peut compliquer ta décision
            </h2>
        </div>

    </div>


    <article className="resultat-hesitation-warning">

        <div className="resultat-hesitation-warning-icon">
            !
        </div>


        <div>

            <h3>
    {analyse.blocage
        ? analyse.blocage.titre
        : "Un point reste encore à éclaircir"
    }
</h3>

<p>
    {analyse.blocage
        ? analyse.blocage.description
        : "Tes réponses ne font pas ressortir de difficulté dominante dans ta décision. " +
          "Cela peut simplement signifier que plusieurs éléments restent encore à mettre en perspective."
    }
</p>

        </div>

    </article>

</section>


        {/* =====================================================
            CRITÈRE + BESOIN
        ===================================================== */}

        <section className="resultat-hesitation-section">

            <div className="resultat-hesitation-section-heading">

                <span className="resultat-hesitation-section-number">
                    05
                </span>

                <div>
                    <p className="resultat-hesitation-section-label">
                        POUR DÉCIDER
                    </p>

                    <h2>
                        Ce qui pourrait t'aider maintenant
                    </h2>
                </div>

            </div>


            <div className="resultat-hesitation-decision-grid">


                {analyse.critere && (

                    <article className="resultat-hesitation-decision-card">

                        <span>
                            PRIORITÉ
                        </span>

                        <h3>
                            {analyse.critere.titre}
                        </h3>

                        <p>
                            {analyse.critere.description}
                        </p>

                    </article>

                )}


                {analyse.besoin && (

                    <article className="resultat-hesitation-decision-card resultat-hesitation-decision-card-highlight">

                        <span>
                            PROCHAINE ACTION
                        </span>

                        <h3>
                            {analyse.besoin.titre}
                        </h3>

                        <p>
                            {analyse.besoin.description}
                        </p>

                    </article>

                )}

            </div>

        </section>


        {/* =====================================================
            CONCLUSION
        ===================================================== */}

        <section className="resultat-hesitation-section">

            <article className="resultat-hesitation-conclusion">

                <p className="resultat-hesitation-conclusion-label">
                    CE QUE NEXTORI RETIENT
                </p>

                <h2>
                    La prochaine étape n'est pas forcément
                    de trouver le choix parfait.
                </h2>

                <p>
                    {analyse.conclusion}
                </p>

            </article>

        </section>


        {/* =====================================================
            CONSEILS
        ===================================================== */}

        <section className="resultat-hesitation-section">

            <div className="resultat-hesitation-section-heading">

                <span className="resultat-hesitation-section-number">
                    06
                </span>

                <div>
                    <p className="resultat-hesitation-section-label">
                        POUR AVANCER
                    </p>

                    <h2>
                        Trois pistes concrètes
                    </h2>
                </div>

            </div>


            <div className="resultat-hesitation-advice-list">

                {analyse.conseils.map(
                    (conseil, index) => (

                        <article
                            className="resultat-hesitation-advice"
                            key={conseil.titre}
                        >

                            <span className="resultat-hesitation-advice-number">
                                {String(index + 1).padStart(2, "0")}
                            </span>

                            <div>

                                <h3>
                                    {conseil.titre}
                                </h3>

                                <p>
                                    {conseil.description}
                                </p>

                            </div>

                        </article>

                    )
                )}

            </div>

        </section>


        {/* =====================================================
            FOOTER / ACTIONS
        ===================================================== */}

        <section className="resultat-hesitation-final">

            <div>

                <p className="resultat-hesitation-final-label">
                    ET MAINTENANT ?
                </p>

                <h2>
                    Transforme ton hésitation
                    en exploration.
                </h2>

                <p>
                    Tu n'as pas besoin de décider immédiatement.
                    Commence par mieux connaître les options
                    qui t'intéressent réellement.
                </p>

            </div>


            <div className="resultat-hesitation-actions">

                <button
                    type="button"
                    className="resultat-hesitation-secondary-button"
                    onClick={() =>
                        navigate("/hesitation")
                    }
                >
                    Refaire mon analyse
                </button>


               <button
    type="button"
    className="resultat-hesitation-primary-button"
    onClick={() => {

        navigate("/hesitation/departager", {
            state: {
                typeChoix,
                metiersSelectionnes,
                filieresSelectionnees,
                reponsesHesitation,
                analyse
            }
        });

    }}
>
    Départager mes choix

    <span>
        <ArrowRight size={18} strokeWidth={2} />
    </span>
</button>

            </div>

        </section>


        {/* =====================================================
            NOTE MÉTHODOLOGIQUE
        ===================================================== */}

        <footer className="resultat-hesitation-methodology">

            <span>
                Analyse NextOri
            </span>

            <p>
                Cette restitution est construite à partir de tes
                réponses et des choix que tu as indiqués. Elle propose
                des pistes de réflexion et ne constitue pas un diagnostic
                définitif de ta personnalité ou de ton avenir professionnel.
            </p>

        </footer>

    </div>
);

}

export default ResultatHesitation;
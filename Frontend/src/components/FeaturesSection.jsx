import {
    UserRound,
    Compass,
    Route,
    ArrowRight
} from "lucide-react";

import "../styles/FeaturesSection.css";


function FeaturesSection() {

    const etapes = [
        {
            numero: "01",
            icone: UserRound,
            titre: "Comprends ton profil",
            description:
                "Identifie tes intérêts, tes forces et ce qui compte réellement pour toi dans ton orientation."
        },
        {
            numero: "02",
            icone: Compass,
            titre: "Explore les possibilités",
            description:
                "Découvre des métiers et des filières qui correspondent à ton profil, tes attentes et tes objectifs."
        },
        {
            numero: "03",
            icone: Route,
            titre: "Construis ton parcours",
            description:
                "Explore les formations et les établissements pour transformer tes idées en véritable projet d'avenir."
        }
    ];


    return (

        <section className="features-section">

            <div className="features-container">

                {/* Introduction */}

                <div className="features-introduction">

                    <span className="features-label">
                        COMMENT ÇA FONCTIONNE ?
                    </span>

                    <h2>
                        Une orientation pensée
                        <span> pour toi.</span>
                    </h2>

                    <p>
                        NextOri ne te donne pas simplement un métier.
                        La plateforme t'aide à mieux te connaître,
                        à explorer les possibilités qui s'offrent à toi
                        et à construire progressivement ton parcours.
                    </p>

                </div>


                {/* Étapes */}

                <div className="features-steps">

                    {etapes.map((etape, index) => {

                        const Icone = etape.icone;

                        return (

                            <article
                                className="feature-card"
                                key={etape.numero}
                            >

                                <div className="feature-card-top">

                                    

                                    <div className="feature-icon">
                                        <Icone size={25} strokeWidth={2} />
                                    </div>

                                </div>


                                <div className="feature-card-content">

                                    <h3>
                                        {etape.titre}
                                    </h3>

                                    <p>
                                        {etape.description}
                                    </p>

                                </div>


                                <div className="feature-card-bottom">

                                    <span>
                                        Étape {index + 1}
                                    </span>

                                    <div className="feature-card-arrow">
                                        <ArrowRight
                                            size={20}
                                            strokeWidth={2}
                                        />
                                    </div>

                                </div>

                            </article>

                        );

                    })}

                </div>

            </div>

        </section>

    );

}


export default FeaturesSection;
import { useNavigate } from "react-router-dom";
import { ArrowRight, Compass } from "lucide-react";

import "../styles/CTASection.css";


function CTASection() {

    const navigate = useNavigate();


    return (

        <section className="cta-section">

            <div className="cta-container">


                <div className="cta-icon">

                    <Compass />

                </div>


                <span className="cta-label">
                    PASSE À L'ÉTAPE SUIVANTE
                </span>


                <h2>
                    Ton orientation
                    <span> commence maintenant.</span>
                </h2>


                <p>
                    Mieux comprendre ton profil, explorer les métiers
                    et les filières qui t'intéressent, puis construire
                    progressivement ton parcours.
                </p>


                <div className="cta-actions">

                    <button
                        className="cta-primary-button"
                        onClick={() => navigate("/test")}
                    >

                        Commencer mon orientation

                        <ArrowRight />

                    </button>


                    <button
                        className="cta-secondary-button"
                        onClick={() => navigate("/metiers")}
                    >

                        Explorer les métiers

                    </button>

                </div>


            </div>

        </section>

    );

}


export default CTASection;
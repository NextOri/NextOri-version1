import { useNavigate } from "react-router-dom";
import { ArrowRight, Compass } from "lucide-react";

import "../styles/HeroSection.css";


function HeroSection() {

    const navigate = useNavigate();


    return (

        <section className="hero-section">

            <div className="hero-container">


                <div className="hero-content">

                    <div className="hero-badge">

                        <Compass />

                        <span>
                            Ton orientation, autrement
                        </span>

                    </div>


                    <h1>

                        Trouve la voie qui
                        <span> correspond à ton potentiel.</span>

                    </h1>


                    <p className="hero-description">

                        Découvre les métiers, les filières et les
                        établissements qui peuvent correspondre à ton
                        profil et construis ton parcours étape par étape.

                    </p>


                    <div className="hero-actions">

                        <button
                            className="hero-primary-button"
                            onClick={() => navigate("/test")}
                        >

                            Commencer mon orientation

                            <ArrowRight />

                        </button>


                        <button
                            className="hero-secondary-button"
                            onClick={() => navigate("/metiers")}
                        >

                            Explorer les métiers

                        </button>

                    </div>


                    <div className="hero-meta">

                        <span>
                            Profil RIASEC
                        </span>

                        <span className="hero-meta-separator">
                            •
                        </span>

                        <span>
                            Métiers
                        </span>

                        <span className="hero-meta-separator">
                            •
                        </span>

                        <span>
                            Filières
                        </span>

                        <span className="hero-meta-separator">
                            •
                        </span>

                        <span>
                            Établissements
                        </span>

                    </div>

                </div>



                <div className="hero-visual">

                    <div className="hero-image-wrapper">

                        <img
                            src="/images/home/hero-nextori.png"
                            alt="Illustration de l'orientation avec NextOri"
                            className="hero-image"
                        />

                    </div>

                </div>


            </div>

        </section>

    );

}


export default HeroSection;
import "../styles/AboutSection.css";

function AboutSection() {

    return (

        <section className="about-section">

            <div className="about-container">

                <div className="about-content">

                    <span className="about-label">
                        À PROPOS DE NEXTORI
                    </span>

                    <h2>
                        Une orientation pensée pour construire
                        <span> ton avenir.</span>
                    </h2>

                    <p>
                        NextOri est une plateforme d'accompagnement
                        à l'orientation qui aide les étudiants et les
                        futurs étudiants à mieux construire leur avenir
                        académique et professionnel.
                    </p>

                    <p>
                        Grâce à l'analyse de tes centres d'intérêt,
                        de tes forces et de tes attentes, NextOri
                        t'aide à mieux comprendre les possibilités
                        qui s'offrent à toi.
                    </p>

                    <p>
                        Découvre des métiers, explore les filières
                        correspondantes et recherche les établissements
                        qui peuvent accompagner ton parcours.
                    </p>

                </div>


                <div className="about-highlight">

                    <div className="about-highlight-number">
                        →
                    </div>

                    <h3>
                        Ton orientation,
                        étape par étape.
                    </h3>

                    <p>
                        Comprendre ton profil, explorer les possibilités
                        et avancer vers un choix qui te ressemble.
                    </p>

                </div>

            </div>

        </section>

    );

}

export default AboutSection;
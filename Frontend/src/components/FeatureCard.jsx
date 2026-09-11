import "../styles/FeatureCard.css";


function FeatureCard({icone, titre, description}) {


    return (

        <div className="feature-card">


            <div className="feature-icon">

                {icone}

            </div>


            <h3>

                {titre}

            </h3>


            <p>

                {description}

            </p>


        </div>

    );

}


export default FeatureCard;
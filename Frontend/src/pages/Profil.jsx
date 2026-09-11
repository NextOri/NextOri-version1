import { API_ROUTES_URL } from "../config/api";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

import {
    User,
    Mail,
    Globe,
    GraduationCap,
    Calendar,
    LogOut,
    ClipboardList,
    ArrowRight,
    BarChart3
} from "lucide-react";

import "../styles/Profil.css";
import FooterNavigation from "../components/FooterNavigation";
import { logout } from "../services/AuthService";

function Profil() {

    const navigate = useNavigate();

    const [utilisateur, setUtilisateur] = useState(() => {

        const user = localStorage.getItem("utilisateur");

        return user ? JSON.parse(user) : null;

    });

    const [nombreTests, setNombreTests] = useState(0);
    const [chargementTests, setChargementTests] = useState(true);




    const handleLogout = async () => {

    try {
        await logout();
    } finally {
        localStorage.removeItem("utilisateur");
        setUtilisateur(null);
        navigate("/connexion");
    }

   };

   useEffect(() => {

    const recupererNombreTests = async () => {

        try {

            const response = await fetch(
                `${API_ROUTES_URL}/historique-tests.php`,
                {
                    credentials: "include"
                }
            );

            const data = await response.json();

            if (data.success) {

                setNombreTests(
                    Array.isArray(data.data)
                        ? data.data.length
                        : 0
                );

            }

        } catch (error) {

            console.error(
                "Erreur récupération nombre de tests :",
                error
            );

        } finally {

            setChargementTests(false);

        }

    };

    recupererNombreTests();

}, []);

    const getInitiales = (nom) => {

    if (!nom) return "";

    const noms = nom.trim().split(" ");

    const premier = noms[0][0];

    const dernier = noms[noms.length - 1][0];

    return (premier + dernier).toUpperCase();

   };



 if (!utilisateur) {

    return (

        <div className="non-connecte-profil-page">


            <div className="profil-non-connecte">


                <div className="profil-non-connecte-icon">
                    ?
                </div>


                <h1>
                    Profil
                </h1>


                <p>
                    Vous devez être connecté pour accéder à votre profil.
                </p>



                <button
                    className="profil-login-button"
                    onClick={() => navigate("/connexion")}
                >
                    Se connecter
                </button>


            </div>

            <FooterNavigation />


        </div>

    );

   }



  return (

<div className="profile-page">


    <div className="profile-container">


        {/* En-tête profil */}

        <section className="profile-header">


            <div className="profile-avatar">

                {getInitiales(utilisateur.nom)}

            </div>


            <h1>
                {utilisateur.nom}
            </h1>


            <p>
                {utilisateur.email}
            </p>


        </section>




        {/* Informations personnelles */}

        <section className="profile-section">


            <h2>
                Informations personnelles
            </h2>



            <div className="info-item">

                <User />

                <div>
                    <span>Nom complet</span>
                    <strong>
                        {utilisateur.nom}
                    </strong>
                </div>

            </div>




            <div className="info-item">

                <Mail />

                <div>
                    <span>Email</span>
                    <strong>
                        {utilisateur.email}
                    </strong>
                </div>

            </div>




            <div className="info-item">

                <Globe />

                <div>
                    <span>Pays</span>
                    <strong>
                        {utilisateur.pays}
                    </strong>
                </div>

            </div>




            <div className="info-item">

                <GraduationCap />

                <div>
                    <span>Niveau d'étude</span>
                    <strong>
                        {utilisateur.niveau_etude}
                    </strong>
                </div>

            </div>




            <div className="info-item">

                <Calendar />

                <div>
                    <span>Membre depuis</span>
                    <strong>
                        {utilisateur.date_creation}
                    </strong>
                </div>

            </div>



        </section>

        <section className="profil-tests-history">

    <div className="profil-tests-history-header">

        <div className="profil-tests-history-title">

            <div className="profil-tests-history-icon">
                <ClipboardList />
            </div>

            <div>

                <span>
                    Orientation
                </span>

                <h2>
                    Mes tests d'orientation
                </h2>

            </div>

        </div>


        <div className="profil-tests-history-count">

            <strong>
                {chargementTests ? "—" : nombreTests}
            </strong>

            <span>
                {nombreTests === 1
                    ? "test effectué"
                    : "tests effectués"
                }
            </span>

        </div>

    </div>


    <div className="profil-tests-history-content">

        <div className="profil-tests-history-description">

            <BarChart3 />

            <p>
                Retrouvez vos résultats, vos scores RIASEC
                et vos recommandations d'orientation.
            </p>

        </div>


        <button
            className="profil-tests-history-button"
            onClick={() => navigate("/historique-tests")}
        >

            Voir l'historique de mes tests

            <ArrowRight />

        </button>

    </div>

</section>




        {/* Action */}

        <button
            className="logout-button"
            onClick={handleLogout}
        >

            <LogOut />

            Se déconnecter

        </button>

       



    </div>

   
       <FooterNavigation />

 </div>

 );

}


export default Profil;

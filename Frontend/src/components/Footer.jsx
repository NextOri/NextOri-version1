import React from "react";
import { Link } from "react-router-dom";

import {
    FaInstagram,
    FaLinkedin,
    FaFacebook,
    FaWhatsapp,
    FaSnapchat
} from "react-icons/fa";

import {
    FaTiktok,
    FaXTwitter
} from "react-icons/fa6";

import "../styles/Footer.css";


function Footer() {

    const reseauxSociaux = [
        {
            nom: "Instagram",
            url: "https://www.instagram.com/nextori2?utm_source=qr&igsi=MXIzODB6aDEwNnFlaA==",
            icone: FaInstagram
        },
        {
            nom: "LinkedIn",
            url: "https://www.linkedin.com/in/nextori-sénégal-361b76431",
            icone: FaLinkedin
        },
        {
            nom: "Facebook",
            url: "https://www.facebook.com/share/1EMXHGo4NU/",
            icone: FaFacebook
        },
        {
            nom: "WhatsApp",
            url: "https://chat.whatsapp.com/ClOq5el9jdPIVx7Vglq4F5?s=cl&p=a&ilr=2",
            icone: FaWhatsapp
        },
        {
            nom: "Snapchat",
            url: "https://www.snapchat.com/add/nextori7?share_id=d9cfIxtQqjo&locale=fr-FR",
            icone: FaSnapchat
        },
        {
            nom: "TikTok",
            url: "https://www.tiktok.com/@nextori07?_r=1&_t=ZS-99QeSoJ1Bvo",
            icone: FaTiktok
        },
        {
            nom: "X",
            url: "https://x.com/NextOrideov",
            icone: FaXTwitter
        }
    ];


    return (

        <footer className="site-footer">

            <div className="site-footer-container">


                {/* Identité */}

               <div className="site-footer-brand">

    <img
        src="/images/logo-nextori.jpg"
        alt="NextOri"
        className="footer-logo"
    />

    <p>
        Votre plateforme d'accompagnement
        à l'orientation académique et
        professionnelle.
    </p>

</div>


                {/* Navigation */}

                <div className="site-footer-links">

                    <h3>
                        Navigation
                    </h3>

                    <div className="site-footer-link-list">

                        <Link to="/">
                            Accueil
                        </Link>

                        <span className="footer-separator">
                            •
                        </span>

                        <Link to="/test">
                            Test RIASEC
                        </Link>

                        <span className="footer-separator">
                            •
                        </span>

                        <Link to="/metiers">
                            Métiers
                        </Link>

                        <span className="footer-separator">
                            •
                        </span>

                        <Link to="/filieres">
                            Formations
                        </Link>

                        <span className="footer-separator">
                            •
                        </span>

                        <Link to="/universite-catalogue">
                            Universités
                        </Link>

                    </div>

                </div>


                {/* Réseaux sociaux */}

                <div className="site-footer-social">

                    <h3>
                        Suivez-nous
                    </h3>

                    <div className="social-links">

                        {reseauxSociaux.map((reseau) => {

                            const Icone = reseau.icone;

                            return (

                                <a
                                    key={reseau.nom}
                                    href={reseau.url || "#"}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    aria-label={`NextOri sur ${reseau.nom}`}
                                >

                                    <Icone />

                                </a>

                            );

                        })}

                    </div>

                </div>


            </div>


            {/* Bas du footer */}

            <div className="site-footer-bottom">

                <p>
                    © 2026 NextOri - Tous droits réservés
                </p>

            </div>

        </footer>

    );

}


export default Footer;
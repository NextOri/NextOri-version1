import { NavLink, useNavigate } from "react-router-dom";
import "../styles/FooterNavigation.css";
import React from "react";
import {
    FaHome,
    FaClipboardList,
    FaBriefcase,
    FaGraduationCap,
    FaUniversity,
    FaComments,
    FaUser
} from "react-icons/fa";


function FooterNavigation() {

    const navigate = useNavigate();

    const handleProfileClick = () => {

        const utilisateur = localStorage.getItem("utilisateur");

        if (utilisateur) {

            navigate("/profil");

        } else {

            navigate("/connexion");

        }

    };

    return (

        <footer className="footer-navigation">


            {/* ACCUEIL */}
            <NavLink to="/dashboard">

                <span>
                    <FaHome />
                </span>

                <p>
                    Accueil
                </p>

            </NavLink>


            {/* TEST */}
            <NavLink to="/test">

                <span>
                    <FaClipboardList />
                </span>

                <p>
                    Test
                </p>

            </NavLink>


            {/* MÉTIERS */}
            <NavLink to="/metiers">

                <span>
                    <FaBriefcase />
                </span>

                <p>
                    Métiers
                </p>

            </NavLink>


            {/* FILIÈRES */}
            <NavLink to="/filieres">

                <span>
                    <FaGraduationCap />
                </span>

                <p>
                    Filières
                </p>

            </NavLink>


            {/* UNIVERSITÉS */}
            <NavLink to="/universite-catalogue">

                <span>
                    <FaUniversity />
                </span>

                <p>
                    Universités
                </p>

            </NavLink>


            {/* TÉMOIGNAGES */}
            <NavLink to="/temoignages">

                <span>
                    <FaComments />
                </span>

                <p>
                    Témoignages
                </p>

            </NavLink>


            {/* PROFIL */}
            <NavLink
                to="/profil"
                onClick={handleProfileClick}
            >

                <span>
                    <FaUser />
                </span>

                <p>
                    Profil
                </p>

            </NavLink>


        </footer>

    );

}


export default FooterNavigation;
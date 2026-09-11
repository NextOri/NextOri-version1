import { Link, useLocation, useNavigate } from "react-router-dom";
import { LogOut } from "lucide-react";

import "../styles/Navbar.css";
import { logout } from "../services/AuthService";

function Navbar() {

    const location = useLocation();
    const navigate = useNavigate();

    const handleLogout = async () => {

        try {
            await logout();
        } finally {
            localStorage.removeItem("utilisateur");
            navigate("/connexion");
        }

    };

    return (

        <nav className="navbar">

            {/* LOGO */}

            <Link
                to="/"
                className="navbar-logo"
                aria-label="NextOri - Accueil"
            >
                <img
                    src="/images/logo-nextori.jpg"
                    alt="NextOri"
                />
            </Link>


            {/* NAVIGATION */}

            <div className="navbar-actions">

                <div className="navbar-links">

                    <Link
                        to="/"
                        className={
                            location.pathname === "/"
                                ? "navbar-link active"
                                : "navbar-link"
                        }
                    >
                        Accueil
                    </Link>


                    <Link
                        to="/test"
                        className={
                            location.pathname === "/test"
                                ? "navbar-link active"
                                : "navbar-link"
                        }
                    >
                        Test
                    </Link>


                    <Link
                        to="/result"
                        className={
                            location.pathname === "/result"
                                ? "navbar-link active"
                                : "navbar-link"
                        }
                    >
                        Résultats
                    </Link>

                </div>


                <button
                    type="button"
                    className="navbar-logout"
                    onClick={handleLogout}
                >
                    <LogOut size={17} />

                    <span>
                        Déconnexion
                    </span>
                </button>

            </div>

        </nav>

    );

}

export default Navbar;
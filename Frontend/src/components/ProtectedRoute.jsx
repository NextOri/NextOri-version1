import { Navigate, Outlet, useLocation } from "react-router-dom";

function ProtectedRoute() {
    const location = useLocation();
    const utilisateur = localStorage.getItem("utilisateur");

    if (!utilisateur) {
        return (
            <Navigate
                to="/connexion"
                replace
                state={{ from: location }}
            />
        );
    }

    return <Outlet />;
}

export default ProtectedRoute;
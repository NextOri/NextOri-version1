import { BrowserRouter, Routes, Route } from "react-router-dom";

import Home from "./pages/Home";
import Test from "./pages/Test";
import Dashboard from "./pages/Dashboard";
import Result from "./pages/Result";
import ProfilRiasec from "./pages/Profil-Riasec";
import Formations from "./pages/Formations";
import Universites from "./pages/Universites";
import Metiers from "./pages/Metiers";
import MetierDetail from "./pages/MetierDetail";
import Filieres from "./pages/Filieres";
import FiliereDetail from "./pages/FiliereDetail";
import UniversiteCatalogue from "./pages/UniversiteCatalogue";
import UniversiteDetail from "./pages/UniversiteDetail";
import Inscription from "./pages/Inscription";
import Connexion from "./pages/Connexion";
import Profil from "./pages/Profil";
import ProtectedRoute from "./components/ProtectedRoute";
import HistoriqueTests from "./pages/HistoriqueTests";
import ResultatHistorique from "./pages/ResultatHistorique";
import Hesitation from "./pages/Hesitation";
import ResultatHesitation from "./pages/ResultatHesitation";
import DepartagerHesitation from "./pages/DepartagerHesitation";
import Avis from "./pages/Avis";
import Temoignages from "./pages/Temoignages";


function App() {

    return (

        
       
        <Routes>


<Route path="/" element={<Home />} />

<Route element={<ProtectedRoute />}>

    <Route path="/test" element={<Test />} />

    <Route path="/dashboard" element={<Dashboard />} />

    <Route path="/result" element={<Result />} />

    <Route path="/formations" element={<Formations />} />

    <Route path="/universites" element={<Universites />} />

    <Route path="/profil-riasec" element={<ProfilRiasec />} />

    <Route path="/metiers" element={<Metiers />} />

    <Route path="/metiers/:id_metier" element={<MetierDetail />} />

    <Route path="/filieres" element={<Filieres />} />

    <Route path="/filieres/:id_filiere" element={<FiliereDetail />} />

    <Route path="/universite-catalogue" element={<UniversiteCatalogue />} />

    <Route path="/universite-catalogue/:id_universite" element={<UniversiteDetail />} />

    <Route path="/profil" element={<Profil />} />

    <Route path="/historique-tests" element={<HistoriqueTests />} />
    
    <Route path="/resultat-test/:id_test" element={<ResultatHistorique />} />

    <Route path="/hesitation" element={<Hesitation />} />

    <Route path="/resultat-hesitation" element={<ResultatHesitation />} />

    <Route path="/hesitation/departager" element={<DepartagerHesitation />} />

    <Route path="/avis" element={<Avis />} />

    <Route path="/temoignages" element={<Temoignages />} />

    </Route>

<Route path="/inscription" element={<Inscription />} />

<Route path="/connexion" element={<Connexion />} />

            


        </Routes>
      

      
    );

}

export default App;
import { API_ROUTES_URL } from "../config/api";
import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";

import FooterNavigation from "../components/FooterNavigation";

import "../styles/UniversiteCatalogue.css";

import { afficherTypeUniversite } from "../utils/universiteUtils";
import { enregistrerAction } from "../services/historiqueService";

import {
  FaUniversity,
  FaSearch,
  FaMapMarkerAlt,
  FaArrowRight
} from "react-icons/fa";


const API_URL =
  `${API_ROUTES_URL}/universite-catalogue.php`;


export default function UniversiteCatalogue() {

  const navigate = useNavigate();

  const [universites, setUniversites] = useState([]);

  const [loading, setLoading] = useState(true);

  const [search, setSearch] = useState(
  () => sessionStorage.getItem("universites_search") || ""
   );

  const [selectedType, setSelectedType] = useState(
  () => sessionStorage.getItem("universites_type") || ""
   );

  const [selectedRegion, setSelectedRegion] = useState(
  () => sessionStorage.getItem("universites_region") || ""
  );


  useEffect(() => {

    fetch(API_URL)

      .then((response) => response.json())

      .then((data) => {

        if (data.success) {

          setUniversites(data.data);

        }

      })

      .catch((error) =>
        console.error(
          "Erreur récupération universités :",
          error
        )
      )

      .finally(() => setLoading(false));

  }, []);

  useEffect(() => {

  sessionStorage.setItem(
    "universites_search",
    search
  );

}, [search]);


useEffect(() => {

  sessionStorage.setItem(
    "universites_type",
    selectedType
  );

}, [selectedType]);


useEffect(() => {

  sessionStorage.setItem(
    "universites_region",
    selectedRegion
  );

}, [selectedRegion]);


  const normaliserTexte = (texte) => {

    return texte
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .trim();

  };


  const regions = useMemo(() => {

    return [
      ...new Set(
        universites.map((u) => u.region)
      )
    ].sort();

  }, [universites]);


  const universitesFiltrees = universites.filter((universite) => {

    const recherche =
      normaliserTexte(universite.nom).includes(
        normaliserTexte(search)
      ) ||

      normaliserTexte(universite.description).includes(
        normaliserTexte(search)
      );


    const type =
      selectedType === "" ||
      universite.type === selectedType;


    const region =
      selectedRegion === "" ||
      universite.region === selectedRegion;


    return recherche && type && region;

  });


  /*
   * ================================
   * CHARGEMENT
   * ================================
   */

  if (loading) {

  return (

    <div className="universites-loading">

      <div className="universites-loading-spinner"></div>

      <h2>
        Chargement des universités...
      </h2>

      <p>
        Veuillez patienter quelques instants.
      </p>

    </div>

  );

}


  return (

    <div className="no-universite-catalogue-page">


      {/* ================================
          EN-TÊTE
      ================================= */}

      <div className="no-universite-catalogue-header">

        <div className="catalogue-header-icon">

          <FaUniversity />

        </div>


        <h1>
          Explorer les universités
        </h1>


        <p>
          Trouvez l'établissement qui correspond
          à votre projet académique.
        </p>

      </div>



      {/* ================================
          RECHERCHE ET FILTRES
      ================================= */}

      <div className="no-universite-catalogue-toolbar">


        <div className="search-container">

          <FaSearch className="search-icon" />

          <input
            type="text"
            placeholder="Rechercher une université..."
            value={search}
            onChange={(e) =>
              setSearch(e.target.value)
            }
            className="no-universite-catalogue-search"
          />

        </div>



        <div className="filter-container">

          <select
            value={selectedType}
            onChange={(e) =>
              setSelectedType(e.target.value)
            }
            className="no-universite-catalogue-filter"
          >

            <option value="">
              Tous les types
            </option>

            <option value="publique">
              Publique
            </option>

            <option value="privee">
              Privée
            </option>

            <option value="parapublique">
              Parapublique
            </option>

          </select>



          <select
            value={selectedRegion}
            onChange={(e) =>
              setSelectedRegion(e.target.value)
            }
            className="no-universite-catalogue-filter"
          >

            <option value="">
              Toutes les régions
            </option>


            {regions.map((region) => (

              <option
                key={region}
                value={region}
              >

                {region}

              </option>

            ))}

          </select>

        </div>

      </div>



      {/* ================================
          COMPTEUR
      ================================= */}

      <div className="no-universite-catalogue-counter">

        <FaUniversity />

        <span>

          {universitesFiltrees.length}

          {" "}

          université
          {universitesFiltrees.length > 1 ? "s" : ""}

          {" "}

          trouvée
          {universitesFiltrees.length > 1 ? "s" : ""}

        </span>

      </div>



      {/* ================================
          GRILLE
      ================================= */}

      <div className="no-universite-catalogue-grid">

  {universitesFiltrees.length > 0 ? (

    universitesFiltrees.map((universite) => (

      <div
        key={universite.id_universite}
        className="no-universite-catalogue-card"
      >

        {/* LOGO */}

        <div className="no-universite-catalogue-logo">

          {universite.logo ? (

            <img
              src={universite.logo}
              alt={`Logo ${universite.nom}`}
            />

          ) : (

            <FaUniversity />

          )}

        </div>


        {/* NOM */}

        <h2>
          {universite.nom}
        </h2>


        {/* DESCRIPTION */}

        <p className="no-universite-catalogue-description">

          {universite.description}

        </p>


        {/* TYPE */}

        <span
          className={
            `no-universite-catalogue-type ${universite.type}`
          }
        >

          {afficherTypeUniversite(
            universite.type
          )}

        </span>


        {/* LOCALISATION */}

        <div className="no-universite-catalogue-localisation">

          <FaMapMarkerAlt />

          <span>

            {universite.ville}
            {" • "}
            {universite.region}

          </span>

        </div>


        {/* BOUTON */}

        <button
          className="no-universite-catalogue-button"

          onClick={async () => {

            await enregistrerAction(
              `UNIVERSITE_CONSULTEE: ${universite.nom}`
            );

            navigate(
              `/universite-catalogue/${universite.id_universite}`
            );

          }}
        >

          <span>
            Voir les détails
          </span>

          <FaArrowRight />

        </button>

      </div>

    ))

  ) : (

    <div className="no-universite-catalogue-empty">

      <FaUniversity />

      <h2>
        Aucune université trouvée
      </h2>

      <p>
        Essayez un autre nom, un autre type
        ou une autre région.
      </p>

    </div>

  )}

</div>



      {/* ================================
          FOOTER
      ================================= */}

      <FooterNavigation />


    </div>

  );

}

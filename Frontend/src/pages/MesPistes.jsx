import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";

import {
    FaPlus,
    FaBookmark,
    FaBriefcase,
    FaGraduationCap,
    FaSearch,
    FaTimes,
    FaArrowRight,
    FaTrash,
    FaCompass,
    FaCheck
} from "react-icons/fa";

import "../styles/MesPistes.css";

import FooterNavigation from "../components/FooterNavigation";

import {
    getPistes,
    ajouterPiste,
    retirerPiste
} from "../services/PistesService";

import { API_ROUTES_URL } from "../config/api";



function MesPistes() {

    const navigate = useNavigate();

    const [pistes, setPistes] = useState([]);

    const [metiers, setMetiers] = useState([]);
    const [filieres, setFilieres] = useState([]);

    const [chargement, setChargement] = useState(true);
    const [chargementCatalogue, setChargementCatalogue] = useState(false);

    const [modalOuverte, setModalOuverte] = useState(false);

    const [typeAjout, setTypeAjout] = useState("metier");

    const [recherche, setRecherche] = useState("");

    const [selection, setSelection] = useState([]);
    const [selectionComparaison, setSelectionComparaison] = useState([]);

    const [actionEnCours, setActionEnCours] = useState(false);

    const [messageErreur, setMessageErreur] = useState("");


    /* =====================================================
       CHARGEMENT DES PISTES
    ===================================================== */

    const chargerPistes = async () => {

        try {

            setChargement(true);
            setMessageErreur("");

            const resultat = await getPistes();

            setPistes(
                Array.isArray(resultat.data)
                    ? resultat.data
                    : []
            );

        } catch (error) {

            console.error(
                "Erreur chargement pistes :",
                error
            );

            setMessageErreur(
                error.message ||
                "Impossible de charger tes pistes."
            );

        } finally {

            setChargement(false);

        }

    };


    useEffect(() => {

        chargerPistes();

    }, []);


    /* =====================================================
       CHARGEMENT DES CATALOGUES POUR LE BOUTON +
    ===================================================== */

    const ouvrirAjout = async () => {

        setModalOuverte(true);
        setRecherche("");
        setSelection([]);
        setMessageErreur("");

        if (
            metiers.length > 0 &&
            filieres.length > 0
        ) {
            return;
        }

        try {

            setChargementCatalogue(true);

            const [
                responseMetiers,
                responseFilieres
            ] = await Promise.all([

                fetch(`${API_ROUTES_URL}/metiers`),

                fetch(`${API_ROUTES_URL}/filiere`)

            ]);

            const [
                dataMetiers,
                dataFilieres
            ] = await Promise.all([

                responseMetiers.json(),

                responseFilieres.json()

            ]);

            if (dataMetiers.success) {

                setMetiers(
                    Array.isArray(dataMetiers.data)
                        ? dataMetiers.data
                        : []
                );

            }

            if (dataFilieres.success) {

                setFilieres(
                    Array.isArray(dataFilieres.data)
                        ? dataFilieres.data
                        : []
                );

            }

        } catch (error) {

            console.error(
                "Erreur chargement catalogue :",
                error
            );

            setMessageErreur(
                "Impossible de charger les possibilités."
            );

        } finally {

            setChargementCatalogue(false);

        }

    };


    /* =====================================================
       PISTES EXISTANTES
    ===================================================== */

    const idsMetiers = useMemo(
        () =>
            new Set(
                pistes
                    .filter(
                        piste =>
                            piste.type_piste === "metier"
                    )
                    .map(
                        piste =>
                            Number(piste.id_metier)
                    )
            ),
        [pistes]
    );


    const idsFilieres = useMemo(
        () =>
            new Set(
                pistes
                    .filter(
                        piste =>
                            piste.type_piste === "filiere"
                    )
                    .map(
                        piste =>
                            Number(piste.id_filiere)
                    )
            ),
        [pistes]
    );


    /* =====================================================
       FILTRAGE DU CATALOGUE
    ===================================================== */

    const normaliser = (texte = "") =>
        texte
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .toLowerCase()
            .trim();


    const catalogueActuel =
        typeAjout === "metier"
            ? metiers
            : filieres;


    const catalogueFiltre = catalogueActuel
        .filter((item) => {

            const nom =
                normaliser(item.nom);

            return nom.includes(
                normaliser(recherche)
            );

        })
        .slice(0, 20);


    /* =====================================================
       SÉLECTION
    ===================================================== */

    const cleSelection = (type, id) =>
        `${type}-${id}`;


    const estSelectionne = (type, id) =>
        selection.includes(
            cleSelection(type, id)
        );


    const basculerSelection = (item) => {

        const id =
            typeAjout === "metier"
                ? item.id_metier
                : item.id_filiere;

        const cle =
            cleSelection(
                typeAjout,
                id
            );

        setSelection((ancienne) => {

            if (ancienne.includes(cle)) {

                return ancienne.filter(
                    valeur =>
                        valeur !== cle
                );

            }

            return [
                ...ancienne,
                cle
            ];

        });

    };


    /* =====================================================
       AJOUT DES PISTES SÉLECTIONNÉES
    ===================================================== */

    const ajouterSelection = async () => {

        if (
            selection.length === 0 ||
            actionEnCours
        ) {
            return;
        }

        try {

            setActionEnCours(true);
            setMessageErreur("");

            for (const cle of selection) {

                const [type, id] =
                    cle.split("-");

                await ajouterPiste(
                    type,
                    Number(id)
                );

            }

            await chargerPistes();

            setSelection([]);

            setModalOuverte(false);

        } catch (error) {

            console.error(
                "Erreur ajout pistes :",
                error
            );

            setMessageErreur(
                error.message ||
                "Impossible d'ajouter les pistes."
            );

        } finally {

            setActionEnCours(false);

        }

    };


    /* =====================================================
       RETRAIT
    ===================================================== */

    const supprimerPiste = async (piste) => {

        if (actionEnCours) {
            return;
        }

        try {

            setActionEnCours(true);
            setMessageErreur("");

            await retirerPiste(
                piste.id_piste
            );

            setPistes(
                anciennes =>
                    anciennes.filter(
                        item =>
                            item.id_piste !==
                            piste.id_piste
                    )
            );

        } catch (error) {

            console.error(
                "Erreur retrait piste :",
                error
            );

            setMessageErreur(
                error.message ||
                "Impossible de retirer cette piste."
            );

        } finally {

            setActionEnCours(false);

        }

    };


    /* =====================================================
       DONNÉES AFFICHAGE
    ===================================================== */

    const pistesMetiers =
        pistes.filter(
            piste =>
                piste.type_piste === "metier"
        );

    const pistesFilieres =
        pistes.filter(
            piste =>
                piste.type_piste === "filiere"
        );



    /* =====================================================
       SÉLECTION POUR COMPARAISON J'HÉSITE
    ===================================================== */

    const basculerSelectionComparaison = (piste) => {
        const dejaSelectionnee = selectionComparaison.some(
            (item) => Number(item.id_piste) === Number(piste.id_piste)
        );

        if (dejaSelectionnee) {
            setSelectionComparaison((ancienne) => ancienne.filter(
                (item) => Number(item.id_piste) !== Number(piste.id_piste)
            ));
            setMessageErreur("");
            return;
        }

        if (selectionComparaison.length >= 3) {
            setMessageErreur("Tu peux comparer deux ou trois pistes à la fois.");
            return;
        }

        if (selectionComparaison.length > 0 && selectionComparaison[0].type_piste !== piste.type_piste) {
            setMessageErreur("Compare les métiers entre eux ou les filières entre elles.");
            return;
        }

        setMessageErreur("");
        setSelectionComparaison((ancienne) => [...ancienne, piste]);
    };

   const ouvrirComparaison = () => {
        if (selectionComparaison.length < 2 || selectionComparaison.length > 3 || actionEnCours) {
            setMessageErreur("Sélectionne deux ou trois pistes du même type pour les comparer.");
            return;
        }

        const types = [...new Set(
            selectionComparaison.map((piste) => piste.type_piste)
        )];

        if (types.length !== 1) {
            setMessageErreur("Compare les métiers entre eux ou les filières entre elles, sans mélanger les types.");
            return;
        }

        const typeChoix = types[0];

        navigate("/comparaison-pistes/questions", {
            state: {
                typeChoix,
                pistesSelectionnees: selectionComparaison,
                id_pistes: selectionComparaison.map((piste) => Number(piste.id_piste)),
            },
        });
    };


    /* =====================================================
       CARTE PISTE
    ===================================================== */

    const afficherPiste = (piste) => {

        const estMetier =
            piste.type_piste === "metier";

        const donnees =
            estMetier
                ? piste.metier
                : piste.filiere;

        if (!donnees) {
            return null;
        }

        const id =
            estMetier
                ? piste.id_metier
                : piste.id_filiere;

        return (

            <article
                className="mes-pistes-card"
                key={piste.id_piste}
            >

                <div
                    className={`mes-pistes-card-icon ${
                        estMetier
                            ? "metier"
                            : "filiere"
                    }`}
                >

                    {estMetier
                        ? <FaBriefcase />
                        : <FaGraduationCap />
                    }

                </div>


                <div className="mes-pistes-card-content">

                    <span className="mes-pistes-card-type">

                        {estMetier
                            ? "Métier"
                            : "Filière"
                        }

                    </span>

                    <h3>
                        {donnees.nom}
                    </h3>

                    {estMetier && donnees.profil_riasec && (

                        <span className="mes-pistes-card-profile">

                            Profil RIASEC :
                            <strong>
                                {donnees.profil_riasec}
                            </strong>

                        </span>

                    )}

                    {!estMetier && donnees.domaine && (

                        <span className="mes-pistes-card-profile">
                            {donnees.domaine}
                        </span>

                    )}

                    {donnees.description && (

                        <p>
                            {donnees.description}
                        </p>

                    )}

                    <div className="mes-pistes-card-actions">

                        <button
                            type="button"
                            className={`mes-pistes-compare-select ${selectionComparaison.some((item) => Number(item.id_piste) === Number(piste.id_piste)) ? "selected" : ""}`}
                            onClick={() => basculerSelectionComparaison(piste)}
                            aria-pressed={selectionComparaison.some((item) => Number(item.id_piste) === Number(piste.id_piste))}
                        >
                            {selectionComparaison.some((item) => Number(item.id_piste) === Number(piste.id_piste)) ? "Retirer de la comparaison" : "Comparer cette piste"}
                        </button>

                        <button
                            type="button"
                            className="mes-pistes-explore"
                            onClick={() => {

                                if (estMetier) {

                                    navigate(
                                        `/metiers/${id}`
                                    );

                                } else {

                                    navigate(
                                        `/filieres/${id}`
                                    );

                                }

                            }}
                        >

                            Explorer

                            <FaArrowRight />

                        </button>


                        <button
                            type="button"
                            className="mes-pistes-remove"
                            onClick={() =>
                                supprimerPiste(piste)
                            }
                            disabled={actionEnCours}
                        >

                            <FaTrash />

                            Retirer

                        </button>

                    </div>

                </div>

            </article>

        );

    };


    /* =====================================================
       RENDU
    ===================================================== */

    return (

        <div className="mes-pistes-page">


            {/* =================================================
                HERO
            ================================================= */}

            <header className="mes-pistes-hero">

                <div className="mes-pistes-hero-decoration"></div>

                <div className="mes-pistes-hero-content">

                    <span className="mes-pistes-eyebrow">
                        MON ESPACE NEXTORI
                    </span>

                    <div className="mes-pistes-title-line">

                        <div className="mes-pistes-title-icon">
                            <FaBookmark />
                        </div>

                        <div>

                            <h1>
                                Mes pistes
                            </h1>

                            <p>
                                Les possibilités que tu envisages
                                pour ton avenir.
                            </p>

                        </div>

                    </div>


                    <div className="mes-pistes-hero-bottom">

                        <div>

                            <strong>
                                {pistes.length}
                            </strong>

                            <span>
                                pistes actives
                            </span>

                        </div>

                    </div>

                </div>

            </header>


            {/* =================================================
                CONTENU
            ================================================= */}

            <main className="mes-pistes-main">


                {messageErreur && (

                    <div className="mes-pistes-error">
                        {messageErreur}
                    </div>

                )}


                {/* =================================================
                    INTRO
                ================================================= */}

                <section className="mes-pistes-intro">

                    <div className="mes-pistes-intro-icon">
                        <FaCompass />
                    </div>

                    <div>

                        <span>
                            UNE ÉTAPE POUR AVANCER
                        </span>

                        <h2>
                            Garde seulement les possibilités
                            qui méritent vraiment ta réflexion.
                        </h2>

                        <p>
                            Tes pistes ne sont pas une liste de favoris.
                            Ce sont les métiers ou les filières que tu
                            envisages sérieusement pour la suite.
                        </p>

                    </div>

                </section>


                {/* =================================================
                    BOUTON AJOUT
                ================================================= */}

                <div className="mes-pistes-add-zone">

                    <div>

                        <span>
                            Autant de pistes que nécessaire
                        </span>

                        <strong>
                            Classe-les par métiers et filières, puis sélectionne jusqu'à 3 options du même type pour les comparer.
                        </strong>

                    </div>


                    <button
                        type="button"
                        className="mes-pistes-add-button"
                        onClick={ouvrirAjout}
                    >

                        <FaPlus />

                        Ajouter une piste

                    </button>

                </div>


                {/* =================================================
                    CHARGEMENT
                ================================================= */}

                {chargement ? (

                    <div className="mes-pistes-loading">

                        <div className="mes-pistes-spinner"></div>

                        <p>
                            Chargement de tes pistes...
                        </p>

                    </div>

                ) : pistes.length === 0 ? (

                    /* =================================================
                       ÉTAT VIDE
                    ================================================= */

                    <section className="mes-pistes-empty">

                        <div className="mes-pistes-empty-icon">
                            <FaBookmark />
                        </div>

                        <span>
                            TON ESPACE EST PRÊT
                        </span>

                        <h2>
                            Commence par garder
                            quelques possibilités.
                        </h2>

                        <p>
                            Ajoute un métier ou une filière
                            qui t'intéresse. Tu pourras ensuite
                            les retrouver ici pour mieux avancer.
                        </p>

                        <button
                            type="button"
                            onClick={ouvrirAjout}
                        >

                            <FaPlus />

                            Ajouter ma première piste

                        </button>

                    </section>

                ) : (

                    <div className="mes-pistes-sections">


                        {/* =================================================
                            MÉTIERS
                        ================================================= */}

                        {pistesMetiers.length > 0 && (

                            <section className="mes-pistes-section">

                                <div className="mes-pistes-section-header">

                                    <div>

                                        <span>
                                            MES POSSIBILITÉS
                                        </span>

                                        <h2>
                                            Métiers
                                        </h2>

                                    </div>

                                    <div className="mes-pistes-count">
                                        {pistesMetiers.length}
                                    </div>

                                </div>


                                <div className="mes-pistes-grid">

                                    {pistesMetiers.map(
                                        afficherPiste
                                    )}

                                </div>

                            </section>

                        )}


                        {/* =================================================
                            FILIÈRES
                        ================================================= */}

                        {pistesFilieres.length > 0 && (

                            <section className="mes-pistes-section">

                                <div className="mes-pistes-section-header">

                                    <div>

                                        <span>
                                            MES POSSIBILITÉS
                                        </span>

                                        <h2>
                                            Filières
                                        </h2>

                                    </div>

                                    <div className="mes-pistes-count">
                                        {pistesFilieres.length}
                                    </div>

                                </div>


                                <div className="mes-pistes-grid">

                                    {pistesFilieres.map(
                                        afficherPiste
                                    )}

                                </div>

                            </section>

                        )}

                    </div>

                )}


                {selectionComparaison.length > 0 && (
                    <section className="mes-pistes-compare-bar" aria-live="polite">
                        <div>
                            <strong>{selectionComparaison.length} piste(s) sélectionnée(s)</strong>
                            <p>{selectionComparaison.length < 2 ? "Sélectionne encore une piste du même type." : "Tu peux maintenant examiner les différences entre ces pistes."}</p>
                            <div className="mes-pistes-compare-chips">
                                {selectionComparaison.map((piste) => (
                                    <span key={piste.id_piste}>{piste.type_piste === "metier" ? piste.metier?.nom : piste.filiere?.nom}</span>
                                ))}
                            </div>
                        </div>
                        <div className="mes-pistes-compare-actions">
                            <button type="button" className="mes-pistes-compare-clear" onClick={() => setSelectionComparaison([])}>Effacer</button>
                            <button type="button" className="mes-pistes-compare-go" onClick={ouvrirComparaison} disabled={selectionComparaison.length < 2 || actionEnCours}>
                                Comparer les pistes <FaArrowRight />
                            </button>
                        </div>
                    </section>
                )}

                {/* =================================================
                    NOTE NEXTORI
                ================================================= */}

                {pistes.length > 0 && (

                    <section className="mes-pistes-next-step">

                        <div className="mes-pistes-next-step-icon">
                            <FaCompass />
                        </div>

                        <div>

                            <span>
                                PROCHAINE ÉTAPE
                            </span>

                            <h2>
                                Comprendre tes possibilités
                            </h2>

                            <p>
                                Lorsque tu hésites entre plusieurs
                                pistes du même type, NextOri pourra
                                t'aider à les comparer et à comprendre
                                ce qui distingue réellement tes options.
                            </p>

                        </div>

                    </section>

                )}

            </main>


            {/* =================================================
                MODALE AJOUT
            ================================================= */}

            {modalOuverte && (

                <div
                    className="mes-pistes-modal-overlay"
                    onMouseDown={(event) => {

                        if (
                            event.target ===
                            event.currentTarget
                        ) {
                            setModalOuverte(false);
                        }

                    }}
                >

                    <div className="mes-pistes-modal">

                        <div className="mes-pistes-modal-header">

                            <div>

                                <span>
                                    AJOUTER UNE POSSIBILITÉ
                                </span>

                                <h2>
                                    Quelle piste veux-tu garder ?
                                </h2>

                                <p>
                                    Tu peux ajouter plusieurs pistes. La limite de 3 s'appliquera uniquement lors de la comparaison.
                                </p>

                            </div>


                            <button
                                type="button"
                                onClick={() =>
                                    setModalOuverte(false)
                                }
                                aria-label="Fermer"
                            >

                                <FaTimes />

                            </button>

                        </div>


                        <div className="mes-pistes-tabs">

                            <button
                                type="button"
                                className={
                                    typeAjout === "metier"
                                        ? "active"
                                        : ""
                                }
                                onClick={() => {

                                    setTypeAjout("metier");
                                    setRecherche("");
                                    setSelection([]);

                                }}
                            >

                                <FaBriefcase />

                                Métiers

                            </button>


                            <button
                                type="button"
                                className={
                                    typeAjout === "filiere"
                                        ? "active"
                                        : ""
                                }
                                onClick={() => {

                                    setTypeAjout("filiere");
                                    setRecherche("");
                                    setSelection([]);

                                }}
                            >

                                <FaGraduationCap />

                                Filières

                            </button>

                        </div>


                        <div className="mes-pistes-search">

                            <FaSearch />

                            <input
                                type="text"
                                placeholder={
                                    typeAjout === "metier"
                                        ? "Rechercher un métier..."
                                        : "Rechercher une filière..."
                                }
                                value={recherche}
                                onChange={(event) =>
                                    setRecherche(
                                        event.target.value
                                    )
                                }
                            />

                        </div>


                        {chargementCatalogue ? (

                            <div className="mes-pistes-modal-loading">

                                <div className="mes-pistes-spinner"></div>

                                Chargement...

                            </div>

                        ) : (

                            <div className="mes-pistes-selection-list">

                                {catalogueFiltre.map((item) => {

                                    const id =
                                        typeAjout === "metier"
                                            ? item.id_metier
                                            : item.id_filiere;

                                    const dejaPresent =
                                        typeAjout === "metier"
                                            ? idsMetiers.has(
                                                Number(id)
                                            )
                                            : idsFilieres.has(
                                                Number(id)
                                            );

                                    const choisi =
                                        estSelectionne(
                                            typeAjout,
                                            id
                                        );
                                    return (

                                        <button
                                            type="button"
                                            key={id}
                                            className={`mes-pistes-option ${
                                                choisi
                                                    ? "selected"
                                                    : ""
                                            } ${
                                                dejaPresent
                                                    ? "already"
                                                    : ""
                                            }`}
                                            onClick={() => {

                                                if (
                                                    !dejaPresent
                                                ) {
                                                    basculerSelection(item);
                                                }

                                            }}
                                            disabled={
                                                dejaPresent
                                            }
                                        >

                                            <span className="mes-pistes-option-icon">

                                                {typeAjout === "metier"
                                                    ? <FaBriefcase />
                                                    : <FaGraduationCap />
                                                }

                                            </span>


                                            <span className="mes-pistes-option-content">

                                                <strong>
                                                    {item.nom}
                                                </strong>

                                                {typeAjout === "metier" &&
                                                    item.secteur && (

                                                        <small>
                                                            {item.secteur}
                                                        </small>

                                                    )}

                                                {typeAjout === "filiere" &&
                                                    item.domaine && (

                                                        <small>
                                                            {item.domaine}
                                                        </small>

                                                    )}

                                            </span>


                                            <span className="mes-pistes-option-check">

                                                {dejaPresent
                                                    ? "Déjà ajoutée"
                                                    : choisi
                                                        ? <FaCheck />
                                                        : ""
                                                }

                                            </span>

                                        </button>

                                    );

                                })}


                                {catalogueFiltre.length === 0 && (

                                    <div className="mes-pistes-no-result">

                                        Aucun résultat trouvé.

                                    </div>

                                )}

                            </div>

                        )}


                        <div className="mes-pistes-modal-footer">

                            <button
                                type="button"
                                className="mes-pistes-modal-cancel"
                                onClick={() =>
                                    setModalOuverte(false)
                                }
                            >
                                Annuler
                            </button>


                            <button
                                type="button"
                                className="mes-pistes-modal-confirm"
                                disabled={
                                    selection.length === 0 ||
                                    actionEnCours
                                }
                                onClick={ajouterSelection}
                            >

                                {actionEnCours
                                    ? "Ajout..."
                                    : `Ajouter${
                                        selection.length
                                            ? ` (${selection.length})`
                                            : ""
                                    }`
                                }

                            </button>

                        </div>

                    </div>

                </div>

            )}


            <FooterNavigation />

        </div>

    );

}


export default MesPistes;
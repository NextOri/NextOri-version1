import { useEffect, useState } from "react";
import {
    FaBookmark,
    FaRegBookmark
} from "react-icons/fa";

import {
    verifierPiste,
    ajouterPiste,
    retirerPiste
} from "../services/PistesService";

import "../styles/PisteButton.css";


function PisteButton({
    typePiste,
    id,
    className = ""
}) {

    const [piste, setPiste] = useState(null);
    const [chargement, setChargement] = useState(true);
    const [actionEnCours, setActionEnCours] = useState(false);
    const [erreur, setErreur] = useState("");


    /*
     * Vérifier l'état actuel
     */
    useEffect(() => {

        let actif = true;

        async function verifier() {

            try {

                setChargement(true);

                const resultat =
                    await verifierPiste(
                        typePiste,
                        id
                    );

                if (actif) {

                    setPiste(
                        resultat.existe
                            ? resultat.data
                            : null
                    );

                }

            } catch (error) {

                console.error(
                    "Erreur vérification piste :",
                    error
                );

                if (actif) {

                    setErreur(
                        "Impossible de vérifier la piste."
                    );

                }

            } finally {

                if (actif) {

                    setChargement(false);

                }

            }

        }

        verifier();

        return () => {

            actif = false;

        };

    }, [typePiste, id]);


    /*
     * Ajouter / retirer
     */
    const handleClick = async () => {

        if (actionEnCours) {
            return;
        }

        try {

            setErreur("");
            setActionEnCours(true);

            if (piste) {

                await retirerPiste(
                    piste.id_piste
                );

                setPiste(null);

            } else {

                const resultat =
                    await ajouterPiste(
                        typePiste,
                        id
                    );

                if (resultat?.data) {

                    setPiste(
                        resultat.data
                    );

                }

            }

        } catch (error) {

            console.error(
                "Erreur action piste :",
                error
            );

            setErreur(
                error.message ||
                "Une erreur est survenue."
            );

        } finally {

            setActionEnCours(false);

        }

    };


    if (chargement) {

        return (
            <button
                type="button"
                className={`piste-button piste-button-loading ${className}`}
                disabled
            >
                Vérification...
            </button>
        );

    }


    return (

        <div className={`piste-button-wrapper ${className}`}>

            <button
                type="button"
                className={`piste-button ${
                    piste
                        ? "piste-button-active"
                        : "piste-button-inactive"
                }`}
                onClick={handleClick}
                disabled={actionEnCours}
                title={
                    piste
                        ? "Retirer de mes pistes"
                        : "Ajouter à mes pistes"
                }
            >

                {piste ? (
                    <FaBookmark />
                ) : (
                    <FaRegBookmark />
                )}

                <span>
                    {actionEnCours
                        ? "Traitement..."
                        : piste
                            ? "Dans mes pistes"
                            : "Ajouter à mes pistes"
                    }
                </span>

            </button>

            {erreur && (

                <small className="piste-button-error">
                    {erreur}
                </small>

            )}

        </div>

    );

}

export default PisteButton;
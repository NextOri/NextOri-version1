import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { FaStar } from "react-icons/fa";
import { envoyerAvis } from "../services/avisService";
import { enregistrerAction } from "../services/historiqueService";
import "../styles/Avis.css";

function Avis() {
    const navigate = useNavigate();

    const [note, setNote] = useState(0);
    const [survol, setSurvol] = useState(0);
    const [commentaire, setCommentaire] = useState("");
    const [afficher, setAfficher] = useState(false);
    const [envoi, setEnvoi] = useState(false);
    const [erreur, setErreur] = useState("");
    const [envoye, setEnvoye] = useState(false);

    async function handleSubmit(event) {
        event.preventDefault();

        setErreur("");

        if (note === 0) {
            setErreur("Veuillez attribuer une note.");
            return;
        }

        if (commentaire.trim() === "") {
            setErreur("Veuillez écrire un commentaire.");
            return;
        }

        try {
            setEnvoi(true);

            await envoyerAvis(
                note,
                commentaire.trim(),
                afficher
            );

            await enregistrerAction("AVIS_DONNE");

            setEnvoye(true);
        } catch (error) {
            console.error(error);

            setErreur(
                error.message || "Une erreur est survenue."
            );
        } finally {
            setEnvoi(false);
        }
    }

    /*
     * Écran affiché après l'envoi réussi
     */
    if (envoye) {
        return (
            <div className="nextori-avis-page">

                <main className="nextori-avis-success">

                    <div className="nextori-avis-success-icon">
                        <FaStar />
                    </div>

                    <span className="nextori-avis-success-label">
                        AVIS ENVOYÉ
                    </span>

                    <h1>
                        Merci pour ton retour !
                    </h1>

                    <p>
                        Ton avis nous aide à améliorer NextOri
                        et à offrir une meilleure expérience aux
                        étudiants qui nous rejoindront.
                    </p>

                    <button
                        type="button"
                        className="nextori-avis-success-button"
                        onClick={() => navigate("/dashboard")}
                    >
                        Retour au tableau de bord
                    </button>

                </main>

            </div>
        );
    }

    return (
        <div className="nextori-avis-page">

            {/* =========================
                HEADER
            ========================== */}
            <header className="nextori-avis-header">

    <button
        type="button"
        className="nextori-avis-back"
        onClick={() => navigate("/dashboard")}
    >
        <span className="nextori-avis-back-icon">
            ←
        </span>

        <span>
            Retour
        </span>
    </button>

    <div className="nextori-avis-brand">
        NextOri
    </div>

    <div className="nextori-avis-header-space" />

</header>


            {/* =========================
                CONTENU PRINCIPAL
            ========================== */}
            <main className="nextori-avis-main">

                {/* Introduction */}
                <section className="nextori-avis-intro">

                    <span className="nextori-avis-label">
                        TON EXPÉRIENCE
                    </span>

                    <h1>
                        Ton avis compte.
                    </h1>

                    <p>
                        Tu viens d'utiliser NextOri.
                        Prends quelques secondes pour nous dire
                        ce que tu en as pensé.
                    </p>

                </section>


                {/* Formulaire */}
                <form
                    className="nextori-avis-card"
                    onSubmit={handleSubmit}
                >

                    {/* =========================
                        NOTE
                    ========================== */}
                    <section className="nextori-avis-rating-section">

                        <div className="nextori-avis-section-heading">

                            <span className="nextori-avis-step">
                                01
                            </span>

                            <div>
                                <h2>
                                    Comment évalues-tu ton expérience ?
                                </h2>

                                <p>
                                    Une note de 1 à 5 étoiles.
                                </p>
                            </div>

                        </div>


                        <div
                            className="nextori-avis-stars"
                            onMouseLeave={() => setSurvol(0)}
                        >

                            {[1, 2, 3, 4, 5].map((etoile) => (

                                <button
                                    key={etoile}
                                    type="button"
                                    className={
                                        etoile <= (survol || note)
                                            ? "nextori-avis-star nextori-avis-star-active"
                                            : "nextori-avis-star"
                                    }
                                    onMouseEnter={() =>
                                        setSurvol(etoile)
                                    }
                                    onClick={() =>
                                        setNote(etoile)
                                    }
                                    aria-label={`${etoile} étoile${etoile > 1 ? "s" : ""}`}
                                    aria-pressed={note === etoile}
                                >
                                    <FaStar />
                                </button>

                            ))}

                        </div>

                        <p className="nextori-avis-rating-message">
                            {note === 0
                                ? "Sélectionne une note pour commencer."
                                : note === 1
                                    ? "Très déçu"
                                    : note === 2
                                        ? "Peut mieux faire"
                                        : note === 3
                                            ? "Une expérience correcte"
                                            : note === 4
                                                ? "Une très bonne expérience"
                                                : "Une excellente expérience !"
                            }
                        </p>

                    </section>


                    {/* Séparateur */}
                    <div className="nextori-avis-divider" />


                    {/* =========================
                        COMMENTAIRE
                    ========================== */}
                    <section className="nextori-avis-comment-section">

                        <div className="nextori-avis-section-heading">

                            <span className="nextori-avis-step">
                                02
                            </span>

                            <div>
                                <h2>
                                    Qu'as-tu pensé de NextOri ?
                                </h2>

                                <p>
                                    Tes suggestions nous intéressent.
                                </p>
                            </div>

                        </div>


                        <div className="nextori-avis-textarea-wrapper">

                            <textarea
                                id="commentaire"
                                value={commentaire}
                                onChange={(event) =>
                                    setCommentaire(event.target.value)
                                }
                                placeholder="Qu'as-tu aimé ? Qu'est-ce qu'on pourrait améliorer ?"
                                rows="6"
                                maxLength="1000"
                            />

                            <span className="nextori-avis-counter">
                                {commentaire.length}/1000
                            </span>

                        </div>

                    </section>


                    {/* =========================
                        CONSENTEMENT
                    ========================== */}
                    <div className="nextori-avis-consent">

                        <label className="nextori-avis-consent-label">

                            <input
                                type="checkbox"
                                checked={afficher}
                                onChange={(event) =>
                                    setAfficher(event.target.checked)
                                }
                            />

                            <span className="nextori-avis-custom-checkbox">
                                <span />
                            </span>

                            <span className="nextori-avis-consent-text">
                                <strong>
                                    Autoriser l'affichage public
                                </strong>

                                <small>
                                    J'accepte que mon avis puisse être
                                    publié sur NextOri.
                                </small>
                            </span>

                        </label>

                    </div>


                    {/* =========================
                        ERREUR
                    ========================== */}
                    {erreur && (
                        <div
                            className="nextori-avis-error"
                            role="alert"
                        >
                            {erreur}
                        </div>
                    )}


                    {/* =========================
                        ACTION
                    ========================== */}
                    <div className="nextori-avis-actions">

                        <button
                            type="submit"
                            className="nextori-avis-submit"
                            disabled={envoi}
                        >
                            <span>
                                {envoi
                                    ? "Envoi en cours..."
                                    : "Envoyer mon avis"
                                }
                            </span>

                            {!envoi && (
                                <span className="nextori-avis-submit-arrow">
                                    →
                                </span>
                            )}
                        </button>

                        <p className="nextori-avis-privacy">
                            Ton avis est associé à ton compte NextOri.
                        </p>

                    </div>

                </form>

            </main>

        </div>
    );
}

export default Avis;
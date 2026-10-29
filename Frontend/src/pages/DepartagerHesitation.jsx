import { useEffect, useMemo, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  ArrowRight,
  Sparkles,
  CheckCircle2,
  Compass,
  Briefcase,
  GraduationCap,
  AlertTriangle,
  Lightbulb,
  Check,
  Eye,
  BookOpen
} from "lucide-react";
import { comparerPistes } from "../services/ComparaisonPistesService";
import { genererAnalyseHesitation, profilsHesitation } from "../utils/moteurHesitation";
import "../styles/DepartagerHesitation.css";

const ETAPES_ANALYSE_IA = [
  "Analyse de tes réponses et de ce qui compte pour toi",
  "Exploration des caractéristiques et critères de tes options dans la base",
  "Évaluation de la correspondance avec ton profil RIASEC",
  "Identification des différences concrètes et des points de divergence",
  "Finalisation de ton éclairage décisionnel personnalisé"
];

const NOMS_RIASEC = {
  R: { nom: "Réaliste", trait: "pratique, technique et concret" },
  I: { nom: "Investigateur", trait: "analytique, curieux et axé sur la réflexion" },
  A: { nom: "Artistique", trait: "créatif, intuitif et expressif" },
  S: { nom: "Social", trait: "humain, tourné vers l'écoute et l'accompagnement" },
  E: { nom: "Entreprenant", trait: "dynamique, persuasif et axé sur l'action" },
  C: { nom: "Conventionnel", trait: "méthodique, rigoureux et structuré" }
};

function decrireProfilRiasec(code) {
  if (!code) return "";
  const lettres = String(code).toUpperCase().split("");
  const traits = lettres.map((l) => NOMS_RIASEC[l]?.trait).filter(Boolean);
  return traits.join(", ");
}

function DepartagerHesitation() {
  const location = useLocation();
  const navigate = useNavigate();

  const idsPistes = useMemo(() => {
    const state = location.state || {};
    const brut =
      state.id_pistes ||
      state.idsPistes ||
      (Array.isArray(state.pistesSelectionnees)
        ? state.pistesSelectionnees.map((p) => p.id_piste)
        : []) ||
      [];
    return [
      ...new Set(
        (Array.isArray(brut) ? brut : [])
          .map(Number)
          .filter((id) => Number.isInteger(id) && id > 0)
      ),
    ];
  }, [location.state]);

  const reponsesHesitation = useMemo(() => {
    return Array.isArray(location.state?.reponsesHesitation)
      ? location.state.reponsesHesitation
      : [];
  }, [location.state]);

  const pistesSelectionnees = useMemo(() => {
    return Array.isArray(location.state?.pistesSelectionnees)
      ? location.state.pistesSelectionnees
      : [];
  }, [location.state]);

  const typeChoix = location.state?.typeChoix || (pistesSelectionnees[0]?.type_piste ?? "metier");

  const [comparaison, setComparaison] = useState(null);
  const [chargementDonnees, setChargementDonnees] = useState(true);
  const [etapeAnalyse, setEtapeAnalyse] = useState(0);
  const [animationTerminee, setAnimationTerminee] = useState(false);
  const [erreur, setErreur] = useState("");

  // Animation étapes IA
  useEffect(() => {
    const timers = [
      setTimeout(() => setEtapeAnalyse(1), 500),
      setTimeout(() => setEtapeAnalyse(2), 1100),
      setTimeout(() => setEtapeAnalyse(3), 1700),
      setTimeout(() => setEtapeAnalyse(4), 2300),
      setTimeout(() => setAnimationTerminee(true), 2800)
    ];

    return () => {
      timers.forEach(clearTimeout);
    };
  }, []);

  // Chargement des données backend avec enregistrement Supabase
  useEffect(() => {
    let actif = true;
    async function charger() {
      if (idsPistes.length < 2 || idsPistes.length > 3) {
        setErreur("Sélectionne deux ou trois pistes enregistrées du même type depuis Mes pistes.");
        setChargementDonnees(false);
        return;
      }
      try {
        setChargementDonnees(true);
        setErreur("");
        const resultat = await comparerPistes(idsPistes, reponsesHesitation);
        if (actif) setComparaison(resultat);
      } catch (error) {
        if (actif) setErreur(error.message || "L'analyse n'a pas pu être effectuée.");
      } finally {
        if (actif) setChargementDonnees(false);
      }
    }
    charger();
    return () => {
      actif = false;
    };
  }, [idsPistes, reponsesHesitation]);

  // Analyse qualitative issue de moteurHesitation
  const analyseQualitative = useMemo(() => {
    const options = (comparaison?.resultats || pistesSelectionnees).map((p) => ({
      id: p.id_piste || p.id_element,
      nom: p.nom || p.metier?.nom || p.filiere?.nom || "Piste"
    }));

    return genererAnalyseHesitation({
      typeChoix,
      metiersSelectionnes: typeChoix === "metier" ? options : [],
      filieresSelectionnees: typeChoix === "filiere" ? options : [],
      reponsesHesitation
    });
  }, [typeChoix, comparaison, pistesSelectionnees, reponsesHesitation]);

  const estEnChargement = !animationTerminee || chargementDonnees;

  // Options comparées
  const optionsAffichees = useMemo(() => {
    if (comparaison?.resultats && comparaison.resultats.length > 0) {
      return comparaison.resultats;
    }
    return pistesSelectionnees.map((p) => {
      const estMetier = p.type_piste === "metier";
      const donnees = estMetier ? p.metier : p.filiere;
      return {
        id_piste: p.id_piste,
        type_piste: p.type_piste,
        nom: donnees?.nom || (estMetier ? "Métier" : "Filière"),
        domaine: donnees?.domaine || donnees?.secteur || "",
        description: donnees?.description || "",
        profil_riasec: donnees?.profil_riasec || null,
        competences: donnees?.competences || null
      };
    });
  }, [comparaison, pistesSelectionnees]);

  // Éclairage RIASEC humain
  const profilUtilisateur = comparaison?.profil_riasec;
  const lettresUtilisateur = profilUtilisateur?.profil_dominant || "";

  /* =========================================================================
     1. ÉCRAN DE CHARGEMENT IA ANIMÉ
  ========================================================================= */
  if (estEnChargement) {
    return (
      <main className="departager-ia-loading-page">
        <div className="departager-ia-loading-card">
          {/* Orbe lumineux animé */}
          <div className="departager-ia-orb-wrapper">
            <div className="departager-ia-orb-ring ring-1"></div>
            <div className="departager-ia-orb-ring ring-2"></div>
            <div className="departager-ia-orb">
              <Sparkles size={32} className="departager-ia-orb-icon" />
            </div>
          </div>

          <span className="departager-ia-loading-badge">INTELLIGENCE NEXTORI</span>
          <h1>Analyse de ta situation en cours...</h1>
          <p className="departager-ia-loading-sub">
            NextOri croise tes réponses, les critères métiers et ton profil RIASEC pour t'offrir un éclairage sur-mesure.
          </p>

          <div className="departager-ia-steps">
            {ETAPES_ANALYSE_IA.map((titreEtape, idx) => {
              const estFaite = idx < etapeAnalyse;
              const estActive = idx === etapeAnalyse;
              return (
                <div
                  key={idx}
                  className={`departager-ia-step ${estFaite ? "completed" : estActive ? "active" : ""}`}
                >
                  <span className="departager-ia-step-dot">
                    {estFaite ? <Check size={14} strokeWidth={3} /> : idx + 1}
                  </span>
                  <span>{titreEtape}</span>
                </div>
              );
            })}
          </div>

          <div className="departager-ia-progress-bar">
            <div
              className="departager-ia-progress-fill"
              style={{ width: `${Math.min(100, (etapeAnalyse + 1) * 20)}%` }}
            ></div>
          </div>
        </div>
      </main>
    );
  }

  /* =========================================================================
     2. GESTION DES ERREURS
  ========================================================================= */
  if (erreur) {
    return (
      <main className="departager-hesitation-page">
        <section className="departager-hesitation-section" role="alert" style={{ textAlign: "center", padding: "40px 20px" }}>
          <h2>Analyse indisponible</h2>
          <p style={{ color: "#64748B", margin: "14px 0 24px" }}>{erreur}</p>
          <button
            type="button"
            className="departager-hesitation-primary-btn"
            onClick={() => navigate("/mes-pistes")}
          >
            <ArrowLeft size={18} /> Revenir à Mes pistes
          </button>
        </section>
      </main>
    );
  }

  /* =========================================================================
     3. RESTITUTION COMPARATIVE EXPLICATIVE (100% QUALITATIVE & HUMAINE)
  ========================================================================= */
  const labelType = typeChoix === "metier" ? "métiers" : "filières";
  const labelTypeSingulier = typeChoix === "metier" ? "métier" : "filière";

  return (
    <main className="departager-hesitation-page">
      {/* -------------------------------------------------------------------
          HERO
      ------------------------------------------------------------------- */}
      <header className="departager-hesitation-hero">
        <button
          type="button"
          className="departager-hesitation-back"
          onClick={() => navigate("/mes-pistes")}
        >
          <ArrowLeft size={18} /> Retour à Mes pistes
        </button>

        <div className="departager-hesitation-badge">
          <Sparkles size={18} /> J’HÉSITE · ÉCLAIRAGE DÉCISIONNEL
        </div>

        <p className="departager-hesitation-eyebrow">
          ANALYSE COMPARATIVE NEXTORI
        </p>

        <h1>
          Voici ce que ton hésitation <span>semble révéler.</span>
        </h1>

        <p>
          Pas de chiffres abstraits ni de choix imposé : voici une lecture concrète de ce qui différencie réellement tes {labelType} pour t'aider à choisir en pleine conscience.
        </p>
      </header>

      {/* -------------------------------------------------------------------
          SECTION 1 : LES OPTIONS QUE TU COMPARES
      ------------------------------------------------------------------- */}
      <section className="departager-hesitation-section">
        <div className="departager-hesitation-section-heading">
          <span className="departager-hesitation-section-num">01</span>
          <div>
            <p className="departager-hesitation-section-tag">TON HÉSITATION</p>
            <h2>Les options mises en perspective</h2>
          </div>
        </div>

        <div className="departager-options-cards-grid">
          {optionsAffichees.map((piste, index) => {
            const estMetier = piste.type_piste === "metier";
            return (
              <article key={piste.id_piste || index} className="departager-option-card">
                <div className="departager-option-header">
                  <span className="departager-option-badge-index">
                    Option {index + 1}
                  </span>
                  <span className="departager-option-type-tag">
                    {estMetier ? <Briefcase size={14} /> : <GraduationCap size={14} />}
                    {estMetier ? "Métier" : "Filière"}
                  </span>
                </div>

                <h3>{piste.nom}</h3>
                {piste.domaine && (
                  <span className="departager-option-domaine">
                    {piste.domaine}
                  </span>
                )}

                {piste.description && (
                  <p className="departager-option-desc">
                    {piste.description}
                  </p>
                )}

                {estMetier && piste.profil_riasec && (
                  <div className="departager-option-trait">
                    <strong>Profil type :</strong> {piste.profil_riasec} ({decrireProfilRiasec(piste.profil_riasec)})
                  </div>
                )}
              </article>
            );
          })}
        </div>
      </section>

      {/* -------------------------------------------------------------------
          SECTION 2 : CE QUE TES RÉPONSES RÉVÈLENT (LES 4 SIGNAUX CLÉS)
      ------------------------------------------------------------------- */}
      <section className="departager-hesitation-section">
        <div className="departager-hesitation-section-heading">
          <span className="departager-hesitation-section-num">02</span>
          <div>
            <p className="departager-hesitation-section-tag">CE QUI COMPTE POUR TOI</p>
            <h2>Les priorités issues de tes réponses</h2>
          </div>
        </div>

        <p className="departager-section-intro">
          Ces repères sont directement tirés de tes réponses aux questions. Ils servent de boussole pour évaluer tes options :
        </p>

        <div className="departager-signals-grid">
          {/* Signal 1 : Ce qui t'attire */}
          {analyseQualitative.attirance && (
            <article className="departager-signal-card">
              <span className="departager-signal-label attirance">Ce qui t'attire</span>
              <h4>{analyseQualitative.attirance.titre}</h4>
              <p>{analyseQualitative.attirance.description}</p>
            </article>
          )}

          {/* Signal 2 : Ta force */}
          {analyseQualitative.pointsForts && analyseQualitative.pointsForts[0] && (
            <article className="departager-signal-card">
              <span className="departager-signal-label force">Ta force dominante</span>
              <h4>{analyseQualitative.pointsForts[0].titre}</h4>
              <p>{analyseQualitative.pointsForts[0].description}</p>
            </article>
          )}

          {/* Signal 3 : Ton critère prioritaire */}
          {analyseQualitative.critere && (
            <article className="departager-signal-card">
              <span className="departager-signal-label critere">Ton critère n°1</span>
              <h4>{analyseQualitative.critere.titre}</h4>
              <p>{analyseQualitative.critere.description}</p>
            </article>
          )}

          {/* Signal 4 : Point de vigilance */}
          {analyseQualitative.blocage && (
            <article className="departager-signal-card">
              <span className="departager-signal-label blocage">Ce qui te fait hésiter</span>
              <h4>{analyseQualitative.blocage.titre}</h4>
              <p>{analyseQualitative.blocage.description}</p>
            </article>
          )}
        </div>
      </section>

      {/* -------------------------------------------------------------------
          SECTION 3 : L'ANALYSE COMPARATIVE DES DIFFÉRENCES
      ------------------------------------------------------------------- */}
      <section className="departager-hesitation-section">
        <div className="departager-hesitation-section-heading">
          <span className="departager-hesitation-section-num">03</span>
          <div>
            <p className="departager-hesitation-section-tag">COMPARAISON CONCRÈTE</p>
            <h2>Ce qui distingue réellement tes options</h2>
          </div>
        </div>

        <div className="departager-differences-container">
          {/* Synthèse globale */}
          <div className="departager-synthesis-highlight">
            <Sparkles size={22} className="departager-synthesis-icon" />
            <div>
              <strong>Ce que montre la comparaison :</strong>
              <p>{analyseQualitative.synthese}</p>
            </div>
          </div>

          {/* Cartes d'analyse comparative qualitative */}
          <div className="departager-comparison-facets">
            {/* Facette 1 : Quotidien & Activités */}
            <article className="departager-facet-card">
              <div className="departager-facet-title">
                <BookOpen size={20} />
                <h3>Au quotidien : que fait-on concrètement ?</h3>
              </div>
              <p>
                La vraie différence se joue souvent dans la routine de travail :
              </p>
              <ul className="departager-facet-list">
                {optionsAffichees.map((opt, i) => (
                  <li key={i}>
                    <strong>{opt.nom} :</strong>{" "}
                    {opt.description
                      ? opt.description
                      : `Cette option s'exprime dans le domaine « ${opt.domaine || "général"} ».`}
                  </li>
                ))}
              </ul>
            </article>

            {/* Facette 2 : Profil & RIASEC */}
            <article className="departager-facet-card">
              <div className="departager-facet-title">
                <Compass size={20} />
                <h3>Personnalité & tempérament : pour quel esprit ?</h3>
              </div>
              <p>
                {lettresUtilisateur ? (
                  <>
                    Ton profil dominant est <strong>{lettresUtilisateur}</strong> ({decrireProfilRiasec(lettresUtilisateur)}).
                  </>
                ) : (
                  "En observant les qualités naturelles requises :"
                )}
              </p>
              <ul className="departager-facet-list">
                {optionsAffichees.map((opt, i) => {
                  const descRiasec = opt.profil_riasec ? decrireProfilRiasec(opt.profil_riasec) : null;
                  return (
                    <li key={i}>
                      <strong>{opt.nom} :</strong>{" "}
                      {descRiasec
                        ? `Convient particulièrement à un tempérament ${descRiasec}.`
                        : `Demande de la régularité, de la curiosité et un intérêt marqué pour son domaine d'application.`}
                    </li>
                  );
                })}
              </ul>
            </article>

            {/* Facette 3 : Points distinctifs observés dans la base */}
            {comparaison?.criteres_distinctifs && comparaison.criteres_distinctifs.length > 0 && (
              <article className="departager-facet-card">
                <div className="departager-facet-title">
                  <Eye size={20} />
                  <h3>Critères distinctifs relevés dans la base</h3>
                </div>
                <p>
                  Les données de votre catalogue font ressortir des différences notables sur les aspects suivants :
                </p>
                <div className="departager-distinctifs-tags">
                  {comparaison.criteres_distinctifs.map((crit, idx) => (
                    <span key={idx} className="departager-distinctif-pill">
                      {crit.nom || crit.code}
                    </span>
                  ))}
                </div>
                <p className="departager-distinctifs-explain">
                  Ces critères représentent les axes sur lesquels vos options ne demandent pas le même investissement quotidien (ex: conditions de travail, niveau d'analyse ou relationnel).
                </p>
              </article>
            )}
          </div>
        </div>
      </section>

      {/* -------------------------------------------------------------------
          SECTION 4 : ANALYSE PAR PISTE (POINTS FORTS & VIGILANCES)
      ------------------------------------------------------------------- */}
      <section className="departager-hesitation-section">
        <div className="departager-hesitation-section-heading">
          <span className="departager-hesitation-section-num">04</span>
          <div>
            <p className="departager-hesitation-section-tag">LECTURE INDIVIDUELLE</p>
            <h2>Points d'appui et vigilances par option</h2>
          </div>
        </div>

        <div className="departager-pistes-analysis-grid">
          {optionsAffichees.map((piste, index) => {
            const analysePiste = comparaison?.analyse?.resultats?.find(
              (r) => r.piste?.id_piste === piste.id_piste
            );

            const estDominante = analysePiste?.position === "dominante";

            return (
              <article
                key={piste.id_piste || index}
                className={`departager-piste-analysis-card ${estDominante ? "highlighted" : ""}`}
              >
                <div className="departager-piste-analysis-header">
                  <div>
                    <span className="departager-piste-analysis-num">Option {index + 1}</span>
                    <h3>{piste.nom}</h3>
                  </div>
                  {estDominante && (
                    <span className="departager-piste-badge-lead">
                      Forte convergence
                    </span>
                  )}
                </div>

                {/* Raisons d'alignement */}
                <div className="departager-piste-block">
                  <span className="departager-piste-block-title green">
                    <CheckCircle2 size={16} /> Ce qui plaide en sa faveur :
                  </span>
                  <ul>
                    {analysePiste?.raisons && analysePiste.raisons.length > 0 ? (
                      analysePiste.raisons.slice(0, 3).map((raison, rIdx) => (
                        <li key={rIdx}>{raison}</li>
                      ))
                    ) : (
                      <>
                        <li>Correspond à tes centres d'intérêt enregistrés.</li>
                        <li>S'inscrit dans un secteur aux opportunités réelles.</li>
                      </>
                    )}
                  </ul>
                </div>

                {/* Points de vigilance */}
                <div className="departager-piste-block">
                  <span className="departager-piste-block-title orange">
                    <AlertTriangle size={16} /> À vérifier avant de trancher :
                  </span>
                  <ul>
                    {analysePiste?.pointsVigilance && analysePiste.pointsVigilance.length > 0 ? (
                      analysePiste.pointsVigilance.slice(0, 3).map((vigilance, vIdx) => (
                        <li key={vIdx}>{vigilance}</li>
                      ))
                    ) : (
                      <>
                        <li>Vérifier les prérequis de formation et les compétences clés.</li>
                        <li>Se renseigner sur la réalité concrète de l'environnement de travail.</li>
                      </>
                    )}
                  </ul>
                </div>

                <div className="departager-piste-footer-action">
                  <button
                    type="button"
                    className="departager-explore-btn"
                    onClick={() =>
                      navigate(
                        piste.type_piste === "metier"
                          ? `/metiers/${piste.id_element || piste.id_metier || piste.id_piste}`
                          : `/filieres/${piste.id_element || piste.id_filiere || piste.id_piste}`
                      )
                    }
                  >
                    Découvrir la fiche complète <ArrowRight size={15} />
                  </button>
                </div>
              </article>
            );
          })}
        </div>
      </section>

      {/* -------------------------------------------------------------------
          SECTION 5 : 3 ACTIONS CONCRÈTES POUR DÉCIDER
      ------------------------------------------------------------------- */}
      <section className="departager-hesitation-section">
        <div className="departager-hesitation-section-heading">
          <span className="departager-hesitation-section-num">05</span>
          <div>
            <p className="departager-hesitation-section-tag">PASSER À L’ACTION</p>
            <h2>Comment trancher sereinement ?</h2>
          </div>
        </div>

        <p className="departager-section-intro">
          {analyseQualitative.conclusion}
        </p>

        <div className="departager-advice-grid">
          {analyseQualitative.conseils.map((conseil, idx) => (
            <article key={idx} className="departager-advice-card">
              <span className="departager-advice-num">0{idx + 1}</span>
              <div>
                <h4>{conseil.titre}</h4>
                <p>{conseil.description}</p>
              </div>
            </article>
          ))}
        </div>
      </section>

      {/* -------------------------------------------------------------------
          ACTIONS FINALES
      ------------------------------------------------------------------- */}
      <section className="departager-final-actions">
        <div>
          <h3>Prêt(e) à approfondir ?</h3>
          <p>
            Prends le temps de lire les fiches détaillées de tes options avant de prendre ta décision.
          </p>
        </div>

        <div className="departager-buttons-group">
          <button
            type="button"
            className="departager-btn-secondary"
            onClick={() => navigate("/mes-pistes")}
          >
            Retour à Mes pistes
          </button>
          <button
            type="button"
            className="departager-btn-primary"
            onClick={() => navigate("/comparaison-pistes/questions", {
              state: {
                typeChoix,
                pistesSelectionnees,
                id_pistes: idsPistes
              }
            })}
          >
            Refaire le questionnaire
          </button>
        </div>
      </section>
    </main>
  );
}

export default DepartagerHesitation;

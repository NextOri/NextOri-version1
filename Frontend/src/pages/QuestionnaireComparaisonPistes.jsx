import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, CheckCircle2 } from "lucide-react";
import { getQuestionsComparaison } from "../services/ComparaisonPistesService";
import "../styles/QuestionnaireComparaisonPistes.css";

const QUESTIONS_FALLBACK = [
  {
    id_question: 1,
    question: "Quand tu penses aux options que tu hésites à choisir, qu’est-ce qui t’attire le plus ?",
    reponses: [
      { id_reponse: 1, code: "ATTIRANCE_CONTENU", texte: "Le contenu : les activités et ce que je vais réellement faire." },
      { id_reponse: 2, code: "ATTIRANCE_SENS", texte: "Le sens : me sentir utile et faire quelque chose qui me correspond." },
      { id_reponse: 3, code: "ATTIRANCE_OPPORTUNITES", texte: "Les possibilités : évolution, débouchés et opportunités." },
      { id_reponse: 4, code: "ATTIRANCE_CADRE", texte: "Le cadre : environnement, conditions et façon de travailler." },
      { id_reponse: 5, code: "ATTIRANCE_DEFI", texte: "Le défi : apprendre, progresser et me dépasser." },
    ],
  },
  {
    id_question: 2,
    question: "Dans quelle situation te sens-tu généralement le plus à l’aise ?",
    reponses: [
      { id_reponse: 6, code: "FORCE_ANALYSER", texte: "Résoudre : analyser un problème et trouver une solution." },
      { id_reponse: 7, code: "FORCE_CREER", texte: "Créer : imaginer quelque chose et proposer des idées." },
      { id_reponse: 8, code: "FORCE_AIDER", texte: "Aider : écouter, expliquer ou accompagner quelqu’un." },
      { id_reponse: 9, code: "FORCE_ORGANISER", texte: "Organiser : structurer, planifier et gérer les choses." },
      { id_reponse: 10, code: "FORCE_AGIR", texte: "Agir : prendre des initiatives et faire avancer un projet." },
    ],
  },
  {
    id_question: 3,
    question: "Qu’est-ce qui rend ton choix le plus difficile aujourd’hui ?",
    reponses: [
      { id_reponse: 11, code: "BLOCAGE_ERREUR", texte: "J’ai peur de me tromper." },
      { id_reponse: 12, code: "BLOCAGE_OPTIONS", texte: "J’ai plusieurs options qui m’intéressent réellement." },
      { id_reponse: 13, code: "BLOCAGE_INFORMATION", texte: "Je manque d’informations pour comparer." },
      { id_reponse: 14, code: "BLOCAGE_CAPACITES", texte: "Je ne suis pas sûr(e) d’avoir le niveau ou les capacités nécessaires." },
      { id_reponse: 15, code: "BLOCAGE_ENTOURAGE", texte: "Mon entourage influence beaucoup mon choix." },
    ],
  },
  {
    id_question: 4,
    question: "Si tu devais aujourd'hui donner le plus de poids à un seul critère, lequel serait-ce ?",
    reponses: [
      { id_reponse: 16, code: "CRITERE_INTERET", texte: "Mon intérêt personnel." },
      { id_reponse: 17, code: "CRITERE_CAPACITES", texte: "Mes capacités et mes points forts." },
      { id_reponse: 18, code: "CRITERE_DEBOUCHES", texte: "Les débouchés professionnels." },
      { id_reponse: 19, code: "CRITERE_CONDITIONS", texte: "Les conditions de travail." },
      { id_reponse: 20, code: "CRITERE_STABILITE", texte: "La stabilité et la sécurité." },
    ],
  },
  {
    id_question: 5,
    question: "Qu’est-ce qui t’aiderait le plus à avancer vers une décision ?",
    reponses: [
      { id_reponse: 21, code: "BESOIN_COMPARAISON", texte: "Comparer clairement mes différentes options." },
      { id_reponse: 22, code: "BESOIN_COMPATIBILITE", texte: "Comprendre ce qui correspond le mieux à mon profil." },
      { id_reponse: 23, code: "BESOIN_REALITE", texte: "Mieux connaître la réalité des études ou du métier." },
      { id_reponse: 24, code: "BESOIN_DEBOUCHES", texte: "Mieux connaître les débouchés." },
      { id_reponse: 25, code: "BESOIN_RASSURANCE", texte: "Être rassuré(e) avant de prendre ma décision." },
    ],
  },
];

export default function QuestionnaireComparaisonPistes() {
  const location = useLocation();
  const navigate = useNavigate();

  const etat = location.state || {};
  const typeChoix = etat.typeChoix;
  const pistesSelectionnees = etat.pistesSelectionnees || [];

  const [questions, setQuestions] = useState([]);
  const [chargement, setChargement] = useState(true);
  const [indexQuestion, setIndexQuestion] = useState(0);
  const [reponses, setReponses] = useState({});

  useEffect(() => {
    let actif = true;

    async function charger() {
      try {
        setChargement(true);
        const donnees = await getQuestionsComparaison();
        if (!actif) return;

        if (Array.isArray(donnees) && donnees.length > 0) {
          setQuestions(donnees);
        } else {
          setQuestions(QUESTIONS_FALLBACK);
        }
      } catch (err) {
        if (!actif) return;
        console.warn("Chargement questions depuis Supabase impossible, utilisation des questions par défaut:", err);
        setQuestions(QUESTIONS_FALLBACK);
      } finally {
        if (actif) {
          setChargement(false);
        }
      }
    }

    charger();
    return () => {
      actif = false;
    };
  }, []);

  if (
    !typeChoix ||
    !Array.isArray(pistesSelectionnees) ||
    pistesSelectionnees.length < 2 ||
    pistesSelectionnees.length > 3
  ) {
    return (
      <main className="qcp-page">
        <section className="qcp-card">
          <h1>Comparaison indisponible</h1>
          <p>
            Sélectionne deux ou trois pistes du même type dans « Mes pistes »,
            puis relance la comparaison.
          </p>
          <button
            type="button"
            className="qcp-primary"
            onClick={() => navigate("/mes-pistes")}
          >
            <ArrowLeft size={18} /> Retour à mes pistes
          </button>
        </section>
      </main>
    );
  }

  if (chargement) {
    return (
      <main className="qcp-page">
        <section className="qcp-card" style={{ textAlign: "center", padding: "60px 20px" }}>
          <h2>Chargement des questions...</h2>
          <p style={{ color: "#526071" }}>
            Nous préparons le questionnaire pour mieux comparer tes pistes.
          </p>
        </section>
      </main>
    );
  }

  const questionCourante = questions[indexQuestion] || questions[0];
  const qId = questionCourante?.id_question ?? questionCourante?.id;
  const reponseChoisie = reponses[qId];

  function choisirReponse(reponse) {
    setReponses((precedentes) => ({
      ...precedentes,
      [qId]: {
        code: reponse.code,
        texte: reponse.texte,
        id_reponse: reponse.id_reponse,
      },
    }));
  }

  function continuer() {
    if (!reponseChoisie) return;

    if (indexQuestion < questions.length - 1) {
      setIndexQuestion((precedent) => precedent + 1);
      return;
    }

    const reponsesHesitation = questions.map((q) => {
      const id = q.id_question ?? q.id;
      const r = reponses[id];
      return {
        id_question: id,
        code: r?.code || "",
        texte: r?.texte || "",
        id_reponse: r?.id_reponse,
      };
    });

    const idPistes = pistesSelectionnees.map((p) => Number(p.id_piste));

    navigate("/hesitation/departager", {
      state: {
        typeChoix,
        pistesSelectionnees,
        id_pistes: idPistes,
        reponsesHesitation,
        origine: "mes-pistes",
      },
    });
  }

  const listeReponses = Array.isArray(questionCourante?.reponses)
    ? questionCourante.reponses
    : [];

  const progressionPourcent = Math.round(
    ((indexQuestion + 1) / questions.length) * 100
  );

  return (
    <main className="qcp-page">
      <header className="qcp-header">
        <button
          type="button"
          className="qcp-back"
          onClick={() => navigate("/mes-pistes")}
        >
          <ArrowLeft size={18} />
          Retour à mes pistes
        </button>

        <span className="qcp-eyebrow">NEXTORI · J’HÉSITE</span>
        <h1>Comparons tes pistes à partir de ce qui compte pour toi.</h1>
        <p>
          Tes réponses nous aideront à mettre en évidence les correspondances
          et les différences entre les options que tu as sélectionnées.
        </p>
      </header>

      <section className="qcp-card">
        <div className="qcp-progress-label">
          <span>Question {indexQuestion + 1} sur {questions.length}</span>
          <span>{progressionPourcent} %</span>
        </div>

        <div
          className="qcp-progress"
          role="progressbar"
          aria-valuenow={indexQuestion + 1}
          aria-valuemin={1}
          aria-valuemax={questions.length}
        >
          <span style={{ width: `${progressionPourcent}%` }} />
        </div>

        <h2>{questionCourante?.question}</h2>

        <div className="qcp-answers">
          {listeReponses.map((reponse) => {
            const active = reponseChoisie?.code === reponse.code;

            return (
              <button
                type="button"
                key={reponse.code || reponse.id_reponse}
                className={`qcp-answer ${active ? "selected" : ""}`}
                onClick={() => choisirReponse(reponse)}
                aria-pressed={active}
              >
                <span>{reponse.texte}</span>
                {active && <CheckCircle2 size={20} />}
              </button>
            );
          })}
        </div>

        <div className="qcp-footer">
          <button
            type="button"
            className="qcp-secondary"
            disabled={indexQuestion === 0}
            onClick={() => setIndexQuestion((precedent) => precedent - 1)}
          >
            <ArrowLeft size={18} /> Précédent
          </button>

          <button
            type="button"
            className="qcp-primary"
            disabled={!reponseChoisie}
            onClick={continuer}
          >
            {indexQuestion === questions.length - 1
              ? "Voir la comparaison"
              : "Question suivante"}
            <ArrowRight size={18} />
          </button>
        </div>
      </section>

      <p className="qcp-privacy">
        Tes réponses servent à éclairer ton choix. NextOri ne décide pas à ta place.
      </p>
    </main>
  );
}

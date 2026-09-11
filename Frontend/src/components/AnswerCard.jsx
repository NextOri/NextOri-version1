function AnswerCard({ proposition, selected, onSelect }) {

    return (

        <div
            className={`answer-card ${selected ? "selected" : ""}`}
            onClick={() => onSelect(proposition)}
        >

            <div className="answer-letter">

                {selected ? "✓" : proposition.lettre}

            </div>

            <div className="answer-text">

                {proposition.libelle}

            </div>

        </div>

    );

}

export default AnswerCard;
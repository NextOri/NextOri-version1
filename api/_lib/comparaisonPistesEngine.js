const LETTRES_RIASEC = new Set(["R", "I", "A", "S", "E", "C"]);

function normaliserCodeRiasec(code) {
  const lettres = [...new Set(String(code || "").toUpperCase().replace(/[^RIASEC]/g, ""))];
  return lettres.join("").slice(0, 3);
}

function calculerCorrespondanceRiasec(profilUtilisateur, profilPiste) {
  const utilisateur = normaliserCodeRiasec(profilUtilisateur);
  const piste = normaliserCodeRiasec(profilPiste);
  if (!utilisateur || !piste) {
    return { disponible: false, libelle: "Correspondance RIASEC non disponible", explication: "Le profil ou les données RIASEC de cette piste ne sont pas disponibles." };
  }

  const lettresUtilisateur = [...utilisateur];
  const lettresPiste = [...piste];
  const communes = lettresUtilisateur.filter((lettre) => lettresPiste.includes(lettre));
  const rangs = communes.map((lettre) => ({ lettre, rangUtilisateur: lettresUtilisateur.indexOf(lettre), rangPiste: lettresPiste.indexOf(lettre) }));
  const points = rangs.reduce((total, item) => total + (item.rangUtilisateur === 0 && item.rangPiste === 0 ? 3 : item.rangUtilisateur <= 1 && item.rangPiste <= 1 ? 2 : 1), 0);
  const maximum = Math.max(1, lettresUtilisateur.length * 3);
  const pourcentage = Math.round((points / maximum) * 100);

  let niveau = "Quelques lettres en commun";
  if (pourcentage >= 67) niveau = "Plusieurs correspondances";
  else if (pourcentage >= 34) niveau = "Correspondances partielles";

  return {
    disponible: true,
    profilUtilisateur: utilisateur,
    profilPiste: piste,
    lettresCommunes: communes,
    pourcentage,
    niveau,
    libelle: niveau,
    explication: communes.length
      ? `Les profils partagent les lettres ${communes.join(", ")}. Cette indication aide à explorer la piste ; elle ne mesure ni la réussite future ni la valeur du choix.`
      : "Les codes ne partagent pas de lettre. Cela ne signifie pas que cette piste ne peut pas te convenir : explore son contenu et ses exigences."
  };
}

function construireComparaisonPistes({ typePiste, pistes, criteres, valeursParCible, profilRiasec, metiersAssocies = [], universitesAssociees = [] }) {
  const criteresActifs = (criteres || []).filter((critere) => critere.actif !== false);
  const resultats = (pistes || []).map((piste) => {
    const cibleId = typePiste === "metier" ? piste.id_metier : piste.id_filiere;
    const valeurs = valeursParCible.get(Number(cibleId)) || new Map();
    const grille = criteresActifs.map((critere) => {
      const valeur = valeurs.has(Number(critere.id_critere)) ? valeurs.get(Number(critere.id_critere)) : null;
      return {
        id_critere: critere.id_critere,
        code: critere.code,
        nom: critere.nom,
        categorie: critere.categorie,
        valeur: Number.isFinite(valeur) ? valeur : null,
        disponible: Number.isFinite(valeur)
      };
    });
    const disponibles = grille.filter((item) => item.disponible);
    const moyenne = disponibles.length ? disponibles.reduce((somme, item) => somme + item.valeur, 0) / disponibles.length : null;
    const cibleAssociee = typePiste === "metier"
      ? null
      : metiersAssocies.filter((item) => Number(item.id_filiere) === Number(cibleId));
    const profilCible = typePiste === "metier"
      ? piste.profil_riasec
      : [...new Set((cibleAssociee || []).map((item) => normaliserCodeRiasec(item.profil_riasec)).filter(Boolean))].join(" / ");
    const correspondanceRiasec = !profilRiasec
      ? { disponible: false, libelle: "Aucun profil RIASEC enregistré", explication: "Tu peux comparer cette piste sans test RIASEC." }
      : typePiste === "metier"
        ? calculerCorrespondanceRiasec(profilRiasec.profil_dominant, profilCible)
        : (cibleAssociee || []).length
          ? {
              disponible: true,
              mode: "metiers_associes",
              metiers: cibleAssociee.map((metier) => ({
                id_metier: metier.id_metier,
                nom: metier.nom,
                profil_riasec: metier.profil_riasec,
                correspondance: calculerCorrespondanceRiasec(profilRiasec.profil_dominant, metier.profil_riasec)
              })),
              explication: "Pour cette filière, les indications RIASEC sont présentées à travers les métiers associés présents dans le catalogue. Elles ne décrivent pas à elles seules la filière."
            }
          : { disponible: false, libelle: "Correspondance RIASEC non documentée", explication: "Aucun métier associé avec un profil RIASEC exploitable n'est enregistré pour cette filière." };

    const associationsMetiers = typePiste === "filiere" ? (cibleAssociee || []).map(({ id_metier, nom, profil_riasec, secteur }) => ({ id_metier, nom, profil_riasec, secteur })) : [];
    const associationsFilieres = typePiste === "metier" ? metiersAssocies.filter((item) => Number(item.id_metier) === Number(cibleId)).map(({ id_filiere, nom, domaine }) => ({ id_filiere, nom, domaine })) : [];
    const etablissements = typePiste === "filiere" ? universitesAssociees.filter((item) => Number(item.id_filiere) === Number(cibleId)).map(({ id_universite, nom, ville, type, region }) => ({ id_universite, nom, ville, type, region })) : [];

    return {
      id_piste: piste.id_piste,
      type_piste: typePiste,
      id_element: cibleId,
      nom: typePiste === "metier" ? piste.nom : piste.nom,
      description: piste.description || piste.presentation || null,
      domaine: typePiste === "metier" ? (piste.secteur || null) : (piste.domaine || null),
      presentation: piste.presentation || null,
      competences: piste.competences || piste.competences_developpees || null,
      duree: typePiste === "filiere" ? (piste.duree || null) : null,
      niveau_etude: typePiste === "metier" ? (piste.niveau_etude || null) : null,
      salaire_min: typePiste === "metier" ? (piste.salaire_min ?? null) : null,
      salaire_max: typePiste === "metier" ? (piste.salaire_max ?? null) : null,
      date_ajout: piste.date_ajout,
      criteres: grille,
      synthese_criteres: {
        nombre_disponible: disponibles.length,
        nombre_total: criteresActifs.length,
        couverture_pourcent: criteresActifs.length ? Math.round((disponibles.length / criteresActifs.length) * 100) : 0,
        moyenne_descriptive: moyenne === null ? null : Math.round(moyenne * 100) / 100
      },
      riasec: correspondanceRiasec,
      metiers_associes: associationsMetiers,
      filieres_associees: associationsFilieres,
      etablissements
    };
  });

  const criteresComparables = criteresActifs.map((critere) => {
    const valeurs = resultats.map((resultat) => ({ id_piste: resultat.id_piste, nom: resultat.nom, valeur: resultat.criteres.find((item) => Number(item.id_critere) === Number(critere.id_critere))?.valeur ?? null }));
    const valeursConnues = valeurs.filter((item) => item.valeur !== null);
    const distinctif = valeursConnues.length >= 2 && new Set(valeursConnues.map((item) => item.valeur)).size > 1;
    return { id_critere: critere.id_critere, code: critere.code, nom: critere.nom, categorie: critere.categorie, valeurs, distinctif };
  });

  const communs = criteresComparables.filter((critere) => critere.valeurs.filter((item) => item.valeur !== null).length === resultats.length && new Set(critere.valeurs.map((item) => item.valeur)).size === 1);
  const distinctifs = criteresComparables.filter((critere) => critere.distinctif);

  return {
    type_piste: typePiste,
    profil_riasec: profilRiasec ? {
      id_test: profilRiasec.id_test,
      date_test: profilRiasec.date_test,
      profil_dominant: profilRiasec.profil_dominant,
      scores: { R: profilRiasec.score_r ?? 0, I: profilRiasec.score_i ?? 0, A: profilRiasec.score_a ?? 0, S: profilRiasec.score_s ?? 0, E: profilRiasec.score_e ?? 0, C: profilRiasec.score_c ?? 0 }
    } : null,
    synthese: profilRiasec
      ? "Compare les informations disponibles et utilise le RIASEC comme une indication supplémentaire, pas comme un verdict."
      : "Compare les informations disponibles. Tu peux utiliser J’HÉSITE même sans résultat RIASEC.",
    resultats,
    grille_criteres: criteresComparables,
    criteres_communs: communs,
    criteres_distinctifs: distinctifs,
    avertissements: [
      "Aucun classement ni gagnant automatique n'est produit.",
      "Les critères sans valeur enregistrée restent indiqués comme indisponibles.",
      ...(profilRiasec ? [] : ["Aucun test RIASEC valide n'a été trouvé ; la comparaison reste pleinement utilisable."])
    ]
  };
}

export { construireComparaisonPistes, calculerCorrespondanceRiasec, normaliserCodeRiasec };

export const afficherTypeUniversite = (type) => {

    const types = {

        "prive": "Privé",

        "publique": "Publique",

        "parapublique": "Parapublique",

        "parapublic": "Parapublic",

        "privee": "Privée",

        "public": "Public",

        "grande_ecole": "Grande école",

        "ecole_superieure": "École supérieure"

    };


    return types[type?.toLowerCase()] || type;

};
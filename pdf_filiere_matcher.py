import pathlib
import re
import csv
from difflib import get_close_matches

sql_path = pathlib.Path('Bases de données/nextori_db_v2 (13).sql')
pdf_path = pathlib.Path('pdf_program_pages_output.txt')
output_csv = pathlib.Path('pdf_filiere_matches.csv')
output_json = pathlib.Path('pdf_filiere_matches.json')

# parse SQL filiere names
text = sql_path.read_text(encoding='utf-8')
pattern = re.compile(r"\(\s*(\d+),\s*'([^']+)'\s*,")
filieres = [(int(m.group(1)), m.group(2)) for m in pattern.finditer(text)]
filieres_lower = [(fid, nom, nom.lower()) for fid, nom in filieres]
name_to_id = {nom: fid for fid, nom in filieres}

pdf_text = pdf_path.read_text(encoding='utf-8')
pdf_text = re.sub(r'^\s*\d+:\s*', '', pdf_text, flags=re.M)

candidates = []
for match in re.finditer(r'\d+\.\s*([^\n]+)', pdf_text):
    candidate = match.group(1).strip()
    if len(candidate) > 20:
        candidate = re.sub(r'\s+', ' ', candidate)
        candidates.append(candidate)

# also capture standalone lines with Licence/Master/Bachelor and no numbering
for line in pdf_text.splitlines():
    line = line.strip()
    if not line:
        continue
    if re.match(r'^(Licence|Master|Bachelor|Dipl[oô]me|MBA)', line, re.I) and len(line) > 20:
        line = re.sub(r'\s+', ' ', line)
        candidates.append(line)

unique_candidates = []
seen = set()
for cand in candidates:
    if cand not in seen:
        unique_candidates.append(cand)
        seen.add(cand)

rules = {
    'Informatique': ['informatique', 'téléinformatique', 'MIAGE', 'réseaux', 'programmation', 'maintenance informatique', 'systèmes embarqués', 'génie logiciel', 'cybersécurité', 'données', 'internet', 'web', 'computer science'],
    'Génie Civil': ['génie civil', 'travaux publics', 'construction', 'route', 'hydraulique', 'géomètre', 'topographe', 'bâtiment'],
    'Médecine': ['médecine', 'docteur en médecine'],
    'Droit': ['droit', 'juridique', 'fiscalité', 'notarial', 'contentieux', 'passation des marchés', 'juridique'],
    'Gestion': ['gestion', 'administration des affaires', 'gestion des entreprises', 'gestion du patrimoine', 'gestion de projets', 'gestion des ressources humaines'],
    'Management': ['management', 'leadership', 'organisation des entreprises', 'entreprises', 'management commercial', 'management des organisations', 'business administration'],
    'Marketing': ['marketing', 'communication', 'commerce international', 'relations publiques', 'marketing digital', 'vente', 'stratégie commerciale'],
    'Génie logistique': ['logistique', 'transport', 'supply chain', 'transit', 'commerce international'],
    'Banque, Assurance, Finance': ['banque', 'assurance', 'finance', 'actuariat', 'micro-finance'],
    'Transport logistique': ['transport logistique', 'logistique maritime', 'manutention portuaire', 'transport maritime'],
    'Sciences infirmières': ['sciences infirmières', 'infirmier', 'sage-femme', 'santé communautaire'],
    'Pharmacie': ['pharmacie'],
    'Biologie médicale': ['biologie', 'analyses biologiques', 'biochimie'],
    'Santé publique': ['santé publique', 'services de santé', 'gestion hospitalière'],
    'Génie des industries agroalimentaires': ['agroalimentaire', 'agro-alimentaire', 'industrie agroalimentaire'],
    'Énergie renouvelable': ['énergies renouvelables', 'photovoltaïques', 'énergie renouvelable'],
    'Qualité, Hygiène, Sécurité et Environnement (QHSE)': ['qualité', 'hygiène', 'sécurité', 'environnement', 'QHSE'],
    'Tourisme, Hôtellerie et Langues': ['tourisme', 'hôtellerie', 'langues appliquées', 'interprétariat'],
    'Gestion hôtelière et restauration': ['gestion hôtelière', 'restauration', 'hotellerie'],
    'Audit et Contrôle de Gestion': ['audit et contrôle de gestion', 'audit contrôle', 'comptabilité audit'],
    'Comptabilité': ['comptabilité', 'comptabilité finance', 'fiscalité'],
    'Comptabilité et Gestion': ['comptabilité et gestion'],
    'Administration des Affaires': ['administration des affaires', 'administration des entreprises'],
    'Gouvernance Locale et Développement Territorial': ['gouvernance locale', 'développement territorial', 'développement local', 'gouvernance publique'],
    'Administration publique et territoriale': ['administration publique', 'administration territoriale'],
    'Management de projet': ['gestion de projets', 'management de projets'],
    'Master of Business Administration (MBA)': ['MBA', 'master of business administration'],
    'Droit des affaires': ['droit des affaires'],
    'Réseaux et Télécommunications': ['réseaux', 'télécommunication', 'télécom', 'systèmes réseaux', 'réseaux télécoms'],
    'Systèmes et Réseaux': ['systèmes et réseaux', 'administration systèmes', 'serveurs', 'virtualisation'],
    'Cybersécurité': ['cybersécurité', 'sécurité des systèmes informatiques', 'sécurité informatique'],
    'Génie Logiciel': ['génie logiciel', 'développement logiciel', 'programmation'],
    'Informatique de Gestion': ['informatique de gestion', 'MIAGE'],
    'Systèmes d’Information': ['systèmes d information', 'systèmes d’ information'],
    'Data Science': ['data science', 'analyse de données', 'statistiques', 'intelligence artificielle'],
    'Intelligence Artificielle': ['intelligence artificielle', 'machine learning'],
    'Statistique et Informatique Décisionnelle': ['statistique', 'décisionnelle', 'information décisionnelle'],
    'Génie biologique': ['génie biologique', 'biotechnologie'],
    'Génie des industries chimiques': ['industries chimiques', 'chimie'],
    'Sciences agroalimentaires': ['sciences agroalimentaires', 'agroalimentaire'],
    'Infographie et Multimédia': ['infographie', 'multimédia', 'graphisme', 'audiovisuel'],
    'Maintenance Informatique': ['maintenance informatique'],
    'Informatique industrielle': ['informatique industrielle', 'électronique industrielle', 'automatisation industrielle'],
    'Architecture': ['architecture'],
    'Journalisme': ['journalisme'],
    'Administration Économique et Sociale (AES)': ['administration économique', 'AES'],
}

matches = []
for cand in unique_candidates:
    cand_lower = cand.lower()
    matched = set()
    # direct filiere name match
    for fid, nom, nom_l in filieres_lower:
        if nom_l in cand_lower:
            matched.add((fid, nom, 'name'))
    # keyword rules
    if not matched:
        for nom, kws in rules.items():
            if any(kw.lower() in cand_lower for kw in kws):
                fid = name_to_id.get(nom)
                if fid is not None:
                    matched.add((fid, nom, 'rule'))
    # fuzzy
    if not matched:
        close = get_close_matches(cand_lower, [nom.lower() for _, nom, _ in filieres_lower], n=2, cutoff=0.65)
        for close_nom in close:
            fid = name_to_id.get(next((fn for fn in name_to_id if fn.lower() == close_nom), None))
            if fid is not None:
                matched.add((fid, next(fn for fn in name_to_id if fn.lower() == close_nom), 'fuzzy'))
    if matched:
        for fid, nom, match_type in sorted(matched):
            matches.append({'program': cand, 'id_filiere': fid, 'filiere_nom': nom, 'match_type': match_type})
    else:
        matches.append({'program': cand, 'id_filiere': '', 'filiere_nom': '', 'match_type': 'none'})

with output_csv.open('w', encoding='utf-8', newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=['program', 'id_filiere', 'filiere_nom', 'match_type'])
    writer.writeheader()
    writer.writerows(matches)

import json
output_json.write_text(json.dumps(matches, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'Wrote {len(matches)} program->filiere mapping rows to {output_csv.name} and {output_json.name}')

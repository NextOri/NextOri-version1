import pathlib
import re
from difflib import get_close_matches

sql_path = pathlib.Path('Bases de données/nextori_db_v2 (13).sql')
pdf_path = pathlib.Path('pdf_program_pages_output.txt')

text = sql_path.read_text(encoding='utf-8')
pattern = re.compile(r"\(\s*(\d+),\s*'([^']+)'\s*,")
filieres = [(int(m.group(1)), m.group(2)) for m in pattern.finditer(text)]
filieres_lower = [(fid, nom, nom.lower()) for fid, nom in filieres]
name_to_id = {nom: fid for fid, nom in filieres}
print(f'Parsed {len(filieres)} filieres')

pdf_text = pdf_path.read_text(encoding='utf-8')
# remove line numbers like 001:
pdf_text = re.sub(r"^\s*\d+:\s*", '', pdf_text, flags=re.M)
# split by pages for context
pages = re.split(r'={10,}\s*\n', pdf_text)
programs = []
for page_block in pages:
    lines = [line.strip() for line in page_block.splitlines() if line.strip()]
    if not lines:
        continue
    # extract page number if possible
    page_num = None
    for line in lines[:5]:
        m = re.match(r'PAGE\s+(\d+)', line)
        if m:
            page_num = int(m.group(1))
            break
    text = ' '.join(lines)
    # split on program numbering or on HA declarations
    candidates = re.split(r'\s*\d+\.\s*', text)
    for cand in candidates[1:]:
        # stop at HA markers if present
        cand = re.split(r'HA-\d{4}|HA\s*-\s*\d{4}|H-\d{4}|RepSEN|RepSEN/Ensup-priv', cand)[0]
        cand = cand.strip(' .;\n')
        if len(cand) < 20:
            continue
        # collapse spaces
        cand = re.sub(r'\s+', ' ', cand)
        if cand not in programs:
            programs.append((page_num, cand))

print(f'Extracted {len(programs)} unique program candidates')

# mapping heuristics
def match_program(p):
    p_lower = p.lower()
    matched = set()
    for fid, nom, nom_l in filieres_lower:
        if nom_l in p_lower:
            matched.add((fid, nom))
    if not matched:
        # keyword rules for common generic fields
        rules = {
            'Informatique': ['informatique', 'système réseau', 'téléinformatique', 'génie logiciel', 'électronique', 'cybersécurité', 'maintenance informatique', 'réseaux', 'MIAGE', 'informatique de gestion', 'systèmes d information', 'programmation'],
            'Génie Civil': ['génie civil', 'travaux publics', 'route', 'construction', 'béton', 'hydraulique', 'géomètre', 'topographe', 'bâtiment'],
            'Médecine': ['médecine', 'docteur en médecine'],
            'Droit': ['droit', 'juridique', 'fiscalité', 'notarial'],
            'Gestion': ['gestion des entreprises', 'administration des affaires', 'gestion financière', 'management des organisations'],
            'Management': ['management', 'entreprises', 'organisation des affaires', 'administration des affaires'],
            'Marketing': ['marketing', 'communication', 'commerce international', 'relations publiques'],
            'Génie logistique': ['logistique', 'transport', 'supply chain', 'transit', 'commerce international'],
            'Banque, Assurance, Finance': ['banque', 'assurance', 'finance', 'actuariat'],
            'Transport logistique': ['transport logistique', 'logistique maritime', 'commerce international'],
            'Sciences infirmières': ['sciences infirmières', 'infirmier', 'sage-femme', 'santé'],
            'Pharmacie': ['pharmacie'],
            'Biologie médicale': ['biologie', 'analyses biologiques', 'biochimie'],
            'Santé publique': ['santé publique', 'administration des services de santé'],
            'Génie des industries agroalimentaires': ['agroalimentaire'],
            'Énergie renouvelable': ['énergies renouvelables'],
            'Qualité, Hygiène, Sécurité et Environnement (QHSE)': ['hygiène sécurité environnement', 'QHSE'],
            'Tourisme, Hôtellerie et Langues': ['tourisme', 'hôtellerie'],
            'Langue appliquée aux affaires': ['langues appliquées'],
            'Gestion hôtelière et restauration': ['hôtellerie', 'restauration'],
            'Administration publique et territoriale': ['administration publique', 'gouvernance locale', 'développement territorial'],
            'Management de projet': ['gestion de projets', 'management de projets'],
            'Master of Business Administration (MBA)': ['MBA', 'master of business administration'],
            'Droit des affaires': ['droit des affaires'],
            'Audit et Contrôle de Gestion': ['audit et contrôle de gestion'],
            'Comptabilité': ['comptabilité', 'contrôle audit'],
            'Comptabilité et Gestion': ['comptabilité et gestion'],
            'Administration et Gestion des Entreprises': ['administration et gestion des entreprises'],
            'Génie électrique': ['électrotechnique', 'électromécanique', 'froid', 'climatisation'],
            'Génie biologique': ['génie biologique'],
            'Génie des industries chimiques': ['industries chimiques'],
            'Génie des industries agroalimentaires': ['industries agroalimentaires'],
            'Architecture': ['architecture'],
            'Journalisme': ['journalisme'],
            'Infographie et Multimédia': ['infographie', 'audiovisuel', 'multimédia'],
            'Maintenance Informatique': ['maintenance informatique'],
            'Informatique industrielle': ['informatique industrielle'],
            'Réseaux et Télécommunications': ['télécommunication', 'réseaux', 'systèmes réseaux'],
            'Systèmes et Réseaux': ['systèmes et réseaux', 'virtualisation'],
            'Cybersécurité': ['cybersécurité', 'sécurité informatique'],
            'Génie Logiciel': ['génie logiciel', 'programmation', 'développement logiciel'],
            'Data Science': ['data science', 'analyse de données', 'statistiques'],
            'Intelligence Artificielle': ['intelligence artificielle', 'machine learning'],
            'Informatique de Gestion': ['informatique de gestion', 'MIAGE'],
            'Systèmes d’Information': ['systèmes d information', 'systems information'],
            'Statistique et Informatique Décisionnelle': ['statistique', 'décisionnelle'],
        }
        for nom, kws in rules.items():
            if any(kw in p_lower for kw in kws):
                if nom in name_to_id:
                    matched.add((name_to_id[nom], nom))
    if not matched:
        close = get_close_matches(p.lower(), [nom for _, nom, _ in filieres_lower], n=3, cutoff=0.45)
        for nom in close:
            matched.add((name_to_id[nom], nom))
    return sorted(matched)

matches = []
for page, prog in programs:
    matched = match_program(prog)
    if matched:
        matches.append((page, prog, matched))

print(f'Found {len(matches)} program candidates with at least one filiere match')
for page, prog, matched in matches:
    print(f'PAGE {page or "?"}: {prog}')
    for fid, nom in matched:
        print(f'   => ({fid}) {nom}')
    print()

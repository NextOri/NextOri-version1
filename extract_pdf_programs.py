import pathlib
import re
from PyPDF2 import PdfReader

path = pathlib.Path('Liste-des-Etablissements-prives-dEnseignement-superieur-EPES-beneficiant-dune-Habilitation-institutionnelle-HA.pdf')
reader = PdfReader(str(path))

# pages 18-48 in our earlier scan correspond to indices 17-47
with open('pdf_program_pages_output.txt', 'w', encoding='utf-8') as out:
    for idx in range(17, 48):
        text = reader.pages[idx].extract_text() or ''
        out.write('=' * 80 + '\n')
        out.write(f'PAGE {idx+1}\n')
        out.write('=' * 80 + '\n')
        lines = [line.strip() for line in text.splitlines() if line.strip()]
        for i, line in enumerate(lines[:120]):
            out.write(f'{i+1:03}: {line}\n')
        out.write('\n\n')
print('wrote pdf_program_pages_output.txt')

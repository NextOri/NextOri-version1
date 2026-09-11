import re
import sys

def parse_phpmyadmin_dump(file_path):
    print(f"Reading {file_path} in pure UTF-8...", file=sys.stderr)
    with open(file_path, 'r', encoding='utf-8-sig', errors='replace') as f:
        content = f.read()

    content = content.replace('\r\n', '\n')

    # 1. Parse AUTO_INCREMENT definitions
    # Example: ALTER TABLE `attente_fonctionnalite` MODIFY `id_attente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
    auto_inc_cols = {} # { table: col }
    auto_inc_matches = re.findall(r'ALTER TABLE `(\w+)`\s+MODIFY `(\w+)` [^;]*?AUTO_INCREMENT', content, re.IGNORECASE)
    for tbl, col in auto_inc_matches:
        auto_inc_cols[tbl] = col

    print(f"Found {len(auto_inc_cols)} auto_increment columns", file=sys.stderr)

    # 2. Parse PRIMARY KEY and other keys from ALTER TABLE
    primary_keys = {} # { table: [col1, ...] }
    indexes = []

    # Find each ALTER TABLE block in the index section
    alter_blocks = re.findall(r'ALTER TABLE `(\w+)`\s+(ADD\s+PRIMARY\s+KEY[^;]+);', content, re.IGNORECASE)
    for tbl, clauses in alter_blocks:
        # Split clauses by comma if not inside parenthesis
        clause_list = []
        cur = ''
        paren = 0
        for char in clauses:
            if char == '(': paren += 1
            elif char == ')': paren -= 1
            elif char == ',' and paren == 0:
                clause_list.append(cur.strip())
                cur = ''
                continue
            cur += char
        if cur.strip():
            clause_list.append(cur.strip())

        for clause in clause_list:
            pk_m = re.match(r'ADD\s+PRIMARY\s+KEY\s*\((.*?)\)', clause, re.IGNORECASE)
            if pk_m:
                cols = [c.strip(' `') for c in pk_m.group(1).split(',')]
                primary_keys[tbl] = cols
                continue

            uk_m = re.match(r'ADD\s+UNIQUE\s+KEY\s+`?(\w+)`?\s*\((.*?)\)', clause, re.IGNORECASE)
            if uk_m:
                idx_name = uk_m.group(1)
                cols = [c.strip(' `') for c in uk_m.group(2).split(',')]
                indexes.append(f"CREATE UNIQUE INDEX IF NOT EXISTS idx_{tbl}_{idx_name} ON {tbl} ({', '.join(cols)});")
                continue

            k_m = re.match(r'ADD\s+KEY\s+`?(\w+)`?\s*\((.*?)\)', clause, re.IGNORECASE)
            if k_m:
                idx_name = k_m.group(1)
                cols = [c.strip(' `') for c in k_m.group(2).split(',')]
                indexes.append(f"CREATE INDEX IF NOT EXISTS idx_{tbl}_{idx_name} ON {tbl} ({', '.join(cols)});")
                continue

    print(f"Found {len(primary_keys)} primary keys and {len(indexes)} indexes", file=sys.stderr)

    # 3. Parse FOREIGN KEY constraints
    fk_constraints = []
    fk_blocks = re.findall(r'ALTER TABLE `(\w+)`\s+(ADD\s+CONSTRAINT[^;]+);', content, re.IGNORECASE)
    for tbl, clauses in fk_blocks:
        clause_list = []
        cur = ''
        paren = 0
        for char in clauses:
            if char == '(': paren += 1
            elif char == ')': paren -= 1
            elif char == ',' and paren == 0:
                clause_list.append(cur.strip())
                cur = ''
                continue
            cur += char
        if cur.strip():
            clause_list.append(cur.strip())

        for clause in clause_list:
            fk_m = re.match(r'ADD\s+CONSTRAINT\s+`?(\w+)`?\s+FOREIGN\s+KEY\s*\(`?(\w+)`?\)\s+REFERENCES\s+`?(\w+)`?\s*\(`?(\w+)`?\)(.*)', clause, re.IGNORECASE)
            if fk_m:
                c_name, col, ref_tbl, ref_col, extra = fk_m.groups()
                extra = extra.strip()
                fk_constraints.append(f"ALTER TABLE {tbl} ADD CONSTRAINT {c_name} FOREIGN KEY ({col}) REFERENCES {ref_tbl} ({ref_col}) {extra};")

    print(f"Found {len(fk_constraints)} foreign keys", file=sys.stderr)

    # 4. Parse CREATE TABLE statements
    create_matches = re.findall(r'CREATE TABLE `(\w+)`\s*\((.*?)\)\s*ENGINE', content, re.DOTALL)
    table_defs = []
    tables_list = []
    boolean_columns = {} # { tbl: set of boolean col names }

    for tbl, body in create_matches:
        tables_list.append(tbl)
        col_lines = []
        bool_cols = set()

        for line in body.split('\n'):
            line = line.strip().rstrip(',')
            if not line:
                continue

            col_m = re.match(r'`(\w+)`\s+([a-zA-Z0-9_]+(?:\([^\)]+\))?)(.*)', line)
            if not col_m:
                continue

            col_name = col_m.group(1)
            raw_type = col_m.group(2).lower()
            rest = col_m.group(3)

            is_auto = (auto_inc_cols.get(tbl) == col_name)

            if is_auto:
                pg_type = 'SERIAL'
                rest = re.sub(r'NOT\s+NULL', '', rest, flags=re.IGNORECASE).strip()
            elif raw_type == 'tinyint(1)':
                pg_type = 'BOOLEAN'
                bool_cols.add(col_name)
                rest = rest.replace("DEFAULT '1'", "DEFAULT true").replace("DEFAULT '0'", "DEFAULT false")
                rest = rest.replace("DEFAULT 1", "DEFAULT true").replace("DEFAULT 0", "DEFAULT false")
            elif raw_type.startswith('tinyint') or raw_type.startswith('smallint'):
                pg_type = 'SMALLINT'
            elif raw_type.startswith('int'):
                pg_type = 'INTEGER'
            elif raw_type.startswith('bigint'):
                pg_type = 'BIGINT'
            elif raw_type.startswith('decimal'):
                pg_type = raw_type.upper()
            elif raw_type in ['datetime', 'timestamp']:
                pg_type = 'TIMESTAMP'
                rest = re.sub(r'current_timestamp\(\)', 'CURRENT_TIMESTAMP', rest, flags=re.IGNORECASE)
                rest = re.sub(r'ON\s+UPDATE\s+CURRENT_TIMESTAMP', '', rest, flags=re.IGNORECASE).strip()
            elif raw_type == 'date':
                pg_type = 'DATE'
            elif raw_type.startswith('enum'):
                pg_type = 'VARCHAR(50)'
            elif raw_type in ['text', 'tinytext', 'mediumtext', 'longtext']:
                pg_type = 'TEXT'
            elif raw_type.startswith('varchar') or raw_type.startswith('char'):
                pg_type = raw_type.upper()
            elif raw_type in ['float', 'double']:
                pg_type = 'DOUBLE PRECISION'
            else:
                pg_type = raw_type.upper()

            col_lines.append(f"    {col_name} {pg_type} {rest}".strip())

        # Add primary key
        if tbl in primary_keys:
            pk_cols = primary_keys[tbl]
            col_lines.append(f"    PRIMARY KEY ({', '.join(pk_cols)})")

        boolean_columns[tbl] = bool_cols
        create_sql = f"CREATE TABLE IF NOT EXISTS {tbl} (\n" + ",\n".join(col_lines) + "\n);"
        table_defs.append(create_sql)

    print(f"Parsed {len(table_defs)} CREATE TABLE statements", file=sys.stderr)

    # 5. Parse INSERT statements
    insert_pattern = re.compile(r'INSERT INTO `(\w+)`\s*\((.*?)\)\s*VALUES\s*(.*?);', re.DOTALL | re.IGNORECASE)
    all_inserts = []

    for match in insert_pattern.finditer(content):
        tbl = match.group(1)
        col_names_str = match.group(2)
        values_str = match.group(3)

        cols = [c.strip(' `') for c in col_names_str.split(',')]
        bool_set = boolean_columns.get(tbl, set())
        
        # Identify boolean column indices
        bool_indices = set()
        for idx, col in enumerate(cols):
            if col in bool_set:
                bool_indices.add(idx)

        # Clean escape
        values_cleaned = values_str.replace("\\'", "''")
        if bool_indices:
            values_cleaned = patch_values_booleans(values_cleaned, bool_indices)

        clean_cols = ', '.join([f'"{c}"' if c.lower() in ('unique', 'user', 'order', 'primary', 'desc', 'asc', 'group', 'table') else c for c in cols])
        insert_sql = f"INSERT INTO {tbl} ({clean_cols}) VALUES\n{values_cleaned.strip()};"
        all_inserts.append(insert_sql)

    print(f"Parsed {len(all_inserts)} INSERT statements", file=sys.stderr)

    return tables_list, table_defs, all_inserts, fk_constraints, indexes, auto_inc_cols


def patch_values_booleans(values_str, bool_indices):
    """Convert integer 0/1 to false/true for boolean column positions in VALUES block."""
    rows = []
    i = 0
    n = len(values_str)

    while i < n:
        while i < n and values_str[i] in (' ', '\t', '\n', '\r', ','):
            i += 1
        if i >= n or values_str[i] != '(':
            break

        i += 1 # skip '('
        col_idx = 0
        cells = []
        cur = ''
        in_str = False

        while i < n:
            ch = values_str[i]
            if in_str:
                if ch == "'":
                    if i + 1 < n and values_str[i + 1] == "'":
                        cur += "''"
                        i += 2
                        continue
                    else:
                        in_str = False
                        cur += ch
                        i += 1
                        continue
                else:
                    cur += ch
                    i += 1
                    continue
            else:
                if ch == "'":
                    in_str = True
                    cur += ch
                    i += 1
                    continue
                elif ch == ',':
                    cells.append((col_idx, cur.strip()))
                    col_idx += 1
                    cur = ''
                    i += 1
                    continue
                elif ch == ')':
                    cells.append((col_idx, cur.strip()))
                    i += 1
                    break
                else:
                    cur += ch
                    i += 1
                    continue

        patched = []
        for c_idx, val in cells:
            if c_idx in bool_indices:
                if val == '0': val = 'false'
                elif val == '1': val = 'true'
            patched.append(val)

        rows.append('(' + ', '.join(patched) + ')')

    return ',\n'.join(rows)


def generate_full_supabase_sql():
    src = 'Bases de données/nextori_db_v2 (21).sql'
    tables, table_defs, inserts, fks, indexes, auto_incs = parse_phpmyadmin_dump(src)

    out = []
    out.append("-- =====================================================")
    out.append("-- SCHEMA & DATA NEXTORI - SUPABASE (POSTGRESQL)")
    out.append("-- Source: nextori_db_v2 (21).sql (dernier export)")
    out.append("-- Encodage: 100% UTF-8 natif (accents impeccables)")
    out.append("-- Compatible Supabase SQL Editor")
    out.append("-- =====================================================\n")
    out.append("SET client_encoding = 'UTF8';")
    out.append("SET standard_conforming_strings = on;")
    out.append("SET check_function_bodies = false;")
    out.append("SET client_min_messages = warning;\n")

    # 1. Drop existing tables
    out.append("-- =====================================================")
    out.append("-- 1. SUPPRESSION DES TABLES EXISTANTES")
    out.append("-- =====================================================\n")
    for tbl in tables + ['avis']:
        out.append(f"DROP TABLE IF EXISTS {tbl} CASCADE;")
    out.append("")

    # 2. Create tables
    out.append("-- =====================================================")
    out.append("-- 2. CREATION DES TABLES")
    out.append("-- =====================================================\n")
    for t_def in table_defs:
        out.append(t_def)
        out.append("")

    # Ensure table `avis` is also included for NextOri reviews
    out.append("""CREATE TABLE IF NOT EXISTS avis (
    id_avis SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    note SMALLINT NOT NULL,
    commentaire TEXT NOT NULL,
    afficher BOOLEAN DEFAULT false,
    approuve BOOLEAN DEFAULT false,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

    # 3. Data inserts
    out.append("-- =====================================================")
    out.append("-- 3. INSERTION DES DONNEES")
    out.append("-- =====================================================\n")
    for ins in inserts:
        out.append(ins)
        out.append("")

    # Insert sample avis (with proper true/false booleans)
    out.append("""INSERT INTO avis (id_avis, id_user, note, commentaire, afficher, approuve, date_creation) VALUES
(1, 19, 4, 'NextOri c le meilleur', true, true, '2026-09-09 16:01:45'),
(2, 19, 5, 'bhdghbyb', false, false, '2026-09-09 16:03:39'),
(3, 19, 1, 'jfdfhj', true, false, '2026-09-09 16:08:38'),
(4, 19, 3, 'dd', true, false, '2026-09-09 16:20:08'),
(5, 19, 3, 'Nextori c le meilleur', true, false, '2026-09-16 16:47:17'),
(6, 19, 3, 'Nextori', true, false, '2026-09-09 17:01:39'),
(7, 19, 5, 'C est une excellente appli', true, true, '2026-09-09 18:01:21'),
(8, 19, 4, 'fcftyuughuby', true, false, '2026-09-09 18:20:20'),
(9, 19, 4, 'Nextori c''est le meilleur', true, true, '2026-09-10 09:05:36');
""")

    # 4. Foreign Keys
    out.append("-- =====================================================")
    out.append("-- 4. CONTRAINTES DE CLES ETRANGERES (FOREIGN KEYS)")
    out.append("-- =====================================================\n")
    for fk in fks:
        out.append(fk)

    out.append("ALTER TABLE avis ADD CONSTRAINT fk_avis_user FOREIGN KEY (id_user) REFERENCES utilisateur (id_user) ON DELETE CASCADE;\n")

    # 5. Indexes
    out.append("-- =====================================================")
    out.append("-- 5. INDEX")
    out.append("-- =====================================================\n")
    for idx in indexes:
        out.append(idx)
    out.append("")

    # 6. Reset Sequences
    out.append("-- =====================================================")
    out.append("-- 6. SYNCHRONISATION DES SEQUENCES AUTO-INCREMENT")
    out.append("-- =====================================================\n")
    for tbl, col in auto_incs.items():
        out.append(f"SELECT setval(pg_get_serial_sequence('{tbl}', '{col}'), COALESCE(MAX({col}), 1)) FROM {tbl};")
    out.append("SELECT setval(pg_get_serial_sequence('avis', 'id_avis'), COALESCE(MAX(id_avis), 1)) FROM avis;\n")

    output_path = 'deployment/supabase_schema_and_data.sql'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(out))

    print(f"SUCCESS: Generated {output_path} with 100% pure UTF-8 encoding!", file=sys.stderr)


if __name__ == '__main__':
    generate_full_supabase_sql()

import re
import sys
import os

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

def patch_insert_booleans(insert_sql, bool_positions):
    """
    Convert integer 0/1 to false/true for BOOLEAN columns in INSERT VALUES.
    """
    values_match = re.search(r'\bVALUES\s*', insert_sql, re.IGNORECASE)
    if not values_match:
        return insert_sql

    prefix = insert_sql[:values_match.end()]
    rows_str = insert_sql[values_match.end():]

    patched_rows = []
    i = 0
    n = len(rows_str)

    while i < n:
        while i < n and rows_str[i] in (' ', '\t', '\n', '\r', ','):
            i += 1
        if i >= n:
            break
        if rows_str[i] != '(':
            break

        i += 1  # skip '('
        col_idx = 0
        cells = []
        current_cell = ''
        in_str = False

        while i < n:
            ch = rows_str[i]
            if in_str:
                if ch == "'":
                    if i + 1 < n and rows_str[i + 1] == "'":
                        current_cell += "''"
                        i += 2
                        continue
                    else:
                        in_str = False
                        current_cell += ch
                        i += 1
                        continue
                else:
                    current_cell += ch
                    i += 1
                    continue
            else:
                if ch == "'":
                    in_str = True
                    current_cell += ch
                    i += 1
                    continue
                elif ch == ',':
                    cells.append((col_idx, current_cell.strip()))
                    col_idx += 1
                    current_cell = ''
                    i += 1
                    continue
                elif ch == ')':
                    cells.append((col_idx, current_cell.strip()))
                    i += 1
                    break
                else:
                    current_cell += ch
                    i += 1
                    continue

        patched_cells = []
        for idx, val in cells:
            if idx in bool_positions:
                if val == '0':
                    val = 'false'
                elif val == '1':
                    val = 'true'
            patched_cells.append(val)

        patched_rows.append('(' + ','.join(patched_cells) + ')')

    return prefix + ','.join(patched_rows)


def convert():
    # Use the ORIGINAL file (utf-8-sig) to preserve special characters correctly
    source_file = 'Bases de données/nextori_db_v2 (21).sql'
    
    # Try multiple encodings
    content = None
    for enc in ['utf-8-sig', 'utf-8', 'latin1', 'cp1252']:
        try:
            with open(source_file, 'r', encoding=enc, errors='strict') as f:
                content = f.read()
            print(f"Read source with encoding: {enc}", file=sys.stderr)
            break
        except (UnicodeDecodeError, FileNotFoundError) as e:
            print(f"Failed {enc}: {e}", file=sys.stderr)
    
    if content is None:
        print("ERROR: Could not read source file!", file=sys.stderr)
        return

    lines = content.split('\n')
    
    out_lines = []
    out_lines.append("-- =====================================================")
    out_lines.append("-- SCHEMA & DATA NEXTORI - SUPABASE (POSTGRESQL)")
    out_lines.append("-- Compatible Supabase SQL Editor")
    out_lines.append("-- =====================================================\n")
    out_lines.append("SET client_encoding = 'UTF8';")
    out_lines.append("SET standard_conforming_strings = on;")
    out_lines.append("SET check_function_bodies = false;")
    out_lines.append("SET client_min_messages = warning;\n")

    in_create_table = False
    current_table = None
    table_lines = []
    tables_created = []
    table_serials = {}
    boolean_columns = {}

    create_table_statements = []
    fk_constraints = []
    indexes = []
    insert_statements = []

    for line in lines:
        stripped = line.strip()
        
        if stripped.startswith('/*') or stripped.startswith('--') or not stripped:
            continue
        if stripped.startswith('LOCK TABLES') or stripped.startswith('UNLOCK TABLES'):
            continue
        if stripped.startswith('START TRANSACTION') or stripped.startswith('COMMIT'):
            continue
        if stripped.startswith('SET '):
            continue

        create_match = re.match(r'CREATE\s+TABLE\s+`?(\w+)`?\s*\(', stripped, re.IGNORECASE)
        if create_match:
            in_create_table = True
            current_table = create_match.group(1)
            tables_created.append(current_table)
            table_lines = []
            continue

        if in_create_table:
            if stripped.startswith(')') or stripped.endswith(');'):
                in_create_table = False
                parsed_defs = []
                pks = []
                bool_pos = set()
                col_idx = 0
                
                for tl in table_lines:
                    tl = tl.rstrip(',').strip()
                    if not tl:
                        continue
                    
                    pk_match = re.match(r'PRIMARY\s+KEY\s*\((.*?)\)', tl, re.IGNORECASE)
                    if pk_match:
                        cols = [c.strip(' `') for c in pk_match.group(1).split(',')]
                        pks.append(f"    PRIMARY KEY ({', '.join(cols)})")
                        continue

                    key_match = re.match(r'(?:UNIQUE\s+)?KEY\s+`?(\w+)`?\s*\((.*?)\)', tl, re.IGNORECASE)
                    if key_match:
                        idx_name = key_match.group(1)
                        cols = [c.strip(' `') for c in key_match.group(2).split(',')]
                        is_unique = "UNIQUE " if "UNIQUE" in tl.upper() else ""
                        indexes.append(f"CREATE {is_unique}INDEX IF NOT EXISTS idx_{current_table}_{idx_name} ON {current_table} ({', '.join(cols)});")
                        continue

                    fk_match = re.match(r'CONSTRAINT\s+`?(\w+)`?\s+FOREIGN\s+KEY\s*\(`?(\w+)`?\)\s+REFERENCES\s+`?(\w+)`?\s*\(`?(\w+)`?\)(.*)', tl, re.IGNORECASE)
                    if fk_match:
                        c_name, col, ref_table, ref_col, extra = fk_match.groups()
                        extra = extra.strip()
                        fk_constraints.append(f"ALTER TABLE {current_table} ADD CONSTRAINT {c_name} FOREIGN KEY ({col}) REFERENCES {ref_table} ({ref_col}) {extra};")
                        continue

                    col_match = re.match(r'`?(\w+)`?\s+([a-zA-Z0-9_]+(?:\([^\)]+\))?)(.*)', tl)
                    if col_match:
                        col_name = col_match.group(1)
                        col_type_raw = col_match.group(2).lower()
                        col_rest = col_match.group(3)

                        col_rest = col_rest.replace('`', '')
                        is_auto_inc = 'AUTO_INCREMENT' in col_rest.upper()
                        col_rest = re.sub(r'AUTO_INCREMENT', '', col_rest, flags=re.IGNORECASE).strip()

                        is_boolean = False
                        if col_type_raw.startswith('enum'):
                            pg_type = 'VARCHAR(50)'
                        elif is_auto_inc:
                            pg_type = 'SERIAL'
                            col_rest = re.sub(r'NOT\s+NULL', '', col_rest, flags=re.IGNORECASE).strip()
                            table_serials[current_table] = col_name
                        elif col_type_raw.startswith('tinyint(1)'):
                            pg_type = 'BOOLEAN'
                            is_boolean = True
                            col_rest = col_rest.replace("DEFAULT '1'", "DEFAULT true").replace("DEFAULT '0'", "DEFAULT false")
                            col_rest = col_rest.replace("DEFAULT 1", "DEFAULT true").replace("DEFAULT 0", "DEFAULT false")
                        elif col_type_raw.startswith('int'):
                            pg_type = 'INTEGER'
                        elif col_type_raw.startswith('tinyint'):
                            pg_type = 'SMALLINT'
                        elif col_type_raw.startswith('smallint'):
                            pg_type = 'SMALLINT'
                        elif col_type_raw.startswith('bigint'):
                            pg_type = 'BIGINT'
                        elif col_type_raw.startswith('varchar'):
                            pg_type = col_type_raw.upper()
                        elif col_type_raw.startswith('char'):
                            pg_type = col_type_raw.upper()
                        elif col_type_raw in ['text', 'tinytext', 'mediumtext', 'longtext']:
                            pg_type = 'TEXT'
                        elif col_type_raw in ['datetime', 'timestamp']:
                            pg_type = 'TIMESTAMP'
                            col_rest = re.sub(r'current_timestamp\(\)', 'CURRENT_TIMESTAMP', col_rest, flags=re.IGNORECASE)
                            col_rest = re.sub(r'ON\s+UPDATE\s+CURRENT_TIMESTAMP', '', col_rest, flags=re.IGNORECASE).strip()
                        elif col_type_raw == 'date':
                            pg_type = 'DATE'
                        elif col_type_raw.startswith('decimal'):
                            pg_type = col_type_raw.upper()
                        elif col_type_raw in ['float', 'double']:
                            pg_type = 'DOUBLE PRECISION'
                        else:
                            pg_type = col_type_raw.upper()

                        if is_boolean:
                            bool_pos.add(col_idx)
                        col_idx += 1

                        def_str = f"    {col_name} {pg_type} {col_rest}".strip()
                        parsed_defs.append(def_str)

                boolean_columns[current_table] = bool_pos
                all_items = parsed_defs + pks
                create_table_statements.append(f"CREATE TABLE IF NOT EXISTS {current_table} (\n" + ",\n".join(all_items) + "\n);")
                continue
            else:
                table_lines.append(stripped)
                continue

        # Handle INSERT INTO — ensure it ends with ;
        if stripped.upper().startswith('INSERT INTO'):
            clean_insert = stripped.replace("\\'", "''")
            clean_insert = re.sub(r'`(\w+)`', r'\1', clean_insert)
            # Ensure trailing semicolon
            if not clean_insert.rstrip().endswith(';'):
                clean_insert = clean_insert.rstrip() + ';'
            
            # Get table name and patch booleans
            insert_table_match = re.match(r'INSERT INTO\s+(\w+)\s+VALUES', clean_insert, re.IGNORECASE)
            if insert_table_match:
                tbl_name = insert_table_match.group(1)
                bool_pos = boolean_columns.get(tbl_name, set())
                if bool_pos:
                    clean_insert = patch_insert_booleans(clean_insert, bool_pos)
            
            insert_statements.append(clean_insert)

    # Output
    out_lines.append("-- 1. TABLES")
    for tbl in tables_created:
        out_lines.append(f"DROP TABLE IF EXISTS {tbl} CASCADE;")
    out_lines.append("")

    for stmt in create_table_statements:
        out_lines.append(stmt)
        out_lines.append("")

    out_lines.append("\n-- =====================================================")
    out_lines.append("-- 2. DATA INSERTS")
    out_lines.append("-- =====================================================\n")
    for ins in insert_statements:
        out_lines.append(ins)

    out_lines.append("\n-- =====================================================")
    out_lines.append("-- 3. FOREIGN KEY CONSTRAINTS")
    out_lines.append("-- =====================================================\n")
    for fk in fk_constraints:
        out_lines.append(fk)

    out_lines.append("\n-- =====================================================")
    out_lines.append("-- 4. INDEXES")
    out_lines.append("-- =====================================================\n")
    for idx in indexes:
        out_lines.append(idx)

    out_lines.append("\n-- =====================================================")
    out_lines.append("-- 5. RESET SEQUENCES")
    out_lines.append("-- =====================================================\n")
    for table, col in table_serials.items():
        out_lines.append(f"SELECT setval(pg_get_serial_sequence('{table}', '{col}'), COALESCE(MAX({col}), 1)) FROM {table};")

    supabase_sql = "\n".join(out_lines)
    with open('deployment/supabase_schema_and_data.sql', 'w', encoding='utf-8') as f:
        f.write(supabase_sql)

    print(f"Done! {len(tables_created)} tables, {len(insert_statements)} inserts, {len([p for p in boolean_columns.values() if p])} tables with boolean columns patched.")


if __name__ == '__main__':
    convert()

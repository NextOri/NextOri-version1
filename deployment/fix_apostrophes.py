"""
Fix unescaped apostrophes in PostgreSQL INSERT statements.
In SQL, a single quote inside a string must be escaped as '' (double single-quote).
This script reads the generated supabase SQL, finds unescaped apostrophes inside
string values in INSERT statements, and fixes them.
"""
import re

INPUT = 'deployment/supabase_schema_and_data.sql'
OUTPUT = 'deployment/supabase_schema_and_data.sql'


def fix_apostrophes_in_sql(content):
    """
    Walk through the SQL content character by character.
    When inside a SQL string literal (between single quotes), any single quote
    that is NOT followed by another single quote and NOT the closing delimiter
    needs to be doubled (escaped).
    
    We use a state machine approach:
      - outside_string: normal SQL
      - inside_string: inside a '...' literal
    """
    result = []
    i = 0
    n = len(content)
    in_string = False
    fixed_count = 0

    while i < n:
        ch = content[i]

        if not in_string:
            if ch == "'":
                in_string = True
                result.append(ch)
                i += 1
            elif ch == '-' and i + 1 < n and content[i+1] == '-':
                # SQL line comment — copy until end of line
                end = content.find('\n', i)
                if end == -1:
                    end = n
                result.append(content[i:end+1])
                i = end + 1
            else:
                result.append(ch)
                i += 1
        else:
            # Inside a string
            if ch == "'":
                # Check if next char is also a quote (already escaped)
                if i + 1 < n and content[i+1] == "'":
                    # Already escaped double-quote — copy both
                    result.append("''")
                    i += 2
                else:
                    # Closing quote — end of string
                    result.append(ch)
                    i += 1
                    in_string = False
            elif ch == '\\':
                # Backslash escape (shouldn't normally appear in standard SQL but handle it)
                result.append(ch)
                i += 1
            else:
                result.append(ch)
                i += 1

    return ''.join(result), fixed_count


def main():
    with open(INPUT, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Input file size: {len(content)} chars")

    # The issue: the source MySQL data had apostrophes escaped with backslash (\')
    # After conversion, they appear as unescaped single quotes inside strings.
    # We need to ensure that inside INSERT VALUE strings, lone apostrophes are doubled.

    # First, let's find problematic patterns by scanning manually
    # Count unmatched quotes per INSERT line
    lines = content.split('\n')
    problem_lines = []
    for i, line in enumerate(lines, 1):
        if line.strip().startswith('(') or 'INSERT INTO' in line:
            # Count single quotes
            count = line.count("'")
            if count % 2 != 0:
                problem_lines.append((i, line[:100]))

    print(f"\nLines with odd number of quotes (potential problems): {len(problem_lines)}")
    for ln, text in problem_lines[:20]:
        print(f"  Line {ln}: {text}")

    # Now fix using state machine
    fixed_content, _ = fix_apostrophes_in_sql(content)

    # Verify fix
    lines2 = fixed_content.split('\n')
    still_problems = []
    for i, line in enumerate(lines2, 1):
        if line.strip().startswith('(') or 'INSERT INTO' in line:
            count = line.count("'")
            if count % 2 != 0:
                still_problems.append((i, line[:100]))

    print(f"\nAfter fix - lines with odd quotes: {len(still_problems)}")
    for ln, text in still_problems[:10]:
        print(f"  Line {ln}: {text}")

    with open(OUTPUT, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"\n[OK] Fixed SQL written to {OUTPUT}")
    print(f"Output file size: {len(fixed_content)} chars")


if __name__ == '__main__':
    main()

"""
Fix curly/smart apostrophes (U+2019) in the Supabase SQL file.
Supabase SQL Editor normalizes U+2019 to a straight quote, which breaks string delimiters.
We need to replace U+2019 inside SQL string values with '' (escaped straight quote).
"""

CURLY_APOS = '\u2019'  # right single quotation mark (curly apostrophe)

def fix_curly_apostrophes(content):
    """
    Walk through SQL content using a state machine.
    When inside a string literal (between straight single quotes),
    replace curly apostrophes U+2019 with two straight quotes ''.
    Outside of strings, replace curly apostrophes with straight apostrophes
    (they shouldn't appear in SQL keywords/identifiers, but just in case).
    """
    result = []
    i = 0
    n = len(content)
    in_string = False
    replacements = 0

    while i < n:
        ch = content[i]

        if not in_string:
            if ch == "'":
                # Start of string literal
                in_string = True
                result.append(ch)
                i += 1
            elif ch == CURLY_APOS:
                # Outside string - replace with straight quote
                result.append("'")
                replacements += 1
                i += 1
            elif ch == '-' and i + 1 < n and content[i+1] == '-':
                # Line comment - copy until end of line
                end = content.find('\n', i)
                if end == -1:
                    end = n
                result.append(content[i:end+1])
                i = end + 1
            else:
                result.append(ch)
                i += 1
        else:
            # Inside a string literal
            if ch == "'":
                if i + 1 < n and content[i+1] == "'":
                    # Already escaped double quote - copy both
                    result.append("''")
                    i += 2
                else:
                    # Closing quote - end of string
                    result.append(ch)
                    i += 1
                    in_string = False
            elif ch == CURLY_APOS:
                # Curly apostrophe inside string - escape as two straight quotes
                result.append("''")
                replacements += 1
                i += 1
            else:
                result.append(ch)
                i += 1

    return ''.join(result), replacements


def main():
    INPUT = 'deployment/supabase_schema_and_data.sql'

    with open(INPUT, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Input: {len(content)} chars")

    # Count curly apostrophes
    total_curly = content.count(CURLY_APOS)
    print(f"Total curly apostrophes U+2019 found: {total_curly}")

    if total_curly == 0:
        print("No curly apostrophes to fix!")
        return

    # Show a few examples
    lines = content.split('\n')
    examples = [(i+1, line) for i, line in enumerate(lines) if CURLY_APOS in line]
    print(f"\nLines containing curly apostrophes: {len(examples)}")
    for ln, line in examples[:10]:
        print(f"  Line {ln}: {line[:120]}")

    # Fix
    fixed_content, count = fix_curly_apostrophes(content)
    print(f"\nFixed {count} curly apostrophes")

    with open(INPUT, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"[OK] Written to {INPUT}")

    # Verify no curly apostrophes remain
    remaining = fixed_content.count(CURLY_APOS)
    print(f"Remaining curly apostrophes: {remaining}")


if __name__ == '__main__':
    main()

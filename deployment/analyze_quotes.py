import re

with open('deployment/supabase_schema_and_data.sql', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
line344 = lines[343]  # 0-indexed
print('Line 344:', repr(line344[:150]))
print()

# Check for curly apostrophe U+2019
if '\u2019' in line344:
    print('Contains curly apostrophe U+2019')
else:
    print('No curly apostrophe U+2019')

# Count straight single quotes on that line
count = line344.count("'")
print(f'Straight quote count on line 344: {count}')

# Now scan ALL lines for odd straight-quote count
problems = []
for i, line in enumerate(lines, 1):
    sq = line.count("'")
    if sq % 2 != 0:
        problems.append((i, sq, line[:120]))

print(f'\nAll lines with odd straight-quote count: {len(problems)}')
for ln, sq, txt in problems[:30]:
    print(f'  Line {ln} (quotes={sq}): {txt}')

import json, sys
p = 'project/data/tables/prologue_yard_dressings.json'
d = json.loads(open(p, encoding='utf-8', newline='').read())
if sys.argv[1] == 'add':
    old = json.loads(open('build/n29-05/table_n28.json', encoding='utf-8').read())
    d['dressings']['arched_n28'] = old['dressings']['arched_line']
else:
    d['dressings'].pop('arched_n28', None)
open(p, 'w', encoding='utf-8', newline='').write(json.dumps(d, indent=2, sort_keys=True) + '\n')
print(sys.argv[1], 'arched_n28' in d['dressings'])

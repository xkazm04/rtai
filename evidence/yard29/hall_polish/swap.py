# swap.py in: arched_line <- c649a15d6's arched_line (backup bytes to build/n29-07/table_head.json); swap.py out: restore the backup bytes
import json, shutil, sys
p = 'project/data/tables/prologue_yard_dressings.json'; b = 'build/n29-07/table_head.json'
if sys.argv[1] == 'in':
    shutil.copyfile(p, b)
    d = json.loads(open(p, encoding='utf-8', newline='').read())
    d['dressings']['arched_line'] = json.loads(open('build/n29-05/table_n28.json', encoding='utf-8').read())['dressings']['arched_line']
    open(p, 'w', encoding='utf-8', newline='').write(json.dumps(d, indent=2, sort_keys=True) + '\n')
else:
    shutil.copyfile(b, p)
print(sys.argv[1])

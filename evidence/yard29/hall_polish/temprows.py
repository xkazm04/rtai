import copy, json, sys
p = 'project/data/tables/prologue_yard_dressings.json'
d = json.loads(open(p, encoding='utf-8', newline='').read())
D = d['dressings']
DAY = {"accent_keep": 0.0, "gamma": 1.0, "id": "day", "paper_level": 1.0}
def day(row):
    x = copy.deepcopy(row)
    x["lights"] = {"grade": DAY, "pools": [], "kinds": [{k: v for k, v in k_.items() if k != "floor_glow"} for k_ in row["lights"]["kinds"]]}
    return x
TEMP = ('arched_n28', 'arched_n28_day', 'arched_day')
if sys.argv[1] == 'add':
    n28 = json.loads(open('build/n29-05/table_n28.json', encoding='utf-8').read())['dressings']['arched_line']
    D['arched_n28'] = n28; D['arched_n28_day'] = day(n28); D['arched_day'] = day(D['arched_line'])
else:
    for t in TEMP: D.pop(t, None)
open(p, 'w', encoding='utf-8', newline='').write(json.dumps(d, indent=2, sort_keys=True) + '\n')
print(sys.argv[1], [t for t in TEMP if t in D])

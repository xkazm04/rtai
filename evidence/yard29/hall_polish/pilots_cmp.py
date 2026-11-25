import json, sys
exp = {r['seed']: r for r in json.load(open('evidence/yard29/prologue-yard-pilots-hall.json'))['runs']}
got = json.load(open(sys.argv[1]))
keys = ('ticks', 'deaths', 'min_hp', 'stuck', 'sha256')
ok = True
for r in got['runs']:
    e = exp[r['seed']]
    same = all(r[k] == e[k] for k in keys)
    ok &= same
    print(f"seed {r['seed']}: ticks {r['ticks']} (exp {e['ticks']}), deaths {r['deaths']} ({e['deaths']}), min_hp {r['min_hp']} ({e['min_hp']}), sha {r['sha256'][:12]} ({e['sha256'][:12]}) {'IDENTICAL' if same else 'DIFF'}")
got['identical'] = ok
got['note'] = ("arched_line at the n29 hall-finish HEAD (tall collapsed bay, roof_glow, mouth wall pools) vs evidence/yard29/prologue-yard-pilots-hall.json; "
               "one Godot process via yard_pilot_rows; identical = ticks, deaths, min_hp, stuck, sha256")
open(sys.argv[2], 'w', newline='\n').write(json.dumps(got, indent=1, sort_keys=True) + '\n')
print('identical', ok)

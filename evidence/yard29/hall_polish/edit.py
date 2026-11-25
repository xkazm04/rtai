import json, sys
p = 'project/data/tables/prologue_yard_dressings.json'
raw = open(p, encoding='utf-8', newline='').read()
d = json.loads(raw)
assert json.dumps(d, indent=2, sort_keys=True) + '\n' == raw, 'table not in canonical form'
r = d['dressings']['arched_line']
what = sys.argv[1]
if what == 'wall':
    L = r['lights']
    assert not any(k['id'] == 'yard_hall_mouth_wall' for k in L['kinds'])
    mouth = next(k for k in L['kinds'] if k['id'] == 'yard_hall_mouth')
    wall = dict(mouth); wall['id'] = 'yard_hall_mouth_wall'
    wall['floor_glow'] = {"color": "ff8c14", "radius_m": 1, "strength": 0}
    wall['intensity'] = 0.45; wall['radius_m'] = 5.5
    L['kinds'].append(wall)
    L['pools'].append({"at": [11.8, -2.9], "id": "burst_mouth_wall", "kind": "yard_hall_mouth_wall"})
    L['pools'].append({"at": [56.2, -2.9], "id": "collapsed_mouth_wall", "kind": "yard_hall_mouth_wall"})
elif what == 'flip':
    n = 0
    for pc in r['factory_front']:
        if pc['at'][0] in (26.6, 41.4) and 'hall_tall' in pc['art']:
            pc['flip'] = True; n += 1
    assert n == 2
open(p, 'w', encoding='utf-8', newline='').write(json.dumps(d, indent=2, sort_keys=True) + '\n')
print('done', what)

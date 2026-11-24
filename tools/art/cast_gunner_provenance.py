"""Append one steam/ai-provenance/2026-11.jsonl line per shipped robot gunner PNG."""
import hashlib
import json
from datetime import date

from cast_soles import ROOT, VIEW

JOBS = {
    'armed_walk': {70: 'gunnerA_armed_walk_70'},
    'attack': {70: 'gunnerA_attack_70', 55: 'gunnerA_attack_55'},
    'hit': {70: 'gunnerA_hit_70', 55: 'gunnerA_hit_70'},
    'fall': {70: 'gunnerA_fall_70', 55: 'gunnerA_fall_55'},
    'planted8_armed_walk': {70: 'gunnerA8_70_a', 55: 'gunnerA8_55_a'},
}
EXTRA = {'planted8_armed_walk': ('b', 'c')}
EDITS = ('Keyed the green sheet, cut each drawing with its muzzle flash or dropped rifle, scaled each facing '
         'to the patrol cop body height, anchored on the shared foot line and registered the eight-drawing '
         'walk on its torso point; no tone change. Cutter: tools/art/cast_gunner_pack.py.')


def entry(action, pitch):
    name = f'robot_gunner_{action}.png'
    path = VIEW / f'p{pitch}' / name
    job = JOBS[action].get(pitch)
    if action == 'armed_walk' and pitch == 55:
        job = JOBS['planted8_armed_walk'][55]
    refs = [f'gtai-art/foes-n27/gunnerA/jobs.json#{job}']
    if action == 'planted8_armed_walk' or (action == 'armed_walk' and pitch == 55):
        refs += [f'gtai-art/foes-n27/gunnerA/jobs.json#gunnerA8_{pitch}_{s}' for s in 'bc']
    return dict(accepted_by='director (source sheets); cast lane (cut)', date=str(date.today()),
                file=path.relative_to(ROOT).as_posix(), human_edits=EDITS,
                model='built-in image_gen (image model not reported)', prompt_ref=refs[0],
                references=refs[1:] + ['gtai-art/foes-n27/gunnerA/refs/plate.png'], seed=None,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest(), ships_in='core.pck', tool='codex-image')


if __name__ == '__main__':
    with open(ROOT / 'steam/ai-provenance/2026-11.jsonl', 'a', encoding='utf-8', newline='\n') as out:
        for action in JOBS:
            for pitch in (70, 55):
                if action == 'armed_walk' and pitch == 70 or action != 'armed_walk':
                    out.write(json.dumps(entry(action, pitch), sort_keys=True) + '\n')
        out.write(json.dumps(entry('armed_walk', 55), sort_keys=True) + '\n')

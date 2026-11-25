"""Append one steam/ai-provenance/2026-11.jsonl line per shipped robot thug PNG (four-drawing sheets)."""
import argparse
import hashlib
import json
from datetime import date

from cast_soles import ROOT, VIEW

ACTIONS = ('armed_walk', 'planted8_armed_walk', 'attack', 'hit', 'fall')
EDITS = ('Keyed the green sheet, cut each drawing, scaled each facing to the patrol cop body height '
         '(hit sheets by their own body height), anchored on the shared foot line, filled the enclosed key '
         'hole of hit_70 col 3; walk8 stripes toned to the four-drawing hue. Cutter: tools/art/cast_thug_pack.py.')
REPLANT = (' n29: cells re-planted by whole-texel moves on the shoe sole with the claw cut out '
           '(tools/art/cast_thug_feet.py), the resting fall cells on their body bottom.')


def entry(action, pitch, replanted=False):
    path = VIEW / f'p{pitch}' / f'robot_thug_{action}.png'
    eight = action.startswith('planted8')
    refs = [f'gtai-art/foes-n26/thug8c/jobs.json#thug8c_{pitch}_{f}_t3' for f in ('down', 'dr', 'right', 'ur', 'up')]
    return dict(accepted_by='director (source sheets); cast lane (cut)', date=str(date.today()),
                file=path.relative_to(ROOT).as_posix(), human_edits=EDITS + (REPLANT if replanted else ''),
                model='built-in image_gen (image model not reported)',
                prompt_ref=refs[0] if eight else f'gtai-art/foes-n26/thug/jobs.json#thug_{action}_{pitch}',
                references=refs[1:] + ['gtai-art/foes-n26/thug/refs/plate.png'] if eight else ['gtai-art/foes-n26/thug/refs/plate.png'], seed=None,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest(), ships_in='core.pck', tool='codex-image')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--only', default='', help='comma list of <pitch>/<action> re-packed PNGs (default: all ten)')
    only = [tuple(item.split('/')) for item in parser.parse_args().only.split(',') if item]
    with open(ROOT / 'steam/ai-provenance/2026-11.jsonl', 'a', encoding='utf-8', newline='\n') as out:
        for pitch, action in only or [(p, a) for a in ACTIONS for p in ('70', '55')]:
            out.write(json.dumps(entry(action, int(pitch), bool(only)), sort_keys=True) + '\n')

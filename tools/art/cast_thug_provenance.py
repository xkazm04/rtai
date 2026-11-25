"""Append one steam/ai-provenance/2026-11.jsonl line per shipped robot thug PNG (four-drawing sheets)."""
import hashlib
import json
from datetime import date

from cast_soles import ROOT, VIEW

ACTIONS = ('armed_walk', 'planted8_armed_walk', 'attack', 'hit', 'fall')
EDITS = ('Keyed the green sheet, cut each drawing, scaled each facing to the patrol cop body height '
         '(hit sheets by their own body height), anchored on the shared foot line, filled the enclosed key '
         'hole of hit_70 col 3; walk8 stripes toned to the four-drawing hue. Cutter: tools/art/cast_thug_pack.py.')


def entry(action, pitch):
    path = VIEW / f'p{pitch}' / f'robot_thug_{action}.png'
    eight = action.startswith('planted8')
    refs = [f'gtai-art/foes-n26/thug8c/jobs.json#thug8c_{pitch}_{f}_t3' for f in ('down', 'dr', 'right', 'ur', 'up')]
    return dict(accepted_by='director (source sheets); cast lane (cut)', date=str(date.today()),
                file=path.relative_to(ROOT).as_posix(), human_edits=EDITS,
                model='built-in image_gen (image model not reported)',
                prompt_ref=refs[0] if eight else f'gtai-art/foes-n26/thug/jobs.json#thug_{action}_{pitch}',
                references=refs[1:] + ['gtai-art/foes-n26/thug/refs/plate.png'] if eight else ['gtai-art/foes-n26/thug/refs/plate.png'], seed=None,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest(), ships_in='core.pck', tool='codex-image')


if __name__ == '__main__':
    with open(ROOT / 'steam/ai-provenance/2026-11.jsonl', 'a', encoding='utf-8', newline='\n') as out:
        for action in ACTIONS:
            for pitch in (70, 55):
                out.write(json.dumps(entry(action, pitch), sort_keys=True) + '\n')

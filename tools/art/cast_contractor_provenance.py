"""Append one steam/ai-provenance/2026-11.jsonl line per shipped contractor PNG (run once, after the cut)."""
import hashlib
import json
from datetime import date

from cast_soles import ROOT, VIEW

ART = 'gtai-art/foes-n26'
SHEETS = ('armed_walk', 'attack', 'cast_hit', 'cast_fall', 'planted8_armed_walk')
EDITS = ('Keyed the green sheet, cut each drawing with its muzzle flash, scaled each facing to the patrol cop body '
         'height, anchored on the shared foot line and registered the eight-drawing walk on its torso point; one '
         'tone pass pulls the cream hard hat toward neutral (saturation x 0.3 on its cream blobs, same on every '
         'sheet). Fall: no rifle drawn (the game spawns the pickup); p70 also drops the second, floating hard hat '
         '(the head already wears one); p55 keeps the dropped hat and has the rifle against the vest in drawing 1 '
         'erased by hand-set polygon. Cutter: tools/art/cast_contractor_pack.py.')


def refs(sheet, pitch):
    if sheet == 'planted8_armed_walk':
        return [f'{ART}/contractor8c/jobs.json#contractor8c_{pitch}_{f}_t3' for f in ('down', 'dr', 'right', 'ur', 'up')]
    return [f'{ART}/contractor/jobs.json#contractor_{sheet.replace("cast_", "")}_{pitch}']


def entry(sheet, pitch):
    path = VIEW / f'p{pitch}/contractor_{sheet}.png'
    r = refs(sheet, pitch)
    return dict(accepted_by='director (source sheets); cast lane (cut)', date=str(date.today()),
                file=path.relative_to(ROOT).as_posix(), human_edits=EDITS,
                model='built-in image_gen (image model not reported)', prompt_ref=r[0],
                references=r[1:] + [f'{ART}/contractor/refs/plate.png'], seed=None,
                sha256=hashlib.sha256(path.read_bytes()).hexdigest(), ships_in='core.pck', tool='codex-image')


if __name__ == '__main__':
    with open(ROOT / 'steam/ai-provenance/2026-11.jsonl', 'a', encoding='utf-8', newline='\n') as out:
        for sheet in SHEETS:
            for pitch in (70, 55):
                out.write(json.dumps(entry(sheet, pitch), sort_keys=True) + '\n')

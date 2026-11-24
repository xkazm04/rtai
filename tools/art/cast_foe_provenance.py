"""Append one steam/ai-provenance/2026-11.jsonl line per shipped foe eight-drawing PNG."""
import argparse
import hashlib
import json
from datetime import date

from cast_foe_soles import SHEETS
from cast_soles import ROOT, VIEW

FOLDERS = {'riot': 'riot8c', 'swat': 'swat8c', 'swat_run': 'swat8run', 'lancer': 'lancer8'}
FACES = ('down', 'dr', 'right', 'ur', 'up')


def jobs(name, pitch):
    folder = FOLDERS[name]
    stem = {'riot': 'riot8c', 'swat': 'swat8c', 'swat_run': 'swat8run'}.get(name)
    if stem:
        ids = [f'{stem}_{pitch}_{face}_t3' for face in FACES]
    else:
        ids = [f'lancer8_armed_walk_{pitch}_a', f'lancer8_armed_walk_{pitch}_b']
    return [f'gtai-art/foes-n26/{folder}/jobs.json#{i}' for i in ids], folder


def entry(name, pitch, edits):
    path = VIEW / f'p{pitch}' / SHEETS[name][2]
    refs, folder = jobs(name, pitch)
    return dict(accepted_by='director (source sheets); cast lane (cut and tone)', date=str(date.today()),
                file=path.relative_to(ROOT).as_posix(), human_edits=edits,
                model='built-in image_gen (image model not reported)', prompt_ref=refs[0],
                references=[*refs[1:], f'gtai-art/foes-n26/{folder}/refs/camera_guide_{pitch}.png'],
                seed=None, sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                ships_in='core.pck', tool='codex-image')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('name', choices=sorted(SHEETS))
    args = parser.parse_args()
    edits = ('Keyed and cleaned the eight-drawing facings, scaled each facing to the shipped walk body '
             'height, aligned the upper body on the standing foot line, matched the shipped sheet blue. '
             'Cutter: tools/art/cast_foe_eight.py.')
    with open(ROOT / 'steam/ai-provenance/2026-11.jsonl', 'a', encoding='utf-8', newline='\n') as out:
        for pitch in (70, 55):
            out.write(json.dumps(entry(args.name, pitch, edits), sort_keys=True) + '\n')

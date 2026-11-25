"""Analyse cast_feet.tscn takes of the pile-driver on either walk (n29): the cast_feet.py analysis with the
war sheets read by their registered pads (cast_war_soles.sole, the CastWarAnchors tables): the four's lowest
band (contact = row // 2), the eight's foe-eight windows (contact = row // 4). --reader=n28 keeps cast_feet's
own pile_points reader for the four (the n28 audit's numbers). Writes feet_64_<reader>.json next to the takes.

usage: python tools/art/cast_war_feet.py <take-directory> <32|64> [--reader=pad|n28]
       python tools/art/cast_war_feet.py --film-soles <out.json>   (profile-column sole texels for the films)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

import cast_feet
from cast_soles import VIEW, cell, project
from cast_war_soles import EIGHT, NAME, ROWS, sole

_read_frame = cast_feet.read_frame


def read_frame(frame, take):
    card = frame.get('card') if isinstance(frame, dict) else None
    if not card or not card['path'].endswith(('/' + EIGHT, '/' + NAME)):
        return _read_frame(frame, take)
    if card['col'] != (2 if take['facing'] == 'right' else 1):
        raise ValueError('equipped card turned away from requested facing')
    name = card['path'].rsplit('/', 1)[-1]
    point = sole(cell(card['path'], tuple(card['rect'])), take['pitch'], card['col'], card['row'], name)
    return {str(card['row'] // (ROWS[name] // 2)): project(card, point)}


def film_soles(out):
    result = {name: {} for name in ROWS}
    for name, rows in ROWS.items():
        for pitch in (70, 55):
            mask = np.asarray(Image.open(VIEW / f'p{pitch}' / name))[:, :, 3] > 128
            cells = np.vsplit(np.hsplit(mask, 5)[2], rows)
            result[name][str(pitch)] = [[float(p[0]), float(p[1])] for p in
                                        (sole(c, pitch, 2, r, name) for r, c in enumerate(cells))]
    Path(out).write_text(json.dumps(result))


if __name__ == '__main__':
    if sys.argv[1] == '--film-soles':
        film_soles(sys.argv[2])
        sys.exit(0)
    reader = 'n28' if '--reader=n28' in sys.argv else 'pad'
    directory, ppm = Path(sys.argv[1]), int(sys.argv[2])
    if reader == 'pad':
        cast_feet.read_frame = read_frame
    cast_feet.run(directory, ppm, 'war_machine')
    name = 'feet.json' if ppm == 32 else 'feet_64.json'
    (directory / name).replace(directory / name.replace('.json', f'_{reader}.json'))

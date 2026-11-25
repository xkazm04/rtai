"""Analyse cast_feet.tscn takes of the door carrier on either walk (n29): the cast_feet.py analysis, with the
eight-drawing door strip read by its own soles (cast_door_soles: the profile slab bar dropped, contact = row // 4).

usage: python tools/art/cast_door_feet.py <take-directory> <32|64>
"""
import sys
from pathlib import Path

import cast_feet
from cast_door_soles import EIGHT, sole
from cast_soles import cell, project

_read_frame = cast_feet.read_frame


def read_frame(frame, take):
    card = frame.get('card') if isinstance(frame, dict) else None
    if not card or not card['path'].endswith('/' + EIGHT) or 'base' in frame:
        return _read_frame(frame, take)
    if card['col'] != (2 if take['facing'] == 'right' else 1):
        raise ValueError('equipped card turned away from requested facing')
    point = sole(cell(card['path'], tuple(card['rect'])), take['pitch'], card['col'], card['row'], EIGHT)
    return {str(card['row'] // 4): project(card, point)}


if __name__ == '__main__':
    cast_feet.read_frame = read_frame
    cast_feet.run(Path(sys.argv[1]), int(sys.argv[2]), 'shield_robot')

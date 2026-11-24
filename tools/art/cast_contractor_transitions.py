"""Contractor body jump (px at 32 px/m) through a stop, a turn and a reversal; sole slide after a stop."""
import json
import sys
from pathlib import Path

import numpy as np

from cast_feet import diameter, project, read_frame, torso

LEAD = 30  # the scene's walk-in ticks before the stop / turn / reversal starts


def sole_after_stop(take):
    """Travel of the support sole, in screen px, from the stop tick on: the drawing held there must not slide."""
    held = None
    points = []
    for f in take['frames'][LEAD:]:
        c = f['card']
        if held is None:
            held = (c['path'], c['row'], c['col'])
        if (c['path'], c['row'], c['col']) != held:
            return None, 'drawing changed after the stop'
        try:
            points.append(next(iter(read_frame(f, take).values())))
        except ValueError as e:
            return None, str(e)
    return diameter(points), held[1]


if __name__ == '__main__':
    out = Path(sys.argv[1])
    bad = 0
    for pitch in (70, 55):
        for take in json.loads((out / f'tracks_{pitch}_32.json').read_text()):
            bodies = [project(f['card'], torso(f['card']['path'], tuple(f['card']['rect']))) for f in take['frames']]
            jumps = np.linalg.norm(np.diff(bodies, axis=0), axis=1)
            line = [pitch, take['gait'], take['facing'], f'jump {jumps.max():.2f}',
                    'PASS' if jumps.max() <= 12 else 'FAIL', 'at frame', int(jumps.argmax())]
            bad += jumps.max() > 12
            if take['gait'] == 'stop':
                slide, row = sole_after_stop(take)
                line += ['sole slide after stop', 'n/a' if slide is None else f'{slide:.2f} px', f'(held row {row})']
                bad += slide is None or slide > 2
            print(*line)
    sys.exit(1 if bad else 0)

"""Largest body jump (screen px at 32 px/m) between rendered frames through a stop, a turn and a reversal."""
import json
import sys
from pathlib import Path

import numpy as np

from cast_feet import project, torso

if __name__ == '__main__':
    out = Path(sys.argv[1])
    for pitch in (70, 55):
        for take in json.loads((out / f'tracks_{pitch}_32.json').read_text()):
            bodies = []
            for f in take['frames']:
                c = f['card']
                bodies.append(project(c, torso(c['path'], tuple(c['rect']))))
            jumps = np.linalg.norm(np.diff(bodies, axis=0), axis=1)
            print(pitch, take['gait'], take['facing'], f'{jumps.max():.2f}', 'PASS' if jumps.max() <= 12 else 'FAIL',
                  'at frame', int(jumps.argmax()))

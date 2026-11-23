"""Measured patrol registration. Windows identify a shoe, all coordinates come from its alpha.

Columns are down, down-right, right, up-right and up. Four and eight show the trailing
toe in the walk. The run is airborne at those two drawings and has no planted point.
"""
import hashlib
from pathlib import Path
from statistics import mean

import numpy as np
from PIL import Image

from cast_soles import ROOT, VIEW, band, body_point

# Percent of opaque width. Use the bottom shoe unless both projections overlap.
FULL = (0, 100)
WINDOWS = {
    ('walk', 70): [
        [FULL, FULL, FULL, (15,44), FULL, FULL, FULL, (15,45)],
        [FULL, FULL, FULL, (5,29), FULL, FULL, FULL, (8,33)],
        [(32,73),(16,56),(15,56),(2,27),(36,75),(16,59),(10,41),(1,25)],
        [(40,80),(24,60),(35,75),(0,27),(45,82),(21,55),(2,38),(0,30)],
        [FULL,FULL,FULL,(16,48),FULL,FULL,FULL,(35,70)],
    ],
    ('walk', 55): [
        [FULL,FULL,FULL,(15,45),FULL,FULL,FULL,(43,70)],
        [FULL,FULL,FULL,(12,39),FULL,FULL,FULL,(6,31)],
        [(52,88),(33,71),(3,39),(0,24),(56,89),(39,74),(3,40),(0,27)],
        [(38,74),(28,63),(33,72),(0,32),(43,80),(28,62),(30,60),(0,32)],
        [FULL,FULL,FULL,(18,50),FULL,FULL,FULL,(45,76)],
    ],
    ('run', 70): [
        [FULL]*8,[FULL,FULL,(3,36),FULL,FULL,FULL,(2,35),FULL],
        [(37,72),(17,54),(0,22),FULL,(42,75),(17,60),(0,31),FULL],
        [FULL]*8,[FULL]*8,
    ],
    ('run', 55): [
        [FULL]*8,[(60,99),FULL,(0,23),FULL,(57,99),FULL,(0,26),FULL],
        [(64,96),(20,60),(0,22),FULL,(67,99),(8,47),(0,23),FULL],
        [FULL]*8,[FULL]*8,
    ],
}


def marks(mask, gait, pitch, col, row):
    limits = WINDOWS[gait, pitch][col][row]
    return band(mask, limits), body_point(mask)


def measure(path, gait, pitch):
    with Image.open(path) as im:
        mask = np.asarray(im)[:, :, 3] > 128
    h, w = mask.shape[0]//8, mask.shape[1]//5
    return [[marks(mask[r*h:(r+1)*h, c*w:(c+1)*w], gait, pitch, c, r)
             for r in range(8)] for c in range(5)]


def measure_step(tables):
    # Profile has no pitch foreshortening along travel. Fit one metre interval to
    # the four contact-to-passing displacements, after the rig's body-height scale.
    steps = []
    for pitch, grid in tables.items():
        metres_per_texel = {70: 1.7*1.12/192, 55: 2.0*1.08/192}[pitch]
        for row in (0,4):
            starts, ends = grid[2][row], grid[2][row+2]
            delta = (ends[1]-ends[0]) - (starts[1]-starts[0])
            steps.append(float(delta[0]) * metres_per_texel / 2)
    return mean(steps)


def generate():
    lines = ['class_name StreetPatrolAnchors', 'extends RefCounted',
             '## DO NOT EDIT. Measured from shipped alpha by tools/art/cast_patrol_soles.py.']
    for gait in ('walk','run'):
        tables = {}
        for pitch in (70,55):
            path = VIEW/f'p{pitch}/cop_patrol_planted8_armed_{gait}.png'
            grid = measure(path, gait, pitch)
            tables[pitch] = grid
            lines += [f'## {path.name} p{pitch} SHA-256', '## '+hashlib.sha256(path.read_bytes()).hexdigest(),
                      f'const {gait.upper()}{pitch}: Array[Vector4] = [']
            for col in grid:
                for sole, body in col:
                    # Coordinates relative to the card pivot at half width and 7/8 height.
                    sole = sole - [120, 224]
                    body = body - [120, 224]
                    lines.append(f'\tVector4({sole[0]:g}, {sole[1]:g}, {body[0]:g}, {body[1]:g}),')
            lines.append(']')
        step = measure_step(tables)
        print(gait, 'mean contact-to-passing profile advance per drawing, metres:', step)
        lines.append(f'const {gait.upper()}_M: float = {step:.4f}')
    (ROOT/'project/features/characters/street_patrol_anchors.gd').write_text(
        '\n'.join(lines)+'\n', encoding='utf-8', newline='\n')


if __name__ == '__main__':
    generate()

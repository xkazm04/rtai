"""Analyse rendered sprite transforms against visible sole ink in game-ready PNGs."""
import argparse
import json
from functools import lru_cache
from pathlib import Path

import numpy as np
from cast_soles import ROOT, band, body_point, cell, project, registered

CORE = {'patrol_cop', 'riot_cop', 'swat', 'robot_thug', 'robot_gunner', 'contractor',
        'sergeant_mulroney', 'appliance_warden'}


def diameter(points):
    points = np.asarray(points, dtype=float)
    return max(float(np.linalg.norm(points-point, axis=1).max()) for point in points)


def contact_stats(series, fixed=False):
    """Each index is a rendered frame. A support identity can survive a change of drawing."""
    spans = []
    for key in sorted({key for points in series for key in points}):
        start = None
        for i, points in enumerate([*series, {}]):
            if key in points and start is None:
                start = i
            if key in points or start is None:
                continue
            # Discard clipped contacts at the ends. A fixed apron uses the entire turn.
            if fixed or (start > 0 and i < len(series)):
                track = [frame[key].tolist() for frame in series[start:i]]
                spans.append(dict(boot=key, first=start, last=i-1, travel=diameter(track), dots=track))
            start = None
    if not spans:
        raise ValueError('no complete support span')
    result = max(span['travel'] for span in spans)
    return result, result <= (0 if fixed else 2), spans


@lru_cache(maxsize=512)
def torso(path, rect):
    return body_point(cell(path, rect))


@lru_cache(maxsize=256)
def outline(path, rect):
    return band(cell(path, rect))


@lru_cache(maxsize=512)
def rig_outline(path, rect, basis):
    # A cutout foot turns in the scene. Select the bottom band AFTER projection.
    ys, xs = np.nonzero(cell(path, rect))
    xx, xy, yx, yy = basis
    x = xx*(xs+.5) + yx*(ys+.5)
    y = xy*(xs+.5) + yy*(ys+.5)
    low = y.max()
    xs = x[y >= low-(low-y.min())*.05]
    return np.array([(xs.min()+xs.max())/2, low])


def pile_points(card, mask, pitch):
    # A visible flat pad can stay down across the wrap; the lifted pad shows
    # its dark underside. Read each pad separately when both bear weight.
    col, row = card['col'], card['row']
    if col == 2 and pitch == 70:
        # The rear pad is flat throughout this profile. Its near-identical
        # contact drawings do not resolve a left/right exchange.
        raise ValueError('rear pad stays flat in all four profile drawings; no identifiable lift')
    if col == 2:
        planted = [('left', (0, 40))] if row in (2, 3) else [('right', (45, 100))]
        if row in (0, 2):
            planted.append(('right', (45, 100)) if row == 2 else ('left', (0, 40)))
    elif pitch == 70:
        planted = []
        if row in (1, 2):
            planted.append(('left', (0, 39)))
        if row in (3, 0, 1):
            planted.append(('right', (53, 91)))
    else:
        planted = [('right', (49, 92))] if row in (0, 1) else [('left', (0, 39))]
        if row == 1:
            planted.append(('left', (0, 39)))
    return {key: project(card, band(mask, window)) for key, window in planted}


def read_frame(frame, take):
    if 'error' in frame:
        raise ValueError(frame['error'])
    if 'card' not in frame:
        points = {}
        for side, spr in enumerate(frame['feet']):
            if spr:
                point = rig_outline(spr['path'], tuple(spr['rect']), tuple(spr['xf'][2:]))
                points[str(side)] = np.asarray(spr['xf'][:2])+point
        return points
    card = frame['card']
    path, rect = card['path'], tuple(card['rect'])
    if 'base' in frame:
        base = frame['base']
        return {'apron': project(base, outline(base['path'], tuple(base['rect'])))}
    if card['col'] != (2 if take['facing'] == 'right' else 1):
        raise ValueError('equipped card turned away from requested facing')
    if not path.endswith('_walk.png'):
        raise ValueError('equipped drawing is not locomotion')
    if take['archetype'] == 'war_machine':
        points = pile_points(card, cell(path, rect), take['pitch'])
    else:
        point = registered(path, rect, card['col'], card['row'])
        points = {str(card['row']//2): project(card, point)}
    return points


def passes(travel, jump, fixed=False):
    return travel <= (0 if fixed else 2) and jump <= 12


def analyse(take):
    frames = take['frames']
    row = {k: v for k, v in take.items() if k != 'frames'}
    row.update(max_contact_travel_px=None, max_body_jump_px=None, verdict='FAIL')
    series, bodies, spans = [], [], []
    factor = 32/take['ppm']
    try:
        for f in frames:
            if 'error' in f:
                raise ValueError(f['error'])
            if 'card' in f:
                c = f['card']
                bodies.append(project(c, torso(c['path'], tuple(c['rect']))))
            else:
                bodies.append(f['torso'])
        row['max_body_jump_px'] = float(np.linalg.norm(np.diff(bodies, axis=0), axis=1).max())*factor
        for f in frames:
            points = read_frame(f, take)
            series.append({k: v*factor for k, v in points.items()})
        fixed = take['gait'] == 'sweep'
        travel, _, spans = contact_stats(series, fixed)
        if not fixed and len({s['boot'] for s in spans}) < 2:
            raise ValueError('only one side has a complete contact')
        if fixed and len({(f['card']['col'], f['card']['xf'][2] > 0) for f in frames}) < 8:
            raise ValueError('dome did not complete eight facing octants')
        passed = passes(travel, row['max_body_jump_px'], fixed)
        row.update(max_contact_travel_px=travel, verdict='PASS' if passed else 'FAIL')
    except ValueError as e:
        row['reason'] = str(e)
    row['contacts'] = len(spans)
    return row, spans


def number(x):
    return 'unmeasured' if x is None else f'{x:.2f}'


def run(directory, ppm, selection):
    cast = json.loads((ROOT/'project/data/tables/cast_cards.json').read_text())['archetypes']
    expected = set(selection.split(',')) if selection else CORE | {k for k, v in cast.items() if v['enabled']}
    rows = []
    for pitch in (70, 55):
        takes = json.loads((directory/f'tracks_{pitch}_{ppm}.json').read_text())
        seen = set()
        for take in takes:
            row, spans = analyse(take)
            if row['pitch'] != pitch or row['ppm'] != ppm:
                raise ValueError('capture scale or pitch mismatch')
            rows.append(row)
            seen.add((row['archetype'], row['facing']))
            print(row['archetype'], pitch, row['gait'], row['facing'],
                  number(row['max_contact_travel_px']), number(row['max_body_jump_px']),
                  row['verdict'], row.get('reason', ''))
            if ppm == 64 and row['gait'] == 'walk' and row['facing'] == 'right':
                trace = dict(tick=38, spans=spans, ppm=32, row=row)
                (directory/f"{row['archetype']}_{pitch}_dots.json").write_text(json.dumps(trace))
        required = {(k, f) for k in expected for f in ('right', 'down_right')}
        if seen != required:
            raise ValueError(f'roster coverage mismatch: {sorted(seen ^ required)}')
    name = 'feet.json' if ppm == 32 else 'feet_64.json'
    (directory/name).write_text(json.dumps(dict(schema='gtai.cast-feet/1', unit_ppm=32, rows=rows),
                                          indent=2, allow_nan=False)+'\n', encoding='utf-8')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    parser.add_argument('ppm', type=int, choices=(32, 64))
    parser.add_argument('selection', nargs='?', default='')
    args = parser.parse_args()
    run(args.directory, args.ppm, args.selection)

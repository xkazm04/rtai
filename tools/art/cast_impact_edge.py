"""Added dark pixels outside each card's hit pose at 64 px/m, hit flash on (pulse) and off (calm), plus the contact sheet.

usage: python cast_impact_edge.py <cast_impact_edge output dir> [sheet.png]
"""
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw

from cast_mulroney_edge import rim

ORDER = ['patrol_cop', 'riot_cop', 'swat', 'rocket_trooper', 'shield_robot', 'appliance_warden', 'robot_gunner']


def main(root, sheet=None):
    notes = {n['id']: n for n in json.loads((root / 'notes.json').read_text())}
    rows = {}
    for name in ORDER:
        rows[name] = {k: rim(root / f'edge_{name}_{k}') for k in ('pulse', 'calm')}
        print(name, 'pulse', rows[name]['pulse'], 'calm', rows[name]['calm'], notes.get(name, {}).get('texture'),
              'natural tint', notes.get(name, {}).get('natural_tint'))
    if sheet:
        w, h = 384, 320
        out = Image.new('RGB', (w * 4, (h + 24) * 4), (40, 40, 40))
        draw = ImageDraw.Draw(out)
        for i, name in enumerate(ORDER):
            for j, kind in enumerate(('pulse', 'calm')):
                x, y = (i % 4) * w, (i // 4) * 2 * (h + 24) + j * (h + 24)
                draw.text((x + 4, y + 4), f'{name} {kind} dark px {rows[name][kind]} ({notes.get(name, {}).get("texture")})',
                          fill=(255, 255, 255))
                out.paste(Image.open(root / f'edge_{name}_{kind}' / 'live.png').convert('RGB'), (x, y + 24))
        out.save(sheet)


if __name__ == '__main__':
    main(Path(sys.argv[1]), sys.argv[2] if len(sys.argv) > 2 else None)


def hue_counts(folder):
    """Red/vermilion and teal px inside the figure (live vs ground differs): hue 345-15 S>=.45 V>=.35; hue 160-200 S>=.35."""
    import colorsys
    live, ground = [Image.open(folder / n).convert('RGB') for n in ('live.png', 'ground.png')]
    red = teal = 0
    for a, b in zip(live.getdata(), ground.getdata()):
        if max(abs(a[i] - b[i]) for i in range(3)) <= 22:
            continue
        h, s, v = colorsys.rgb_to_hsv(*(c / 255 for c in a))
        h *= 360
        red += (h >= 345 or h <= 15) and s >= .45 and v >= .35
        teal += 160 <= h <= 200 and s >= .35
    return int(red), int(teal)


def hue_table(root):
    for name in ('shield_robot', 'robot_gunner', 'rocket_trooper'):
        c = hue_counts(root / f'edge_{name}_calm')
        p = hue_counts(root / f'edge_{name}_pulse')
        print(f'{name} red/teal calm {c} flashed {p} delta ({p[0] - c[0]}, {p[1] - c[1]})')


def strip(roots, out_path):
    """One contact sheet: rows pulse and calm, columns lancer ref, door carrier, gunner, per root."""
    w, h = 384, 320
    cols = [(r, n) for r in roots for n in ('rocket_trooper', 'shield_robot', 'robot_gunner')]
    out = Image.new('RGB', (w * len(cols), (h + 24) * 2), (40, 40, 40))
    draw = ImageDraw.Draw(out)
    for i, (r, name) in enumerate(cols):
        for j, kind in enumerate(('pulse', 'calm')):
            draw.text((i * w + 4, j * (h + 24) + 4), f'{r.name} {name} {kind}', fill=(255, 255, 255))
            out.paste(Image.open(r / f'edge_{name}_{kind}' / 'live.png').convert('RGB'), (i * w, j * (h + 24) + 24))
    out.save(out_path)

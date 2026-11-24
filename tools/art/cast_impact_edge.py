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

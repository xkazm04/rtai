"""n30 span shadow: which stand points have Rivet's feet on solid span art (alpha >= 0.5), the
same test as PrologueSpanShadow.on_span (footprint box, full crop, rotation 0 for every span).
python -I evidence/yard30/span_mask.py <targets.txt>"""
import json, sys
import numpy as np
from PIL import Image
rows = json.load(open('project/data/tables/prologue_yard_dressings.json', encoding='utf-8'))['dressings']['arched_line']['layout']['debris']
spans = [r for r in rows if r['id'].startswith('span_')]
masks = [(r, np.asarray(Image.open(r['art'].replace('res://', 'project/')).convert('RGBA'))[..., 3] >= 128) for r in spans]
def on(x, y):
    for r, a in masks:
        (cx, cy), (w, h) = r['at'], r['size_m']
        u, v = (x - cx + w / 2) / w, (y - cy + h / 2) / h
        if 0 <= u < 1 and 0 <= v < 1 and a[int(v * a.shape[0]), int(u * a.shape[1])]:
            return r['id']
    return None
for t in open(sys.argv[1]).read().strip().split(','):
    k, x, y = t.split(':')
    if k == 'rivet':
        print(t, on(float(x), float(y)))

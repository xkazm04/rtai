"""n30 span shadow: n29's belt_under_span.py Rivet measure, before (shadow hidden) vs after (shadow shown).
python -W ignore -I evidence/yard30/span_shadow_measure.py <dir arched_line> <dir arched_nospan>
Probe: evidence/yard30/span_stand_probe.gd.txt. Per stand point the arched_line dir has <lab>.png (shadow faded in),
<lab>_off.png (shadow hidden = the look before the shadow) and <lab>_ground.png (actors AND shadow hidden: no Rivet, no
shadow); the nospan dir is the temp row arched_line minus the five span_* rows (no spans, so no shadow node).
Span pixels = where the two ground frames differ (as n29). Rivet box as n29: |dx| <= 30, -60..+14 px round the feet.
  before: body = box & |off - ground| > 14, m = body & span, |mean lum(off)[m] - mean lum(ground)[m]|  (= n29's number)
  after:  body = box & |on - ground| > 14 (Rivet plus his shadow: the ground frame has neither), same formula on <lab>.png
  floor:  the nospan frames over the same m as n29 (before mask); the after mask is printed too.
feet_on = the stand point's feet fall on solid span art (the shadow's own test); the bar is read on those, all 28 printed.
floor_px = pixels where <lab>.png and <lab>_off.png differ OUTSIDE the span pixels (the shadow must never reach the floor)."""
import json, sys
from pathlib import Path
import numpy as np
from PIL import Image

def lum(rgb):
    s = rgb / 255.0
    return (np.where(s <= 0.04045, s / 12.92, ((s + 0.055) / 1.055) ** 2.4)) @ [0.2126, 0.7152, 0.0722]
ld = lambda p: np.asarray(Image.open(p).convert("RGB"), dtype=float)
A, N = Path(sys.argv[1]), Path(sys.argv[2])
yy, xx = np.mgrid[0:1080, 0:1920]
rows = []
for fr in json.loads((A / "sample_points.json").read_text())["frames"]:
    lab = fr["frame"]
    if not lab.endswith("_rivet"):
        continue
    on, off, ga = ld(A / f"{lab}.png"), ld(A / f"{lab}_off.png"), ld(A / f"{lab}_ground.png")
    hn, gn = ld(N / f"{lab}.png"), ld(N / f"{lab}_ground.png")
    span = abs(ga - gn).max(axis=2) > 6
    p = [q for q in fr["points"] if q["kind"] == "rivet"][0]
    x, y = p["xy"]
    if not (40 < x < 1880 and 80 < y < 1040):
        continue
    box = (abs(xx - x) <= 30) & (yy >= y - 60) & (yy <= y + 14)
    for q in fr["points"]:
        if q is not p:
            box &= (abs(xx - q["xy"][0]) > 24) | (abs(yy - q["xy"][1]) > 24)
    shadow = abs(on - off).max(axis=2) > 2
    feet_on = bool(shadow.any())
    floor_px = int((shadow & ~span).sum())
    m0 = box & (abs(off - ga).max(axis=2) > 14) & span
    m1 = box & (abs(on - ga).max(axis=2) > 14) & span
    if m0.sum() < 150:
        continue
    d = lambda h, g, m: abs(lum(h)[m].mean() - lum(g)[m].mean())
    rows.append((lab, p["pos_m"], feet_on, int(m0.sum()), int(m1.sum()), d(off, ga, m0), d(on, ga, m1), d(hn, gn, m0), d(hn, gn, m1), floor_px, int(shadow.sum())))
print("frame pos_m feet_on px_before px_after before after floor floor_after_mask shadow_px_off_span shadow_px")
for r in rows:
    print(f"{r[0]} {r[1][0]:.2f},{r[1][1]:.2f} {int(r[2])} {r[3]} {r[4]} {r[5]:.4f} {r[6]:.4f} {r[7]:.4f} {r[8]:.4f} {r[9]} {r[10]}")
for name, sel in (("all", rows), ("feet_on", [r for r in rows if r[2]]), ("feet_off", [r for r in rows if not r[2]])):
    if sel:
        mean = lambda i: float(np.mean([r[i] for r in sel]))
        print(f"SUMMARY {name}: {len(sel)} samples, span before {mean(5):.4f}, after {mean(6):.4f}, floor-only {mean(7):.4f} "
              f"(after mask {mean(8):.4f}), shadow px off the span {sum(r[9] for r in sel)}")

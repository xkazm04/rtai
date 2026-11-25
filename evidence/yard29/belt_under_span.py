"""n29 belt-finish: readability under a span. python -W ignore -I evidence/yard29/belt_under_span.py <dir arched_line> <dir arched_nospan>
Both dirs are --dusk captures of the SAME sim (spans are non-blocking over-print: result.json identical). Span pixels = where the two
actor-hidden ground frames differ. For every patrol cop / Rivet whose body (box of rivet_delta.py: |dx|<=30, -60..+14 px round the feet point;
body = |hero - ground| > 14, minus 24 px round any other point) has >= 150 body pixels over span pixels:
  patrol: mean WCAG contrast ratio (L1+.05)/(L2+.05) of the cop's blue-mask pixels over span pixels vs the ground under them, as dusk_contrast.py;
  rivet: |mean lum(body) - mean lum(ground under)| (rivet_delta.py). span = arched_line frame, floor = nospan frame, same pixels
  retained % = span / floor. Rivet delta is the same number for Rivet. Prints a table and a summary."""
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
    if not (A / f"{lab}_ground.png").exists() or not (N / f"{lab}_ground.png").exists():
        continue
    ha, ga, hn, gn = ld(A / f"{lab}.png"), ld(A / f"{lab}_ground.png"), ld(N / f"{lab}.png"), ld(N / f"{lab}_ground.png")
    span = abs(ga - gn).max(axis=2) > 6
    for p in fr["points"]:
        # only the actor stood on the span in this exposure (frame label s<n>_rivet / s<n>_cop); a --dusk capture has none of these suffixes
        sub = lab.rsplit("_", 1)[-1]
        if p["kind"] not in ("rivet", "patrol_cop") or (sub in ("rivet", "cop") and p["kind"] != {"rivet": "rivet", "cop": "patrol_cop"}[sub]):
            continue
        if sub == "cop" and p["kind"] == "patrol_cop" and p["id"] != min(q["id"] for q in fr["points"] if q["kind"] == "patrol_cop"):
            continue
        x, y = p["xy"]
        if not (40 < x < 1880 and 80 < y < 1040):
            continue
        box = (abs(xx - x) <= 30) & (yy >= y - 60) & (yy <= y + 14)
        for q in fr["points"]:
            if q is not p and (abs(xx - q["xy"][0]) <= 24) & (abs(yy - q["xy"][1]) <= 24) is not None:
                box &= (abs(xx - q["xy"][0]) > 24) | (abs(yy - q["xy"][1]) > 24)
        body = box & (abs(ha - ga).max(axis=2) > 14)
        if p["kind"] == "patrol_cop":
            # dusk_contrast.py's patrol mask: the daylight blue of the cop's own pixels (b > r + 13, b > g + 6), cop box 64 x 80 at (x-32, y-64)
            r, g, b = ha[..., 0], ha[..., 1], ha[..., 2]
            cop = (abs(xx - x) < 16) & (yy >= y - 55) & (yy < y - 15) & (b > r + 13) & (b > g + 6) & (abs(ha - ga).max(axis=2) > 6)
            m = cop & span
            if m.sum() < int(__import__("os").environ.get("MINPX", 150)):
                continue
            wcag = lambda f, g_: float(np.mean((np.maximum(lum(f)[m], lum(g_)[m]) + 0.05) / (np.minimum(lum(f)[m], lum(g_)[m]) + 0.05)))
            sc, fc = wcag(ha, ga), wcag(hn, gn)
        else:
            m = body & span
            if m.sum() < int(__import__("os").environ.get("MINPX", 150)):
                continue
            sc = abs(lum(ha)[m].mean() - lum(ga)[m].mean()); fc = abs(lum(hn)[m].mean() - lum(gn)[m].mean())
        rows.append((lab, p["kind"], p["id"], int(m.sum()), int(body.sum()), sc, fc))
print("frame kind id px_over_span body_px span_contrast floor_contrast retained_%")
for r in rows:
    print(f"{r[0]} {r[1]} {r[2]} {r[3]} {r[4]} {r[5]:.4f} {r[6]:.4f} {100 * r[5] / r[6] if r[6] else float('nan'):.1f}")
for k in ("patrol_cop", "rivet"):
    s = [r for r in rows if r[1] == k]
    if s:
        print(f"SUMMARY {k}: {len(s)} samples, span mean {np.mean([r[5] for r in s]):.4f}, floor-only mean {np.mean([r[6] for r in s]):.4f}, "
              f"retained (ratio of means) {100 * np.mean([r[5] for r in s]) / np.mean([r[6] for r in s]):.1f} %, min per-sample {min(100 * r[5] / r[6] for r in s if r[6]):.1f} %")

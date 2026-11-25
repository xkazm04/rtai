"""python -W ignore -I evidence/yard29/gate_lamp_gain.py <lamp x> <dir>...: gate-lamp pool gain = mean floor L* within 3 m of the lamp minus the ring 6..8 m, dusk ground frames (sweep_measure geometry)."""
import json, sys
from pathlib import Path
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
import floor_warmth_lib as fw
lx, ly = float(sys.argv[1]), 32.3
ky = 32 * np.sin(np.radians(70))
for a in sys.argv[2:]:
    inn, ring = [], []
    for fr in json.loads((Path(a) / "dusk/sample_points.json").read_text())["frames"]:
        riv = [p for p in fr["points"] if p["kind"] == "rivet"]
        f = Path(a) / "dusk" / f"{fr['frame']}_ground.png"
        if not riv or not f.exists():
            continue
        x, y = riv[0]["xy"]; rx, ry = riv[0]["pos_m"]
        cx, cy = rx - (x - 960) / 32.0, ry - (y - 540) / ky
        L, aa, bb = fw.lab(fw.load_half(f))
        wx, wy = fw.world(cx, cy, ky / 2)
        m = fw.floor_mask(L, np.hypot(aa, bb), wy, "mid")
        d = np.hypot(wx - lx, wy - ly)
        inn.append(L[m & (d <= 3)]); ring.append(L[m & (d >= 6) & (d <= 8)])
    i = np.concatenate(inn); r = np.concatenate(ring)
    print(a, "in px", len(i), "L", round(float(i.mean()), 2) if len(i) else None, "ring px", len(r), "L", round(float(r.mean()), 2) if len(r) else None, "gain", round(float(i.mean() - r.mean()), 2) if len(i) and len(r) else None)

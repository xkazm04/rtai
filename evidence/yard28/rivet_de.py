"""Rivet's hue/chroma separation from the floor under him: CIEDE2000 between the mean CIELAB of his body pixels and of the
floor pixels under the same mask (rivet_delta.py's mask: |hero - ground| > 14 in a 60 x 74 px box round his feet, 24 px round
any cop removed), averaged over the exposures. Also dL* (body - floor). python -W ignore -I evidence/yard28/rivet_de.py <dir>..."""
import json, math, sys
from pathlib import Path
import numpy as np
from PIL import Image
def lab1(rgb):
    c = np.asarray(rgb, dtype=np.float64) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    m = np.array([[0.4124564, 0.3575761, 0.1804375], [0.2126729, 0.7151522, 0.0721750], [0.0193339, 0.1191920, 0.9503041]])
    xyz = m @ c / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 216 / 24389, np.cbrt(xyz), (24389 / 27 * xyz + 16) / 116)
    return 116 * f[1] - 16, 500 * (f[0] - f[1]), 200 * (f[1] - f[2])
def de2000(l1, l2):
    L1, a1, b1 = l1; L2, a2, b2 = l2
    C1, C2 = math.hypot(a1, b1), math.hypot(a2, b2); Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt(Cb ** 7 / (Cb ** 7 + 25 ** 7)))
    a1p, a2p = (1 + G) * a1, (1 + G) * a2
    C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1 = math.degrees(math.atan2(b1, a1p)) % 360; h2 = math.degrees(math.atan2(b2, a2p)) % 360
    dL, dC = L2 - L1, C2p - C1p
    dh = h2 - h1
    dh = dh - 360 if dh > 180 else dh + 360 if dh < -180 else dh
    dH = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dh / 2))
    Lb, Cbp = (L1 + L2) / 2, (C1p + C2p) / 2
    hb = (h1 + h2) / 2 if abs(h1 - h2) <= 180 else (h1 + h2 + 360) / 2 if h1 + h2 < 360 else (h1 + h2 - 360) / 2
    T = 1 - 0.17 * math.cos(math.radians(hb - 30)) + 0.24 * math.cos(math.radians(2 * hb)) + 0.32 * math.cos(math.radians(3 * hb + 6)) - 0.20 * math.cos(math.radians(4 * hb - 63))
    Sl = 1 + 0.015 * (Lb - 50) ** 2 / math.sqrt(20 + (Lb - 50) ** 2); Sc = 1 + 0.045 * Cbp; Sh = 1 + 0.015 * Cbp * T
    Rt = -2 * math.sqrt(Cbp ** 7 / (Cbp ** 7 + 25 ** 7)) * math.sin(math.radians(60 * math.exp(-(((hb - 275) / 25) ** 2))))
    return math.sqrt((dL / Sl) ** 2 + (dC / Sc) ** 2 + (dH / Sh) ** 2 + Rt * (dC / Sc) * (dH / Sh))
for arg in sys.argv[1:]:
    root = Path(arg); rows = []
    for fr in json.loads((root / "sample_points.json").read_text())["frames"]:
        riv = [p for p in fr["points"] if p["kind"] == "rivet"]
        if not riv: continue
        x, y = riv[0]["xy"]
        if not (40 < x < 1880 and 80 < y < 1040): continue
        l, t = x - 30, max(0, y - 60); box = (max(0, l), t, x + 31, y + 15)
        hero = np.asarray(Image.open(root / f"{fr['frame']}.png").convert("RGB").crop(box), dtype=np.int16)
        ground = np.asarray(Image.open(root / f"{fr['frame']}_ground.png").convert("RGB").crop(box), dtype=np.int16)
        yy, xx = np.mgrid[box[1]:box[3], box[0]:box[2]]
        keep = (yy >= y - 60) & (yy <= y + 14)
        for p in fr["points"]:
            if p["kind"] != "rivet": keep &= (abs(xx - p["xy"][0]) > 24) | (abs(yy - p["xy"][1]) > 24)
        mask = keep & (np.abs(hero - ground).max(axis=2) > 14)
        if mask.sum() < 150: continue
        lb, lf = lab1(hero[mask].mean(0)), lab1(ground[mask].mean(0))
        rows.append((fr["tick"], de2000(lb, lf), lb[0] - lf[0], lb, lf))
    print(f"{arg}: dE2000 mean {np.mean([r[1] for r in rows]):.1f} (min {min(r[1] for r in rows):.1f}) dL* mean {np.mean([r[2] for r in rows]):+.1f} over {len(rows)} exposures; "
          f"body Lab {np.round(np.mean([r[3] for r in rows], 0), 1).tolist()} floor Lab {np.round(np.mean([r[4] for r in rows], 0), 1).tolist()}")

"""Floor warmth of the yard stills: fire-pool core vs between pools, n26 light vs HEAD light.

Usage: python -W ignore -I evidence/yard27/floor_warmth.py build/films27 > evidence/yard27/floor_warmth.txt
Stills are the 1920x1080, 32 px/m top-down yard_film frames (ls_n26_*, ls_head_*), camera centred on
`at`, so world = at + (px - (960, 540)) / 32.
"""
import json, sys
from pathlib import Path
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

PPM = 32.0
FRAMES = {"mid t2290": ("mid", (35.21, 19.93)), "front t2858": ("front", (26.0, 3.0))}
VARIANTS = {"n26 light": "n26", "HEAD light": "head"}
dress = json.loads(Path("project/data/tables/prologue_yard_dressings.json").read_text())["dressings"]["raised_line"]
POOLS = [(p["id"], p["kind"], p["at"]) for p in dress["lights"]["pools"]]

def lab(rgb):
    c = rgb.astype(np.float64) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    m = np.array([[0.4124564, 0.3575761, 0.1804375], [0.2126729, 0.7151522, 0.0721750], [0.0193339, 0.1191920, 0.9503041]])
    xyz = c @ m.T / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 216 / 24389, np.cbrt(xyz), (24389 / 27 * xyz + 16) / 116)
    return 116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])

def floor_mask(L, C, h, wx, wy, place):
    """Concrete only: inside the yard rect, no actor/prop/paint/stain/shadow pixel (dark, saturated, or far from the local floor tone)."""
    med = ndi.median_filter(L[::2, ::2], size=21)
    med = np.kron(med, np.ones((2, 2)))[: L.shape[0], : L.shape[1]]
    obstacle = (L < med - 14) | (L > med + 14) | (C > 48) | (L < 30)
    obstacle = ndi.binary_dilation(obstacle, iterations=5)
    yx = np.indices(L.shape)
    px, py = yx[1], yx[0]
    inside = (px > 135) & (px < 1735) & (py > 20) & (py < 880)
    if place == "front":
        inside &= wy > 0.6          # below the factory front wall and its rubble apron
    return inside & ~obstacle

def stats(L, a, b, m):
    C = np.hypot(a, b)
    hue = np.degrees(np.arctan2(b, a)) % 360
    ha = np.degrees(np.arctan2(b[m].mean(), a[m].mean())) % 360  # hue of mean a*, b*
    return int(m.sum()), L[m].mean(), C[m].mean(), ha

out = [__doc__.strip(), ""]
out.append("Method: floor mask = pixels inside the yard rect (px x 135..1735, y 20..880; front frame also world y > 0.6 m, below the wall rubble) that are not within 5 px of a pixel that is dark (L* < 30), saturated (C* > 48: paint, blood, orange props) or more than 14 L* from the 21 px local median (shadows, stains, prop edges, actor edges). The same mask rule runs per frame; masks differ a little between n26 and HEAD because the light moves the local median.")
out.append("Core = within 3 m of a yard_fire or yard_fire_mid pool centre (raised_line pools, 11 in all). Between = more than 12 m from every pool (fires and lamps). Hue is the angle of the mean (a*, b*) in CIELAB, 0 = red-magenta, 90 = yellow; C* is mean chroma; L* mean lightness (D65, sRGB).")
out.append("")
out.append("| frame | light | zone | pixels | L* | C* | hue deg |")
out.append("|---|---|---|---:|---:|---:|---:|")
table = {}
for fname, (place, at) in FRAMES.items():
    for vname, tag in VARIANTS.items():
        rgb = np.array(Image.open(Path(sys.argv[1]) / f"ls_{tag}_{place}.png").convert("RGB"))
        L, a, b = lab(rgb)
        C = np.hypot(a, b)
        yx = np.indices(L.shape)
        wx = at[0] + (yx[1] - 960) / PPM
        wy = at[1] + (yx[0] - 540) / PPM
        fm = floor_mask(L, C, None, wx, wy, place)
        dmin_fire = np.full(L.shape, 1e9); dmin_all = np.full(L.shape, 1e9)
        for pid, kind, (x, y) in POOLS:
            d = np.hypot(wx - x, wy - y)
            dmin_all = np.minimum(dmin_all, d)
            if kind in ("yard_fire", "yard_fire_mid"):
                dmin_fire = np.minimum(dmin_fire, d)
        zones = {"core (<= 3 m of a fire)": fm & (dmin_fire <= 3.0), "between (> 12 m of all)": fm & (dmin_all > 12.0)}
        for zname, m in zones.items():
            if m.sum() < 500:
                out.append(f"| {fname} | {vname} | {zname} | {int(m.sum())} | too few | | |")
                continue
            n, l, c, h = stats(L, a, b, m)
            table[(fname, vname, zname)] = (l, c, h)
            out.append(f"| {fname} | {vname} | {zname} | {n} | {l:.1f} | {c:.1f} | {h:.1f} |")
out.append("")
out.append("Warm-up (HEAD minus n26):")
for fname in FRAMES:
    for zname in ("core (<= 3 m of a fire)", "between (> 12 m of all)"):
        k0, k1 = (fname, "n26 light", zname), (fname, "HEAD light", zname)
        if k0 in table and k1 in table:
            d = [x - y for x, y in zip(table[k1], table[k0])]
            out.append(f"- {fname}, {zname}: dL* {d[0]:+.1f}, dC* {d[1]:+.1f}, dhue {d[2]:+.1f} deg")
print("\n".join(out))

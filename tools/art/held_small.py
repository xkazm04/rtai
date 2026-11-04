"""Held parts re-toned for gameplay scale (weapon-art lane, iteration 12, 2026-11-04).

In Rivet's claw at 32-48 px/m every gun printed as the same dark ink lozenge. Cause (measured):
the print shader (print_part.gdshader) posterizes small parts hard (ink at density >= ~0.43 at
48 px/m), and the held guns' body tones sit at a median luminance of 101-123 while Rivet's own
D4 parts sit at 180-200. So the gun body crossed into solid ink and took its inner shapes along.

`held_small.png` is the held part on the SAME canvas (grip_px, muzzle_px, length_px stay valid)
with the body lifted into Rivet's tone budget: a luminance curve that keeps the darkest ink
(outlines, bores, slots) and lifts the mid tones by an additive shift, so a rust pixel keeps its
red lead (never crosses the vermilion gate) and real vermilion (hazard bands) stays vermilion.
WeaponArt.make_held swaps to it below `held_small_below_ppm` (weapon_art.json).

    python tools/art/held_small.py <weapon_art_dir> [ids...]
    python tools/art/held_small.py --sim <out.png> <weapon_art_dir> [ids...]   (print preview)
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image

KEEP_INK = 52.0  # luminance at or below this stays as drawn (outlines, bores)
TARGET_MID = 186.0  # where the body's median luminance lands (Rivet's D4 claw: 185)
SOFT = 34.0  # luminance band over which the lift fades in above KEEP_INK
FLAT = 0.45  # the body's tone spread around TARGET_MID (1 = as drawn): flatter reads cleaner small
EDGE = 9  # part px of ink inked along the silhouette (about 1 screen px at 48 px/m)
LW = np.array([0.299, 0.587, 0.114])


def retone(rgba):
    a = rgba.astype(float)
    rgb, alpha = a[..., :3], a[..., 3]
    lum = rgb @ LW
    body = (alpha > 128) & (lum > KEEP_INK)
    mid = float(np.median(lum[body]))
    want = TARGET_MID + (lum - mid) * FLAT
    w = np.clip((lum - KEEP_INK) / SOFT, 0.0, 1.0)
    out = rgb + ((want - lum) * w)[..., None]
    out = np.where(_edge(alpha)[..., None], np.array([27.0, 21.0, 23.0]), out)
    out = np.clip(out, 0, 255)
    return np.dstack([out, alpha]).astype(np.uint8), TARGET_MID - mid


def _edge(alpha):
    """Opaque pixels within EDGE px of the silhouette (a square erosion, done by shifts)."""
    solid = alpha > 128
    inner = solid.copy()
    for dy in range(-EDGE, EDGE + 1, 3):
        for dx in range(-EDGE, EDGE + 1, 3):
            if dx * dx + dy * dy <= EDGE * EDGE:
                inner &= np.roll(np.roll(solid, dy, 0), dx, 1)
    return solid & ~inner


# --- print preview: the shader's D4 path at gameplay scale, for checking without Godot --------
CREAM = np.array([0.949, 0.910, 0.835])
INK = np.array([0.090, 0.075, 0.106])
VERM = np.array([0.910, 0.314, 0.165])


def print_sim(rgba, screen_scale, px_scale):
    w, h = rgba.shape[1], rgba.shape[0]
    size = (max(1, round(w * screen_scale)), max(1, round(h * screen_scale)))
    im = Image.fromarray(rgba).resize(size, Image.Resampling.BOX)
    a = np.asarray(im).astype(float)
    c, al = a[..., :3] / 255.0, a[..., 3] / 255.0
    lum = c @ LW
    lc, li = CREAM @ LW, INK @ LW
    d = np.clip((lc - lum) / (lc - li), 0, 1)
    t = np.clip((px_scale - 0.12) / 0.18, 0, 1)
    small = 1 - t * t * (3 - 2 * t)
    lo, hi = 0.30 + (0.36 - 0.30) * small, 0.78 + (0.40 - 0.78) * small
    cov = np.clip((d - lo) / (hi - lo), 0, 1)
    k = (0.30 + (0.62 - 0.30) * cov)[..., None]
    o = CREAM * (1 - k) + INK * k
    o = np.where((d >= hi)[..., None], INK, o)
    o = np.where((d <= lo)[..., None], CREAM, o)
    vr = (c[..., 0] - np.maximum(c[..., 1], c[..., 2])) * 255
    o = np.where((vr > 62)[..., None], VERM, o)
    bg = np.array([0.47, 0.44, 0.43])
    o = np.where((al >= 0.45)[..., None], o, bg)
    return Image.fromarray((o * 255).astype(np.uint8))


def main(argv):
    sim = None
    if argv and argv[0] == "--sim":
        sim, argv = argv[1], argv[2:]
    root = Path(argv[0])
    ids = argv[1:] or ["pistol", "machine_pistol", "hand_cannon", "gloria"]
    import json

    rows = {r["id"]: r for r in json.loads((root.parents[3] / "data/tables/weapon_art.json").read_text())["weapons"]}
    tiles = []
    for wid in ids:
        src = root / wid / "held.png"
        rgba = np.asarray(Image.open(src).convert("RGBA"))
        small, lift = retone(rgba)
        if sim is None:
            Image.fromarray(small).save(root / wid / "held_small.png", optimize=True)
            print(f"{wid}: lift {lift:+.0f}")
            continue
        r = rows[wid]
        ws = r["length_m"] * 32.0 / r["length_px"] * 1.2
        for zoom in (1.0, 1.5):
            sc = ws * zoom
            tiles.append((wid, zoom, print_sim(rgba, sc, 0.1 * zoom), print_sim(small, sc, 0.1 * zoom)))
    if sim:
        _sheet(tiles, sim)


def _sheet(tiles, out):
    pad, k = 6, 6
    cw = max(t[2].width for t in tiles) * k + pad
    ch = max(t[2].height for t in tiles) * k + pad
    sheet = Image.new("RGB", (cw * 2 + pad, ch * len(tiles) + pad), (242, 232, 213))
    for i, (_wid, _z, before, after) in enumerate(tiles):
        for j, im in enumerate((before, after)):
            big = im.resize((im.width * k, im.height * k), Image.Resampling.NEAREST)
            sheet.paste(big, (pad + j * cw, pad + i * ch))
    sheet.save(out)


if __name__ == "__main__":
    main(sys.argv[1:])

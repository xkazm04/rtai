"""SWAT look parts for the cop rig (human-reactions REQUEST 1), derived, no generation.

head_swat  = head_cap's footprint and pivots: the cream crown becomes a dark gunmetal shell, the
             brim band a pale visor band (the reverse of the patrol cap's tones, so the three cop
             heads read apart at 32 px/m), plus two ink side rails.
torso_swat = torso's footprint and pivots: the blue shirt stays the main fill; a plate carrier
             (a darker blue plate with an ink rim) and three ink pouches with paper flap lines.
Both the D4 set (art/cop, flat fills) and the D5 set (art/d5/cop, the hatching kept by
modulating each new fill with the source part's own luminance). No red, no vermilion.

    python tools/art/swat_parts.py
"""

import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path("project/features/characters/art")
SETS = ["cop", "d5/cop"]
INK = np.array([27, 21, 23], float)
PAPER2 = np.array([233, 220, 195], float)
SHELL = np.array([58, 60, 72], float)  # gunmetal: ink lifted toward cop blue
PLATE = np.array([38, 50, 78], float)  # cop blue, one step darker
HEAD = '[remap]\n\nimporter="texture"\ntype="CompressedTexture2D"\n\n[params]'
POUCH = np.array([34, 28, 38], float)


def lum(rgb):
    return rgb @ np.array([0.299, 0.587, 0.114])


def textured(base_rgb, mask, color):
    """color modulated by the source's luminance under mask (D5 keeps its hatching, D4 stays flat)."""
    l = lum(base_rgb)
    med = np.median(l[mask]) if mask.any() else 1.0
    k = np.clip(l / max(med, 1.0), 0.8, 1.2)[..., None]
    return np.clip(color[None, None, :] * k, 0, 255)


def head_swat(src):
    a = np.array(src).astype(float)
    rgb, al = a[..., :3], a[..., 3]
    solid = al > 128
    l = lum(rgb)
    sat = rgb.max(-1) - rgb.min(-1)
    band = solid & (sat > 25) & (rgb[..., 2] > rgb[..., 0] + 15)  # the blue brim band and the badge dot
    crown = solid & ~band & (l > 75) & (sat <= 40)  # the cream crown and its grey hatching
    out = rgb.copy()
    out[crown] = textured(rgb, crown, SHELL)[crown]
    out[band] = textured(rgb, band, PAPER2)[band]
    img = Image.fromarray(np.dstack([out, al]).astype(np.uint8), "RGBA")
    d = ImageDraw.Draw(img)
    h = img.height
    for y in (int(h * 0.22), int(h * 0.78) - 10):  # side rails across the shell
        d.rounded_rectangle((34, y, 84, y + 10), 4, fill=tuple(INK.astype(int)) + (255,))
    d.line((40, h // 2, 70, h // 2), fill=tuple(PAPER2.astype(int)) + (255,), width=4)  # crest seam
    return img


def torso_swat(src):
    a = np.array(src).astype(float)
    rgb, al = a[..., :3], a[..., 3]
    solid = al > 128
    blue = solid & (rgb[..., 2] > rgb[..., 0] + 20)
    ys, xs = np.nonzero(blue)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    x1 = x0 + int((x1 - x0) * 0.42)  # the panel only, not the neck ring
    plate = np.zeros_like(blue)
    plate[y0 + 22 : y1 - 21, x0 + 10 : x1] = True
    plate &= blue
    out = rgb.copy()
    out[plate] = textured(rgb, plate, PLATE)[plate]
    img = Image.fromarray(np.dstack([out, al]).astype(np.uint8), "RGBA")
    d = ImageDraw.Draw(img)
    ink = tuple(INK.astype(int)) + (255,)
    d.rounded_rectangle((x0 + 10, y0 + 22, x1, y1 - 21), 14, outline=ink, width=6)
    py = np.linspace(y0 + 34, y1 - 33 - 46, 3)
    for y in py:  # three pouches down the back edge, a paper flap line each
        y = int(y)
        d.rounded_rectangle((x0 + 16, y, x0 + 50, y + 46), 6, fill=tuple(POUCH.astype(int)) + (255,), outline=ink, width=4)
        d.line((x0 + 20, y + 12, x0 + 46, y + 12), fill=tuple(PAPER2.astype(int)) + (255,), width=4)
    keep = Image.fromarray(np.where(solid, 255, 0).astype(np.uint8))  # never outside the footprint
    img.putalpha(Image.fromarray(np.minimum(np.array(img)[..., 3], np.array(keep))))
    return img


def main():
    for s in SETS:
        d = ROOT / s
        meta = json.loads((d / "parts.json").read_text())
        for new, base, fn in (("head_swat", "head_cap", head_swat), ("torso_swat", "torso", torso_swat)):
            fn(Image.open(d / f"{base}.png").convert("RGBA")).save(d / f"{new}.png")
            meta[new] = {k: v for k, v in meta[base].items() if k not in ("sheet", "cell")}
            meta[new]["derived_from"] = base
            # the import params only (lossless + mipmaps like the rig parts); Godot writes the rest
            params = (d / f"{base}.png.import").read_text().split("[params]", 1)[1]
            (d / f"{new}.png.import").write_text(HEAD + params)
        (d / "parts.json").write_bytes(json.dumps(meta, indent=1).encode())


if __name__ == "__main__":
    main()

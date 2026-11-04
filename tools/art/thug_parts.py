"""The robot thug's own part set (human-reactions REQUEST 2), derived from Rivet's, no generation.

Rivet's part names, sizes and pivots (parts.json copied as is), so ThugPlan only swaps its art_dir:
    art/thug/      from art/rivet/      (D4, flat fills)
    art/d5/thug/   from art/d5/rivet/   (D5, hatched)
The look: Rivet's pale lilac metal becomes a dark cool gunmetal (the thug reads darker than Rivet
at 32 px/m), the rust streaks become dark oil stains (no red, no vermilion), the helmet carries a
single round optic (a paper lens with an ink pupil, never teal), the torso plate gets ink dents and
two paper gang bars. ThugPlan draws no collar and no hose; they are recoloured anyway (no vermilion
anywhere in the set).

    python tools/art/thug_parts.py
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path("project/features/characters/art")
SETS = [("rivet", "thug"), ("d5/rivet", "d5/thug")]
INK = (27, 21, 23, 255)
PAPER2 = (233, 220, 195, 255)
METAL = np.array([0.50, 0.53, 0.58])  # lum -> gunmetal (cool, darker than Rivet's lilac)
STAIN = np.array([0.30, 0.28, 0.27])  # rust -> a dark oil stain
HEAD = '[remap]\n\nimporter="texture"\ntype="CompressedTexture2D"\n\n[params]'


def recolour(img):
    a = np.array(img.convert("RGBA")).astype(float)
    rgb = a[..., :3]
    l = rgb @ np.array([0.299, 0.587, 0.114])
    warm = (rgb[..., 0] - rgb[..., 2]) > 35  # rust, the collar's vermilion, any orange
    out = l[..., None] * METAL[None, None, :] + 12.0
    out[warm] = (l[warm][:, None] * STAIN[None, :]) + 10.0
    ink = l < 45  # keep the ink line its own colour
    out[ink] = rgb[ink]
    a[..., :3] = np.clip(out, 0, 255)
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def clip_to(img, src):
    alpha = np.minimum(np.array(img)[..., 3], np.array(src.convert("RGBA"))[..., 3])
    img.putalpha(Image.fromarray(alpha))
    return img


def helmet(img):
    """A single round optic over the helmet plate: gunmetal bezel, paper lens, ink pupil."""
    w, h = img.size
    c, r = (w / 2, h / 2), min(w, h) * 0.34
    d = ImageDraw.Draw(img)
    box = lambda k: (c[0] - r * k, c[1] - r * k, c[0] + r * k, c[1] + r * k)  # noqa: E731
    d.ellipse(box(1.0), fill=(70, 74, 82, 255), outline=INK, width=max(3, int(r * 0.12)))
    d.ellipse(box(0.66), fill=PAPER2, outline=INK, width=max(3, int(r * 0.09)))
    d.ellipse(box(0.30), fill=INK)
    d.ellipse((c[0] + r * 0.18, c[1] - r * 0.40, c[0] + r * 0.36, c[1] - r * 0.22), fill=PAPER2)
    return img


def torso(img):
    """Ink dents and two paper gang bars on the chest plate."""
    w, h = img.size
    d = ImageDraw.Draw(img)
    lw = max(3, w // 40)
    for cx, cy, rr in ((0.36, 0.30, 0.07), (0.62, 0.68, 0.09), (0.30, 0.74, 0.05)):
        x, y, r = cx * w, cy * h, rr * w
        d.arc((x - r, y - r, x + r, y + r), 200, 340, fill=INK, width=lw)
    for k in (0.0, 0.11):  # two slanted bars on the back plate (the head covers the chest from above)
        x0, y0 = w * (0.12 + k), h * 0.40
        d.polygon(
            [(x0, y0), (x0 + w * 0.06, y0), (x0 + w * 0.12, y0 + h * 0.20), (x0 + w * 0.06, y0 + h * 0.20)],
            fill=PAPER2,
            outline=INK,
        )
    return img


EXTRA = {"helmet": helmet, "torso": torso}


def main():
    for src_dir, dst_dir in SETS:
        s, d = ROOT / src_dir, ROOT / dst_dir
        d.mkdir(parents=True, exist_ok=True)
        (d / "parts.json").write_bytes((s / "parts.json").read_bytes())
        for png in sorted(s.glob("*.png")):
            src = Image.open(png)
            img = recolour(src)
            if png.stem in EXTRA:
                img = clip_to(EXTRA[png.stem](img), src)
            img.save(d / png.name)
            params = (s / f"{png.name}.import").read_text().split("[params]", 1)[1]
            (d / f"{png.name}.import").write_bytes((HEAD + params).encode())


if __name__ == "__main__":
    main()

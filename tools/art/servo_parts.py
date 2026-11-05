"""n7-servo: cut Servo's core part sheet (Codex, chroma green, the n5-cast 3x2 layout template) into
keyed parts, recolour them to the palette rules, and assemble the top-down (90 degree) body for a
look against the target.

  python tools/art/servo_parts.py <core_sheet.png> <limbs_sheet.png> <out_dir> [<install_art_dir>]

Cells (row-major, 3 x 2), core: [ref] head pad / pelvis torso rack; limbs: [ref] drone crate /
thigh shin arm. The top-left cell is the template's scale reference and is skipped. Palette (data/tables/palette.json gates): vermilion is
r - max(g, b) >= 0.31, reserved for danger; the sheet's orange (hazard stripes, hoses) is pulled to
a muted orange-brown at <= MUTED (0.24), and the head's glowing visor slot to ink (the game tints
the visor vermilion only during a tell). Writes <out_dir>/<part>.png + parts.json (sizes) and
<out_dir>/servo_top_<ppm>ppm.png (the assembled body at 32 and 64 px/m). With an install dir, each
part is also written there at INSTALL_PPM (the game scales it to metres from parts.json).
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

CORE = [None, "head", "pad", "pelvis", "torso", "rack"]
LIMBS = [None, "drone", "crate", "thigh", "shin", "arm"]
INSTALL_PPM = 96
MUTED = 0.24
INK_2 = np.array([81, 71, 72]) / 255.0
# Metres across (the width on the page): the rack wing is half of the 5.4 m rack bar.
METRES = {"rack": 2.6, "torso": 1.7, "pelvis": 1.5, "head": 0.9, "pad": 1.3, "drone": 0.7, "crate": 0.9}
# The limb struts are sized by their length (down the page).
LENGTH = {"thigh": 1.7, "shin": 1.9, "arm": 1.9}


def key(img):
    a = np.asarray(img.convert("RGB")).astype(float) / 255.0
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    green = (g - np.maximum(r, b)) > 0.18
    a[..., 1] = np.where(~green, np.minimum(g, np.maximum(r, b) + 0.05), g)  # despill
    alpha = np.where(green, 0.0, 1.0)
    return a, alpha


def mute(a, visor=False):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    d = r - np.maximum(g, b)
    hot = d > MUTED
    mean = a.mean(axis=2, keepdims=True)
    k = np.where(hot, MUTED / np.maximum(d, 1e-6), 1.0)[..., None]
    out = mean + (a - mean) * k
    if visor:  # the visor glow: bright orange in the lower half of the head -> ink
        h = a.shape[0]
        rows = np.arange(h)[:, None] > h * 0.55
        glow = hot & rows
        out[glow] = INK_2
    return out


def cut(sheet, names):
    a, alpha = key(sheet)
    h, w = alpha.shape
    parts = {}
    for i, name in enumerate(names):
        if name is None:
            continue
        y0, x0 = (i // 3) * h // 2, (i % 3) * w // 3
        cell_a = alpha[y0 : y0 + h // 2, x0 : x0 + w // 3]
        ys, xs = np.nonzero(cell_a)
        y1, y2, x1, x2 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
        rgb = mute(a[y0 + y1 : y0 + y2, x0 + x1 : x0 + x2], visor=(name == "head"))
        rgba = np.dstack([rgb, cell_a[y1:y2, x1:x2]])
        parts[name] = Image.fromarray((np.clip(rgba, 0, 1) * 255).astype(np.uint8), "RGBA")
    return parts


def fit(im, metres, ppm, along=False):
    k = metres * ppm / (im.height if along else im.width)
    return im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)


def assemble(parts, ppm):
    """Servo from straight above, facing DOWN the page (the sheet's convention)."""
    canvas = Image.new("RGBA", (round(7 * ppm), round(4 * ppm)), (0, 0, 0, 0))
    cx, cy = canvas.width // 2, round(1.6 * ppm)

    def put(im, x, y):
        canvas.alpha_composite(im, (round(x - im.width / 2), round(y - im.height / 2)))

    pad = fit(parts["pad"], METRES["pad"], ppm)
    for s in (-1, 1):
        put(pad, cx + s * 2.6 * ppm, cy + 1.2 * ppm)  # the pads hang forward of the wings
    put(fit(parts["pelvis"], METRES["pelvis"], ppm), cx, cy + 0.5 * ppm)
    rack = fit(parts["rack"], METRES["rack"], ppm)
    put(rack, cx - 1.4 * ppm, cy - 0.2 * ppm)
    put(rack.transpose(Image.FLIP_LEFT_RIGHT), cx + 1.4 * ppm, cy - 0.2 * ppm)
    put(fit(parts["torso"], METRES["torso"], ppm), cx, cy + 0.3 * ppm)
    put(fit(parts["head"], METRES["head"], ppm), cx, cy + 1.2 * ppm)
    return canvas


def sized(name, im, ppm):
    return fit(im, LENGTH[name], ppm, True) if name in LENGTH else fit(im, METRES[name], ppm)


def main():
    out = Path(sys.argv[3])
    out.mkdir(parents=True, exist_ok=True)
    parts = cut(Image.open(sys.argv[1]), CORE)
    parts.update(cut(Image.open(sys.argv[2]), LIMBS))
    meta = {}
    for name, im in parts.items():
        im.save(out / f"{name}.png")
        art = sized(name, im, INSTALL_PPM)
        meta[name] = {"px": list(art.size), "ppm": INSTALL_PPM}
        if len(sys.argv) > 4:
            Path(sys.argv[4]).mkdir(parents=True, exist_ok=True)
            art.save(Path(sys.argv[4]) / f"{name}.png")
    (out / "parts.json").write_text(json.dumps(meta, indent=1, sort_keys=True) + "\n")
    for ppm in (32, 64):
        assemble(parts, ppm).save(out / f"servo_top_{ppm}ppm.png")
    print("parts:", {k: v["px"] for k, v in meta.items()})


if __name__ == "__main__":
    main()

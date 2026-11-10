"""n13 weapon art: an interim wind-up cell composed from a Rivet equipped strip's own parts.

usage: python -I tools/art/blade_windup.py <eq_strip.png> <out.png> [--side=1] [--cam=0]
       [--side_deg=-95] [--cam_deg=-95] [--reach=8] [--under] [--sim=<preview.png>]

The drawn strips (5 facings, side and camera strike, rest) have no wind-up cell. This cuts a
two-cell strip (rivet_eq_<weapon>_windup.png: 0 = the side wind-up, 1 = the camera wind-up) from
the strip itself, no new pixels: the body is the nearest facing cell (`side`, `cam`); the blade
plate (the glow's largest run and every opaque pixel within `reach` px of it, as blade_ink_rim.py)
is lifted out of it and turned about its base (the end that meets the hilt) until it points at
`*_deg` (screen degrees, y down: -90 = straight up), then laid over the body (raised in front of
him) or, with --under, under it (raised behind him: with the hands at the hip a blade turned up and
back hides behind the torso, n13 JOURNAL). The cells are HEAD_PX taller than the strip's (headroom;
the feet keep the strip's pad, RivetStrips.foot_px). Nearest-neighbour rotation of whole source
pixels (no new colour). Deterministic.
"""

import math
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

OPAQUE = 160
HEAD_PX = 48


def _core(t: np.ndarray) -> np.ndarray:
    r, g, b, a = (t[..., i].astype(int) for i in range(4))
    glow = (a > OPAQUE) & (r > 190) & (g > 100) & (b < 150) & (r - b > 80)
    lab, n = ndimage.label(glow)
    if n == 0:
        return glow
    sizes = ndimage.sum(glow, lab, range(1, n + 1))
    return lab == (int(np.argmax(sizes)) + 1)


def _plate(t: np.ndarray, reach: float) -> tuple:
    core = _core(t)
    near = ndimage.distance_transform_edt(~core) <= reach
    plate = near & (t[..., 3] > 0)
    return core, plate


def _base_and_axis(core: np.ndarray, plate: np.ndarray, t: np.ndarray) -> tuple:
    ys, xs = np.nonzero(core)
    pts = np.stack([xs, ys], 1).astype(float)
    c = pts.mean(0)
    _, _, vt = np.linalg.svd(pts - c, full_matrices=False)
    ax = vt[0]
    proj = (pts - c) @ ax
    ends = [c + ax * proj.min(), c + ax * proj.max()]
    # the base is the end with more of the figure (hands, hilt) around it, outside the plate
    other = (t[..., 3] > OPAQUE) & ~plate
    score = []
    for e in ends:
        x0, y0 = int(round(e[0])), int(round(e[1]))
        win = other[max(0, y0 - 8) : y0 + 9, max(0, x0 - 8) : x0 + 9]
        score.append(int(win.sum()))
    i = int(np.argmax(score))
    base, tip = ends[i], ends[1 - i]
    return base, math.atan2(tip[1] - base[1], tip[0] - base[0])


def windup_cell(t: np.ndarray, deg: float, reach: float, under: bool = False) -> np.ndarray:
    core, plate = _plate(t, reach)
    if not core.any():
        return t.copy()
    base, ang = _base_and_axis(core, plate, t)
    body = t.copy()
    body[plate] = 0
    blade = np.zeros_like(t)
    blade[plate] = t[plate]
    turn = math.radians(deg) - ang
    h, w = t.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(float)
    # inverse map: each output pixel reads the source pixel turned back about the base
    dx, dy = xx - base[0], yy - base[1]
    cs, sn = math.cos(-turn), math.sin(-turn)
    sx = np.round(base[0] + dx * cs - dy * sn).astype(int)
    sy = np.round(base[1] + dx * sn + dy * cs).astype(int)
    ok = (sx >= 0) & (sx < w) & (sy >= 0) & (sy < h)
    turned = np.zeros_like(t)
    turned[ok] = blade[sy[ok], sx[ok]]
    top, low = (body, turned) if under else (turned, body)
    a = top[..., 3:4].astype(float) / 255.0
    out = (top.astype(float) * a + low.astype(float) * (1.0 - a)).round()
    out[..., 3] = np.maximum(body[..., 3], turned[..., 3])
    return out.astype(np.uint8)


def cut(src: str, cells: int, opts: dict) -> Image.Image:
    rgba = np.asarray(Image.open(src).convert("RGBA"))
    cw = rgba.shape[1] // cells
    head = int(opts.get("head", HEAD_PX))  # headroom over the strip's cell for the raised blade
    rgba = np.concatenate([np.zeros((head, rgba.shape[1], 4), np.uint8), rgba], 0)
    reach = float(opts.get("reach", 8))
    under = "under" in opts
    picks = [
        (int(opts.get("side", 1)), float(opts.get("side_deg", -95))),
        (int(opts.get("cam", 0)), float(opts.get("cam_deg", -95))),
    ]
    out = np.zeros((rgba.shape[0], cw * 2, 4), np.uint8)
    for j, (c, deg) in enumerate(picks):
        out[:, j * cw : (j + 1) * cw] = windup_cell(rgba[:, c * cw : (c + 1) * cw], deg, reach, under)
    return Image.fromarray(out, "RGBA")


def main() -> None:
    opts = {a.split("=")[0][2:]: a.split("=", 1)[-1] for a in sys.argv[1:] if a.startswith("--")}
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    img = cut(args[0], int(opts.get("cells", 8)), opts)
    if "sim" in opts:
        bg = Image.new("RGBA", img.size, (110, 100, 100, 255))
        bg.alpha_composite(img)
        bg.resize((img.width * 3, img.height * 3), Image.Resampling.NEAREST).save(opts["sim"])
        return
    img.save(args[1], optimize=True)


if __name__ == "__main__":
    main()

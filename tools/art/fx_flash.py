"""r2_w4's blast flash for the smoke-ring frame (look lane, n5 iteration 12): the sheet's blast keeps
a white-hot core and yellow radial spikes reaching through the dark smoke; ours printed a hollow ring.
flash() paints, over the frame: `n` hashed ink-outlined spikes from the centre to r_out x the cell's
half-width, a ragged yellow star burst filling the ring's hollow (burst_k x its inner radius), and a
white-hot star (hot_k x the burst) inside it. Hash-placed from `seed`: deterministic."""

import math

from PIL import Image, ImageDraw

INK = (27, 21, 23, 255)


def _h(i, s):
    v = math.sin(i * 12.9898 + s * 78.233) * 43758.5453
    return v - math.floor(v)


def _star(cx, cy, n, r_hi, r_lo, seed, grow=0.0):
    pts = []
    for i in range(2 * n):
        a = (i + (_h(i, seed) - 0.5) * 0.5) / (2 * n) * 2 * math.pi
        r = (r_hi if i % 2 == 0 else r_lo) * (0.8 + 0.4 * _h(i, seed + 2.1)) + grow
        pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
    return pts


def _spike(cx, cy, a, r0, r1, half_w, grow=0.0):
    ux, uy = math.cos(a), math.sin(a)
    px, py = -uy, ux
    w = half_w + grow
    b0 = (cx + ux * r0 + px * w, cy + uy * r0 + py * w)
    b1 = (cx + ux * r0 - px * w, cy + uy * r0 - py * w)
    tip = (cx + ux * (r1 + grow * 1.6), cy + uy * (r1 + grow * 1.6))
    return [b0, tip, b1]


def flash(img, rin, spec):
    """Returns `img` with the flash composited over it; rin = the ring's median inner radius."""
    cx, cy = img.width / 2, img.height / 2
    half = img.width / 2
    seed = spec.get("seed", 1.0)
    ink_px = spec.get("ink_px", 4.0)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    dr = ImageDraw.Draw(layer)
    spikes = []
    for i in range(spec["n"]):
        a = (i + (_h(i, seed + 9.1) - 0.5) * 0.7) / spec["n"] * 2 * math.pi
        r1 = half * (spec["r_out"][0] + (spec["r_out"][1] - spec["r_out"][0]) * _h(i, seed + 4.4))
        spikes.append((a, r1, spec["half_w"] * (0.7 + 0.6 * _h(i, seed + 6.6))))
    burst_r = rin * spec["burst_k"]
    for a, r1, w in spikes:
        dr.polygon(_spike(cx, cy, a, burst_r * 0.5, r1, w, ink_px), fill=INK)
    for a, r1, w in spikes:
        dr.polygon(_spike(cx, cy, a, burst_r * 0.5, r1, w), fill=tuple(spec["spike"]) + (255,))
    burst = _star(cx, cy, spec["points"], burst_r, burst_r * 0.78, seed + 1.3, ink_px)
    dr.polygon(burst, fill=INK)
    fill = tuple(spec["burst"]) + (255,)
    dr.polygon(_star(cx, cy, spec["points"], burst_r, burst_r * 0.78, seed + 1.3), fill=fill)
    hot_r = burst_r * spec["hot_k"]
    dr.polygon(_star(cx, cy, spec["points"], hot_r, hot_r * 0.7, seed + 3.7), fill=tuple(spec["hot"]) + (255,))
    out = img.copy()
    out.alpha_composite(layer)
    return out

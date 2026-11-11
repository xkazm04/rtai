"""Planted-feet slip of a drawn ghost gait, in world space, from its sheet and the shipped timing.

usage: ghost_slip.py <name> <sheet.png> <cycle_cell> <fig_px> <height_m> <speed_mps> [steps csv|even] [cols]
A frame i shows over its dwell of ground (GhostStride.dwell_of; even = cycle/cols). The stance
contact (profile row, lowest 4 px) is drawn at cell x c_i; its world x while frame i shows is
c_i + ground walked, so within a frame it rides forward by the dwell (the sawtooth) and at the
change it moves by c_{i+1} - c_i. Prints, per stance pair (same foot in i and i+1: the contact
moved back, not forward and not a new landing), the frame-centre drift = how far the foot creeps in
the world between two frames, in cell px and in screen px at 32 and 64 px/m; and the sawtooth.
"""
import sys
import numpy as np
from PIL import Image

name, sheet = sys.argv[1], sys.argv[2]
cycle, fig, h, v = (float(x) for x in sys.argv[3:7])
spec = sys.argv[7] if len(sys.argv) > 7 else "even"
cols = int(sys.argv[8]) if len(sys.argv) > 8 else 8
a = np.asarray(Image.open(sheet).convert("RGBA"))[..., 3]
cw, ch = a.shape[1] // cols, a.shape[0] // 5


def contacts(c):
    cell = a[2 * ch:3 * ch, c * cw:(c + 1) * cw] > 128
    low = np.where(cell.any(1))[0].max()
    xs = np.where(cell[low - 3:low + 1].any(0))[0]
    out, s = [], xs[0]
    for i in range(1, len(xs) + 1):
        if i == len(xs) or xs[i] - xs[i - 1] > 6:
            out.append((s + xs[i - 1]) / 2); s = xs[i] if i < len(xs) else 0
    return out


if spec == "even":
    dwell = [cycle / cols] * cols
else:
    st = [float(x) for x in spec.split(",")]
    m = sum(st) / len(st)
    dwell = [max((st[i - 1] + st[i]) / 2, m * 0.4) for i in range(len(st))]
    k = cycle / sum(dwell); dwell = [d * k for d in dwell]
cm = h / fig  # metres per cell px
cps = v / (cycle * cm)
print(f"{name}: cycle {cycle:.0f} cell px = {cycle * cm:.2f} m, {cps:.2f} cycles/s at {v} m/s, "
      f"{cps * cols:.1f} frames/s; timing {spec}")
cs = [contacts(c) for c in range(cols)]
drifts = []
for i in range(cols):
    j = (i + 1) % cols
    best = None
    for x in cs[i]:
        for y in cs[j]:
            d = y - x  # facing right: a planted foot moves back (negative)
            if -80 < d <= 4 and (best is None or abs(d + (dwell[i] + dwell[j]) / 2) < abs(best[2])):
                best = (x, y, d + (dwell[i] + dwell[j]) / 2)
    if best:
        drifts.append(best[2])
        print(f"  f{i + 1}->f{j + 1}: contact {best[0]:6.1f} -> {best[1]:6.1f}, dwell {dwell[i]:5.1f}/{dwell[j]:5.1f}: "
              f"centre drift {best[2]:+6.1f} cell = {best[2] * cm * 32:+5.1f} px@32 {best[2] * cm * 64:+5.1f} px@64")
    else:
        print(f"  f{i + 1}->f{j + 1}: no stance pair (switch or flight)")
dr = np.abs(drifts)
print(f"  mean |drift| {dr.mean():.1f} cell = {dr.mean() * cm * 32:.1f} px@32, worst {dr.max() * cm * 32:.1f} px@32; "
      f"sawtooth (mean dwell) {np.mean(dwell) * cm * 32:.1f} px@32 / {np.mean(dwell) * cm * 64:.1f} px@64")

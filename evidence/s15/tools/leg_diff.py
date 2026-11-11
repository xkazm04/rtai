"""n15 hero it16: per-frame diff of two k16 films (build/film/k16_<form>_<tag>_<leg>_<ff>.png).
usage: py -3 -I leg_diff.py <before prefix> <after prefix> [<out strip.png> <leg>]
prints, per leg, the % of crop pixels that differ in each frame; with <out> writes a before-over-after
strip of that leg (every frame, x0.5) on grey."""
import sys
from pathlib import Path
from PIL import Image, ImageChops

b, a = sys.argv[1], sys.argv[2]
for leg in (2, 3):
    row = []
    for f in range(16):
        pb, pa = Path(f"{b}_{leg}_{f:02d}.png"), Path(f"{a}_{leg}_{f:02d}.png")
        if not pb.exists() or not pa.exists():
            continue
        ib, ia = Image.open(pb).convert("RGBA"), Image.open(pa).convert("RGBA")
        d = ImageChops.difference(ib, ia).convert("L").point(lambda v: 255 if v > 8 else 0)
        row.append(100.0 * d.histogram()[255] / (ib.width * ib.height))
    print(f"leg {leg}: " + " ".join(f"{v:4.1f}" for v in row))
if len(sys.argv) > 4:
    leg = int(sys.argv[4])
    fr = [[Image.open(f"{p}_{leg}_{f:02d}.png").convert("RGBA") for f in range(16)] for p in (b, a)]
    w, h = fr[0][0].width // 2, fr[0][0].height // 2
    out = Image.new("RGBA", (w * 16, h * 2), (120, 120, 128, 255))
    for r, frames in enumerate(fr):
        for c, im in enumerate(frames):
            out.alpha_composite(im.resize((w, h), Image.LANCZOS), (c * w, r * h))
    out.convert("RGB").save(sys.argv[3])

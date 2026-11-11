"""n17 rivet-strike: Rivet's boot line per tick in a tools/film shot, against his ground point.

usage: python -I tools/art/rivet_boot_line.py <film dir> <first tick> <last tick> [half width px, 30]

<film dir> is a film.mjs --out dir (probe.json + t<tick>.png). Per tick it prints the lowest row of
Rivet's rust-coloured pixels (red-orange, not yellow, not bright: the blade, sparks and the cream arc
are out) within +-half px of his probe screen x, in frame px from his ground point (minus = above).
Compare a strike or wind-up cell's value with the armed walk ticks before it: the owner's "a hit cell
stands at the walk cell's height, same boot line". Use +-60 for a wide wind-up stance; a low-held
weapon with orange coils (the baton) can read as a boot: check the odd tick at 4x.
Deterministic; reads only, writes nothing.
"""

import json
import os
import sys

import numpy as np
from PIL import Image


def boot_row(frame, sx, sy, half):
    """The lowest rust row near (sx, sy) in frame px from sy, or None."""
    x0, y0 = int(sx - half), int(sy - 120)
    c = frame[y0 : int(sy + 30), x0 : int(sx + half)]
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    hue_ok = (r >= g) & (g >= b) & ((g - b) < (r - b) * 0.75)  # red-orange, not yellow
    rust = hue_ok & ((r - b) > 45) & (r > 70) & (c.min(axis=2) < 150)
    ys = np.nonzero(rust.sum(axis=1) >= 2)[0]
    return None if len(ys) == 0 else round(float(y0 + ys.max() - sy))


def main(argv):
    film, t0, t1 = argv[1], int(argv[2]), int(argv[3])
    half = int(argv[4]) if len(argv) > 4 else 30
    probe = json.load(open(os.path.join(film, "probe.json"), encoding="utf-8"))
    rows = {r.get("tick", i): r for i, r in enumerate(probe["rows"])}
    out = []
    for t in range(t0, t1 + 1):
        path = os.path.join(film, "t%d.png" % t)
        if not os.path.exists(path) or t not in rows:
            continue
        rivet = [f for f in rows[t]["fighters"] if f["role"] == "rivet"][0]
        frame = np.asarray(Image.open(path).convert("RGB")).astype(int)
        v = boot_row(frame, rivet["screen"][0], rivet["screen"][1], half)
        out.append("t%d:%s" % (t, "-" if v is None else "%+d" % v))
    print(film, " ".join(out))


if __name__ == "__main__":
    main(sys.argv)

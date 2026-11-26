"""Contact-ink bars on delivered play_take frames (n31-22).

  python tools/ground/contact_ink.py --mp4=<take.mp4> --ticks=2080,1330 [--at=x,y ...] [--json=<file>] [--label=<s>]

Per tick: the core box (6x3 px, 1080p) centred on the drawn-sole midpoint (Rivet: the middle of the
fixed pixel (961, 549), just under the boots at 32 px/m, where the camera holds his ground point; --at=x,y per tick for a
foe), its mean luminance vs the same-size floor boxes 12 px to the left and right (brief) and 40 px to
each side (clear of the body), and the edge: the largest luminance step per pixel, as a share of the
floor luminance, down the column band under the soles (7 columns averaged, the profile smoothed 1 px)."""
import json
import subprocess
import sys

import numpy as np
from scipy import ndimage


SOLE = (961, 549)  # 32 px/m: the camera holds the ground point at (961, 538); the boots cover rows to ~546, so the core box is the visible
# part just under them (a box on the hidden middle would measure the boots, not the ink)


def arg(argv, k, d=None):
    for a in argv:
        if a.startswith(f"--{k}="):
            return a[len(k) + 3:]
    return d


def frame(mp4, n):
    p = subprocess.run(["ffmpeg", "-v", "error", "-i", mp4, "-vf", f"select=eq(n\,{n})", "-vsync", "0", "-frames:v", "1",
                        "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True)
    return np.frombuffer(p.stdout, np.uint8).reshape(1080, 1920, 3)


def lum(img):
    c = img.astype(float)
    return (0.299 * c[..., 0] + 0.587 * c[..., 1] + 0.114 * c[..., 2])


def rivet_sole(img):
    """(x, y) of the sole midpoint of Rivet's brown mask near the screen centre, or None."""
    bx, by, bs = 835, 385, 240
    c = img[by:by + bs, bx:bx + bs].astype(int)
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    m = (r > 110) & (r - b > 45) & (g > 70) & (g < r - 20) & (g > 40)
    m[:50] = False
    m[:, :60] = False
    m[:, 190:] = False
    lab, n = ndimage.label(m)
    if not n:
        return None
    m = lab == (1 + int(np.argmax(ndimage.sum(m, lab, range(1, n + 1)))))
    rows = np.where(m.sum(axis=1) >= 1)[0]
    bot = int(rows[-1])
    ys, xs = np.where(m[max(bot - 11, 0):bot + 1])
    return int(xs.mean()) + bx, bot + by


def box(L, x, y, w=6, h=3):
    return float(L[y - h // 2:y - h // 2 + h, x - w // 2:x - w // 2 + w].mean())


def measure(img, x, y):
    L = lum(img)
    core = box(L, x, y)
    f12 = (box(L, x - 12, y) + box(L, x + 12, y)) / 2
    f40 = (box(L, x - 40, y) + box(L, x + 40, y)) / 2
    band = L[y - 3:y + 30, x - 3:x + 4].mean(axis=1)
    band = np.convolve(band, [0.25, 0.5, 0.25], mode="same")[1:-1]
    step = float(np.abs(np.diff(band)).max()) / max(f40, 1.0)
    row = L[y - 1:y + 2, x - 30:x + 31].mean(axis=0)  # the same step along the row (a kerb or wall under the soles spoils the column)
    row = np.convolve(row, [0.25, 0.5, 0.25], mode="same")[1:-1]
    step_x = float(np.abs(np.diff(row)).max()) / max(f40, 1.0)
    return {"x": x, "y": y, "edge_x_step_pct": round(100 * step_x, 2), "core": round(core, 1), "floor12": round(f12, 1), "floor40": round(f40, 1),
            "dark12_pct": round(100 * (1 - core / f12), 1), "dark40_pct": round(100 * (1 - core / f40), 1),
            "edge_step_pct": round(100 * step, 2)}


def main(argv):
    mp4 = arg(argv, "mp4")
    ticks = [int(t) for t in arg(argv, "ticks").split(",")]
    ats = [a for a in argv if a.startswith("--at=")]
    out = []
    for i, t in enumerate(ticks):
        img = frame(mp4, t)
        if ats:
            x, y = [int(v) for v in ats[i].split("=")[1].split(",")]
        else:
            x, y = SOLE  # the camera holds Rivet's ground point: the contact core is a fixed pixel
        out.append({"tick": t, **measure(img, x, y)})
    for o in out:
        print(json.dumps(o))
    j = arg(argv, "json")
    if j:
        json.dump({"label": arg(argv, "label", ""), "mp4": mp4, "rows": out}, open(j, "w"), indent=1)


if __name__ == "__main__":
    main(sys.argv[1:])

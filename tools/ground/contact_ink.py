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


def free_mask(img, pad=6):
    """True where a pixel is floor or shadow: not sprite (brown/orange/skin/blue/red: any saturated or bright pixel) and not within pad px of one."""
    c = img.astype(int)
    sat = c.max(axis=2) - c.min(axis=2)
    bad = (sat > 28) | (lum(img) > 120)
    return ~ndimage.binary_dilation(bad, iterations=pad)


def measure_free(img, cx=961, cy=546, hw=20, hh=14):
    """Same rule for every take: the darkest 6x3 box in the window around the sole point that touches no sprite
    pixel (so it is shadow on floor, not outline), against the median of the free boxes 36-44 px to each side on
    that row; the edge step is the largest smoothed luminance gradient (per px) in the free part of the window, as a
    share of that floor. None if no free box is found (a body, a blood decal or the boots cover the window)."""
    free = free_mask(img)
    L = lum(img)
    best = None
    for y in range(cy - hh, cy + hh + 1):
        for x in range(cx - hw, cx + hw + 1):
            if free[y - 1:y + 2, x - 3:x + 3].all():
                v = box(L, x, y)
                if best is None or v < best[0]:
                    best = (v, x, y)
    if best is None:
        return None
    core, x, y = best
    side = [box(L, x + d, y) for d in range(-44, -35, 2) + list(range(36, 45, 2))
            if free[y - 1:y + 2, x + d - 3:x + d + 3].all()] if False else []
    for d in list(range(-44, -35, 2)) + list(range(36, 45, 2)):
        if free[y - 1:y + 2, x + d - 3:x + d + 3].all():
            side.append(box(L, x + d, y))
    if not side:
        return None
    floor = float(np.median(side))
    G = ndimage.gaussian_filter(L, 1.5)
    gy, gx = np.gradient(G)
    m = free[cy - hh - 6:cy + hh + 7, cx - hw - 6:cx + hw + 7]
    g = np.hypot(gx, gy)[cy - hh - 6:cy + hh + 7, cx - hw - 6:cx + hw + 7][m]
    prof = []  # the skirt along the row, right of the core: the mean of the free pixels in rows y-1..y+1 per column
    for xx in range(x, min(x + 48, 1900)):
        col = free[y - 1:y + 2, xx]
        prof.append(float(L[y - 1:y + 2, xx][col].mean()) if col.all() else np.nan)
    pr = np.array(prof)
    ok = ~np.isnan(pr)
    pr = np.interp(np.arange(len(pr)), np.arange(len(pr))[ok], pr[ok]) if ok.sum() > 8 else pr
    pr = ndimage.uniform_filter1d(pr, 5)
    skirt = round(100 * float(np.abs(np.diff(pr)).max()) / max(floor, 1.0), 2) if ok.sum() > 8 else None
    return {"x": x, "y": y, "skirt_step_pct": skirt, "core": round(core, 1), "floor": round(floor, 1), "dark_pct": round(100 * (1 - core / floor), 1),
            "edge_step_pct": round(100 * float(g.max()) / max(floor, 1.0), 2) if g.size else None}


def main(argv):
    mp4 = arg(argv, "mp4")
    ticks = [int(t) for t in arg(argv, "ticks").split(",")]
    ats = [a for a in argv if a.startswith("--at=")]
    out = []
    for i, t in enumerate(ticks):
        img = frame(mp4, t)
        if "--free" in argv:
            out.append({"tick": t, **(measure_free(img) or {"disqualified": "no sprite-free box in the window"})})
            continue
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

"""n31-07: per-layer phase drift of a drift_probe take (project/dev/ground_n31/drift_probe.gd).

For each pair of captured ticks (t, t+k) it measures, by sub-pixel phase correlation on the centre
crop (Rivet masked out):
  floor  - the look-off frames (`_b`): the floor geometry as the world canvas draws it;
  print  - the as-played minus look-off frames (`_a - _b`): the print pattern (halftone, grime,
           paper tooth, overlays) on its own;
and compares both with the camera's logged canvas shift. The drift of the print against the floor
is `print - floor`; a layer locked to the screen shows up as a peak at (0, 0) in its correlation.

  python tools/ground/drift/drift.py <take dir> [--k=1,30] [--pan=<from>,<to>] [--json=<file>]
  python tools/ground/drift/drift.py <take dir> --strip=<t1>,<t2>,...:<out.png>
"""
import json
import os
import sys

import numpy as np
from PIL import Image

MASK = (200, 320)  # w, h of the box around Rivet left out of the correlation (crop px)


def gray(path):
    return np.asarray(Image.open(path).convert("RGB"), np.float64).mean(axis=2)


def window(shape):
    return np.outer(np.hanning(shape[0]), np.hanning(shape[1]))


def phase_peak(a, b, mask=None):
    """(dx, dy, peak, zero): the shift that maps a onto b (b(x) = a(x - d)), sub-pixel."""
    w = window(a.shape)
    if mask is not None:
        w = w * mask
    fa = np.fft.fft2((a - a.mean()) * w)
    fb = np.fft.fft2((b - b.mean()) * w)
    r = fb * np.conj(fa)
    r /= np.maximum(np.abs(r), 1e-12)
    c = np.real(np.fft.ifft2(r))
    iy, ix = np.unravel_index(np.argmax(c), c.shape)
    h, wd = c.shape

    def sub(m, p, n):
        den = m - 2.0 * p + n
        return 0.0 if abs(den) < 1e-12 else 0.5 * (m - n) / den

    dy = iy + sub(c[(iy - 1) % h, ix], c[iy, ix], c[(iy + 1) % h, ix])
    dx = ix + sub(c[iy, (ix - 1) % wd], c[iy, ix], c[iy, (ix + 1) % wd])
    dy = dy - h if dy > h / 2 else dy
    dx = dx - wd if dx > wd / 2 else dx
    return float(dx), float(dy), float(c[iy, ix]), float(c[0, 0])


def rivet_mask(shape, rivet_xy):
    m = np.ones(shape)
    x, y = int(rivet_xy[0]), int(rivet_xy[1])
    m[max(0, y - MASK[1] * 3 // 4):y + MASK[1] // 4, max(0, x - MASK[0] // 2):x + MASK[0] // 2] = 0.0
    return m


def load_rows(take):
    rows = {}
    for line in open(os.path.join(take, "ticks.jsonl"), encoding="utf8"):
        r = json.loads(line)
        if r["pass"]:
            rows[(r["tick"], r["pass"])] = r
    return rows


def stretch(row):
    """(sx, sy, tx, ty): logical px -> render px; identity for a take without stretch."""
    return row.get("stretch", [1.0, 1.0, 0.0, 0.0])


def origin_px(row):
    """World (0, 0) on the render target, px (the canvas origin through the window stretch)."""
    sx, sy, tx, ty = stretch(row)
    return [row["canvas_origin"][0] * sx + tx, row["canvas_origin"][1] * sy + ty]


def rivet_in_crop(row):
    """Rivet's ground point in crop px from the logged canvas origin (world px = metres * 32)."""
    zx, zy = row["zoom"]
    sx, sy, _, _ = stretch(row)
    ox, oy = origin_px(row)
    rx, ry = row["rivet_m"]
    return (rx * 32.0 * zx * sx + ox - row["crop_at"][0], ry * 32.0 * zy * sy + oy - row["crop_at"][1])


def measure(take, t, k, rows):
    a0, a1 = gray(f"{take}/t{t:05d}_a.png"), gray(f"{take}/t{t + k:05d}_a.png")
    b0, b1 = gray(f"{take}/t{t:05d}_b.png"), gray(f"{take}/t{t + k:05d}_b.png")
    r0, r1 = rows[(t, "a")], rows[(t + k, "a")]
    mask = rivet_mask(a0.shape, rivet_in_crop(r0)) * rivet_mask(a0.shape, rivet_in_crop(r1))
    cam = [origin_px(r1)[i] - origin_px(r0)[i] for i in (0, 1)]
    lock = [-(r1["world_px"][i] - r0["world_px"][i]) for i in (0, 1)]
    fx, fy, fpk, fz = phase_peak(b0, b1, mask)
    px, py, ppk, pz = phase_peak(a0 - b0, a1 - b1, mask)
    return {
        "t": t, "k": k, "camera_shift": cam, "print_lock_shift": lock,
        "floor_shift": [fx, fy], "floor_peak": fpk,
        "print_shift": [px, py], "print_peak": ppk, "print_zero_peak": pz,
        "drift_print_vs_floor": [px - fx, py - fy],
        "drift_print_vs_camera": [px - cam[0], py - cam[1]],
        "drift_lock_vs_camera": [lock[0] - cam[0], lock[1] - cam[1]],
    }


def pairs(rows, k):
    ticks = sorted({t for (t, p) in rows if p == "b"})
    have = set(ticks)
    return [t for t in ticks if t + k in have]


def summary(results):
    out = {}
    for k in sorted({r["k"] for r in results}):
        rs = [r for r in results if r["k"] == k and np.hypot(*r["camera_shift"]) > 0.5]
        if not rs:
            continue
        for key in ("drift_print_vs_camera", "drift_print_vs_floor", "drift_lock_vs_camera"):
            v = np.array([r[key] for r in rs])
            mag = np.hypot(v[:, 0], v[:, 1])
            out[f"k{k}_{key}"] = {"n": len(rs), "max_px": float(mag.max()), "mean_px": float(mag.mean())}
        out[f"k{k}_print_zero_peak_max"] = max(r["print_zero_peak"] for r in rs)
    return out


def cumulative(take, start, end):
    """The print lock against the floor from the per-tick log over [start, end]: render px."""
    rows = {}
    for line in open(os.path.join(take, "ticks.jsonl"), encoding="utf8"):
        r = json.loads(line)
        if r["pass"] != "b":
            rows[r["tick"]] = r
    a, b = rows[start], rows[end]
    cam = [origin_px(b)[i] - origin_px(a)[i] for i in (0, 1)]
    lock = [-(b["world_px"][i] - a["world_px"][i]) for i in (0, 1)]
    per = []
    for t in range(start, end):
        c = [origin_px(rows[t + 1])[i] - origin_px(rows[t])[i] for i in (0, 1)]
        k = [-(rows[t + 1]["world_px"][i] - rows[t]["world_px"][i]) for i in (0, 1)]
        per.append(float(np.hypot(k[0] - c[0], k[1] - c[1])))
    return {"start": start, "end": end, "camera_px": cam, "print_px": lock,
            "drift_px": [lock[0] - cam[0], lock[1] - cam[1]],
            "per_tick_max_px": max(per), "per_tick_mean_px": float(np.mean(per))}


def strip(take, ticks, dest, size=(320, 200)):
    """The as-played frames at `ticks`, each cropped on one world-anchored box (the floor holds
    still across the strip, so a print sliding over it shows), x2 nearest, side by side."""
    rows = load_rows(take)
    o0 = origin_px(rows[(ticks[0], "a")])
    ims = [Image.open(f"{take}/t{t:05d}_a.png").convert("RGB") for t in ticks]
    d = [[origin_px(rows[(t, "a")])[i] - o0[i] for i in (0, 1)] for t in ticks]
    # the one world box every frame holds: midway in the range that keeps it inside each crop
    x0 = (max(-v[0] for v in d) + min(ims[0].width - size[0] - v[0] for v in d)) / 2
    y0 = (max(-v[1] for v in d) + min(ims[0].height - size[1] - v[1] for v in d)) / 2
    tiles = []
    for im, v in zip(ims, d):
        x, y = int(round(x0 + v[0])), int(round(y0 + v[1]))
        tile = im.crop((x, y, x + size[0], y + size[1]))
        tiles.append(tile.resize((size[0] * 2, size[1] * 2), Image.NEAREST))
    out = Image.new("RGB", (sum(t.width for t in tiles) + 8 * (len(tiles) - 1), tiles[0].height), (255, 0, 255))
    for i, tile in enumerate(tiles):
        out.paste(tile, (i * (tile.width + 8), 0))
    out.save(dest)
    return dest


def main(argv):
    take = argv[0]
    ks = [1, 30]
    dest = None
    pan = None
    for a in argv[1:]:
        if a.startswith("--k="):
            ks = [int(x) for x in a[4:].split(",")]
        elif a.startswith("--pan="):
            pan = [int(x) for x in a[6:].split(",")]
        elif a.startswith("--json="):
            dest = a[7:]
    for a in argv[1:]:
        if a.startswith("--strip="):
            ticks = [int(x) for x in a[8:].split(":")[0].split(",")]
            print(strip(take, ticks, a.split(":", 1)[1]))
            return 0
    rows = load_rows(take)
    results = [measure(take, t, k, rows) for k in ks for t in pairs(rows, k)]
    doc = {"schema": "gtai.n31-drift/1", "take": take, "pairs": results, "summary": summary(results)}
    if pan:
        doc["summary"]["pan"] = cumulative(take, pan[0], pan[1])
    for r in results:
        print(json.dumps({x: (np.round(r[x], 3).tolist() if isinstance(r[x], list) else r[x])
                          for x in r}))
    print(json.dumps(doc["summary"]))
    if dest:
        with open(dest, "w", encoding="utf8") as f:
            json.dump(doc, f, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

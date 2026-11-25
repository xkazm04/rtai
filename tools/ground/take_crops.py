"""Rivet crops from two play_take mp4s at the same ticks, before | after, plus a helmet/sole measure.

  python tools/ground/take_crops.py --a=<before.mp4> --b=<after.mp4> --from=<tick> --count=<n> --out=<dir>
         [--la="main ba8e470b0"] [--lb=HEAD] [--box=835,385,240] [--scale=4]

Writes <out>/pair_<tick>.png (crop x scale nearest, A | B, labelled) for every tick, <out>/strip.mp4
(60 fps, the same pairs) and <out>/measure.json: per tick and arm the top and bottom row of the
orange body mask inside the box (1080p pixels). Measured in the delivered frames, not a lineup."""
import json
import os
import subprocess
import sys

import numpy as np
from scipy import ndimage
from PIL import Image, ImageDraw, ImageFont


def arg(argv, k, d=None):
    for a in argv:
        if a.startswith(f"--{k}="):
            return a[len(k) + 3:]
    return d


def grab(mp4, start, count):
    """Frames start..start+count-1 as an (n,1080,1920,3) uint8 list."""
    p = subprocess.Popen(["ffmpeg", "-v", "error", "-i", mp4, "-vf", "select=between(n\\,%d\\,%d)" % (start, start + count - 1),
                          "-vsync", "0", "-frames:v", str(count), "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
                         stdout=subprocess.PIPE)
    n = 1920 * 1080 * 3
    out = []
    while len(out) < count:
        b = p.stdout.read(n)
        if len(b) < n:
            break
        out.append(np.frombuffer(b, np.uint8).reshape(1080, 1920, 3))
    p.kill()
    return out


def body_rows(crop):
    """Rivet's brown body mask rows and the contact shadow in a crop (1080p px, crop coordinates).

    Returns {top, bottom, sh_cy, sh_bottom} or None: top/bottom = first/last row of the brown body mask
    (helmet top, sole), sh_cy/sh_bottom = centroid and lowest row of the dark grey blob under the body."""
    c = crop.astype(int)
    r, g, b = c[..., 0], c[..., 1], c[..., 2]
    m = (r > 110) & (r - b > 45) & (g > 70) & (g < r - 20) & (g > 40)
    m[:50] = False
    m[:, :60] = False
    m[:, 190:] = False
    lab, n = ndimage.label(m)
    if n:
        sizes = ndimage.sum(m, lab, range(1, n + 1))
        m = lab == (1 + int(np.argmax(sizes)))
    rows = np.where(m.sum(axis=1) >= 1)[0]
    if not len(rows):
        return None
    top, bot = int(rows[0]), int(rows[-1])
    cols = np.where(m.sum(axis=0) >= 2)[0]
    x0, x1 = max(int(cols[0]) - 15, 0), int(cols[-1]) + 15
    lum = (r + g + b) / 3
    reg = lum[50:, :]
    med = float(np.median(reg))
    s = (np.abs(r - b) < 22) & (lum < med - 18) & (r < 100)
    s[:bot - 25] = False
    s[bot + 60:] = False
    s[:, :x0] = False
    s[:, x1:] = False
    ys = np.where(s.sum(axis=1) >= 4)[0]
    sh = (float(np.where(s)[0].mean()), int(ys[-1])) if len(ys) else (None, None)
    return {"top": top, "bottom": bot, "sh_cy": sh[0], "sh_bottom": sh[1]}


def main(argv):
    a, b = arg(argv, "a"), arg(argv, "b")
    t0, n = int(arg(argv, "from")), int(arg(argv, "count"))
    out = arg(argv, "out")
    bx, by, bs = [int(v) for v in arg(argv, "box", "835,385,240").split(",")]
    sc = int(arg(argv, "scale", "4"))
    la, lb = arg(argv, "la", "main ba8e470b0"), arg(argv, "lb", "HEAD")
    os.makedirs(out, exist_ok=True)
    fa, fb = grab(a, t0, n), grab(b, t0, n)
    font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 36)
    meas = []
    for i, (x, y) in enumerate(zip(fa, fb)):
        ca, cb = x[by:by + bs, bx:bx + bs], y[by:by + bs, bx:bx + bs]
        meas.append({"tick": t0 + i, "a": body_rows(ca), "b": body_rows(cb)})
        im = Image.new("RGB", (bs * sc * 2 + 8, bs * sc + 50), (20, 20, 20))
        im.paste(Image.fromarray(ca).resize((bs * sc, bs * sc), Image.NEAREST), (0, 50))
        im.paste(Image.fromarray(cb).resize((bs * sc, bs * sc), Image.NEAREST), (bs * sc + 8, 50))
        d = ImageDraw.Draw(im)
        d.text((8, 4), f"{la}  tick {t0 + i}", fill=(255, 255, 255), font=font)
        d.text((bs * sc + 16, 4), f"{lb}  tick {t0 + i}", fill=(255, 255, 255), font=font)
        im.save(os.path.join(out, f"pair_{t0 + i:05d}.png"))
    json.dump(meas, open(os.path.join(out, "measure.json"), "w"))
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-framerate", "60", "-start_number", str(t0),
                    "-i", os.path.join(out, "pair_%05d.png"), "-c:v", "libx264", "-crf", "20", "-pix_fmt", "yuv420p", os.path.join(out, "strip.mp4")])
    for k in ("a", "b"):
        v = [m[k] for m in meas if m[k]]
        if not v:
            continue
        tops, bots = [q["top"] for q in v], [q["bottom"] for q in v]
        gaps = [q["sh_cy"] - q["top"] for q in v if q["sh_cy"] is not None]
        print(f"{k}: helmet top y {min(tops)}-{max(tops)} (range {max(tops) - min(tops)}), body-bottom y {min(bots)}-{max(bots)} "
              f"(range {max(bots) - min(bots)}), helmet-top to shadow-centre {np.mean(gaps):.1f} px mean "
              f"({min(gaps):.0f} to {max(gaps):.0f}, range {max(gaps) - min(gaps):.0f}), {len(v)}/{n} frames")


if __name__ == "__main__":
    main(sys.argv[1:])

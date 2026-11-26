"""Finds the ticks where the camera (so Rivet) moves in a play_take mp4, and which way.

  python tools/ground/running_ticks.py <take.mp4> [--step=4] [--min=0.5] [--json=<file>]

Frames are decoded at 480x270 gray (full frame / 4); the background shift between frame n and n+step
(phase correlation) is the camera move; Rivet moves the opposite way of the background shift.
Prints runs: `start-end  dir  speed_px_per_tick(1080p)`. dir is the screen direction Rivet runs
(N = up-screen)."""
import json
import subprocess
import sys

import numpy as np

W, H = 480, 270


def frames(path):
    p = subprocess.Popen(["ffmpeg", "-v", "error", "-i", path, "-vf", f"scale={W}:{H}:flags=area,format=gray",
                          "-f", "rawvideo", "-"], stdout=subprocess.PIPE)
    n = W * H
    while True:
        b = p.stdout.read(n)
        if len(b) < n:
            break
        yield np.frombuffer(b, np.uint8).astype(np.float32).reshape(H, W)


def shift(a, b):
    """Integer (dx, dy) such that b ~= a moved by (dx, dy), by phase correlation."""
    win = np.outer(np.hanning(H), np.hanning(W)).astype(np.float32)
    fa, fb = np.fft.fft2((a - a.mean()) * win), np.fft.fft2((b - b.mean()) * win)
    r = fa.conj() * fb
    r /= np.abs(r) + 1e-6
    c = np.fft.ifft2(r).real
    y, x = np.unravel_index(np.argmax(c), c.shape)
    return (x if x <= W // 2 else x - W), (y if y <= H // 2 else y - H)


def direction(vx, vy):
    names = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
    ang = np.degrees(np.arctan2(vy, vx)) % 360
    return names[int(((ang + 22.5) % 360) // 45)]


def runs(vel, minspeed, gap=6):
    """Groups per-sample (tick, vx, vy) into runs of moving samples; vel in px/tick at 1080p."""
    out, cur = [], None
    for t, vx, vy in vel:
        if np.hypot(vx, vy) >= minspeed:
            if cur and t - cur["end"] <= gap:
                cur["end"] = t
                cur["v"].append((vx, vy))
            else:
                cur = {"start": t, "end": t, "v": [(vx, vy)]}
                out.append(cur)
    res = []
    for r in out:
        vx, vy = np.mean(r["v"], axis=0)
        res.append({"start": r["start"], "end": r["end"], "dir": direction(vx, vy),
                    "speed": round(float(np.hypot(vx, vy)), 2)})
    return res


def main(argv):
    path = argv[0]
    step = int([a for a in argv if a.startswith("--step=")][0][7:]) if any(a.startswith("--step=") for a in argv) else 4
    mn = float([a for a in argv if a.startswith("--min=")][0][6:]) if any(a.startswith("--min=") for a in argv) else 0.5
    buf, vel = [], []
    for i, f in enumerate(frames(path)):
        buf.append(f)
        if len(buf) > step:
            a = buf.pop(0)
            dx, dy = shift(a, f)
            # background moves opposite to Rivet; x4 for 1080p, per tick
            vel.append((i - step, -dx * 4 / step, -dy * 4 / step))
    res = runs(vel, mn)
    for r in res:
        print(f"{r['start']}-{r['end']}  {r['dir']}  {r['speed']}")
    for a in argv:
        if a.startswith("--json="):
            json.dump(res, open(a[7:], "w"))


if __name__ == "__main__":
    main(sys.argv[1:])

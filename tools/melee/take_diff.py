"""n31 melee 04f: where two takes of one seed differ (item 4's view-only impacts).

python tools/melee/take_diff.py <before.mp4> <after.mp4>

Both takes play the same seed and rules, so every frame matches but for the marks. Prints the seconds
(20 fps, the middle half of a 960x540 frame) with more than 40 differing pixels and their median spot.
"""

import subprocess
import sys

import numpy as np

FPS = 20
W, H = 960, 540


def frames(path):
    vf = "fps=%d,scale=%d:%d" % (FPS, W, H)
    cmd = ["ffmpeg", "-loglevel", "error", "-i", path, "-vf", vf, "-f", "rawvideo", "-pix_fmt", "rgb24", "-"]
    return subprocess.Popen(cmd, stdout=subprocess.PIPE)


def main(before, after):
    a, b = frames(before), frames(after)
    size = W * H * 3
    i = 0
    hits = []
    while True:
        x, y = a.stdout.read(size), b.stdout.read(size)
        if len(x) < size or len(y) < size:
            break
        x = np.frombuffer(x, np.uint8).reshape(H, W, 3).astype(np.int16)
        y = np.frombuffer(y, np.uint8).reshape(H, W, 3).astype(np.int16)
        d = np.abs(x - y).sum(2)[:, W // 4 : W * 3 // 4] > 90
        n = int(d.sum())
        if n > 40:
            ys, xs = np.nonzero(d)
            hits.append("%.2f:%d@%d,%d" % (i / FPS, n, int(np.median(xs)) + W // 4, int(np.median(ys))))
        i += 1
    print("frames %d" % i)
    print("differ " + " ".join(hits))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])

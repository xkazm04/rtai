"""n31-16: two frames of a prologue_play_take film cropped on ONE world-anchored box, side by side.

The camera pans, so a screen box shows other floor in the second frame; this cuts the box at the first
tick and the same floor box (moved by the logged canvas shift, render px) at the second, so a print
that slides over the floor shows as grime/tooth moving against a rock that holds still.

  python tools/ground/world_still.py <take dir> <tick1> <tick2> <x,y,w,h> <out.png> [--scale=2]
x,y,w,h: the box in render px of the movie frame at tick1 (movie = the 1920x1080 window).
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image


def load(take):
    rows = [json.loads(line) for line in open(os.path.join(take, "ticks.jsonl"), encoding="utf8")]
    return {r["tick"]: r for r in rows}, rows[0]["tick"]


def origin_px(row):
    sx, sy, tx, ty = row["stretch"]
    return np.array([row["canvas_origin"][0] * sx + tx, row["canvas_origin"][1] * sy + ty])


def frame_index(tick, first_tick, n_rows, n_frames):
    """The movie has a few frames before the first logged step: they sit at the start."""
    return tick - first_tick + (n_frames - n_rows)


def box_shift(row1, row2):
    """Render px the floor moved between the two ticks (the box follows it)."""
    return origin_px(row2) - origin_px(row1)


def grab(mp4, index, dest):
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", mp4, "-vf", f"select=eq(n\,{index})",
                    "-vframes", "1", dest], check=True)
    return Image.open(dest).convert("RGB")


def main(argv):
    take, t1, t2 = argv[0], int(argv[1]), int(argv[2])
    x, y, w, h = [int(v) for v in argv[3].split(",")]
    out = argv[4]
    scale = int([a for a in argv[5:] if a.startswith("--scale=")][0][8:]) if len(argv) > 5 else 2
    rows, first = load(take)
    mp4 = os.path.join(take, "take.mp4")
    n_frames = int(subprocess.check_output(["ffprobe", "-v", "error", "-count_packets", "-select_streams", "v:0",
                                            "-show_entries", "stream=nb_read_packets", "-of", "csv=p=0", mp4]).decode().strip())
    tiles = []
    for t in (t1, t2):
        im = grab(mp4, frame_index(t, first, len(rows), n_frames), out + f".t{t}.png")
        d = box_shift(rows[t1], rows[t])
        bx, by = int(round(x + d[0])), int(round(y + d[1]))
        tiles.append(im.crop((bx, by, bx + w, by + h)).resize((w * scale, h * scale), Image.NEAREST))
        os.remove(out + f".t{t}.png")
    sheet = Image.new("RGB", (tiles[0].width * 2 + 8, tiles[0].height), (255, 0, 255))
    sheet.paste(tiles[0], (0, 0))
    sheet.paste(tiles[1], (tiles[0].width + 8, 0))
    sheet.save(out)
    print(out, "ticks", t1, t2, "floor shift px", np.round(box_shift(rows[t1], rows[t2]), 2).tolist())
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

"""Build the n21 boards from kerf_n21_review.mjs and ghost_films.mjs captures (Pillow, FFmpeg)."""

import argparse
import json
from pathlib import Path
import subprocess

from PIL import Image, ImageDraw, ImageFont

PAPER = "#132226"
INK = "#e0eeec"
MUTED = "#8bb2af"


def shot_path(archive, view, mark, ppm):
    return archive / "wire" / f"{mark}_{view}_{ppm}.png"


def crop(archive, view, mark, ppm, size):
    path = shot_path(archive, view, mark, ppm)
    meta = json.loads(path.with_suffix(".json").read_text())
    x, y = meta["centre"]
    if mark == "guard":
        gx, gy = meta["guard"]
        x, y = (x + gx) / 2, (y + gy - 24) / 2
    x, y = round(x - size[0] / 2), round(y - size[1] / 2)
    with Image.open(path) as im:
        return im.convert("RGB").crop((x, y, x + size[0], y + size[1]))


def label(canvas, xy, text, size=18, color=INK):
    font = ImageFont.truetype("segoeui.ttf", size)
    ImageDraw.Draw(canvas).text(xy, text, font=font, fill=color, anchor="lt")


def guard_board(archive):
    w, h, margin = 300, 240, 12
    out = Image.new("RGB", (3 * w * 3 + 4 * margin, h * 4 + 144), PAPER)
    for i, (view, title) in enumerate([("tilt70", "70\u00b0 tilt"), ("tilt", "55\u00b0 tilt"), ("top", "Overhead")]):
        frame = crop(archive, view, "guard", 32, (w, h))
        x = margin + i * (3 * w + margin)
        label(out, (x, 16), title, 24)
        label(out, (x + w, 53), "32 px/m  \u00b7  native", 17, MUTED)
        out.paste(frame, (x + w, 80))
        label(out, (x, 100 + h), "3\u00d7 nearest-neighbour", 17, MUTED)
        out.paste(frame.resize((3 * w, 3 * h), Image.Resampling.NEAREST), (x, 128 + h))
    out.save(archive / "kerf_guard_32.png")


def pose_board(archive):
    w, h, gap = 532, 486, 8
    out = Image.new("RGB", (4 * (w + gap) + gap, 2 * (h + 47) + 48), PAPER)
    for r, (view, title) in enumerate([("tilt70", "70\u00b0 tilt"), ("top", "Overhead")]):
        y = 46 + r * (h + 47)
        label(out, (gap, y - 3), f"{title}   /   64 px/m", 19, MUTED)
        for i, mark in enumerate(("hover", "cruise", "turn", "hit")):
            x = gap + i * (w + gap)
            if r == 0:
                label(out, (x, 9), mark.upper(), 22)
            out.paste(crop(archive, view, mark, 64, (w, h)), (x, y + 28))
    out.save(archive / "kerf_poses_64.png")


def plate_board(archive, plate):
    out = Image.new("RGB", (1312, 532), PAPER)
    label(out, (12, 12), "Swarf Ronin   /   concept plate", 21)
    label(out, (807, 12), "HOVER   /   70\u00b0 tilt   /   64 px/m", 21)
    with Image.open(plate) as original:
        ref = original.convert("RGB").resize((720, 480), Image.Resampling.LANCZOS)
    out.paste(ref, (12, 42))
    out.paste(crop(archive, "tilt70", "hover", 64, (558, 480)), (742, 42))
    out.save(archive / "kerf_plate_vs_game.png")


def before_after(archive, before):
    # Both films start on arena tick 68. Select the exact decoded frame, independently of keyframes.
    tick = 158
    out = Image.new("RGB", (2 * 478 + 24, 2 * 282 + 118), PAPER)
    for i, (name, movie) in enumerate([("n20   /   Gantry Wraith", before),
                                       ("n21   /   Swarf Ronin", archive / "kerf_move_32.mp4")]):
        path = archive / "wire" / f"comparison_{i}.png"
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(movie), "-vf",
                        f"select=eq(n\\,{tick - 68})", "-frames:v", "1", "-update", "1", str(path)], check=True)
        x = 8 + i * 486
        label(out, (x, 12), f"{name}    /    tick {tick}    /    32 px/m", 17)
        with Image.open(path) as frame:
            for row, (title, y) in enumerate([("70\u00b0 tilt", 154), ("Overhead", 650)]):
                label(out, (x, 43 + row * 320), title, 18, MUTED)
                out.paste(frame.crop((974, y, 1452, y + 282)), (x, 69 + row * 320))
    out.save(archive / "kerf_move_before_after_32.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    args = parser.parse_args()
    archive = args.archive.resolve()
    guard_board(archive)
    pose_board(archive)
    plate_board(archive, archive.parent / "concepts/kerf_b.png")
    before_after(archive, archive.parents[1] / "n20/kerf/kerf_move_32.mp4")

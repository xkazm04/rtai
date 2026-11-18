"""Build the 64 px/m comparison and 32 px/m MP4 from stride_film leg 2.

Usage: py -3 -I evidence/tonnage-hold/frames.py build/film <masters directory>
Inputs use the prefixes gait64_tonnage_full_{before,after} and gait32_tonnage_clip.
"""

import argparse
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def still(film, destination):
    samples = [(55, 1), (61, 2), (67, 3), (76, 5), (88, 6), (95, 7)]
    width, height, label = 290, 324, 36
    out = Image.new("RGB", (len(samples) * width, 2 * (height + label)), (33, 37, 40))
    draw = ImageDraw.Draw(out)
    for row, stage in enumerate(("before", "after")):
        for j, (tick, col) in enumerate(samples):
            x, y = j * width, row * (height + label)
            with Image.open(film / f"gait64_tonnage_full_{stage}_2_{tick:02}.png") as frame:
                out.paste(frame.crop((85, 68, 375, 392)).convert("RGB"), (x, y + label))
            bold = col in (2, 6)
            font = ImageFont.truetype("segoeuib.ttf" if bold else "segoeui.ttf", 19 if bold else 18)
            draw.text((x + 7, y + 4), f"{stage.title()}   t{tick}   col {col}", (247, 248, 250), font)
    out.save(destination / "profile_before_after_64ppm.png")


def clip(film, destination):
    font = ImageFont.truetype("segoeui.ttf", 13)
    path = destination / "tonnage_walk_after_32ppm.mp4"
    args = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "rawvideo",
            "-pix_fmt", "rgb24", "-s", "260x286", "-r", "60", "-i", "pipe:0", "-an",
            "-c:v", "libx264", "-crf", "15", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(path)]
    with subprocess.Popen(args, stdin=subprocess.PIPE) as encoder:
        for copies, speed in ((1, "real time"), (3, "one-third speed")):
            for tick in range(180):
                pic = Image.new("RGB", (260, 286), (33, 37, 40))
                with Image.open(film / f"gait32_tonnage_clip_2_{tick:02}.png") as frame:
                    pic.paste(frame, (0, 0))
                ImageDraw.Draw(pic).text((7, 264), "Tonnage   /   32 px/m   /   " + speed,
                                         font=font, fill="white")
                encoder.stdin.write(pic.tobytes() * copies)
        encoder.stdin.close()
        if encoder.wait():
            raise RuntimeError("ffmpeg failed to encode the walk clip")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("film", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    args.destination.mkdir(parents=True, exist_ok=True)
    still(args.film, args.destination)
    clip(args.film, args.destination)

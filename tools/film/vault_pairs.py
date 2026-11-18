"""Build labelled, same-tick comparisons from vault_course framebuffer captures."""
import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def pair(directory: Path, view: str, ppm: int, tick: int, phase: str) -> None:
    # Keep both approaches in frame at native resolution, including the 64 px/m run.
    width, height, header = 448, (320 if ppm == 64 else 240), 36
    canvas = Image.new("RGB", (width * 2 + 4, height + header), "#17131b")
    ink = ImageDraw.Draw(canvas)
    font = ImageFont.load_default(size=17)
    for index, arm in enumerate(("before", "after")):
        name = f"{view}_{ppm}_{arm}_t{tick:03d}.png"
        with Image.open(directory / name) as image:
            left = (image.width - width) // 2
            top = (image.height - height) // 2
            crop = image.crop((left, top, left + width, top + height))
            x = index * (width + 4)
            canvas.paste(crop, (x, header))
            label = f"{arm.upper()}   {view}   {ppm} px/m   {phase}   tick {tick}"
            ink.text((x + 10, 7), label, fill="#f3e8d5", font=font)
    canvas.save(directory / f"{view}_{ppm}_pair_t{tick:03d}.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    args = parser.parse_args()
    for camera, scale in (("top", 32), ("tilt", 32), ("tilt70", 32), ("tilt70", 64)):
        for frame, pose in ((45, "approach"), (55, "take-off"), (63, "apex"), (72, "landing")):
            if scale == 32 or frame >= 63:
                pair(args.directory, camera, scale, frame, pose)

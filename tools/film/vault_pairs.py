"""Build labelled, same-tick comparisons from the vault and cover courses."""
import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def pair(directory: Path, view: str, ppm: int, tick: int, phase: str) -> None:
    """The original vault crop, at the framebuffer's native resolution."""
    _pair(directory, view, ppm, (tick, phase), (448, 320 if ppm == 64 else 240))


def _pair(directory: Path, view: str, ppm: int, pose: tuple[int, str], size: tuple[int, int]) -> None:
    tick, phase = pose
    width, height = size
    header = 36
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


def cover_pairs(directory: Path) -> None:
    """Keep both guns, the incoming round and the taller off-cover figure in each panel."""
    shots = ((65, "IN / incoming"), (116, "slide"), (162, "peek / fire"),
             (219, "back in"), (254, "leaving"))
    for view in ("top", "tilt", "tilt70"):
        for chapter, kind in enumerate(("low", "high")):
            for tick, pose in shots:
                _pair(directory, view, 32, (tick + chapter * 315, f"{kind} {pose}"), (512, 336))
    for tick, pose in (shots[0], shots[2]):
        _pair(directory, "tilt70", 64, (tick, f"low {pose}"), (800, 512))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("--course", choices=("vault", "cover"), default="vault")
    args = parser.parse_args()
    if args.course == "cover":
        cover_pairs(args.directory)
        parser.exit()
    for camera, scale in (("top", 32), ("tilt", 32), ("tilt70", 32), ("tilt70", 64)):
        for frame, pose in ((45, "approach"), (55, "take-off"), (63, "apex"), (72, "landing")):
            if scale == 32 or frame >= 63:
                pair(args.directory, camera, scale, frame, pose)

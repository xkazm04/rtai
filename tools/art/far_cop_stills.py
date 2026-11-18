"""Annotate and pair the character-path stills from dev/sim/far_cop_rows."""

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def crop(directory, ppm, tick, actor, source):
    probe = json.loads((directory / f"probe_{ppm}.json").read_text(encoding="utf-8"))
    row = next(r for r in probe["rows"] if r["tick"] == tick and r["actor_id"] == actor)
    with Image.open(directory / f"{source}_t{tick}_{ppm}ppm.png") as frame:
        x, y = map(round, row["screen_px"])
        y -= round(ppm * 0.55)  # instance origin is at the feet
        radius = round(ppm * 1.15)
        w, h = frame.size
        if not (radius <= x < w - radius and radius <= y < h - radius):
            raise ValueError(f"actor {actor} is outside the frame at {ppm} px/m")
        marked = frame.convert("RGB")
        ImageDraw.Draw(marked).ellipse(
            (x - radius, y - radius, x + radius, y + radius),
            outline="#ffe257", width=2,
        )
        marked.save(directory / f"{source}_circled_t{tick}_{ppm}ppm.png")
        # Keep the original pixel grid. Show six metres around the measured instance origin.
        half = 3 * ppm
        detail = marked.crop((x - half, y - half, x + half, y + half))
        return detail.resize((384, 384), Image.Resampling.NEAREST), row


def pair(args, ppm, source):
    joined = Image.new("RGB", (768, 452), "#19232e")
    draw = ImageDraw.Draw(joined)
    title = ImageFont.truetype("segoeui.ttf", 18)
    label = ImageFont.truetype("segoeui.ttf", 16)
    draw.text((12, 6), f"Heat 3   /   Cop {args.actor}   /   Tick {args.tick}   /   {ppm} px/m",
              font=title, fill="white")
    stages = ("before", "after") if args.after else ("before",)
    for j, stage in enumerate(stages):
        detail, row = crop(args.root / stage, ppm, args.tick, args.actor, source)
        if source == "city":
            path, look = "Native city", row["sim_row"]
        else:
            path, look = "Character preview", row["atlas_row"]
        draw.text((384 * j + 12, 38), f"{stage.title()}   /   {path}   /   Row {look}",
                  font=label, fill="#ffe257")
        joined.paste(detail, (384 * j, 68))
    if args.after:
        joined.save(args.root / f"{source}_pair_t{args.tick}_{ppm}ppm.png")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("--after", action="store_true")
    parser.add_argument("--actor", type=int, default=49)
    parser.add_argument("--tick", type=int, default=360)
    args = parser.parse_args()
    for ppm in (16, 32):
        for source in ("city", "character"):
            pair(args, ppm, source)


if __name__ == "__main__":
    main()

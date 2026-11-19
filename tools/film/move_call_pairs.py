"""Pair native-pixel move captures and index the measured shots for the owner's Calls.

python tools/film/move_call_pairs.py build/owner-calls/final <move masters directory>
"""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageDraw, ImageFont


def pair(left, right, box, labels, destination):
    """Crop both framebuffers at identical coordinates and retain their original pixel scale."""
    width, height = box[2] - box[0], box[3] - box[1]
    sheet = Image.new("RGB", (width * 2 + 2, height + 34), "#272822")
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("segoeui.ttf", 16)
    except OSError:
        font = ImageFont.load_default()
    for i, (path, label) in enumerate(zip((left, right), labels)):
        with Image.open(path) as src:
            if src.size != (1280, 800):
                raise ValueError(f"Unexpected framebuffer size in {path}")
            x = i * (width + 2)
            sheet.paste(src.crop(box), (x, 34))
            draw.text((x + 10, 5), label, fill="#f2efe8", font=font)
    sheet.save(destination)


def evidence(rows, subject, value, ppm):
    row = next(r for r in rows if (r["subject"], r["value"], r["ppm"]) == (subject, value, ppm))
    return row["measured"]


def crop(subject, ppm):
    # Bounds in ground metres around the fixed framebuffer centre for the two arena cameras.
    limits = {"cover": (-3.7, -4.25, 5.9, 3.8), "vault": (-3.8, -4.2, 3.8, 4.3),
              "car": (-4.5, -4.2, 4.5, 3.4)}
    a, b, c, d = limits[subject]
    return (640 + round(a * ppm), 400 + round(b * ppm), 640 + round(c * ppm), 400 + round(d * ppm))


def make_pairs(takes, masters):
    rows = json.loads((takes / "measurements.json").read_text(encoding="utf-8"))
    out = masters / "calls"
    out.mkdir(parents=True, exist_ok=True)
    lines = ["# RTAI movement Calls", "",
             "Each panel shows the same simulation tick and 70° camera. Crops retain the captured pixel scale. "
             "The left panel uses the shipped data or default flag state.", "",
             "| Comparison | Tick | Density | Values and observations |",
             "| --- | --- | --- | --- |"]
    for ppm in (64, 32):
        for subject, tick, arms in (("cover", 162, ("0.8", "0.45")), ("vault", 12, ("false", "true")),
                                   ("car", 124, ("off", "on"))):
            if subject == "car":
                paths = [masters / "car" / f"{arm}-{ppm}" / "124-approach.png" for arm in arms]
                labels = ("Flag off · cosmetic entry", "--car-doors · timed entry")
                note = "Flag off seats Rivet on the use press. With the flag on his feet are still approaching the door."
            else:
                paths = [takes / f"{subject}_{arm}_{ppm}_t{tick:03}.png" for arm in arms]
                logs = [evidence(rows, subject, arm, ppm) for arm in arms]
                if subject == "cover":
                    labels = ("peek_m = 0.8 m", "peek_m = 0.45 m")
                    answers = [re.search(r"blocks=(true|false)", line).group(1) for line in logs]
                    note = (f"0.8 m and 0.45 m. ArenaWalls.blocks returned **{answers[0]}** and **{answers[1]}** "
                            "for Rivet's first fired round, projected from its muzzle along its actual spread direction.")
                else:
                    labels = ("bodies_block_landing = false", "bodies_block_landing = true")
                    metrics = [re.search(r"peak_mps=([\d.]+) shove_m=([\d.]+) reason=(\w+)", line).groups()
                               for line in logs]
                    note = (f"False allowed the tackle ({float(metrics[0][0]):.2f} m/s peak, "
                            f"{float(metrics[0][1]):.2f} m shove). True returned {metrics[1][2]} "
                            f"and moved the guard {float(metrics[1][1]):.2f} m.")
            file = f"{subject}-{ppm}-t{tick:03}.png"
            pair(*paths, crop(subject, ppm), labels, out / file)
            lines.append(f"| [{subject.title()}]({file}) | {tick} | {ppm} px/m | {note} |")
    (out / "INDEX.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("takes", type=Path)
    parser.add_argument("masters", type=Path)
    args = parser.parse_args()
    make_pairs(args.takes, args.masters)

"""Recut the accepted factory-n26 masters. Pass their out directory as the argument."""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw

from prologue_yard_cut import ART, cut_job


def piece(name, box, metres, **options):
    return dict(id=name, box=box, size_m=metres, **options)


def cover(name, box, metres, **options):
    return piece(name, box, metres, trim_to_solid=True, **options)


# Source boxes are in master pixels; metre sizes are the final ground-plane projection.
SHEETS = {
    "fence-gate": [
        # Split both rails through matching steel posts. Offset the finished panel
        # so the texture sampler crosses the repeat inside a continuous source bay.
        piece("fence_panel", (175, 119, 1276, 207), (9.6, 1.45)),
        piece("side_fence", (1635, 105, 50, 640), (0.32, 6.0)),
        piece("sliding_gate", (113, 481, 596, 326), (5.1, 2.38)),
        piece("gate_post_left", (777, 480, 128, 325), (0.76, 2.18)),
        piece("gate_post_right", (950, 480, 140, 325), (0.76, 2.18)),
        piece("corner_post", (1154, 430, 355, 376), (2.25, 2.44)),
    ],
    "conveyor-run": [
        cover("straight_west", (0, 0, 885, 315), (5.4, 1.2)),
        cover("straight_east", (885, 0, 889, 315), (5.2, 1.2)),
        cover("bent_rail", (0, 315, 900, 340), (5.2, 1.2)),
        cover("torn_end", (900, 315, 874, 340), (5.4, 1.2)),
        cover("feed_slope", (885, 0, 889, 315), (5.2, 1.2), end_rise=-1.4),
        cover("return_slope", (0, 0, 885, 315), (5.4, 1.2), end_rise=1.4),
        cover("tail_slope", (900, 315, 874, 340), (5.4, 1.2), end_rise=-1.2),
        cover("outer_bend", (0, 315, 900, 340), (5.2, 1.2), end_rise=1.35, bend=True),
        cover("inner_bend", (0, 315, 900, 340), (5.2, 1.2),
              end_rise=1.35, bend=True, mirror=True),
        piece("belt_fray", (1347, 402, 368, 164), (2.25, 0.87), end_rise=-1.3, bend=True,
              outline=[(7, 39), (12, 21), (40, 27), (68, 19), (98, 5), (171, 2),
                       (173, 55), (105, 83), (192, 70), (363, 72), (367, 157),
                       (241, 154), (159, 115), (114, 124), (50, 85), (9, 62)]),
        piece("loose_roller", (1531, 533, 44, 36), (0.52, 0.30),
              outline=[(0, 11), (11, 3), (19, 3), (25, 13), (32, 19), (43, 18),
                       (43, 30), (31, 34), (20, 24), (9, 19), (0, 20)]),
        piece("fallen_washer", (528, 686, 217, 143), (1.18, 0.86)),
        piece("fridge_door", (1009, 699, 178, 70), (1.35, 0.49)),
        piece("hook_drum", (396, 135, 140, 156), (0.73, 0.88),
              outline=[(54, 2), (82, 2), (86, 21), (78, 37), (80, 49),
                       (109, 50), (116, 63), (136, 76), (133, 138), (102, 152),
                       (13, 149), (5, 130), (12, 65), (20, 49), (56, 48)]),
    ],
    "front-broken-b": [
        piece("burst_bay", (0, 0, 768, 545), (15, 7.35)),
        piece("feed_bay", (768, 0, 768, 545), (15, 7.85)),
        piece("shutter_bay", (0, 545, 768, 479), (15, 6.95)),
        piece("collapsed_bay", (768, 545, 768, 479), (15, 7.35)),
        piece("wall_lamp", (360, 710, 87, 68), (0.95, 0.85),
              outline=[(36, 17), (41, 16), (43, 29), (49, 35), (58, 42), (62, 50),
                       (53, 53), (42, 54), (39, 57), (34, 54), (18, 52), (16, 48),
                       (21, 42), (29, 36), (35, 29)]),
    ],
    "yard-props": [
        piece("gate_lamp", (0, 0, 480, 550), (1.6, 1.6)),
        piece("payphone", (545, 0, 350, 550), (0.82, 1.19)),
        cover("pallet_stack", (975, 0, 561, 550), (2.4, 1.6)),
        cover("pallet_toppled", (0, 550, 435, 474), (2.4, 1.6)),
        cover("toppled_arm", (435, 550, 535, 474), (2.5, 3.7), turn_clockwise=True),
        cover("fridge_bank", (970, 550, 566, 474), (4, 1.8)),
    ],
}


def open_wire(master):
    """Remove the printed paper inside the diamonds, including its grey halftone.

    The stock matte key follows the exterior silhouette. These apertures stop at
    the posts and rails; the dented second bay follows the dip of its top rail.
    """
    mask = Image.new("1", master.size)
    draw = ImageDraw.Draw(mask)
    for left, right in [(147, 162), (185, 478), (818, 1122), (1147, 1439), (1464, 1481)]:
        draw.rectangle((left, 201, right, 289), fill=1)
    draw.polygon([(503, 201), (538, 202), (581, 216), (644, 217), (705, 202),
                  (794, 201), (794, 289), (503, 289)], fill=1)
    draw.rectangle((173, 555, 624, 730), fill=1)
    draw.rectangle((1201, 687, 1422, 765), fill=1)
    rgb = np.asarray(master.convert("RGB"), dtype=np.float32)
    # Coverage against the warm grey paper in the fenced cells. Keep dense metal
    # in its original colours and unmix the fringe before the cut is resampled.
    coverage = np.clip((205 - rgb.min(axis=2)) / 110, 0, 1)
    coverage = np.where(np.asarray(mask), coverage, 1)
    ink = 205 + (rgb - 205) / np.maximum(coverage[..., None], 1 / 255)
    return Image.fromarray(np.dstack((ink, coverage * 255)).round().clip(0, 255).astype("uint8"))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--sheet", choices=SHEETS)
    args = parser.parse_args()
    folder = ART / "line_fire"
    folder.mkdir(exist_ok=True)
    for name, rows in SHEETS.items():
        if args.sheet and args.sheet != name:
            continue
        with Image.open(args.source / f"{name}.png") as master:
            if name == "fence-gate":
                master = open_wire(master)
            cuts = cut_job(master, {"px_per_m": 96, "shadow_ink": "#211e1c", "pieces": rows})
        if name == "conveyor-run":
            cuts["belt_fold"] = cuts["belt_fray"].transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        if name == "fence-gate":
            panel = cuts["fence_panel"]
            cuts["fence_panel"] = ImageChops.offset(panel, panel.width // 8, 0)
            left = cuts.pop("gate_post_left")
            right = cuts.pop("gate_post_right")
            posts = Image.new("RGBA", (left.width + right.width, left.height))
            posts.paste(left)
            posts.paste(right, (left.width, 0))
            cuts["gate_posts"] = posts
        for stem, cut in cuts.items():
            cut.save(folder / f"{stem}.png")


if __name__ == "__main__":
    main()

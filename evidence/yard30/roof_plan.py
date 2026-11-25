"""n30 roof placement plan: slab and plume rows for arched_line.factory_front, written to roof_plan.json.

python evidence/yard30/roof_plan.py
Reads the table's five bay pieces and the cuts in project/boot/prologue/art/arched_line/. Nothing is edited.
Paste order: the five slabs first, then the plumes, then the bays.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "art"))
import prologue_yard_roof as roof  # noqa: E402

ART = ROOT / "project/boot/prologue/art/arched_line"
TABLE = ROOT / "project/data/tables/prologue_yard_dressings.json"
DEPTH_M = 5.5
SIDE_OVERLAP_M = 0.15  # each side
PLUME_FOOT_M = 0.25  # the plume's foot sits this far below the fire spot
# Bay order of the front -> slab name, plume indices (1-based hall_plume_<n>); no plume used twice.
BAYS = [("hall_roof_shutter_w", [1, 2]), ("hall_roof_burst", [3, 4]), ("hall_roof_feed", [5]),
        ("hall_roof_shutter_e", [6]), ("hall_roof_collapsed", [7])]
SRC = ROOT / "tools/art/prologue_yard_sources/n30"


def rgba(path):
    return np.asarray(Image.open(path).convert("RGBA"))


def plume_sizes():
    plumes = roof.split_plumes(roof.keyed(SRC / "plumes-a.png"))
    scale = roof.plume_scale(plumes)
    return [[round(p.shape[1] * scale, 2), round(p.shape[0] * scale, 2)] for p in plumes]


def main():
    front = json.loads(TABLE.read_text(encoding="utf-8"))["dressings"]["arched_line"]["factory_front"]
    bays = [p for p in front if "hall_tall_" in p["art"]]
    assert len(bays) == 5, len(bays)
    sizes = plume_sizes()
    out = {"depth_m": DEPTH_M, "tuck_m": roof.TUCK_M, "slabs": [], "plumes": [], "notes": []}
    for bay, (name, plume_ids) in zip(bays, BAYS):
        flip = bool(bay.get("flip", False))
        w_m, h_m = bay["size_m"]
        bay_png = rgba(ART / (Path(bay["art"]).name))
        line_m = roof.roof_line(bay_png) / bay_png.shape[0] * h_m
        south = bay["at"][1] - h_m / 2 + line_m + roof.TUCK_M
        width = round(w_m + 2 * SIDE_OVERLAP_M, 2)
        slab = {"art": f"res://boot/prologue/art/arched_line/{name}.png",
                "at": [bay["at"][0], round(south - DEPTH_M / 2, 3)], "ochre": True, "rotation_deg": 0,
                "size_m": [width, DEPTH_M]}
        if flip:
            slab["flip"] = True
        out["slabs"].append(slab)
        cut = rgba(ART / f"{name}.png")
        sx, sy = roof.fire_spot(cut)
        fx = (sx / cut.shape[1] - 0.5) * width
        fy = (sy / cut.shape[0] - 0.5) * DEPTH_M
        for j, pid in enumerate(plume_ids):
            dx = fx + j * width / 3
            dx = (dx + width / 2) % width - width / 2
            px = bay["at"][0] + (-dx if flip else dx)
            pw, ph = sizes[pid - 1]
            out["plumes"].append({"art": f"res://boot/prologue/art/arched_line/hall_plume_{pid}.png",
                                  "at": [round(px, 3), round(slab["at"][1] + fy + PLUME_FOOT_M - ph / 2, 3)],
                                  "ochre": False, "rotation_deg": 0, "size_m": [pw, ph]})
        out["notes"].append({"bay": bay["art"].rsplit("/", 1)[1], "roof_line_m": round(line_m, 3),
                             "south_edge_y": round(south, 3), "fire_spot_m": [round(fx, 2), round(fy, 2)]})
    (Path(__file__).with_name("roof_plan.json")).write_text(json.dumps(out, indent=2, sort_keys=True) + "\n")
    print(json.dumps(out["notes"], indent=1))


main()

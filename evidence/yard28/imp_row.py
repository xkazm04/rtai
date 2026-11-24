"""n28 impression sweep temp edit: python -I evidence/yard28/imp_row.py <impression tint rrggbbaa|none>
Adds arched_line ground_impression (arched_line/floor_tile.png, 8 m tiles, ground[0] rect); ground layers stay as committed. arched_day = same row, day grade, no pools."""
import copy, json, sys
from pathlib import Path
NL = chr(10)
T = Path("project/data/tables/prologue_yard_dressings.json")
DAY = {"accent_keep": 0.0, "gamma": 1.0, "id": "day", "paper_level": 1.0}
top = json.loads(T.read_text())
d = top["dressings"]
row = d["arched_line"]
if sys.argv[1] != "none":
    g = row["ground"][0]
    row["ground_impression"] = {"rect_m": g["rect_m"], "texture": "res://boot/prologue/art/arched_line/floor_tile.png", "tile_size_m": [8, 8], "tiled": True, "tint": sys.argv[1]}
day = copy.deepcopy(row)
day["lights"] = {"grade": DAY, "pools": [], "kinds": [{k: v for k, v in x.items() if k != "floor_glow"} for x in row["lights"]["kinds"]]}
d["arched_day"] = day
with T.open("w", newline=NL) as f:
    f.write(json.dumps(top, indent=2, sort_keys=True) + NL)
print("impression", sys.argv[1])

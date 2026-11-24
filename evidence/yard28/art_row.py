"""n28 art sweep temp edit: python -I evidence/yard28/art_row.py <tint rrggbbaa> <stains tint rrggbbaa> <wash rrggbbaa>
Sets arched_line ground[0].texture to the new tile and the tint, ground[1] stains tint and wash; arched_day = the same row, day grade, no pools."""
import copy, json, sys
from pathlib import Path
NL = chr(10)
T = Path("project/data/tables/prologue_yard_dressings.json")
DAY = {"accent_keep": 0.0, "gamma": 1.0, "id": "day", "paper_level": 1.0}
top = json.loads(T.read_text())
d = top["dressings"]
row = d["arched_line"]
g = row["ground"]
g[0]["texture"] = "res://boot/prologue/art/arched_line/floor_tile.png"
g[0]["tint"], g[1]["tint"], g[1]["wash"] = sys.argv[1:4]
day = copy.deepcopy(row)
day["lights"] = {"grade": DAY, "pools": [], "kinds": [{k: v for k, v in x.items() if k != "floor_glow"} for x in row["lights"]["kinds"]]}
d["arched_day"] = day
with T.open("w", newline=NL) as f:
    f.write(json.dumps(top, indent=2, sort_keys=True) + NL)
print("ground", g[0]["tint"], g[1]["tint"], g[1]["wash"])

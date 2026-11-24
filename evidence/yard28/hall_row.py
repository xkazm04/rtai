"""n28 hall: python -I evidence/yard28/hall_row.py [mouth strength] [mouth radius_m] [floor strength] [floor radius_m]
Sets arched_line's burst/collapsed front art to the burning bays and gives the two mouth pools the yard_hall_mouth kind."""
import json, sys
from pathlib import Path
NL = chr(10)
T = Path("project/data/tables/prologue_yard_dressings.json")
top = json.loads(T.read_text())
row = top["dressings"]["arched_line"]
a = [float(x) for x in sys.argv[1:5]] + [None] * 4
inten, rad, fs, fr = (a + [0.34, 7.5, 0.4, 12])[:4] if len(sys.argv) < 5 else a[:4]
swap = {"line_fire/burst_bay.png": "arched_line/hall_burst_bay.png", "line_fire/collapsed_bay.png": "arched_line/hall_collapsed_bay.png"}
for p in row["factory_front"]:
    for old, new in swap.items():
        if p["art"].endswith(old):
            p["art"] = "res://boot/prologue/art/" + new
kind = {"alt_color": "ffb23a", "color": "ff9a1f", "cone_deg": 0, "flicker_hz": 1.5, "id": "yard_hall_mouth",
        "intensity": inten, "life_ticks": 0, "radius_m": rad, "steps": 6,
        "floor_glow": {"color": "ff8c14", "radius_m": fr, "strength": fs}}
kinds = [k for k in row["lights"]["kinds"] if k["id"] != "yard_hall_mouth"]
row["lights"]["kinds"] = kinds + [kind]
for p in row["lights"]["pools"]:
    if p["id"] in ("burst_door", "collapsed_wall"):
        p["kind"] = "yard_hall_mouth"
with T.open("w", newline=NL) as f:
    f.write(json.dumps(top, indent=2, sort_keys=True) + NL)
print("mouth", inten, rad, fs, fr)

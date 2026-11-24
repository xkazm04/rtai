"""Temporary data edit for the n28 floor sweep: write arched_line (floor scaled by k) and arched_day
(the same row under the day grade, no pools) into project/data/tables/prologue_yard_dressings.json.
python -I evidence/yard28/sweep_row.py <k> [<tint rrggbb> <wash rrggbb>]   k = 1.0 is the raised_line floor unchanged.
The tile layer tint is 255*k*(1, .90, .76) (warmer as it darkens), the stains wash colour is the
raised_line cream f6dca8 scaled by k*(1, .95, .85) with its alpha 80 kept."""
import copy, json, sys
from pathlib import Path
NL = chr(10)
T = Path("project/data/tables/prologue_yard_dressings.json")
WARM_TILE, WARM_WASH = (1.0, 0.90, 0.76), (1.0, 0.95, 0.85)
DAY = {"grade": {"accent_keep": 0.0, "gamma": 1.0, "id": "day", "paper_level": 1.0}, "pools": []}

def scaled(base_hex, k, warm):
    rgb = [int(base_hex[i:i + 2], 16) for i in (0, 2, 4)]
    return "".join(f"{min(255, round(c * k * w)):02x}" for c, w in zip(rgb, warm))

def build(d, k, tint=None, wash=None):
    row = copy.deepcopy(d["raised_line"])
    g = row["ground"]
    g[0]["tint"] = (tint or scaled("ffffff", k, WARM_TILE)) + "ff" if k != 1.0 or tint else g[0]["tint"]
    g[1]["wash"] = (wash or scaled("f6dca8", k, WARM_WASH)) + "80" if k != 1.0 or wash else g[1]["wash"]
    return row

if __name__ == "__main__":
    d = json.loads(T.read_text())["dressings"]
    k = float(sys.argv[1])
    row = build(d, k, *(sys.argv[2:4] if len(sys.argv) > 3 else ()))
    day = copy.deepcopy(row)
    day["lights"] = {"grade": DAY["grade"], "pools": [], "kinds": [{kk: v for kk, v in x.items() if kk != "floor_glow"} for x in row["lights"]["kinds"]]}
    d["arched_line"], d["arched_day"] = row, day
    top = json.loads(T.read_text())
    top["dressings"] = d
    with T.open("w", newline=NL) as f:
        f.write(json.dumps(top, indent=2, sort_keys=True) + NL)
    print("ground", row["ground"][0]["tint"], row["ground"][1]["wash"])

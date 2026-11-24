"""n28: add the temp arched_day row (arched_line with the day grade, no pools) for a paired measure. Remove with `git checkout`-free tool: day_row.py --drop."""
import copy, json, sys
from pathlib import Path
NL = chr(10)
T = Path("project/data/tables/prologue_yard_dressings.json")
DAY = {"accent_keep": 0.0, "gamma": 1.0, "id": "day", "paper_level": 1.0}
top = json.loads(T.read_text())
d = top["dressings"]
d.pop("arched_day", None)
if "--drop" not in sys.argv:
    row = d["arched_line"]
    day = copy.deepcopy(row)
    day["lights"] = {"grade": DAY, "pools": [], "kinds": [{k: v for k, v in x.items() if k != "floor_glow"} for x in row["lights"]["kinds"]]}
    d["arched_day"] = day
with T.open("w", newline=NL) as f:
    f.write(json.dumps(top, indent=2, sort_keys=True) + NL)

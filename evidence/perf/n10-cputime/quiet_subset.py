"""Rounds of cpu_runs.json where every arm saw at most <max_others> other godot/RTAI processes before its run.
Usage: quiet_subset.py <dir> <max_others> [<base>,<new>,<twin>]"""
import json, statistics as st, sys
from pathlib import Path
D = Path(sys.argv[1]); lim = int(sys.argv[2])
BASE, NEW, TWIN = (sys.argv[3] if len(sys.argv) > 3 else "main,head,twin").split(",")
rows = json.loads((D / "cpu_runs.json").read_text(encoding="utf-8-sig"))
by = {}
for x in rows:
    x["p50"] = st.median(json.loads((D / f"riotc-{x['arm']}-{x['round']}.json").read_text(encoding="utf-8"))["frame_ms"])
    by.setdefault(x["round"], {})[x["arm"]] = x
ok = [r for r, v in sorted(by.items()) if len(v) == 3 and max(a["others"] for a in v.values()) <= lim]
print(f"rounds with every arm at others <= {lim}: {len(ok)} of {len(by)} -> {ok}")
for key in ("total_s", "p50"):
    for n, a, b in ((f"{NEW}-{BASE}", NEW, BASE), (f"{NEW}-{TWIN}", NEW, TWIN)):
        d = [by[r][a][key] - by[r][b][key] for r in ok]
        if d:
            print(f"  {key} {n}: median {st.median(d):+.3f} lower {sum(v < 0 for v in d)}/{len(d)} range [{min(d):+.3f},{max(d):+.3f}]")

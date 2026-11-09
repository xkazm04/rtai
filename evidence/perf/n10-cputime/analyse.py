"""Paired deltas of cpu_runs.json (cpu_ab.ps1): head - main and the A/A head - twin, per round.
CPU seconds are of the whole process over one fixed run; frame p50 comes from each run's own log.
Usage: analyse.py <dir> [<summary.json>|-] [<base>,<new>,<twin>] (arm names, default main,head,twin)"""
import json
import math
import random
import statistics as st
import sys
from pathlib import Path

D = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).parent)
rows = json.loads((D / "cpu_runs.json").read_text(encoding="utf-8-sig"))
if isinstance(rows, dict):
    rows = [rows]


def p50(arm, r):
    doc = json.loads((D / f"riotc-{arm}-{r}.json").read_text(encoding="utf-8"))
    return st.median(doc["frame_ms"]), doc["metrics"]["framesMeasured"]


def sign_p(lower, n):
    """Two-sided sign test."""
    k = min(lower, n - lower)
    return min(1.0, 2 * sum(math.comb(n, i) for i in range(k + 1)) / 2**n)


def boot_ci(d, seed=1, n=4000):
    """95 % bootstrap interval of the median paired delta."""
    rng = random.Random(seed)
    med = sorted(st.median(rng.choices(d, k=len(d))) for _ in range(n))
    return med[int(0.025 * n)], med[int(0.975 * n)]


BASE, NEW, TWIN = (sys.argv[3] if len(sys.argv) > 3 else "main,head,twin").split(",")
by = {}
for x in rows:
    if "error" in x or x.get("exit") != 0:
        print("SKIP", x)
        continue
    x["p50"], x["frames"] = p50(x["arm"], x["round"])
    by.setdefault(x["round"], {})[x["arm"]] = x

rounds = [r for r in sorted(by) if len(by[r]) == 3]
print(f"complete rounds {len(rounds)} of {len(by)}; frames {sorted({v['frames'] for r in rounds for v in by[r].values()})}")
others = sorted(x.get("others", -1) for x in rows)
print(f"script errors {sum(x.get('script_errors', 0) for x in rows)}; other godot/RTAI processes before a run: min {others[0]} median {others[len(others) // 2]} max {others[-1]}")
out = {"rounds": len(rounds), "metrics": {}}
for key, unit in (("total_s", "s"), ("user_s", "s"), ("kernel_s", "s"), ("wall_s", "s"), ("p50", "ms")):
    arms = {a: round(st.median(by[r][a][key] for r in rounds), 3) for a in (BASE, NEW, TWIN)}
    print(f"\n{key}\n  median by arm: {arms}")
    out["metrics"][key] = {"median_by_arm": arms}
    for name, a, b in ((f"{NEW}-{BASE}", NEW, BASE), (f"{TWIN}-{BASE}", TWIN, BASE), (f"{NEW}-{TWIN}", NEW, TWIN)):
        d = [by[r][a][key] - by[r][b][key] for r in rounds]
        lower = sum(v < 0 for v in d)
        lo, hi = boot_ci(d)
        p = sign_p(lower, len(d))
        print(f"  {name:10s} median {st.median(d):+.3f} {unit}  CI95 [{lo:+.3f},{hi:+.3f}]  lower {lower}/{len(d)} (sign p {p:.2g})  range [{min(d):+.3f},{max(d):+.3f}]")
        out["metrics"][key][name] = {"median": st.median(d), "ci95": [lo, hi], "lower": lower, "n": len(d), "sign_p": p}
if len(sys.argv) > 2 and sys.argv[2] != "-":
    out["runs"] = [{k: v for k, v in x.items()} for r in rounds for x in by[r].values()]
    Path(sys.argv[2]).write_text(json.dumps(out, indent=1), encoding="utf-8")

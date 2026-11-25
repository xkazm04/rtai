import json, statistics, sys
from pathlib import Path
T95 = 4.303
root = Path(sys.argv[1])
rows = {(n, a): json.loads((root / f"r{n}_{a}.json").read_text()) for n in (1, 2, 3) for a in ("before", "after")}
print("| Round | n28 p50 | n28 p99 | n29 p50 | n29 p99 | frames n28/n29 |\n|---|---:|---:|---:|---:|---|")
for n in (1, 2, 3):
    b, a = rows[(n, "before")], rows[(n, "after")]
    print(f"| {n} | {b['p50_ms']:.3f} | {b['p99_ms']:.3f} | {a['p50_ms']:.3f} | {a['p99_ms']:.3f} | {b['frame_count']}/{a['frame_count']} |")
print("\nPaired differences (n29 - n28), Student-t 95% interval over three rounds:\n\n| | mean | 95% CI |\n|---|---:|---:|")
for key in ("p50_ms", "p99_ms"):
    d = [rows[(n, "after")][key] - rows[(n, "before")][key] for n in (1, 2, 3)]
    m, s = statistics.mean(d), statistics.stdev(d); h = T95 * s / 3 ** 0.5
    print(f"| {key[:3]} | {m:+.3f} ms | [{m - h:+.3f}, {m + h:+.3f}] |")
print("\ndebug_build", {r.get("debug_build") for r in rows.values()}, rows[(1, "before")].get("gpu"))

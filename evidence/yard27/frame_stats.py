"""Paired frame-cost table from build/frame27/r<N>_{before,after}.json (yard_frame_probe samples)."""
import json, statistics, sys
from pathlib import Path

T95 = 4.303  # two-sided Student t, 2 degrees of freedom
root = Path(sys.argv[1])
rows = {(n, a): json.loads((root / f"r{n}_{a}.json").read_text()) for n in (1, 2, 3) for a in ("before", "after")}
print("| Round | Before p50 | Before p99 | After p50 | After p99 | frames b/a |\n|---|---:|---:|---:|---:|---|")
for n in (1, 2, 3):
    b, a = rows[(n, "before")], rows[(n, "after")]
    print(f"| {n} | {b['p50_ms']:.3f} | {b['p99_ms']:.3f} | {a['p50_ms']:.3f} | {a['p99_ms']:.3f} | {b['frame_count']}/{a['frame_count']} |")
for key in ("p50_ms", "p99_ms"):
    d = [rows[(n, "after")][key] - rows[(n, "before")][key] for n in (1, 2, 3)]
    m, s = statistics.mean(d), statistics.stdev(d)
    h = T95 * s / 3 ** 0.5
    print(f"{key}: mean after-before {m:+.3f} ms, 95% CI [{m - h:+.3f}, {m + h:+.3f}]  (diffs {', '.join(f'{x:+.3f}' for x in d)})")
print("debug_build", {r["debug_build"] for r in rows.values()}, rows[(1, "before")]["gpu"])

"""perf-city: frame-time graph + sim-hold report of a FightFrames log (gtai.fight-frames/1).
python tools/bench/fight_graph.py <frames.json> <out.png> [title]"""
import json, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

d = json.load(open(sys.argv[1]))
out = sys.argv[2]
title = sys.argv[3] if len(sys.argv) > 3 else sys.argv[1]
w = d["wall_ms"]; ticks = d["tick"]; loop = d["loop_ms"]; rc = d["render_cpu_ms"]; rg = d["render_gpu_ms"]
t = []; acc = 0.0
for v in w:
    acc += v; t.append(acc / 1000.0)
# sim stalls: wall time while the tick does not move (hit-stop holds) longer than 100 ms
stalls = []; s0 = None
for i in range(1, len(ticks)):
    if ticks[i] == ticks[i - 1]:
        if s0 is None: s0 = i - 1
    else:
        if s0 is not None and t[i] - t[s0] > 0.1:
            stalls.append((round(t[s0], 2), round(t[i] - t[s0], 3), ticks[s0]))
        s0 = None
s = dict(d["summary"])
# "after the first second" by wall time (older logs settled after 60 frames)
k = next((i for i, x in enumerate(t) if x >= 1.0), len(t) - 1) + 1
settled = w[k:] or w[-1:]
s["worst_settled_ms"] = max(settled)
s["over33_settled"] = sum(x > 33.0 for x in settled)
print(json.dumps(s))
print("sim holds > 100 ms (start s, length s, tick):", stalls)
fig, ax = plt.subplots(figsize=(12, 4.2), dpi=110)
ax.plot(t, w, lw=0.6, color="#1B1A17", label="frame (wall) ms")
ax.plot(t, loop, lw=0.5, color="#2E5FA8", alpha=0.8, label="sim loop ms")
ax.plot(t, rc, lw=0.5, color="#888", alpha=0.7, label="render cpu ms")
for a, ln, _ in stalls:
    ax.axvspan(a, a + ln, color="#E2532D", alpha=0.15)
ax.axhline(16.67, color="#999", ls="--", lw=0.7); ax.axhline(33.3, color="#E2532D", ls=":", lw=0.8)
ax.set_ylim(0, max(40, min(120, max(w) * 1.05)))
ax.set_xlabel("real time (s)"); ax.set_ylabel("ms")
ax.set_title(f"{title}\np50 {s['p50_ms']:.2f}  p99 {s['p99_ms']:.2f}  1% low {s['low1_fps']:.0f} fps  worst {s['worst_ms']:.0f} (after 1 s {s['worst_settled_ms']:.0f})  >33ms after 1 s: {s['over33_settled']}  sim holds {len(stalls)} (shaded)", fontsize=9)
ax.legend(loc="upper right", fontsize=7)
fig.tight_layout(); fig.savefig(out)

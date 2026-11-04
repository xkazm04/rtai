"""Prints the drive bench per label from evidence/bench-bisect/<label>-run<n>.json."""
import glob, json, os, sys
d = sys.argv[1] if len(sys.argv) > 1 else "evidence/bench-bisect"
for f in sorted(glob.glob(os.path.join(d, "*-run*.json"))):
    m = json.load(open(f))["metrics"]
    print(f"{os.path.basename(f):24} p99 {m['p99CpuMs']:6.3f} ms  avg {m['avgFrameMs']:.3f}  low1 {m['low1Fps']:6.1f}  visible {m['visibleAvg']:.1f}  rig p99 {m['rigMsP99']:.3f}  sim/tick {m['simStepMsPerTick']:.3f}")

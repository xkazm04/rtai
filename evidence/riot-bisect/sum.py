import json,glob,statistics,os,sys
rows=[]
for d in ['head','base','m1-city','m2-cast','m3-combat','m4-vehicles','m5-bodies','m6-slice','m7-save','m8-audio','m3-noblood','m3-nostains','m3-nopop']:
    fs=sorted(glob.glob(os.path.join(os.path.dirname(__file__),d,'riot-*.json')))
    if not fs: continue
    ms=[json.load(open(f))['metrics'] for f in fs]
    g=lambda k:[m[k] for m in ms]
    print(f"{d:12} n={len(ms)} p99 {[round(x,2) for x in g('p99CpuMs')]} med {statistics.median(g('p99CpuMs')):.2f} | low1 med {statistics.median(g('low1Fps')):.0f} | avg {statistics.median(g('avgFrameMs')):.2f} | sim {statistics.median(g('simStepMsPerTick')):.3f} rig {statistics.median(g('rigMsP99')):.3f}")

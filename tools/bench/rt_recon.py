"""perf-city: a real-time film rebuilt from a FightFrames log (gtai.fight-frames/1).

python tools/bench/rt_recon.py <rt.json> <fixed.json> <png_dir> <tick0> <tick1> <out.mp4> [label]

Desktop capture is unsafe on the shared machine: the owner's windows go above the game. So the film is
rebuilt from two runs of the same deterministic fight:
- <fixed.json> + <png_dir>: a --fixed-fps 60 --write-movie PNG run with a FightFrames log. Every frame
  steps exactly one tick, so PNG k is the game's own render of one tick. Godot writes one PNG per
  drawn frame and FightFrames logs from its first _process frame, so the two line up from the end:
  PNG index = log index + (png count - log length).
- <rt.json>: the real-time run (exported release, vsync as shipped). Frame i showed tick[i] on
  screen until frame i+1 presented, so it stays up for wall_ms[i+1].
The output is a 60 fps CFR mp4 in which every displayed frame is shown for the time the live run held
it: a late frame becomes a held frame, two ticks in one frame become a skipped tick, as on screen.
No frame is drawn or blended here. The frames are only placed on the measured wall clock.
"""
import json, os, subprocess, sys, tempfile

rt = json.load(open(sys.argv[1]))
fx = json.load(open(sys.argv[2]))
png_dir, t0, t1, out = sys.argv[3], int(sys.argv[4]), int(sys.argv[5]), sys.argv[6]
label = sys.argv[7] if len(sys.argv) > 7 else os.path.basename(sys.argv[1])

pngs = sorted(f for f in os.listdir(png_dir) if f.endswith(".png"))
off = len(pngs) - len(fx["tick"])
png_of = {}
for i, t in enumerate(fx["tick"]):
    if 0 <= i + off < len(pngs):
        png_of.setdefault(t, os.path.join(png_dir, pngs[i + off]))

ticks, wall = rt["tick"], rt["wall_ms"]
lines, held, total, missing = [], 0, 0.0, 0
for i in range(len(ticks) - 1):
    t = ticks[i]
    if t < t0 or t > t1:
        continue
    if t not in png_of:
        missing += 1
        continue
    dur = wall[i + 1] / 1000.0
    total += dur
    held += dur > 0.025
    lines.append("file '%s'\nduration %.6f" % (png_of[t].replace("\\", "/"), dur))
lines.append(lines[-1].split("\n")[0])  # the concat demuxer drops the last duration otherwise
lst = tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False)
lst.write("\n".join(lines) + "\n")
lst.close()
text = "%s  (real-time frame log, frames placed on its wall clock)" % label
draw = "drawtext=text='%s':x=12:y=12:fontsize=20:fontcolor=white:box=1:boxcolor=black@0.6" % text.replace(
    ":", "\\:"
)
subprocess.run(
    ["ffmpeg", "-loglevel", "error", "-y", "-f", "concat", "-safe", "0", "-i", lst.name,
     "-vf", "fps=60," + draw, "-c:v", "libx264", "-preset", "veryfast", "-crf", "18",
     "-pix_fmt", "yuv420p", out],
    check=True,
)
os.unlink(lst.name)
print(json.dumps({"out": out, "frames": len(lines) - 1, "seconds": round(total, 2),
                  "held_over_25ms": held, "missing_ticks": missing, "png_offset": off}))

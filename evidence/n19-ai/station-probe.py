"""Run the existing city fight probe with a read-only, end-of-stage geometry counter."""

import json
from pathlib import Path
import re
import subprocess
import sys


stage = Path("project/features/arena/arena_stage.gd")
output = Path(sys.argv[1]).resolve()
seeds = int(sys.argv[2]) if len(sys.argv) > 2 else 20
original = stage.read_bytes()
anchor = b"\n\nfunc write_state(out: StreamPeerBuffer)"
observer = r'''
	_station_sample(p_tick)


var _station_ticks: int = 0
var _station_partner_ticks: int = 0


func _station_sample(t: int) -> void:
	var near: int = 0
	for h: Fighter in arena.hostiles:
		if h.id < 3000 or h.id > 3004 or not h.alive():
			continue
		for other: Fighter in arena.hostiles:
			if other != h and other.alive() and h.pos.distance_squared_to(other.pos) <= 1.0:
				near += 1
				break
	_station_ticks += int(near > 0)
	_station_partner_ticks += near
	if t == 2399:
		Log.info("station_probe", "%d %d" % [_station_ticks, _station_partner_ticks])
'''
source = original.decode().replace("\r\n", "\n").encode()
assert source.count(anchor) == 1
measured = source.replace(anchor, observer.encode() + anchor)
output.mkdir(parents=True, exist_ok=True)
try:
    stage.write_bytes(measured)
    for brain in sys.argv[3:] or ["guard", "squad"]:
        result = output / f"city-{brain}.json"
        command = ["node", "tools/dev/run.mjs", "fight_probe", "--encounter=city",
                   f"--enemy-brain={brain}", f"--seeds={seeds}", "--timeout=300",
                   f"--out={result}", f"--result={result}"]
        run = subprocess.run(command, stdout=subprocess.PIPE, text=True)
        print(run.stdout, flush=True)
        run.check_returncode()
        log = Path(re.search(r"^run: log (.+)$", run.stdout, re.M)[1])
        counts = re.findall(r"station_probe: (\d+) (\d+)", log.read_text())
        runs = json.loads(result.read_text())["runs"]
        assert len(counts) == len(runs) == seeds
        rows = [{"seed": r["seed"], "ticks": int(t), "partner_ticks": int(p)}
                for r, (t, p) in zip(runs, counts)]
        (output / f"spacing-{brain}.json").write_text(json.dumps(rows, indent=2) + "\n")
        print(brain, "crowded ticks", sum(x["ticks"] for x in rows), flush=True)
finally:
    if stage.read_bytes() != measured:
        raise RuntimeError("ArenaStage changed during measurement; preserve concurrent edits")
    stage.write_bytes(original)

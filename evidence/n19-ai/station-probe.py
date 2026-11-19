"""Count station crowding and solid penetration around the existing city fight probe."""

import json
from pathlib import Path
import re
import subprocess
import sys


stage = Path("project/features/arena/arena_stage.gd")
combat = Path("project/features/combat/combat_arena.gd")
output = Path(sys.argv[1]).resolve()
seeds = int(sys.argv[2]) if len(sys.argv) > 2 else 20
original = stage.read_bytes()
anchor = b"\n\nfunc write_state(out: StreamPeerBuffer)"
observer = r'''
	_station_sample(p_tick)


var _station_ticks: int = 0
var _station_partner_ticks: int = 0
var _inside_push: int = 0
var _inside_end: int = 0


func _station_sample(t: int) -> void:
	var near: int = 0
	var inside: bool = false
	for h: Fighter in arena.hostiles:
		if h.id < 3000 or h.id > 3004 or not h.alive():
			continue
		inside = inside or cells.solid(floori(h.pos.x), floori(h.pos.y))
		for box: Rect2 in walls.boxes:
			inside = inside or box.has_point(h.pos)
		for other: Fighter in arena.hostiles:
			if other != h and other.alive() and h.pos.distance_squared_to(other.pos) <= 1.0:
				near += 1
				break
	_station_ticks += int(near > 0)
	_station_partner_ticks += near
	var inside_tick: int = arena.get_meta(&"probe_inside_tick", -1)
	_inside_push += int(inside_tick == t)
	_inside_end += int(inside)
	if t == 2399:
		var counts: Array[int] = [_station_ticks, _station_partner_ticks, _inside_push, _inside_end]
		Log.info("station_probe", "%d %d %d %d" % counts)
'''
source = original.decode().replace("\r\n", "\n").encode()
assert source.count(anchor) == 1
measured = source.replace(anchor, observer.encode() + anchor)
combat_original = combat.read_bytes()
combat_source = combat_original.replace(b"\r\n", b"\n")
post = b"\t\t\tGuardBrain.space_partner(h, hostiles)\n"
assert combat_source.count(post) == int(b"GuardBrain.space_partner" in combat_source)
combat_measured = combat_source.replace(post, post + b"""\t\t\tfor box: Rect2 in guard_map.boxes_near(h.pos, 0.0):
				if box.has_point(h.pos):
					set_meta(&"probe_inside_tick", tick)
""")
output.mkdir(parents=True, exist_ok=True)
try:
    stage.write_bytes(measured)
    combat.write_bytes(combat_measured)
    for brain in sys.argv[3:] or ["guard", "squad"]:
        result = output / f"city-{brain}.json"
        command = ["node", "tools/dev/run.mjs", "fight_probe", "--encounter=city",
                   f"--enemy-brain={brain}", f"--seeds={seeds}", "--timeout=300",
                   f"--out={result}", f"--result={result}"]
        run = subprocess.run(command, stdout=subprocess.PIPE, text=True)
        print(run.stdout, flush=True)
        run.check_returncode()
        log = Path(re.search(r"^run: log (.+)$", run.stdout, re.M)[1])
        counts = re.findall(r"station_probe: (\d+) (\d+) (\d+) (\d+)", log.read_text())
        runs = json.loads(result.read_text())["runs"]
        assert len(counts) == len(runs) == seeds
        rows = [{"seed": r["seed"], "ticks": int(t), "partner_ticks": int(p),
                 "inside_push": int(ip), "inside_end": int(ie)}
                for r, (t, p, ip, ie) in zip(runs, counts)]
        (output / f"spacing-{brain}.json").write_text(json.dumps(rows, indent=2) + "\n")
        for name in ("ticks", "partner_ticks", "inside_push", "inside_end"):
            print(brain, name, sum(row[name] for row in rows), flush=True)
finally:
    if combat.read_bytes() == combat_measured:
        combat.write_bytes(combat_original)
    if stage.read_bytes() != measured:
        raise RuntimeError("ArenaStage changed during measurement; preserve concurrent edits")
    stage.write_bytes(original)

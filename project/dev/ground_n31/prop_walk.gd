extends Node
## n31-21/24: Rivet walks into props with the real input path (Input move_* actions, sampled by
## LiveInput) and the probe logs where he stops (waves held off, tilt 70, one sim tick per frame,
## for `--write-movie`). The probe list is the JSON file named by env PROP_WALK (see
## tools/ground/prop_take.mjs): {arena, result, ppm, probes: [...]}. Writes walk.jsonl, stops.json.

const KNOWN_FLAGS: PackedStringArray = []
const NEEDS_WINDOW: bool = true
const Open = preload("res://dev/ground_n31/prop_walk_open.gd")
const Probe = preload("res://dev/ground_n31/prop_walk_probe.gd")
const Out = preload("res://dev/ground_n31/prop_walk_out.gd")
const IDLE_TICKS: int = 36
const HOLD_TICKS: int = 18
const STILL_M: float = 0.004
const STILL_TICKS: int = 14
const HOLD_STOP_TICKS: int = 60
const BACK_TICKS: int = 48
const MOVES: Dictionary = {
	Vector2i(0, -1): &"move_up",
	Vector2i(0, 1): &"move_down",
	Vector2i(-1, 0): &"move_left",
	Vector2i(1, 0): &"move_right",
}

var _cfg: Dictionary
var _arena: CombatArena
var _loop: SimLoop
var _street: GauntletStreet
var _out: Out
var _probes: Array[Probe] = []
var _at: int = 0
var _phase: String = "idle"
var _phase_tick: int = 0
var _still: int = 0
var _last: Vector2 = Vector2.ZERO
var _walked: float = 0.0
var _from: Vector2 = Vector2.ZERO
var _placed: Vector2 = Vector2.ZERO
var _hops: int = 0
var _tick: int = 0
var _ready_done: bool = false


func _ready() -> void:
	var path: String = OS.get_environment("PROP_WALK")
	var text: String = FileAccess.get_file_as_string(path) if not path.is_empty() else ""
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		Log.error("prop-walk", "PROP_WALK must name a probe json")
		get_tree().quit(2)
		return
	_cfg = parsed
	var rows: Array = _cfg.get("probes", [])
	for row: Variant in rows:
		var one: Dictionary = row
		var probe: Probe = Probe.new()
		probe.fill(one)
		_probes.append(probe)
	_out = Out.new(str(_cfg["result"]))
	var open: Open = Open.new()
	var ppm: float = Probe.num(_cfg.get("ppm", 32))
	if str(_cfg["arena"]) == "gauntlet":
		open.gauntlet(self, ppm)
	else:
		open.yard(self, ppm)
	_arena = open.arena
	_loop = open.loop
	_street = open.street
	_ready_done = _arena != null


func _process(_delta: float) -> void:
	if not _ready_done:
		return
	_loop.step()
	_tick += 1
	var probe: Probe = null if _at >= _probes.size() else _probes[_at]
	_out.tick(_tick, _arena.rivet.pos, "" if probe == null else probe.id)
	if probe == null:
		_out.finish()
		get_tree().quit(0)
		return
	_phase_tick += 1
	match _phase:
		"idle":
			_idle(probe)
		"walk":
			_walk(probe)
		"hold":
			_hold(probe)
		"back":
			_back(probe)


func _shift(probe: Probe) -> float:
	if _street == null:
		return 0.0
	for seg: GauntletSegment in _street.window:
		if String(seg.id) == probe.segment:
			return seg.start_x
	return NAN


func _idle(probe: Probe) -> void:
	_release()
	var dx: float = _shift(probe)
	if is_nan(dx):
		_hop()
		return
	if _phase_tick == 1:
		var boxes: Array[Rect2] = [] if _arena.walls == null else _arena.walls.boxes
		_placed = probe.place(boxes, dx, _arena.rivet.radius_m)
		_arena.rivet.pos = _placed
	if _phase_tick > 1:
		_arena.rivet.pos = _placed
	if _phase_tick >= IDLE_TICKS:
		_phase = "walk"
		_phase_tick = 0
		_still = 0
		_walked = 0.0
		_last = _arena.rivet.pos
		_from = _last
		_press(probe)


func _hop() -> void:
	_hops += 1
	if _hops > 150:
		_out.stop({"id": _probes[_at].id, "verdict": "unreached"})
		_next()
		return
	_arena.rivet.pos = Vector2(_street.window[-1].start_x + 1.0, 0.0)
	_phase_tick = 0


func _press(probe: Probe) -> void:
	var action: StringName = MOVES[probe.dir]
	Input.action_press(action)


func _release() -> void:
	for action: StringName in MOVES.values():
		Input.action_release(action)


func _walk(probe: Probe) -> void:
	var pos: Vector2 = _arena.rivet.pos
	var moved: float = pos.distance_to(_last)
	_walked += moved
	_still = _still + 1 if moved < STILL_M and _phase_tick > HOLD_TICKS else 0
	_last = pos
	var passed: bool = (
		probe.mode == "pass" and probe.along(pos, _shift_or_zero(probe), probe.pass_to) >= 0.0
	)
	var stopped: bool = _still >= STILL_TICKS
	if stopped or passed or _phase_tick >= probe.ticks:
		var verdict: String = "passed" if passed else "stopped" if stopped else "timeout"
		var row: Dictionary = probe.result(pos, _shift_or_zero(probe), _walked, verdict)
		row["ticks"] = _phase_tick
		row["tick"] = _tick
		row["radius_m"] = _arena.rivet.radius_m
		row["placed_at"] = [
			snappedf(_placed.x - _shift_or_zero(probe), 0.001), snappedf(_placed.y, 0.001)
		]
		row["start_m"] = [
			snappedf(_from.x - _shift_or_zero(probe), 0.001), snappedf(_from.y, 0.001)
		]
		_out.stop(row)
		_phase = "hold"
		_phase_tick = 0


## He keeps pushing a second into what stopped him, then walks back a metre or so.
func _hold(probe: Probe) -> void:
	var held: int = HOLD_STOP_TICKS if _arena.rivet.pos.distance_to(_last) < STILL_M else 0
	_last = _arena.rivet.pos
	if _phase_tick >= held:
		_release()
		var back: StringName = MOVES[-probe.dir]
		Input.action_press(back)
		_phase = "back"
		_phase_tick = 0


func _back(_probe: Probe) -> void:
	if _phase_tick >= BACK_TICKS:
		_next()


func _shift_or_zero(probe: Probe) -> float:
	var dx: float = _shift(probe)
	return 0.0 if is_nan(dx) else dx


func _next() -> void:
	_release()
	_at += 1
	_phase = "idle"
	_phase_tick = 0
	_hops = 0

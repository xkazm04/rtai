extends Node
## n31-21: Rivet walks into props with the real input path (Input move_* actions pressed, sampled by
## LiveInput) and the probe logs where he stops. The prologue yard or the gauntlet street (waves
## held off: the GauntletWaves hook is dropped), tilt 70, 32 px/m, one sim tick per frame; meant for
## `--write-movie`. The probe list comes from the JSON file named by the PROP_WALK environment
## variable (the gauntlet scene rejects flags it does not know, so no flag carries it):
## {arena: yard|gauntlet, result: <abs dir>, ppm, probes: [{id, segment?, start:[x,y], dir:[dx,dy],
## edge (drawn base edge along dir's axis), ticks, mode: stop|pass, pass_to}]}. Gauntlet x values
## are local to the segment. Writes walk.jsonl (tick, rivet_m, probe) and stops.json.

const KNOWN_FLAGS: PackedStringArray = []
const NEEDS_WINDOW: bool = true
const YARD: PackedScene = preload("res://boot/prologue/prologue.tscn")
const GAUNTLET: PackedScene = preload("res://dev/gauntlet/gauntlet.tscn")
const Probe = preload("res://dev/ground_n31/prop_walk_probe.gd")
const Out = preload("res://dev/ground_n31/prop_walk_out.gd")
const IDLE_TICKS: int = 36
const HOLD_TICKS: int = 18
const STILL_M: float = 0.004
const STILL_TICKS: int = 14
const MOVES: Dictionary = {
	Vector2i(0, -1): &"move_up",
	Vector2i(0, 1): &"move_down",
	Vector2i(-1, 0): &"move_left",
	Vector2i(1, 0): &"move_right",
}

var _cfg: Dictionary
var _arena: CombatArena
var _stage: ArenaStage
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
		_probes.append(_probe_of(one))
	_out = Out.new(str(_cfg["result"]))
	if str(_cfg["arena"]) == "gauntlet":
		_open_gauntlet()
	else:
		_open_yard()
	_ready_done = _arena != null


func _probe_of(row: Dictionary) -> Probe:
	var p: Probe = Probe.new()
	p.fill(row)
	return p


func _open_yard() -> void:
	ViewMode.select("tilt70")
	var game: PrologueGame = YARD.instantiate() as PrologueGame
	add_child(game)
	game.result_path = ""
	game.world.set_process(false)
	_stage = game.stage
	_arena = game.stage.arena
	_loop = game.world.loop()
	_stage.hooks.erase(game.encounter)
	for child: Node in game.get_children():
		if child is PrologueView:
			var view: PrologueView = child as PrologueView
			view.px_per_m = Probe.num(_cfg.get("ppm", 32))
			view.print_stage.zoom = view.px_per_m / SimConst.PX_PER_M


func _open_gauntlet() -> void:
	var g: Node = GAUNTLET.instantiate()
	add_child(g)
	g.set_physics_process(false)
	var session: GauntletSession = g.get("session")
	var waves: GauntletWaves = g.get("waves")
	session.stage.hooks.erase(waves)
	_stage = session.stage
	_arena = _stage.arena
	_street = session.street
	_loop = session.world.loop()
	session.world.set_process(false)


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
		_arena.rivet.pos = Vector2(dx + probe.start.x, probe.start.y)
	if _phase_tick >= IDLE_TICKS:
		_phase = "walk"
		_phase_tick = 0
		_still = 0
		_walked = 0.0
		_last = _arena.rivet.pos
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
		_out.stop(row)
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

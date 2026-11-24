extends Node
## Why does `pair_dash` lose HP after 10 s? One line per HP drop after LATE_FROM: tick, amount,
## source, Rivet's motion phase, where he stood against the circle and each trooper, the dash
## cooldown, and whether a dash press was refused. Run:
## node tools/dev/run.mjs pressure_dash_trace -- --out=<abs file.md> [--seeds=3,5,1]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--seeds"]
const LATE_FROM: int = 600

var _take: PressureTake
var _burst_tick: Array[int] = []
var _burst_at: Array[Vector2] = []
var _burst_from: Array[int] = []
var _presses: Array[String] = []
var _launched: Array[int] = []
var _dashed: Array[int] = []


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	if not path.is_absolute_path():
		Log.error("pressure-dash-trace", "Expected an absolute --out file")
		get_tree().quit(2)
		return
	var out: Array[String] = ["# pair_dash: every HP drop after tick %d" % LATE_FROM, ""]
	for part: String in args.text("--seeds", "3,5,1").split(","):
		out.append_array(_seed(int(part)))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string("\n".join(out) + "\n"):
		get_tree().quit(1)
		return
	file.close()
	get_tree().quit(0)


func _seed(seed_value: int) -> Array[String]:
	_take = PressureTake.new()
	if not _take.open("pair_dash", seed_value):
		return ["## seed %d did not open" % seed_value, ""]
	for list: Array in [_burst_tick, _burst_at, _burst_from, _presses, _launched, _dashed]:
		list.clear()
	var rows: Array[String] = []
	var before: int = 0
	var hp: float = _take.arena.rivet.hp
	while _take.tick < _take.length:
		var counts: Array[int] = _counts()
		_take.advance()
		_watch()
		_log_press(counts)
		var lost: float = hp - _take.arena.rivet.hp
		hp = _take.arena.rivet.hp
		if lost <= 0.0:
			continue
		if _take.tick <= LATE_FROM:
			before += 1
		else:
			rows.append(_row(lost, counts))
	var head: Array[String] = _head(seed_value, hp, before, rows.size())
	_take.session.close()
	var ticks: Array[String] = [
		"Rocket launches: " + ", ".join(_launched.map(str)),
		"",
		"Dashes started: " + ", ".join(_dashed.map(str)),
	]
	return head + rows + [""] + _presses + [""] + ticks + [""]


func _head(seed_value: int, hp: float, before: int, after: int) -> Array[String]:
	return [
		"## seed %d" % seed_value,
		"",
		(
			"HP at 10 s %.1f, HP at end %.1f; %d drops up to 10 s, %d after."
			% [_take.pair.hp_at_10s, hp, before, after]
		),
		"",
		(
			"| tick | HP lost | source | phase | dash cooldown | off circle (m) | trooper A (m) "
			+ "| trooper B (m) | circle centre moved (m) | burst from Rivet (m) | rocket launched "
			+ "| presses refused so far |"
		),
		"|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|",
	]


func _counts() -> Array[int]:
	var p: PressurePair = _take.pair
	return [p.direct, p.splash, p.other, p.dash_presses, _take.session.pilot.motion.dashes]


func _watch() -> void:
	for shot: Shot in _take.arena.shots:
		if shot is FoeRocketFlight.Round and not shot.has_meta(&"trace_seen"):
			shot.set_meta(&"trace_seen", true)
			_launched.append(_take.tick)
			@warning_ignore("return_value_discarded")
			(shot as FoeRocketFlight.Round).landed.connect(_burst)


func _burst(shot: FoeRocketFlight.Round, at: Vector2) -> void:
	_burst_tick.append(_take.tick)
	_burst_at.append(at)
	var launched: int = shot.get_meta(&"pair_seen", 0)
	_burst_from.append(launched)


func _log_press(counts: Array[int]) -> void:
	var p: PressurePair = _take.pair
	var started: bool = _take.session.pilot.motion.dashes > counts[4]
	if started:
		_dashed.append(_take.tick)
	if p.dash_presses == counts[3]:
		return
	if not started:
		_presses.append("- tick %d: dash press refused, %s" % [_take.tick, _why()])


func _why() -> String:
	var motion: PlayerMotion = _take.session.pilot.motion
	if motion.phase == PlayerMotion.Phase.DASH:
		return "already mid-dash"
	return "cooldown %d ticks left" % motion.dash.cooldown


func _row(lost: float, counts: Array[int]) -> String:
	var p: PressurePair = _take.pair
	var source: String = "other"
	if p.direct > counts[0]:
		source = "direct"
	elif p.splash > counts[1]:
		source = "splash"
	var rivet: Vector2 = _take.arena.rivet.pos
	var mid: Vector2 = (p.troopers[0].pos + p.troopers[1].pos) / 2.0
	var moved: float = mid.distance_to(p.centre)
	var near_m: float = -1.0
	var near_from: int = 0
	for i: int in _burst_tick.size():
		var d: float = _burst_at[i].distance_to(rivet)
		if _burst_tick[i] == _take.tick and (near_m < 0.0 or d < near_m):
			near_m = d
			near_from = _burst_from[i]
	var motion: PlayerMotion = _take.session.pilot.motion
	var refused: int = _presses.size()
	var cells: Array = [
		_take.tick,
		"%.1f" % lost,
		source,
		PlayerMotion.Phase.keys()[motion.phase],
		motion.dash.cooldown,
		"%+.1f" % (rivet.distance_to(mid) - PressurePair.RADIUS_M),
		"%.1f" % rivet.distance_to(p.troopers[0].pos),
		"%.1f" % rivet.distance_to(p.troopers[1].pos),
		"%.1f" % moved,
		"%.1f" % near_m,
		"tick %d" % near_from,
		refused,
	]
	return "| " + " | ".join(cells.map(str)) + " |"

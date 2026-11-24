class_name FireGapArena
extends GauntletCombat
## Observe CombatArena's actual spawn and impact order without changing the projectile array.
## A round remains in the ordered snapshot even if its blast erased it before damage was emitted.

const TICKS: int = 30 * SimClock.TICK_RATE
const RANGE_M: float = 10.0

var foe: Fighter
var motion: String
var speed: float
var radius_m: float = RANGE_M
var dash_motion: PlayerMotion
var dash_ticks: Array[int] = []
var lock_ticks: Array[int] = []
var fire_ticks: Array[int] = []
var hit_ticks: Array[int] = []
var phases: Array[String] = []
var under_fire: PackedByteArray
var _react_at: int = -1
var _across: Vector2
var _clock: FireGapClock = FireGapClock.new()
var _birth: Dictionary[Shot, int] = {}
var _ordered: Array[Shot] = []
var _starts: Dictionary[Shot, Vector2] = {}
var _window_hits: int = 0
var _impact_error: bool = false


func prepare(id: StringName, path: String, run_mps: float, distance_m: float = RANGE_M) -> void:
	motion = path
	speed = run_mps
	radius_m = distance_m
	if motion == "circle_dash":
		dash_motion = PlayerMotion.from_table(
			DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
		)
	var bounds: Rect2 = Rect2(-100, -100, 200, 200)
	guard_map = GuardRouteMap.new(bounds, [], null, tuning.human["radius_m"])
	var squad: GauntletStreet.StreetSquad = GauntletStreet.StreetSquad.new(guard_map)
	squad.mods = StatMods.new()
	squad_ai = squad
	foe = squad.spawn_member(self, Vector2.ZERO, id)
	foe.pos = Vector2.ZERO
	foe.facing = Vector2.RIGHT
	rivet.pos = Vector2.RIGHT * radius_m
	rivet.max_hp = 1000000.0
	rivet.hp = rivet.max_hp
	@warning_ignore("return_value_discarded")
	under_fire.resize(TICKS)
	@warning_ignore("return_value_discarded")
	struck.connect(_impact)


func measure() -> bool:
	for t: int in range(1, TICKS + 1):
		_move_target(t)
		step(t)
	# Follow the last in-window shots to impact with the same target motion and enemy AI.
	# Additional launches outside the sample are neither counted nor attributed.
	var t: int = TICKS
	while not _birth.is_empty() and t < TICKS + 10 * SimClock.TICK_RATE:
		t += 1
		_move_target(t)
		step(t)
	if not _birth.is_empty():
		Log.error("fire-gaps", "unresolved in-window projectiles")
	return _birth.is_empty() and not _impact_error and phases.size() == TICKS


func _move_target(t: int) -> void:
	var stride: float = speed * SimClock.TICK_DT
	if motion == "circle_dash" and _dash_step(t):
		return
	if motion in ["circle", "circle_dash"]:
		# Intersect a sprint-length step with the circle. After a straight dash, rejoin
		# at sprint speed even when the circle is farther than one stride away.
		var offset: Vector2 = rivet.pos - foe.pos
		var d: float = offset.length()
		var r: float = radius_m
		if motion == "circle_dash":
			# Keep running around the trooper while recovering the original radius.
			# A purely radial correction after the burst would run back down the firing line.
			r = move_toward(d, radius_m, stride * 0.25)
		var cosine: float = (d * d + r * r - stride * stride) / (2.0 * d * r)
		rivet.pos = foe.pos + offset.normalized().rotated(acos(clampf(cosine, -1, 1))) * r
	elif motion == "strafe":
		rivet.pos.y = 5.0 - absf(fposmod(5.0 + t * stride, 20.0) - 10.0)


func _dash_step(t: int) -> bool:
	var dash: PlayerMotionDash = dash_motion.dash
	var ready: bool = dash.rest_tick()
	if t == _react_at and ready:
		var command: PlayerCommand = PlayerCommand.new()
		command.move = _across
		dash.start(dash_motion, command)
		dash_ticks.append(t)
	if dash_motion.phase != PlayerMotion.Phase.DASH:
		return false
	rivet.pos += dash.advance(dash_motion, speed)
	return true


func _step_hostile(h: Fighter) -> void:
	var count: int = shots.size()
	var mind: SquadMind = squad_ai.mind_for(h)
	if tick <= TICKS:
		_clock.before(h, mind, self)
	var tracking: bool = (
		h.tell_left > 0 and not guard_tell.locked(h) if dash_motion != null else false
	)
	super._step_hostile(h)
	if tracking and guard_tell.locked(h):
		lock_ticks.append(tick)
		_react_at = tick + 15
		_across = h.pos.direction_to(mind.rocket.locked_point).rotated(PI / 2.0)
	if tick > TICKS:
		return
	if shots.size() > count:
		_birth[shots[-1]] = tick
		fire_ticks.append(tick)
		phases.append("muzzle")
	else:
		phases.append(_clock.reason(h, mind, self))


func _step_shots() -> void:
	_ordered.assign(shots)
	_starts.clear()
	for s: Shot in _ordered:
		_starts[s] = s.pos
	super._step_shots()
	for s: Shot in _ordered:
		if not shots.has(s):
			@warning_ignore("return_value_discarded")
			_birth.erase(s)


func _impact(victim: Fighter, _dir: Vector2, _lethal: bool, _weapon: StringName) -> void:
	if victim != rivet:
		return
	for i: int in range(_ordered.size() - 1, -1, -1):
		var s: Shot = _ordered[i]
		if s.pos == _starts[s]:
			continue
		if _birth.has(s):
			hit_ticks.append(tick)
			_window_hits += int(tick <= TICKS)
			for flight_tick: int in range(_birth[s] - 1, mini(tick, TICKS)):
				under_fire[flight_tick] = 1
		return
	_impact_error = true
	Log.error("fire-gaps", "impact without an advancing round at tick %d" % tick)


func result() -> Dictionary:
	var parts: Dictionary[String, int] = {}
	for part: String in FireGapClock.PARTS:
		parts[part] = 0
	var intervals: int = fire_ticks.size() - 1
	var longest: int = 0
	var window_parts: Dictionary[String, int] = parts.duplicate()
	for phase: String in phases:
		window_parts[phase] += 1
	var total: int = 0
	for i: int in range(1, fire_ticks.size()):
		var gap: int = fire_ticks[i] - fire_ticks[i - 1]
		longest = maxi(longest, gap)
		total += gap
		for j: int in range(fire_ticks[i - 1], fire_ticks[i]):
			parts[phases[j]] += 1
	return {
		"archetype": foe.archetype,
		"weapon": foe.weapon,
		"motion": motion,
		"rounds": fire_ticks.size(),
		"rounds_per_s": fire_ticks.size() / 30.0,
		"mean_gap_s": null if intervals < 1 else total * SimClock.TICK_DT / intervals,
		"max_gap_s": null if intervals < 1 else longest * SimClock.TICK_DT,
		"gap_parts_ticks": parts,
		"window_parts_ticks": window_parts,
		"hits": hit_ticks.size(),
		"hits_within_window": _window_hits,
		"hit_share": null if fire_ticks.is_empty() else float(hit_ticks.size()) / fire_ticks.size(),
		"under_fire_ticks": under_fire.count(1),
		"under_fire_share": float(under_fire.count(1)) / TICKS,
		"muzzle_ticks": fire_ticks,
		"impact_ticks": hit_ticks,
	}

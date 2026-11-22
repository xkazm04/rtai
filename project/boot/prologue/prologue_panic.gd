class_name ProloguePanic
extends RefCounted
## The second file waits on the pavement. Inside the yard the patrol bunches up
## between short pistol bursts and breaks away when Rivet closes.

var members: Dictionary[Fighter, ProloguePatrol.Officer] = {}
var _start: int
var _centre: Vector2
var _yard: Rect2
var _gap: float
var _speed: float
var _delay: int
var _front_standing: bool


func _init(data: DataTable, yard: Rect2) -> void:
	var arrival: Dictionary = data.object(data.raw, "arrival")
	_yard = yard.grow(-1.0)
	_gap = data.num(arrival, "retreat_gap_m")
	_speed = data.num(arrival, "retreat_mps")
	_delay = CombatTuning.ticks(data.num(arrival, "reinforce_s"))


func begin(tick: int) -> void:
	_start = tick


func regroup() -> void:
	_front_standing = false
	var sum: Vector2 = Vector2.ZERO
	var count: int = 0
	for h: Fighter in members:
		var officer: ProloguePatrol.Officer = members[h]
		if h.alive() and not officer.reserve:
			_front_standing = true
		if h.alive() and officer.inside:
			sum += h.pos
			count += 1
	if count > 0:
		_centre = sum / count


func step(h: Fighter, arena: CombatArena, rng: RandomNumberGenerator, can_fire: bool) -> Shot:
	var officer: ProloguePatrol.Officer = members[h]
	if not officer.inside:
		if officer.reserve and _front_standing and arena.tick - _start < _delay:
			return null
		_walk(h, officer.gate_exit)
		officer.inside = h.pos.distance_to(officer.gate_exit) < 0.2
		return null
	var player: Vector2 = arena.rivet.pos
	var away: Vector2 = player.direction_to(h.pos)
	if h.pos.distance_to(player) < _gap:
		_escape(h, arena.guard_map, away)
	else:
		var mark: Vector2 = _centre + officer.offset
		if mark.distance_to(player) < _gap:
			mark = player + away * _gap + officer.offset
		if h.pos.distance_to(player) > arena.tuning.weapon(h.weapon).range_m:
			mark = player + away * _gap + officer.offset
		_walk(h, mark.clamp(_yard.position, _yard.end))
	h.facing = h.pos.direction_to(player)
	var range_m: float = arena.tuning.weapon(h.weapon).range_m
	if (
		can_fire
		and h.pos.distance_to(player) <= range_m
		and arena.guard_map.sight_line(h.pos, player)
	):
		return GuardBrain.trigger(h, arena.tuning, rng)
	return null


func _escape(h: Fighter, map: GuardRouteMap, away: Vector2) -> void:
	# Peel along the obstacle if a straight retreat would hit it. Stable handedness
	# keeps two frightened cops from choosing the same shoulder every time.
	var side: float = 1.0 if h.id % 2 == 0 else -1.0
	for angle: float in [0.0, PI / 4, -PI / 4, PI / 2, -PI / 2]:
		var dir: Vector2 = away.rotated(angle * side)
		var ahead: Vector2 = h.pos + dir * 1.5
		if _yard.has_point(ahead) and map.clear_line(h.pos, ahead):
			h.pos += dir * _speed * SimClock.TICK_DT
			return


func _walk(h: Fighter, mark: Vector2) -> void:
	if not h.pursuit.advance(h, mark, _speed):
		h.pos = h.pos.move_toward(mark, _speed * SimClock.TICK_DT)

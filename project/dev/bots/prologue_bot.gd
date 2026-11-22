extends InputSource
## Walk the late approach through StageIntent. In the fight use the same directional,
## primary, quick claw, guard and roll commands StagePilot decodes for a human.

const STRIKE_M: float = 1.55

var _stage: ArenaStage
var _encounter: PrologueEncounter
var _guard_until: int = -1
var _guarded: bool = false
var _rolled: bool = false
var _clawed: bool = false


func _init(stage: ArenaStage, encounter: PrologueEncounter) -> void:
	_stage = stage
	_encounter = encounter


func sample(tick: int) -> TickInput:
	var arena: CombatArena = _stage.arena
	if not arena.rivet.alive() or _encounter.phase == PrologueEncounter.Phase.BEAT_TWO:
		return TickInput.new()
	var patrol: ProloguePatrol = _encounter.patrol
	if _encounter.phase == PrologueEncounter.Phase.TALK:
		if patrol.approaching == 0:
			return TickInput.new()
		var to: Vector2 = patrol.dale.pos - arena.rivet.pos
		var gap: float = STRIKE_M if patrol.approaching >= 2 else 3.8
		if to.length() > gap:
			_stage.intent.move_to = _waypoint(patrol.dale.pos)
		var strike: bool = _encounter.strike_ready and to.length() <= STRIKE_M
		return _command(to, Vector2.ZERO, _bit(&"fire") if strike else 0)
	return _fight(tick)


func _fight(tick: int) -> TickInput:
	var target: Fighter = _nearest()
	if target == null:
		return TickInput.new()
	var at: Vector2 = _stage.arena.rivet.pos
	var aim: Vector2 = target.pos - at
	var walk: Vector2 = (
		at.direction_to(_waypoint(target.pos)) if aim.length() > 1.15 else Vector2.ZERO
	)
	var buttons: int = _bit(&"fire") if aim.length() <= STRIKE_M else 0
	var hints: ProloguePrompts = _encounter.prompts
	if hints.active("guard") and not _guarded:
		_guarded = true
		_guard_until = tick + 18
	if tick < _guard_until:
		buttons = _bit(&"guard")
	elif hints.active("roll") and not _rolled and _stage.pilot.motion.can_roll():
		_rolled = true
		buttons = _bit(&"roll")
		walk = aim.normalized()
	elif hints.active("claw") and not _clawed and aim.length() <= STRIKE_M:
		_clawed = true
		buttons = _bit(&"melee")
	return _command(aim, walk, buttons)


func _nearest() -> Fighter:
	var at: Vector2 = _stage.arena.rivet.pos
	var best: Fighter
	var distance: float = INF
	for officer: ProloguePatrol.Officer in _encounter.patrol.officers:
		var h: Fighter = officer.body
		var d: float = at.distance_squared_to(h.pos)
		if h.alive() and d < distance:
			best = h
			distance = d
	return best


func _waypoint(goal: Vector2) -> Vector2:
	var at: Vector2 = _stage.arena.rivet.pos
	var map: GuardRouteMap = _stage.arena.guard_map
	if map.clear_line(at, goal):
		return goal
	var path: PackedVector2Array = map.route(at, goal)
	for point: Vector2 in path:
		if at.distance_to(point) > 0.35:
			return point
	return goal


func _command(aim: Vector2, walk: Vector2, buttons: int) -> TickInput:
	var packed: int = buttons | PlayerCommand.pack_aim(aim.normalized(), _stage.pilot.actions)
	return TickInput.new(
		packed, roundi(walk.x * TickInput.AXIS_MAX), roundi(walk.y * TickInput.AXIS_MAX)
	)


func _bit(action: StringName) -> int:
	return 1 << _stage.pilot.actions.bit(action)

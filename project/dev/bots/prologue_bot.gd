extends InputSource
## Walk and fight with the same StageIntent and StagePilot controls as a human.

const STRIKE_M: float = 1.55

var _stage: ArenaStage
var _encounter: PrologueEncounter
var _guard_until: int = -1
var _rolled: bool = false
var _clawed: bool = false
var _skip_lines: bool = LaunchArgs.value("--bot") == "skipper"


func _init(stage: ArenaStage, encounter: PrologueEncounter) -> void:
	_stage = stage
	_encounter = encounter


func sample(tick: int) -> TickInput:
	var input: TickInput = _decide(tick)
	if _skip_lines and _encounter.lines.current != "" and tick % 2 == 0:
		var opened: int = _encounter.lines.events.back()["tick"]
		if (
			_encounter.phase == PrologueEncounter.Phase.STREET
			or tick - opened >= SimClock.TICK_RATE
		):
			input.buttons |= _bit(&"interact")
	return input


func _decide(tick: int) -> TickInput:
	var arena: CombatArena = _stage.arena
	if not arena.rivet.alive():
		return TickInput.new()
	if _encounter.phase == PrologueEncounter.Phase.STREET:
		return _street(tick)
	if _encounter.phase == PrologueEncounter.Phase.BEAT_TWO:
		return _ranged(tick)
	var claw_ready: bool = not _stage.pilot.melee.busy()
	var patrol: ProloguePatrol = _encounter.patrol
	if _encounter.phase == PrologueEncounter.Phase.TALK:
		if patrol.approaching == 0:
			return TickInput.new()
		var to: Vector2 = patrol.dale.pos - arena.rivet.pos
		var gap: float = STRIKE_M if patrol.approaching >= 2 else 3.8
		if to.length() > gap:
			_stage.intent.move_to = _waypoint(patrol.dale.pos)
		var cue: bool = _encounter.strike_ready and not _encounter.lines.busy()
		var strike: bool = cue and claw_ready and to.length() <= STRIKE_M
		return _command(to, Vector2.ZERO, _bit(&"fire") if strike else 0)
	return _fight(tick, claw_ready)


func _street(tick: int) -> TickInput:
	var street: PrologueStreet = _encounter.street
	var yard: PrologueYard = _stage.plan as PrologueYard
	var at: Vector2 = _stage.arena.rivet.pos
	var phone: Vector2 = _stage.layout.phones[street.phone]
	var goal: Vector2 = yard.gate + Vector2.DOWN * 1.4
	var buttons: int = 0
	match street.phase:
		PrologueStreet.Phase.OUT, PrologueStreet.Phase.VOICES:
			pass
		PrologueStreet.Phase.PHONE:
			if at.y >= yard.gate.y + 0.8:
				goal = phone + Vector2.LEFT * 0.9
			if at.distance_to(goal) < 0.2 and not _encounter.lines.busy():
				buttons = _bit(&"interact")
		PrologueStreet.Phase.REQUEST:
			buttons = _bit(&"interact") if tick - street.request_tick > SimClock.TICK_RATE else 0
			return _command(Vector2.ZERO, Vector2.ZERO, buttons)
		PrologueStreet.Phase.RADIO:
			goal = phone + Vector2.RIGHT * 4.0
		_:
			return TickInput.new()
	var walk: Vector2 = (
		at.direction_to(_waypoint(goal)) if at.distance_to(goal) > 0.12 else Vector2.ZERO
	)
	return _command(walk, walk, buttons)


func _fight(tick: int, claw_ready: bool) -> TickInput:
	var target: Fighter = FightReach.nearest(_stage.arena, _stage.arena.rivet.pos, INF, [])
	if target == null:
		return TickInput.new()
	var combat: PrologueCombat = _stage.arena as PrologueCombat
	var at: Vector2 = combat.rivet.pos
	var aim: Vector2 = target.pos - at
	# Let one warden finish a live pole swing so the pilot experiences the pin.
	if combat.first_catch_tick < 0 and target.archetype == &"appliance_warden":
		return _command(aim, Vector2.ZERO, 0)
	var gap: float = aim.length()
	var walk: Vector2 = at.direction_to(_waypoint(target.pos)) if gap > 1.15 else Vector2.ZERO
	var strike: bool = claw_ready and gap <= STRIKE_M
	var buttons: int = _bit(&"fire") if strike else 0
	var hints: ProloguePrompts = _encounter.prompts
	if hints.active("guard") and _guard_until < 0:
		_guard_until = tick + 18
	if tick < _guard_until:
		buttons = _bit(&"guard")
	elif hints.active("roll") and not _rolled and _stage.pilot.motion.can_roll():
		_rolled = true
		buttons = _bit(&"roll")
		walk = aim.normalized()
	elif hints.active("claw") and not _clawed and strike:
		_clawed = true
		buttons = _bit(&"melee")
	return _command(aim, walk, buttons)


func _ranged(tick: int) -> TickInput:
	var battle: PrologueBattle = _encounter.battle
	if not battle.ranged:
		return TickInput.new()
	var arena: CombatArena = _stage.arena
	var carry: RivetCarry = _stage.pilot.carry
	var at: Vector2 = arena.rivet.pos
	var blasts: Array[int] = battle.fire.shotgun.shot_ticks
	if not blasts.is_empty() and tick == blasts[-1] + 1 and _stage.pilot.motion.can_roll():
		var toward: Vector2 = at.direction_to(battle.formation.boss.pos)
		var side: Vector2 = toward.orthogonal()
		if not arena.guard_map.clear_line(at, at + side * _stage.pilot.motion.roll_m):
			side = -side
		return _command(toward, side, _bit(&"roll"))
	if not carry.ground.items.is_empty():
		var walk: Vector2 = at.direction_to(_waypoint(carry.ground.items[0].pos))
		return _command(walk, walk, 0)
	if _stage.pilot.wheel.selected() != battle.pistol.id:
		return _command(Vector2.ZERO, Vector2.ZERO, _bit(&"weapon_next"))
	var line: PrologueFormation = battle.formation
	var target: Fighter = _gun_target(line, at)
	var window: bool = (
		tick + 8 < battle.exposed_until or battle.fire.shotgun.pump_progress(tick) >= 0
	)
	if target == null or (window and line.boss.hurt_tick < 0):
		target = line.boss
	var aim: Vector2 = target.pos - at
	var walk: Vector2 = _strafe(at, target.pos)
	var buttons: int = 0
	if arena.gun != null and arena.gun.trigger.ammo == 0:
		buttons = _bit(&"reload") if tick % 2 == 0 else 0
	elif tick % 17 == 0 and (target != line.boss or window):
		buttons = _bit(&"fire")
	return _command(aim, walk, buttons)


func _gun_target(line: PrologueFormation, at: Vector2) -> Fighter:
	var best: Fighter
	var distance: float = INF
	for h: Fighter in line.members:
		if not h.alive() or h == line.boss:
			continue
		var cost: float = at.distance_to(h.pos)
		if h in line.shields:
			cost += 7.0
		if not _stage.arena.guard_map.sight_line(at, h.pos):
			cost += 12.0
		if cost < distance:
			best = h
			distance = cost
	return best


func _strafe(at: Vector2, target: Vector2) -> Vector2:
	var map: GuardRouteMap = _stage.arena.guard_map
	var to: Vector2 = at.direction_to(target)
	if at.distance_to(target) > 8.0 or not map.sight_line(at, target):
		return at.direction_to(_waypoint(target))
	var radial: float = clampf((at.distance_to(target) - 5.0) / 2.0, -0.8, 0.8)
	var side: Vector2 = to.orthogonal()
	if not map.clear_line(at, at + side * 2.0):
		side = -side
	return (side + to * radial).normalized()


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

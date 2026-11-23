class_name GhostDeployFilmInput
extends InputSource
## Staged subjects hold their marks until release. Officers and projectiles use gauntlet combat.

const FORMS: Array[StringName] = [&"kerf", &"ohm", &"tonnage", &"dent"]
const BEAT: int = 180
const RELEASE: int = 108

var stage: ArenaStage
var single: StringName
var subject: Fighter
var officer: Fighter
var cue: StringName
var casts: int = 0
var fired_while_active: int = 0
var hits_on_marks: int = 0
var live_holds: int = 0
var _held_ticks: int = 0
var _held_shots: int = 0
var _formation: Array[Fighter] = []
var _aim: Vector2
var _beat: int = -1
var _shots: int = 0
var _contacts: Array[Fighter] = []


func bind(source: ArenaStage) -> void:
	stage = source
	@warning_ignore("return_value_discarded")
	stage.arena.wounded.connect(_hit)
	@warning_ignore("return_value_discarded")
	stage.arena.kill_landed.connect(_hit.unbind(3))


func _hit(foe: Fighter, weapon: StringName) -> void:
	if weapon == StringName("deploy_" + String(cue)):
		_contacts.append(foe)


func sample(tick: int) -> TickInput:
	@warning_ignore("integer_division")
	var beat: int = (tick - 1) / BEAT if single == &"all" else 0
	var age: int = tick - 1 - beat * BEAT
	if beat != _beat:
		_beat = beat
		cue = FORMS[beat % FORMS.size()] if single == &"all" else single
		_set_marks()
	var actions: PlayerActions = stage.pilot.actions
	var bits: int = 0
	var r: Fighter = stage.arena.rivet
	if stage.pilot.ghosts.forms.selected != cue and age % 2 == 0:
		bits |= 1 << actions.bit(&"power_gearbox")
	var wide: bool = single == &"all"
	var placing: bool = age >= RELEASE - (84 if wide else 54) and age < RELEASE
	var at: Vector2 = _gun_target()
	if placing:
		bits |= 1 << actions.bit(&"ghost_deploy")
	if (placing and (not wide or age >= RELEASE - 18)) or age == RELEASE:
		at = _target()
	if age == RELEASE + 1:
		for foe: Fighter in _formation:
			foe.brain_owned = wide and foe.archetype in [&"sentry_turret", &"war_machine"]
	if age < RELEASE - (18 if wide else 66) or age >= RELEASE:
		bits |= 1 << actions.bit(&"fire")
	var gun: GunHand = stage.arena.gun
	if age == 8 and gun != null and gun.trigger.ammo < 5:
		bits |= 1 << actions.bit(&"reload")
	var aim: Vector2 = at - r.pos
	bits |= PlayerCommand.pack_aim(aim.normalized(), actions, aim.length())
	var side: int = 35 if r.pos.y < -0.4 else -35
	if age < RELEASE + 20 and age >= RELEASE - 26:
		side = 52
	return TickInput.new(bits, 42, side)


func _target() -> Vector2:
	if cue == OhmStage.GHOST:
		return _aim
	if cue == DentStage.GHOST:
		var end: Vector2 = _formation[-1].pos
		return end + stage.arena.rivet.pos.direction_to(end) * 0.4
	if cue == HaulerStage.GHOST:
		return subject.pos - stage.arena.rivet.pos.direction_to(subject.pos) * 3.7
	return subject.pos


func _gun_target() -> Vector2:
	if officer.alive():
		return officer.pos
	return stage.arena.rivet.pos + Vector2(-12.0 if single == &"all" else 12.0, -2.0)


func _set_marks() -> void:
	var r: Vector2 = stage.arena.rivet.pos
	var side: float = 1.0 if _beat % 2 == 0 else -1.0
	_aim = r + Vector2(8.1, side * 1.5)
	_formation.clear()
	_contacts.clear()
	match cue:
		KerfStage.GHOST:
			_member(&"shield_robot", _aim)
		OhmStage.GHOST:
			if single == &"all":
				_member(&"sentry_turret", _aim + Vector2(1.45, -1.7))
				_member(&"shield_robot", _aim + Vector2(2.1, 1.55))
				_member(&"patrol_cop", _aim + Vector2(-1.7, 1.65))
			else:
				_member(&"sentry_turret", _aim + Vector2(0.65, -2.85))
				_member(&"shield_robot", _aim + Vector2(2.65, 1.9))
				_member(&"patrol_cop", _aim + Vector2(-1.8, 1.85))
		HaulerStage.GHOST:
			_member(&"war_machine", _aim + Vector2(1.25 if single == &"all" else 3.75, 0.8))
		DentStage.GHOST:
			var end: Vector2 = _aim + Vector2.RIGHT * 1.1
			var start: Vector2 = r + Vector2(5.6, -0.32 + side * 0.4)
			for i: int in 3:
				_member(&"patrol_cop", start.lerp(end, i * 0.5))
	subject = _formation[1] if cue == DentStage.GHOST else _formation[0]
	var gun_side: float = -9.4 if single == &"all" else 9.4
	officer = _spawn(&"patrol_cop", r + Vector2(gun_side, -side * 3.7))


func _member(id: StringName, at: Vector2) -> void:
	var foe: Fighter = _spawn(id, at)
	foe.brain_owned = true
	_formation.append(foe)


func _spawn(id: StringName, at: Vector2) -> Fighter:
	var arena: CombatArena = stage.arena
	var foe: Fighter = arena.squad_ai.spawn_member(arena, at, id)
	foe.pos = stage.walls.push_out(at, foe.radius_m)
	foe.facing = foe.pos.direction_to(arena.rivet.pos)
	if arena.squad_ai.mounts.anchors.has(foe):
		arena.squad_ai.mounts.anchors[foe] = foe.pos
	return foe


func observe() -> void:
	var ghost: GhostDeploy = stage.pilot.ghosts.deploy
	var shots: int = stage.shots_fired - _shots
	if ghost.phase == GhostDeploy.Phase.AIMING:
		_held_ticks += 1
		_held_shots += shots
	if ghost.strike.release_tick == stage.tick:
		casts += 1
		live_holds += int(_held_ticks >= SimClock.TICK_RATE and _held_shots > 0)
		Log.info(
			"deploy-film", "%s held %d ticks, fired %d shots" % [cue, _held_ticks, _held_shots]
		)
		_held_ticks = 0
		_held_shots = 0
		var hits: int = 0
		for foe: Fighter in _formation:
			if foe in _contacts:
				hits += 1
			else:
				Log.info(
					"deploy-film", "missed %s at %s hp=%.1f" % [foe.archetype, foe.pos, foe.hp]
				)
		if hits == _formation.size():
			hits_on_marks += 1
		Log.info("deploy-film", "%s hit %d/%d staged targets" % [cue, hits, _formation.size()])
		Log.info("deploy-film", "release %s tick=%d at=%s" % [ghost.form, stage.tick, ghost.spot])
	if ghost.phase == GhostDeploy.Phase.ACTIVE:
		fired_while_active += shots
	_shots = stage.shots_fired

class_name PressureRifles
extends RefCounted
## Three staggered firing positions. Both defensive takes receive the same aiming and cadence.

var passed: int = 0
var returned: int = 0
var _blade: MeleeTable = MeleeTable.weapon(&"plasma_sword")
var _shots: Array[Fighter] = []
var _session: GauntletSession
var _arena: CombatArena
var _sword: bool


func place(session: GauntletSession, mark: Vector2, sword: bool) -> void:
	_session = session
	_arena = session.stage.arena
	_sword = sword
	@warning_ignore("return_value_discarded")
	DeflectRule.of(_arena).passed.connect(_passed)
	@warning_ignore("return_value_discarded")
	_arena.deflected.connect(_returned)
	if _sword:
		@warning_ignore("return_value_discarded")
		session.pilot.carry.add(&"plasma_sword")
	for angle: float in [-0.32, 0.0, 0.32]:
		var at: Vector2 = mark + Vector2.RIGHT.rotated(angle) * 9.5
		var cop: Fighter = _arena.spawn_guard(at)
		cop.pos = at
		cop.pursuit = null
		cop.archetype = &"patrol_cop"
		cop.cooldown = ArenaTargets.NEVER
		_shots.append(cop)


func drive(input: TickInput, tick: int) -> void:
	# Three riflemen fire in order. The pause between salvos lets Rivet lower his guard.
	var beat: int = posmod(tick - 45, 130)
	if tick == 2 and _sword:
		input.buttons |= 1 << _session.actions.bit(&"weapon_next")
	if tick >= 45 and beat in [0, 24, 48]:
		@warning_ignore("integer_division")
		var cop: Fighter = _shots[beat / 24]
		if cop.alive():
			var dir: Vector2 = cop.pos.direction_to(_arena.rivet.pos)
			_arena.shots.append(Shot.fire(cop, dir, _arena.tuning.weapon(&"assault-rifle")))
			cop.cooldown = ArenaTargets.NEVER
	if not _sword and tick >= 45 and beat < 69 and posmod(beat, 24) >= 11:
		input.buttons |= 1 << _session.actions.bit(&"guard")
	elif _sword and not _session.pilot.melee.busy():
		for shot: Shot in _arena.shots:
			if shot.from_rivet or shot.has_meta(PlayerDeflect.PASSED):
				continue
			var distance: float = shot.pos.distance_to(_arena.rivet.pos) - _blade.deflect_m
			var eta: int = ceili(distance / (shot.vel.length() * SimClock.TICK_DT))
			if eta == _blade.hits[0].windup:
				input.buttons |= 1 << _session.actions.bit(&"fire")
				break


func _passed(_at: Vector2, _dir: Vector2) -> void:
	passed += 1


func _returned(_at: Vector2, _dir: Vector2) -> void:
	returned += 1

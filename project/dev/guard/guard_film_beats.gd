class_name GuardFilmBeats
extends RefCounted
## Steps the stage once per image and cues the player's actions and the launcher's shots.

var film_set: GuardFilmSet
var beat: String
var tick: int = 0
var rocket_cues: int = 0


func _init(p_set: GuardFilmSet, id: String) -> void:
	film_set = p_set
	beat = id


func advance() -> void:
	tick += 1
	var input: TickInput = TickInput.new()
	var arena: CombatArena = film_set.stage.arena
	var facing: Vector2 = arena.rivet.pos.direction_to(arena.hostiles[0].pos)
	if beat == "guard":
		facing = GuardFilmSet.AIM
		if tick >= 20 and tick < 263 and ControlsMode.wheel():
			_press(input, &"guard")
		if tick == 272:
			for cop: Fighter in arena.hostiles:
				cop.burst_left = 0
				cop.cooldown = ArenaTargets.NEVER
	elif beat == "wheel":
		_wheel(input)
	else:
		_blast(input)
	input.buttons |= PlayerCommand.pack_aim(facing, film_set.actions, 12.0)
	film_set.stage.step(tick, input)


func _press(input: TickInput, action: StringName) -> void:
	input.buttons |= 1 << film_set.actions.bit(action)


func _wheel(input: TickInput) -> void:
	var arena: CombatArena = film_set.stage.arena
	var gap: Vector2 = arena.hostiles[0].pos - arena.rivet.pos
	if ((tick >= 84 and tick < 158) or (tick >= 439 and tick < 483)) and gap.length() > 1.45:
		var stick: Vector2 = gap.normalized() * TickInput.AXIS_MAX
		input.move_x = roundi(stick.x)
		input.move_y = roundi(stick.y)
	if tick in [131, 278, 437]:
		_press(input, &"weapon_next")
	if (tick >= 56 and tick <= 76) or (tick >= 159 and tick <= 201):
		_press(input, &"fire")
	if tick in [310, 343, 378, 483]:
		_press(input, &"fire")


func _blast(input: TickInput) -> void:
	if tick == 3:
		_press(input, &"weapon_slot_1")
	if beat == "rocket" and tick >= 42 and tick < 490:
		_press(input, &"guard")
	if beat == "wall" and tick >= 186 and tick < 242:
		input.move_y = TickInput.AXIS_MAX
	var launch: bool = tick in [117, 360] if beat == "rocket" else tick in [93, 315]
	if launch:
		film_set.fire_rocket()
		rocket_cues += 1


func sample() -> Dictionary:
	var s: ArenaStage = film_set.stage
	var g: PlayerGuard = s.pilot.guard
	var w: RivetWheel = s.pilot.wheel
	var a: FightAreas = s.arena.areas
	var cop: Fighter = s.arena.hostiles[0]
	return {
		"tick": tick,
		"hp": s.arena.rivet.hp,
		"meter": g.meter() * 100.0 if g != null else null,
		"up": g != null and g.up(),
		"broken": g != null and g.broken(),
		"deflects": g.deflects if g != null else 0,
		"selected": w.selected() if w != null else &"",
		"melee": s.pilot.melee.combo.starts,
		"swings": s.pilot.melee_swings,
		"shots": s.shots_fired,
		"flying": s.arena.shots.size(),
		"returned": s.arena.shots.filter(func(shot: Shot) -> bool: return shot.from_rivet).size(),
		"rockets": rocket_cues,
		"blocked": s.dodges.blocked,
		"blast_tick": a.blast_ticks.back() if a != null and not a.blast_ticks.is_empty() else -1,
		"cop_hp": cop.hp,
		"rivet_m": [s.arena.rivet.pos.x, s.arena.rivet.pos.y],
	}

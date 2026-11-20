class_name GhostReviewInput
extends InputSource
## Each take selects and transforms normally in pre-roll, then drives actions relative to START.

const START: int = 68
const MARK: Vector2 = Vector2(91.0, -20.0)
const GUARDS: Dictionary[StringName, Array] = {
	&"tonnage":
	[Vector2(2.1, 0.5), Vector2(3.7, -1.2), Vector2(7.7, 0.3), Vector2(11, 0), Vector2(14, 2.1)],
	&"dent": [Vector2(1.15, 0.2), Vector2(7, -1.0), Vector2(12, 1.0), Vector2(18, 3.7)],
	&"kerf": [Vector2(5, 0), Vector2(8, 1.2), Vector2(12, -0.8), Vector2(16, 0.8)],
	&"ohm": [Vector2(5.5, 0), Vector2(7, -1.2), Vector2(8.5, 0.7), Vector2(8, 3.3)],
}

var session: ArenaSession
var ghost: StringName
var morphing: bool = false
var dent_hits: bool = false
var attacking: bool
var victims: Array[Fighter] = []
var car: VehicleBody


func _init(
	p_session: ArenaSession, p_ghost: StringName, p_attacking: bool, p_morph: bool = false
) -> void:
	session = p_session
	ghost = p_ghost
	attacking = p_attacking
	morphing = p_morph
	session.stage.arena.rivet.pos = MARK


func sample(tick: int) -> TickInput:
	var t: int = tick - START
	if attacking and t == -6:
		_cast()
	if t < 0:
		var pick: int = session.pilot.ghosts.forms.table.order.find(ghost)
		var cycle: bool = tick >= 2 and tick <= 2 * pick and tick % 2 == 0
		var action: StringName = &"power_gearbox" if cycle else &""
		var enter: int = 61 if morphing else 10
		return _pad(Vector2.ZERO, Vector2.RIGHT, &"power_hauler" if tick == enter else action)
	if morphing:
		var end: int = 241 + session.pilot.ghosts.forms.table.form(ghost).enter_ticks
		var aim: Vector2 = Vector2.from_angle(clampf((tick - 125.0) / 90.0, 0.0, 1.0) * PI * 0.6)
		var move: Vector2 = aim * 0.22 if tick >= 125 and tick < 215 else Vector2.ZERO
		return _pad(move, aim, &"power_hauler" if tick == end else &"")
	if not attacking:
		return _dent_hit(t) if dent_hits else _movement(t)
	match ghost:
		&"tonnage":
			var go: bool = t >= 85 and t < 242
			var press: bool = t in [24, 222]
			return _pad(
				Vector2.RIGHT if go else Vector2.ZERO, Vector2.RIGHT, &"melee" if press else &""
			)
		&"kerf":
			var aim: Vector2 = Vector2.LEFT if t == 250 else _nearest()
			return _pad(Vector2.ZERO, aim, &"melee" if t in [28, 77, 126, 200, 250] else &"")
	return _dent(t) if ghost == &"dent" else _ohm(t)


func _movement(t: int) -> TickInput:
	# A long profile, seven 45-degree turns, back to east, then enough time to coast to rest.
	var octant: int = 0 if t < 87 else mini(8, 1 + floori((t - 87) / 21.0))
	var dir: Vector2 = Vector2.RIGHT.rotated(octant * PI / 4.0)
	var move: Vector2 = dir if t >= 5 and t < 258 else Vector2.ZERO
	return _pad(move, dir, &"melee" if ghost == &"kerf" and t == 62 else &"")


## Two nonlethal blows on the normal fighter, once at speed and once after a real seize.
func _dent_hit(t: int) -> TickInput:
	var rivet: Fighter = session.stage.arena.rivet
	if t == 22 or t == 86:
		rivet.take(1.0, t + START, Vector2.LEFT if t == 22 else Vector2.RIGHT)
	if t == 50:
		car = session.stage.vehicles.spawn_parked(
			&"police_cruiser", rivet.pos + Vector2(4.5, -1.3), Vector2.RIGHT
		)
	var aim: Vector2 = rivet.pos.direction_to(car.pos) if car != null and t <= 64 else Vector2.RIGHT
	return _pad(Vector2.RIGHT if t < 45 else Vector2.ZERO, aim, &"fire" if t == 64 else &"")


func _dent(t: int) -> TickInput:
	var aim: Vector2 = Vector2.RIGHT
	var act: StringName = &""
	if t in [20, 51, 166]:
		act = &"melee"
	elif t >= 65 and t <= 84 and car != null:
		aim = session.stage.arena.rivet.pos.direction_to(car.pos)
		act = &"fire" if t == 84 else &""
	return _pad(Vector2.ZERO, aim, act)


func _ohm(t: int) -> TickInput:
	# Both delay settings receive the very same aim, even during the three pending ticks.
	var aim: Vector2 = Vector2.RIGHT
	if t >= 92:
		aim = Vector2(8, 3.3) if t < 172 else Vector2(8.3, -2.8)
	var press: bool = t in [26, 64, 106, 149, 187, 222, 256]
	return _pad(Vector2.ZERO, aim, &"melee" if press else &"")


func _cast() -> void:
	for offset: Vector2 in GUARDS[ghost]:
		var fighter: Fighter = session.stage.arena.spawn_guard(MARK + offset)
		fighter.pos = MARK + offset
		fighter.facing = Vector2.LEFT
		victims.append(fighter)
	var parking: Dictionary[StringName, Vector2] = {
		&"tonnage": Vector2(2.4, 2.3), &"dent": Vector2(3, -1.8), &"ohm": Vector2(8.3, -2.8)
	}
	if parking.has(ghost):
		car = session.stage.vehicles.spawn_parked(
			&"police_cruiser", MARK + parking[ghost], Vector2.RIGHT
		)


func _nearest() -> Vector2:
	var at: Vector2 = session.stage.arena.rivet.pos
	var best: Fighter = GhostReel.nearest(victims, at)
	if best != null:
		return at.direction_to(best.pos)
	return at.direction_to(car.pos) if car != null else Vector2.RIGHT


func _pad(move: Vector2, aim: Vector2, action: StringName) -> TickInput:
	var buttons: int = PlayerCommand.pack_aim(aim, session.actions)
	if action != &"":
		buttons |= 1 << session.actions.bit(action)
	var axes: Vector2i = Vector2i((move * TickInput.AXIS_MAX).round())
	return TickInput.new(buttons, axes.x, axes.y)

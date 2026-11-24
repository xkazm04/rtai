class_name PressurePair
extends RefCounted
## Two rocket troopers on the street and Rivet circling them at RADIUS_M without shooting back.
## With `dodge` he also dashes across each rocket's flight line a read-time after it leaves the
## launcher, as the average bot profile does. Counts every launch and splits each HP drop into a
## rocket that burst on his body (direct), a blast that only reached him (splash) or anything else.

const RADIUS_M: float = 10.0
const GAP_M: float = 3.0
const CONTACT_SLACK_M: float = 0.01
const TROOPER: StringName = &"rocket_trooper"

var dodge: bool
var centre: Vector2
var troopers: Array[Fighter] = []
var launches: int = 0
var direct: int = 0
var splash: int = 0
var other: int = 0
var hp_lost: float = 0.0
var dash_presses: int = 0
var first_launch: int = 0
var death_tick: int = 0
var hp_at_10s: float = -1.0
var _read: int = BotProfile.shipped(&"average").dash_read_ticks
var _due: Array[int] = []
var _lines: Array[Vector2] = []
var _hp: float
var _session: GauntletSession
var _arena: CombatArena


func place(session: GauntletSession, at: Vector2, p_dodge: bool) -> void:
	_session = session
	_arena = session.stage.arena
	dodge = p_dodge
	centre = at
	for i: int in 2:
		var spot: Vector2 = at + Vector2(0, (float(i) - 0.5) * GAP_M)
		var foe: Fighter = _arena.squad_ai.spawn_member(_arena, spot, TROOPER)
		foe.pos = spot
		troopers.append(foe)
	_arena.rivet.pos = at + Vector2(-RADIUS_M, 0)
	_hp = _arena.rivet.hp


## The circle around the troopers' own midpoint at sprint, and the aim toward it.
func drive(input: TickInput, tick: int) -> Vector2:
	var mid: Vector2 = _midpoint()
	var offset: Vector2 = _arena.rivet.pos - mid
	var radial: Vector2 = offset.normalized()
	var pull: float = clampf((RADIUS_M - offset.length()) * 0.5, -0.6, 0.6)
	var move: Vector2 = (radial.orthogonal() + radial * pull).normalized()
	input.buttons |= 1 << _session.actions.bit(&"sprint")
	if dodge and not _due.is_empty() and tick >= _due[0]:
		@warning_ignore("return_value_discarded")
		_due.pop_front()
		dash_presses += 1
		var side: Vector2 = _lines.pop_front()
		move = side if side.dot(move) >= 0.0 else -side
		input.buttons |= 1 << _session.actions.bit(&"dash")
	input.move_x = roundi(move.x * TickInput.AXIS_MAX)
	input.move_y = roundi(move.y * TickInput.AXIS_MAX)
	return _arena.rivet.pos.direction_to(mid)


## After the stage stepped: log new rockets, any HP not taken by a rocket, and the moment he fell.
func observe(tick: int) -> void:
	for shot: Shot in _arena.shots:
		if shot is FoeRocketFlight.Round and not shot.has_meta(&"pair_seen"):
			shot.set_meta(&"pair_seen", tick)
			launches += 1
			first_launch = first_launch if first_launch > 0 else tick
			_due.append(tick + _read)
			_lines.append(shot.vel.normalized().orthogonal())
			@warning_ignore("return_value_discarded")
			(shot as FoeRocketFlight.Round).landed.connect(_landed)
	var rest: float = _hp - _arena.rivet.hp
	if rest > 0.0:
		other += 1
		hp_lost += rest
	_hp = _arena.rivet.hp
	if tick == 10 * SimClock.TICK_RATE:
		hp_at_10s = _hp
	if death_tick == 0 and not _arena.rivet.alive():
		death_tick = tick


func summary() -> Dictionary:
	return {
		"launches": launches,
		"direct": direct,
		"splash": splash,
		"other": other,
		"hp_lost": hp_lost,
		"first_launch": first_launch,
		"death_tick": death_tick,
		"hp_at_10s": hp_at_10s,
		"dash_presses": dash_presses,
	}


## A rocket burst; the sim has already dealt its blast. A burst on his body (the burst point inside
## his radius, where the blast has full strength) is a direct hit, one beside him a splash graze.
func _landed(_shot: FoeRocketFlight.Round, at: Vector2) -> void:
	var dealt: float = _hp - _arena.rivet.hp
	if dealt <= 0.0:
		return
	if at.distance_to(_arena.rivet.pos) <= _arena.rivet.radius_m + CONTACT_SLACK_M:
		direct += 1
	else:
		splash += 1
	hp_lost += dealt
	_hp = _arena.rivet.hp


func _midpoint() -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	for foe: Fighter in troopers:
		sum += foe.pos
	return sum / float(troopers.size())

class_name RivetBody
extends RefCounted
## Rivet's body in the city sim (features/bodies/README.md): each tick it turns where Rivet wants
## to be into the sim's body spec (SimConst.BD_*) from the body table, and after the step reads
## back where he ends up (pushed out of every person) and who he knocked down this tick. People
## are `human`; Rivet on foot is `rivet_base` (his radius comes from the table, never the sprite).

const CLASS: StringName = &"rivet_base"
const PERSON: StringName = &"human"
## Rivet's runtime actor id (boot/city_characters.gd RIVET_ID; actor ids are never data ids).
const RIVET_ACTOR_ID: int = 1 << 20
## The sim's slide deceleration, m/s^2 (sim_core/src/body.cpp down(), the same as a body).
const SLIDE_DECEL: float = 8.0
## A displacement faster than this is a teleport (a cutscene or a dev jump), never a tackle.
const TELEPORT_MPS: float = 30.0
## A tackle speed no body reaches: the rule's run result is not a knockdown.
const NEVER_MPS: float = 1.0e9

## The class he steps as: CLASS on foot, `rivet_ghost` while the Hauler soul is on (features/souls).
var body_class: StringName = CLASS
## False while Rivet is in a car: the sim then has no player body.
var on: bool = true
var table: BodyTable = null
## Where Rivet ended the last step (resolved), and his velocity into it, m/s.
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
## The last step's knockdowns: BR_STRIDE floats each (slot, x, y).
var knocks: PackedFloat64Array = PackedFloat64Array()
## A one-step radial pulse (features/souls: the Hauler stomp): [radius m, knock slide m/s, down s].
## While set, the next spec() knocks down every person inside the radius, then clears it.
var pulse: Vector3 = Vector3.ZERO
## n9 knocked down by a car (bodies.json car_hit): the slide velocity m/s, the seconds left lying
## (0 = up), and the hit's heading (unit, the car's) and speed m/s, read by the view.
var knock_vel: Vector2 = Vector2.ZERO
var knock_left: float = 0.0
var knock_heading: Vector2 = Vector2.ZERO
var knock_speed: float = 0.0
var _events: EventBus = null


func _init(p_table: BodyTable, at: Vector2 = Vector2.ZERO) -> void:
	table = p_table
	pos = at


func bind(events: EventBus) -> void:
	_events = events


## The sim spec for a step in which Rivet moves from the resolved `pos` to `want`.
func spec(want: Vector2) -> PackedFloat64Array:
	if knock_left > 0.0:
		want = _knock_step()
	vel = (want - pos) / SimClock.TICK_DT
	if vel.length() > TELEPORT_MPS:
		vel = Vector2.ZERO
	var s: PackedFloat64Array = SimArrays.f64(SimConst.BD_LEN)
	s[SimConst.BD_X] = want.x
	s[SimConst.BD_Y] = want.y
	s[SimConst.BD_VX] = vel.x
	s[SimConst.BD_VY] = vel.y
	s[SimConst.BD_ON] = 1.0 if on else 0.0
	s[SimConst.BD_R] = table.radius(body_class)
	s[SimConst.BD_RP] = table.radius(PERSON)
	s[SimConst.BD_SHARE] = table.share(body_class, PERSON)
	var r: BodyRule = table.rule(body_class, PERSON)
	var knock: bool = r != null and r.run == &"knockdown"
	s[SimConst.BD_TACKLE] = table.run_mps(body_class) if knock else NEVER_MPS
	s[SimConst.BD_KNOCK] = sqrt(2.0 * SLIDE_DECEL * r.knockback_m) if knock else 0.0
	s[SimConst.BD_DOWN] = r.down_s if knock else 0.0
	s[SimConst.BD_FLEE] = table.flee_s
	var back: BodyRule = table.rule(PERSON, body_class)
	var blocked: bool = back != null and back.run == &"blocked"
	s[SimConst.BD_RUN_IN] = table.run_mps(PERSON) if blocked else 0.0
	s[SimConst.BD_CAR_HIT] = table.car_hit.x if body_class == CLASS else 0.0
	pos = want
	if pulse.x > 0.0:
		_pulse(s)
	return s


## The pulse overrides: a still body of the pulse radius that tackles at any closing speed and
## moves nobody by overlap (share 0), so each person slides out along the radial knock.
func _pulse(s: PackedFloat64Array) -> void:
	s[SimConst.BD_VX] = 0.0
	s[SimConst.BD_VY] = 0.0
	s[SimConst.BD_R] = pulse.x
	s[SimConst.BD_SHARE] = 0.0
	s[SimConst.BD_TACKLE] = -1.0
	s[SimConst.BD_KNOCK] = pulse.y
	s[SimConst.BD_DOWN] = pulse.z
	s[SimConst.BD_RUN_IN] = 0.0
	pulse = Vector3.ZERO


## Reads the sim's body_result() after the step; emits one actor_knocked_down per knockdown.
func take(result: PackedFloat64Array) -> void:
	knocks = PackedFloat64Array()
	if not on or result.size() < SimConst.BR_HEAD:
		return
	pos = Vector2(result[SimConst.BR_X], result[SimConst.BR_Y])
	knocks = result.slice(SimConst.BR_HEAD)
	if result[SimConst.BR_HIT] > 0.0 and knock_left <= 0.0:
		_knocked(Vector2(result[SimConst.BR_HHX], result[SimConst.BR_HHY]), result[SimConst.BR_HIT])
	if _events == null:
		return
	for k: int in range(0, knocks.size(), SimConst.BR_STRIDE):
		var at: Vector2 = Vector2(knocks[k + 1], knocks[k + 2])
		_events.actor_knocked_down.emit(RIVET_ACTOR_ID, int(knocks[k]), PERSON, at)


func knocked() -> bool:
	return knock_left > 0.0


## One tick of the car knock: slide along it at the sim's slide deceleration, count the lying time.
func _knock_step() -> Vector2:
	var at: Vector2 = pos + knock_vel * SimClock.TICK_DT
	knock_vel = knock_vel.move_toward(Vector2.ZERO, SLIDE_DECEL * SimClock.TICK_DT)
	knock_left = maxf(0.0, knock_left - SimClock.TICK_DT)
	return at


## A car at speed hit him: the slide along its heading, the lying time, the damage and the Events.
func _knocked(heading: Vector2, speed: float) -> void:
	var ch: Vector4 = table.car_hit
	knock_heading = heading
	knock_speed = speed
	knock_vel = heading * speed * ch.y
	knock_left = ch.z
	var dmg: float = maxf(0.0, ch.w * (speed - ch.x * 0.5))
	if _events != null:
		_events.rivet_knocked.emit(heading, speed, dmg)

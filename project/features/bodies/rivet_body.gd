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

## False while Rivet is in a car: the sim then has no player body.
var on: bool = true
var table: BodyTable = null
## Where Rivet ended the last step (resolved), and his velocity into it, m/s.
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
## The last step's knockdowns: BR_STRIDE floats each (slot, x, y).
var knocks: PackedFloat64Array = PackedFloat64Array()
var _events: EventBus = null


func _init(p_table: BodyTable, at: Vector2 = Vector2.ZERO) -> void:
	table = p_table
	pos = at


func bind(events: EventBus) -> void:
	_events = events


## The sim spec for a step in which Rivet moves from the resolved `pos` to `want`.
func spec(want: Vector2) -> PackedFloat64Array:
	vel = (want - pos) / SimClock.TICK_DT
	if vel.length() > TELEPORT_MPS:
		vel = Vector2.ZERO
	var s: PackedFloat64Array = SimArrays.f64(SimConst.BD_LEN)
	s[SimConst.BD_X] = want.x
	s[SimConst.BD_Y] = want.y
	s[SimConst.BD_VX] = vel.x
	s[SimConst.BD_VY] = vel.y
	s[SimConst.BD_ON] = 1.0 if on else 0.0
	s[SimConst.BD_R] = table.radius(CLASS)
	s[SimConst.BD_RP] = table.radius(PERSON)
	s[SimConst.BD_SHARE] = table.share(CLASS, PERSON)
	var r: BodyRule = table.rule(CLASS, PERSON)
	var knock: bool = r != null and r.run == &"knockdown"
	s[SimConst.BD_TACKLE] = table.tackle_mps if knock else NEVER_MPS
	s[SimConst.BD_KNOCK] = sqrt(2.0 * SLIDE_DECEL * r.knockback_m) if knock else 0.0
	s[SimConst.BD_DOWN] = r.down_s if knock else 0.0
	s[SimConst.BD_FLEE] = table.flee_s
	var back: BodyRule = table.rule(PERSON, CLASS)
	s[SimConst.BD_RUN_IN] = 1.0 if back != null and back.run == &"blocked" else 0.0
	pos = want
	return s


## Reads the sim's body_result() after the step; emits one actor_knocked_down per knockdown.
func take(result: PackedFloat64Array) -> void:
	knocks = PackedFloat64Array()
	if not on or result.size() < SimConst.BR_HEAD:
		return
	pos = Vector2(result[SimConst.BR_X], result[SimConst.BR_Y])
	knocks = result.slice(SimConst.BR_HEAD)
	if _events == null:
		return
	for k: int in range(0, knocks.size(), SimConst.BR_STRIDE):
		var at: Vector2 = Vector2(knocks[k + 1], knocks[k + 2])
		_events.actor_knocked_down.emit(RIVET_ACTOR_ID, int(knocks[k]), PERSON, at)

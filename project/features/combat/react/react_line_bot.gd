class_name ReactLineBot
extends InputSource
## Lane human-reactions' scripted player for the reaction line (arena_stations/human-reactions.json,
## --bot=react_line): Rivet walks round each of the four dummies in turn and shoots it once from
## the west, north, east and south, so one clip shows every look (patrol cop, riot cop, two
## pedestrians) taking a round from four sides. Deterministic: it reads only the sim.
## The dummies face east (Fighter's default): the riot cop's round from the east hits the shield.

const SPAWNS: Array[String] = ["react_dummy_1", "react_dummy_2", "react_dummy_3", "react_dummy_4"]
## The dummies' looks (RigVariant.crowd index) and body plans, by spawn id (ArenaRigs reads it).
const LOOKS: Dictionary[String, Vector2i] = {
	"react_dummy_1": Vector2i(BodyPlan.Kind.COP, 5),
	"react_dummy_2": Vector2i(BodyPlan.Kind.COP, 6),
	"react_dummy_3": Vector2i(BodyPlan.Kind.PED, 0),
	"react_dummy_4": Vector2i(BodyPlan.Kind.PED, 3),
}
## Where Rivet stands to shoot, from the dummy (m): west, north, east, south. The line's dummies
## are 4 m apart, so the side spots sit half way between two of them.
const SIDES: Array[Vector2] = [
	Vector2(-2.0, 0.0), Vector2(0.0, -2.8), Vector2(2.0, 0.0), Vector2(0.0, 2.8)
]
const SIDE_NAMES: Array[String] = [
	"from the west", "from the north", "from the east", "from the south"
]
const WHO: Array[String] = [
	"patrol cop", "riot cop (shield east)", "pedestrian coat", "pedestrian hoodie"
]
const REACH_M: float = 0.35
## After arriving: settle, pull the trigger once, watch the reaction play.
const SETTLE_TICKS: int = 12
const WATCH_TICKS: int = 54

var stage: ArenaStage
var actions: PlayerActions
var shots: int = 0
## The spots walked, in order (a scenario plants a fault by replacing them).
var sides: Array[Vector2] = SIDES.duplicate()
## Aim this far beside each dummy (m, dev --wide): every round flies past it, a near miss.
var wide_m: float = 0.0
var _homes: Array[Vector2] = []
var _step: int = 0
var _arrived: int = -1


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	for id: String in SPAWNS:
		for t: ArenaTargets.Target in stage.targets.targets:
			if t.spawn.id == id:
				_homes.append(t.home)


func done() -> bool:
	return _step >= _homes.size() * SIDES.size()


func sample(tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	if done():
		return _input(Vector2.ZERO, Vector2.RIGHT, false)
	var home: Vector2 = _homes[_step / SIDES.size()]
	var spot: Vector2 = home + sides[_step % sides.size()]
	var aim: Vector2 = (
		(home + (home - rivet).normalized().orthogonal() * wide_m - rivet).normalized()
	)
	if _arrived < 0:
		if rivet.distance_to(spot) > REACH_M:
			return _input((spot - rivet).limit_length(1.0), aim, false)
		_arrived = tick
	var since: int = tick - _arrived
	if since >= SETTLE_TICKS + WATCH_TICKS:
		_step += 1
		_arrived = -1
	var fire: bool = since == SETTLE_TICKS
	if fire:
		shots += 1
		Log.info(
			"react_line", "shot %s %s tick %d" % [_who(), SIDE_NAMES[_step % SIDES.size()], tick]
		)
	return _input(Vector2.ZERO, aim, fire)


func _who() -> String:
	return WHO[_step / SIDES.size()]


## The (body plan, look) the rigs draw a target spawn with; (-1, -1) for any other spawn.
static func look_of(spawn_id: String) -> Vector2i:
	return LOOKS.get(spawn_id, Vector2i(-1, -1))


func _input(move: Vector2, aim: Vector2, fire: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))

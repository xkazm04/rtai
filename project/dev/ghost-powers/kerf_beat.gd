class_name KerfBeat
extends RefCounted
## The Kerf beat of GhostReel (`--bot=ghosts --ghost=kerf`), lane ghost-powers: a spread group
## far ahead of Rivet (three patrol cops, a riot cop, a robot thug at the back). He takes the soul
## (Q), blinks once with nothing in reach (the speed move), then picks them off one at a time:
## a chain of three blink-slices, a pause while a charge comes back, and the rest (the robot
## takes two cuts).

const GROUP: Array[Vector2] = [
	Vector2(12.0, -1.5), Vector2(14.0, 1.8), Vector2(15.5, -0.6), Vector2(13.5, 4.0)
]
const RIOT: int = 2
const ROBOT: Vector2 = Vector2(17.5, 1.2)
const ROBOT_HP: float = 6.0
## ghost-forms (GhostPilot): G presses pick the ghost (order tonnage, dent, kerf, ohm), Q
## transforms, the attacks wait for the settled form.
const SELECT_AT: Array[int] = [40, 42]
const TAKE_AT: int = 44
const FIRST_BLINK: int = 76
const CADENCE: int = 20

var victims: Array[Fighter] = []
var robot: Fighter = null


func begin(reel: GhostReel, stage: ArenaStage, anchor: Vector2) -> void:
	for i: int in GROUP.size():
		victims.append(reel.spawn(stage, anchor + GROUP[i], i == RIOT))
	robot = stage.arena.spawn_boss(anchor + ROBOT)
	robot.max_hp = ROBOT_HP
	robot.hp = ROBOT_HP
	robot.facing = Vector2.LEFT
	victims.append(robot)
	reel.victims.append_array(victims)


## Sim side, every tick: the arena's only robot is the quest boss's brain (exposed only while its
## tazer is spent, and CombatArena.damage drops every hit while it is not), so the beat holds the
## stand-in exposed as a robot thug would be (as OhmBeat does). Dev scaffolding until a robot thug
## lands in CombatArena.
func hold() -> void:
	if robot != null and robot.alive():
		robot.exposed = true


## (move, aim, buttons-wanted) for `local` ticks into the beat: Q at TAKE_AT, the first press a
## plain dash toward the group, then a blink press every CADENCE ticks at the nearest standing.
func want(stage: ArenaStage, local: int) -> Array:
	var rivet: Vector2 = stage.arena.rivet.pos
	var foe: Fighter = _nearest(rivet)
	var aim: Vector2 = (foe.pos - rivet).normalized() if foe != null else Vector2.RIGHT
	if local == TAKE_AT:
		return [Vector2.ZERO, aim, &"power_hauler"]
	if SELECT_AT.has(local):
		return [Vector2.ZERO, aim, &"power_gearbox"]
	if local < FIRST_BLINK or foe == null:
		return [Vector2.ZERO, aim, &""]
	var press: bool = (local - FIRST_BLINK) % CADENCE == 0
	return [Vector2.ZERO, aim, &"melee" if press else &""]


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in victims:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best

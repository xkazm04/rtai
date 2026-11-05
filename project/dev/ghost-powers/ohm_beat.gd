class_name OhmBeat
extends RefCounted
## The Ohm beat of GhostReel (`--bot=ghosts --ghost=ohm`), lane ghost-powers: a tight knot of
## three patrol cops ahead (the fork jumps between them), a riot cop beside them, a robot thug
## farther on and a police cruiser past it. He takes the soul (Q) and throws a bolt every CADENCE
## ticks at the nearest standing body: the cops are stunned and burned down in two bolts, the
## robot is struck first and dies to one bolt (machine_k), then the bolts burn the cruiser. He
## walks in when the target is beyond REACH_M.

const KNOT: Array[Vector2] = [Vector2(7.0, -0.8), Vector2(7.6, 0.6), Vector2(8.4, -0.2)]
const RIOT: Vector2 = Vector2(9.2, 1.6)
const ROBOT: Vector2 = Vector2(10.5, -1.6)
const ROBOT_HP: float = 6.0
const CAR: Vector2 = Vector2(9.5, 3.4)
## ghost-forms (GhostPilot): G presses pick the ghost (order tonnage, dent, kerf, ohm), Q
## transforms, the attacks wait for the settled form.
const SELECT_AT: Array[int] = [40, 42, 44]
const TAKE_AT: int = 46
const FIRST_BOLT: int = 90
const CADENCE: int = 30
const REACH_M: float = 9.5

var victims: Array[Fighter] = []
var robot: Fighter = null
var car: VehicleBody = null


func begin(reel: GhostReel, stage: ArenaStage, anchor: Vector2) -> void:
	for off: Vector2 in KNOT:
		victims.append(reel.spawn(stage, anchor + off, false))
	victims.append(reel.spawn(stage, anchor + RIOT, true))
	robot = stage.arena.spawn_boss(anchor + ROBOT)
	robot.max_hp = ROBOT_HP
	robot.hp = ROBOT_HP
	robot.facing = Vector2.LEFT
	victims.append(robot)
	reel.victims.append_array(victims)
	if stage.vehicles != null:
		car = stage.vehicles.spawn_parked(&"police_cruiser", anchor + CAR, Vector2.RIGHT)
	reel.car = car


## Sim side, every tick: the arena's only robot is the quest boss's brain (exposed only while
## its tazer is spent; Ohm's stun freezes that brain), so the beat holds the stand-in exposed as
## a robot thug would be. Dev scaffolding until a robot thug lands in CombatArena.
func hold() -> void:
	if robot != null and robot.alive():
		robot.exposed = true


## (move, aim, buttons-wanted): Q at TAKE_AT, then a bolt press every CADENCE ticks at the
## nearest standing body, then at the cruiser once all are down.
func want(stage: ArenaStage, local: int) -> Array:
	var rivet: Vector2 = stage.arena.rivet.pos
	var foe: Fighter = robot if robot != null and robot.alive() else _nearest(rivet)
	var at: Vector2 = (
		foe.pos if foe != null else (car.pos if car != null else rivet + Vector2.RIGHT)
	)
	var aim: Vector2 = (at - rivet).normalized()
	var walk: Vector2 = aim * 0.6 if rivet.distance_to(at) > REACH_M else Vector2.ZERO
	if local == TAKE_AT:
		return [Vector2.ZERO, aim, &"power_hauler"]
	if SELECT_AT.has(local):
		return [Vector2.ZERO, aim, &"power_gearbox"]
	if local < FIRST_BOLT:
		return [walk, aim, &""]
	var press: bool = (local - FIRST_BOLT) % CADENCE == 0
	return [walk, aim, &"melee" if press else &""]


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in victims:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best

class_name DentBeat
extends RefCounted
## The Dent beat of GhostReel (`--bot=ghosts --ghost=dent`), lane ghost-powers: a police
## cruiser parked beside Rivet, a pair of cops ahead (A) and a riot cop with two cops farther on
## and to the right (B), in the open lane between the course's props and its south wall. He
## seizes the cruiser (G picks Dent, Q, fire), drives it through A, changes direction onto B
## (the owner's "change direction"), and the overloaded car blows up in B on impact.

const CAR: Vector2 = Vector2(3.0, -2.5)
const GROUP_A: Array[Vector2] = [Vector2(8.0, -0.6), Vector2(8.6, 0.8)]
const GROUP_B: Array[Vector2] = [Vector2(14.2, 3.4), Vector2(14.0, 2.3), Vector2(15.1, 3.0)]
const RIOT_B: int = 0
## ghost-forms (GhostPilot): G picks Dent (Tonnage is first in the order), Q transforms (Dent's
## enter_s 0.6 = 36 ticks), then the fire press seizes (ghost-powers REQUEST 2).
const SELECT_AT: int = 40
const ENTER_AT: int = 42
const SEIZE_AT: int = 80

var group_a: Array[Fighter] = []
var group_b: Array[Fighter] = []
var car: VehicleBody = null


func begin(reel: GhostReel, stage: ArenaStage, anchor: Vector2) -> void:
	for off: Vector2 in GROUP_A:
		group_a.append(reel.spawn(stage, anchor + off, false))
	for i: int in GROUP_B.size():
		group_b.append(reel.spawn(stage, anchor + GROUP_B[i], i == RIOT_B))
	reel.victims.append_array(group_a)
	reel.victims.append_array(group_b)
	if stage.vehicles != null:
		car = stage.vehicles.spawn_parked(&"police_cruiser", anchor + CAR, Vector2.RIGHT)
	reel.car = car


## (move, aim, buttons-wanted) for `local` ticks into the beat: G at SEIZE_AT, aim at A until the
## car has struck, then at B.
func want(stage: ArenaStage, local: int) -> Array:
	var rivet: Vector2 = stage.arena.rivet.pos
	var dent: DentStage = stage.pilot.dent if stage.pilot != null else null
	var target: Array[Fighter] = group_a if dent == null or dent.strikes == 0 else group_b
	var aim: Vector2 = (_centre(target, rivet) - rivet).normalized()
	if local <= SEIZE_AT and car != null:  # look at the cruiser to seize it
		aim = (car.pos - rivet).normalized()
	var act: StringName = &""
	if local == SELECT_AT:
		act = &"power_gearbox"
	elif local == ENTER_AT:
		act = &"power_hauler"
	elif local == SEIZE_AT:
		act = &"fire"
	return [Vector2.ZERO, aim, act]


static func _centre(group: Array[Fighter], fallback: Vector2) -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	var n: int = 0
	for f: Fighter in group:
		if f.alive():
			sum += f.pos
			n += 1
	return sum / n if n > 0 else fallback + Vector2.RIGHT

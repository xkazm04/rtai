class_name ServoDroneBodies
extends RefCounted
## The swarm's drones as arena bodies (BossMoves.bodies()): one brain-owned Fighter per live
## drone, standing on the drone's ground shadow, so every weapon, the claw and the four ghosts hit
## it (Ohm's arc chains through a swarm, Kerf's blink cuts a line of them). A body the arena
## knocked to 0 hp shoots its drone down (ServoSwarm.kill: a carried parcel falls where it is); a
## drone that docked or expired takes its body with it. Bodies keep the swarm's order
## (deterministic hostiles).

const FIRST_ID: int = 9500

var hp: float = 1.0
var radius_m: float = 0.45
var shot: int = 0
var _by_drone: Dictionary[int, Fighter] = {}
var _list: Array[Fighter] = []


## After the swarm's step: down the shot drones, then one body per live drone at its shadow.
func sync(swarm: ServoSwarm) -> void:
	for d: ServoDrone in swarm.drones:
		var b: Fighter = _by_drone.get(d.id)
		if b != null and not b.alive():
			swarm.kill(d)
			shot += 1
	var next: Dictionary[int, Fighter] = {}
	_list = []
	for d: ServoDrone in swarm.drones:
		if not d.alive():
			continue
		var b: Fighter = _by_drone.get(d.id)
		if b == null:
			b = Fighter.make(Fighter.Kind.GUARD, FIRST_ID + d.id, d.pos, hp)
			b.radius_m = radius_m
			b.brain_owned = true
			b.machine = true  # a drone is a robot: no human kill, no red
		b.pos = d.pos
		b.facing = d.vel.normalized() if d.vel.length() > 0.1 else b.facing
		next[d.id] = b
		_list.append(b)
	_by_drone = next


func list() -> Array[Fighter]:
	return _list


## True if `id` is one of the drones' bodies (the view's oil, never blood).
func owns(id: int) -> bool:
	for b: Fighter in _list:
		if b.id == id:
			return true
	return false

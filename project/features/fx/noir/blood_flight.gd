class_name BloodFlight
extends RefCounted
## The flying drops of a BloodFx (split out of it by lane perf): their columns and one tick of
## flight. The city hands in `bulk`, the same tick in C++ (CitySim.step_blood_drops, a Vector2's
## float32 arithmetic); step_script stays as the no-DLL fallback and is what test_blood_flight
## holds the C++ to. Render only.

const WALL: int = 0
const LAND: int = 1

var pos: PackedVector2Array = PackedVector2Array()
var vel: PackedVector2Array = PackedVector2Array()
var size: PackedFloat32Array = PackedFloat32Array()
var life: PackedInt32Array = PackedInt32Array()
## Optional Callable(pos, vel, life, drag, land) -> [pos, vel, life, events].
var bulk: Callable = Callable()
var _n: int = 0


func _init(max_drops: int) -> void:
	pos = NoirPack.vec2s(max_drops)
	vel = NoirPack.vec2s(max_drops)
	size = NoirPack.floats(max_drops)
	life = NoirPack.ints(max_drops)


## The next free slot after the last one used, or -1 when every drop flies.
func free_slot() -> int:
	for k: int in pos.size():
		var i: int = (_n + k) % pos.size()
		if life[i] <= 0:
			return i
	return -1


func put(i: int, at: Vector2, v: Vector2, size_px: float, ticks: int) -> void:
	pos[i] = at
	vel[i] = v
	size[i] = size_px
	life[i] = ticks
	_n = i + 1


## One tick. Returns slot * 2 + WALL or LAND, in slot order, for the drops that stopped: a wall
## drop stays where it was (the caller reads its contact), and both kinds end with life 0.
func step(solid: Callable, drag: float, land: float) -> PackedInt32Array:
	if bulk.is_valid():
		var r: Array = bulk.call(pos, vel, life, drag, land)
		pos = r[0]
		vel = r[1]
		life = r[2]
		return r[3]
	return step_script(solid, drag, land)


func step_script(solid: Callable, drag: float, land: float) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	var walls: bool = solid.is_valid()
	for i: int in pos.size():
		if life[i] <= 0:
			continue
		if walls and BloodMarks.wall_normal(solid, pos[i], vel[i]) != Vector2.ZERO:
			life[i] = 0
			@warning_ignore("return_value_discarded")
			out.append(i * 2 + WALL)
			continue
		pos[i] += vel[i]
		vel[i] *= drag
		life[i] -= 1
		if life[i] <= 0 or vel[i].length() < land:
			life[i] = 0
			@warning_ignore("return_value_discarded")
			out.append(i * 2 + LAND)
	return out

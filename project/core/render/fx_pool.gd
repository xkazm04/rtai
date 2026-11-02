class_name FxPool
extends RefCounted
## The particle slots behind FxSystem: a fixed budget, no allocation after init. Positions and
## velocities are in world px; everything advances per sim tick (SimClock.TICK_DT).

const PX_PER_M: float = 32.0

var pos: PackedVector2Array = PackedVector2Array()
var vel: PackedVector2Array = PackedVector2Array()
var rot: PackedFloat32Array = PackedFloat32Array()
var born: PackedInt32Array = PackedInt32Array()
var kind_of: Array[Dictionary] = []
var seed_of: PackedFloat32Array = PackedFloat32Array()
var alive: int = 0


func _init(cap: int) -> void:
	@warning_ignore("return_value_discarded")
	pos.resize(cap)
	@warning_ignore("return_value_discarded")
	vel.resize(cap)
	@warning_ignore("return_value_discarded")
	rot.resize(cap)
	@warning_ignore("return_value_discarded")
	born.resize(cap)
	@warning_ignore("return_value_discarded")
	seed_of.resize(cap)
	@warning_ignore("return_value_discarded")
	kind_of.resize(cap)


func capacity() -> int:
	return pos.size()


## Appends one particle (the caller checked the budget).
## `at`: the spawn position (origin) and heading (rotation).
func put(k: Dictionary, at: Transform2D, v: Vector2, tick: int, s: float) -> void:
	var i: int = alive
	pos[i] = at.origin
	vel[i] = v
	rot[i] = at.get_rotation()
	born[i] = tick
	kind_of[i] = k
	seed_of[i] = s
	alive += 1


## Advances `steps` ticks, expires the dead (swap-remove), writes the MultiMesh at `tick`.
func step(steps: int, tick: int, mm: MultiMesh) -> void:
	var i: int = 0
	while i < alive:
		var k: Dictionary = kind_of[i]
		var life: float = k["life_ticks"]
		var age: int = tick - born[i]
		if age >= int(life):
			_swap_out(i)
			continue
		var drag: float = k["drag"]
		for s: int in steps:
			pos[i] += vel[i] * SimClock.TICK_DT
			vel[i] *= maxf(0.0, 1.0 - drag * SimClock.TICK_DT)
		var size_m: float = k["size_m"]
		var grow: float = k["grow"]
		var size: float = size_m * PX_PER_M * (1.0 + grow * age * SimClock.TICK_DT) * 0.5
		var col: Color = k["color"]
		var fade_from: float = k.get("fade_from", 0.0)
		col.a = clampf((1.0 - float(age) / life) / (1.0 - fade_from), 0.0, 1.0)
		mm.set_instance_transform_2d(i, Transform2D(rot[i], Vector2.ONE * size, 0.0, pos[i]))
		mm.set_instance_color(i, col)
		var shape: float = k["shape_id"]
		mm.set_instance_custom_data(i, Color(shape, seed_of[i], cell(k, age, seed_of[i]), 0.0))
		i += 1
	mm.visible_instance_count = alive


## The FX sheet cell + 1 a particle of kind `k` draws at `age` ticks (0 = the analytic shape):
## "pick" holds one cell chosen by the seed, "anim" steps a cell every `frame_ticks` (or spreads
## the cells over the life) and holds the last one.
static func cell(k: Dictionary, age: int, s: float) -> float:
	if not k.has("cell0"):
		return 0.0
	var first: float = k["cell0"]
	var n: float = k["cell_n"]
	var f: float = floorf(s * n)
	if k["anim"]:
		var life: float = k["life_ticks"]
		var ft: float = k.get("frame_ticks", life / n)
		f = floorf(age / ft)
	return first + clampf(f, 0.0, n - 1.0) + 1.0


func _swap_out(i: int) -> void:
	alive -= 1
	pos[i] = pos[alive]
	vel[i] = vel[alive]
	rot[i] = rot[alive]
	born[i] = born[alive]
	kind_of[i] = kind_of[alive]
	seed_of[i] = seed_of[alive]

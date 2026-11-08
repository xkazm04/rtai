class_name FxPool
extends RefCounted
## The particle slots behind FxSystem: a fixed budget, no allocation after init. Positions and
## velocities are in world px; everything advances per sim tick (SimClock.TICK_DT).

const PX_PER_M: float = 32.0
const MIRROR_STRIDE: int = 14

var pos: PackedVector2Array = PackedVector2Array()
var vel: PackedVector2Array = PackedVector2Array()
var rot: PackedFloat32Array = PackedFloat32Array()
var born: PackedInt32Array = PackedInt32Array()
var row_of: Array[FxKindRow] = []
var seed_of: PackedFloat32Array = PackedFloat32Array()
## 1: slot i holds a particle the MultiMesh has not been written for (a put, a swap-in).
var fresh: PackedByteArray = PackedByteArray()
var alive: int = 0
## MultiMesh instances written by step() (a held particle is not rewritten).
var writes: int = 0
## Tests: sized to capacity x MIRROR_STRIDE, every instance write lands here too (a headless
## MultiMesh keeps no data): transform 6, colour 4, custom 4 floats a slot.
var mirror: PackedFloat32Array = PackedFloat32Array()
var _last_kind: Dictionary = {}
var _last_row: FxKindRow = null


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
	row_of.resize(cap)
	@warning_ignore("return_value_discarded")
	fresh.resize(cap)


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
	if _last_row == null or not is_same(k, _last_kind):  # a spawn puts `count` of one kind
		_last_kind = k
		_last_row = FxKindRow.of(k)
	row_of[i] = _last_row
	seed_of[i] = s
	fresh[i] = 1
	alive += 1


## Advances `steps` ticks, expires the dead (swap-remove), writes the MultiMesh at `tick`. A held
## particle (no motion, no growth, full alpha, the same cell as `steps` ticks ago) already shows
## these values and is not rewritten: a ground splat lies still for ~75 % of its life.
func step(steps: int, tick: int, mm: MultiMesh) -> void:
	var i: int = 0
	while i < alive:
		var r: FxKindRow = row_of[i]
		var age: int = tick - born[i]
		if age >= r.life_i:
			_swap_out(i)
			continue
		var still: bool = vel[i] == Vector2.ZERO
		var drag: float = r.drag
		for s: int in steps:
			pos[i] += vel[i] * SimClock.TICK_DT
			vel[i] *= maxf(0.0, 1.0 - drag * SimClock.TICK_DT)
		var size: float = r.size_m * PX_PER_M * (1.0 + r.grow * age * SimClock.TICK_DT) * 0.5
		var col: Color = r.color
		col.a = clampf((1.0 - float(age) / r.life) / (1.0 - r.fade_from), 0.0, 1.0)
		var sd: float = seed_of[i]
		var cell_now: float = r.cell(age, sd)
		if fresh[i] == 0 and (steps == 0 or _held(r, still, col.a, cell_now, age - steps, sd)):
			i += 1
			continue
		fresh[i] = 0
		writes += 1
		var xf: Transform2D = Transform2D(rot[i], Vector2.ONE * size, 0.0, pos[i])
		var cu: Color = Color(r.shape_id, sd, cell_now, r.rim)
		mm.set_instance_transform_2d(i, xf)
		mm.set_instance_color(i, col)
		mm.set_instance_custom_data(i, cu)
		if not mirror.is_empty():
			mirror_write(mirror, i, xf, col, cu)
		i += 1
	mm.visible_instance_count = alive


static func mirror_write(
	m: PackedFloat32Array, i: int, xf: Transform2D, c: Color, cu: Color
) -> void:
	var o: int = i * MIRROR_STRIDE
	var v: Array[float] = [xf.x.x, xf.x.y, xf.y.x, xf.y.y, xf.origin.x, xf.origin.y]
	v.append_array([c.r, c.g, c.b, c.a, cu.r, cu.g, cu.b, cu.a])
	for j: int in MIRROR_STRIDE:
		m[o + j] = v[j]


## True when a particle written `steps` ticks ago (at `age_was`) shows exactly what it did then:
## it did not move (zero velocity), its size has no growth term, its alpha is the full 1.0 (alpha
## only falls with age, so it was 1.0 then too) and its sheet cell is the same.
static func _held(r: FxKindRow, still: bool, a: float, c: float, age_was: int, s: float) -> bool:
	if not still or r.grow != 0.0 or a != 1.0:
		return false
	return not r.anim or c == r.cell(age_was, s)


## The fx_ink instance custom: shape id, seed, sheet cell + 1, the cell's ink rim (fx.json
## atlas `rim`, cell widths; 0 = none).
static func custom_of(k: Dictionary, age: int, s: float) -> Color:
	var shape: float = k["shape_id"]
	var rim: float = k.get("rim", 0.0)
	return Color(shape, s, cell(k, age, s), rim)


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
	row_of[i] = row_of[alive]
	seed_of[i] = seed_of[alive]
	fresh[i] = 1

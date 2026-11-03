class_name BloodDecals
extends RefCounted
## D-Noir blood decals (lane noir, BloodFx's ground marks): two fixed rings of splats and pools
## (pools are the last `pools` slots, so droplets never evict a kill's pool), each decal growing
## from r0 to r1 after it is born and fading over the decal table's ticks. Render only.

var pools: int = 16
var _pos: PackedVector2Array = PackedVector2Array()
var _r0: PackedFloat32Array = PackedFloat32Array()
var _r1: PackedFloat32Array = PackedFloat32Array()
var _born: PackedInt32Array = PackedInt32Array()
var _grow: PackedInt32Array = PackedInt32Array()
## Per decal: the travel direction at landing (length = elongation), or a pool's flow.
var _dir: PackedVector2Array = PackedVector2Array()
var _next: int = 0
var _p_next: int = 0


func _init(max_decals: int, max_pools: int) -> void:
	pools = max_pools
	_pos = NoirPack.vec2s(max_decals)
	_r0 = NoirPack.floats(max_decals)
	_r1 = NoirPack.floats(max_decals)
	_born = NoirPack.ints(max_decals)
	_grow = NoirPack.ints(max_decals)
	_dir = NoirPack.vec2s(max_decals)


func size() -> int:
	return _pos.size()


## A decal of radius r1 (grows from r0 over `grow` ticks from tick `born`); its slot.
func add(at: Vector2, r1: float, grow: int, r0: float, born: int) -> int:
	var splats: int = _pos.size() - pools
	var i: int = _next
	if grow > 0:
		i = splats + _p_next
		_p_next = (_p_next + 1) % pools
	else:
		_next = (_next + 1) % splats
	_pos[i] = at
	_r1[i] = r1
	_r0[i] = r1 if r0 < 0.0 else r0
	_born[i] = born
	_grow[i] = grow
	_dir[i] = Vector2.ZERO
	return i


func set_dir(i: int, dir: Vector2) -> void:
	_dir[i] = dir


## Decals on the ground now (splats + pools; capped by the budget).
func live() -> int:
	var n: int = 0
	for r: float in _r1:
		n += 1 if r > 0.0 else 0
	return n


## True when a pool decal sits within `r` px of `at`.
func has_pool_at(at: Vector2, r: float) -> bool:
	for i: int in range(_pos.size() - pools, _pos.size()):
		if _r1[i] > 0.0 and _pos[i].distance_to(at) <= r:
			return true
	return false


## Draws the first `count` slots on `canvas` at `tick` in `fluid`'s ground colours.
func draw(canvas: CanvasItem, tick: int, count: int, fluid: NoirFluid, dc: Dictionary) -> void:
	var after: int = dc["fade_after_ticks"]
	var fade: int = dc["fade_ticks"]
	for i: int in count:
		var age: int = tick - _born[i]
		if age < 0 or _r1[i] <= 0.0:
			continue
		var g: float = 1.0 if _grow[i] == 0 else clampf(float(age) / _grow[i], 0.0, 1.0)
		var r: float = lerpf(_r0[i], _r1[i], 1.0 - pow(1.0 - g, 2.0))
		var a: float = 1.0 - clampf(float(age - after) / fade, 0.0, 1.0)
		if _grow[i] > 0:
			var cols: PackedColorArray = [
				Color(fluid.dark, a), Color(fluid.ground, a), Color(fluid.sheen, a * 0.9)
			]
			BloodMarks.pool(canvas, _pos[i], r, _dir[i], cols)
		else:
			BloodMarks.splat(canvas, _pos[i], r, _dir[i], Color(fluid.ground, a))

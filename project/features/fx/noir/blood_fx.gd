class_name BloodFx
extends Node2D
## D-Noir blood (lane noir): directional spurts of pooled droplets that land as splat decals,
## pools that spread under kills, decals that persist and fade over minutes. All tuning is
## data (blood_fx.json). Stepped on the fixed tick (step_ticks), never on frame delta; its
## scatter is a counter hash, not an RNG stream, so it touches no sim state. Render only.
## Coordinates are this node's local px (32 px per metre, like the world canvas).

const PARAMS: String = "res://features/fx/noir/blood_fx.json"

var tick: int = 0
var p: Dictionary = {}
var drops: int = 0
var decals: int = 0
var _pos: PackedVector2Array = PackedVector2Array()
var _vel: PackedVector2Array = PackedVector2Array()
var _size: PackedFloat32Array = PackedFloat32Array()
var _life: PackedInt32Array = PackedInt32Array()
var _d_pos: PackedVector2Array = PackedVector2Array()
var _d_r0: PackedFloat32Array = PackedFloat32Array()
var _d_r1: PackedFloat32Array = PackedFloat32Array()
var _d_born: PackedInt32Array = PackedInt32Array()
var _d_grow: PackedInt32Array = PackedInt32Array()
var _d_seed: PackedInt32Array = PackedInt32Array()
## Per decal: the travel direction at landing (length = elongation), or a pool's flow.
var _d_dir: PackedVector2Array = PackedVector2Array()
var _d_next: int = 0
var _p_next: int = 0
var _pools: int = 16
var _n: int = 0
var _k: int = 0
var _blood: Color
var _dark: Color
var _sheen: Color


func _init() -> void:
	p = NoirLook.read_params(PARAMS)
	var budget: Dictionary = p["budget"]
	var max_drops: int = budget["max_drops"]
	var max_decals: int = budget["max_decals"]
	_pools = budget["max_pools"]
	decals = max_decals
	_pos = _pv(max_drops)
	_vel = _pv(max_drops)
	_size = _pf(max_drops)
	_life = _pi(max_drops)
	_d_pos = _pv(max_decals)
	_d_r0 = _pf(max_decals)
	_d_r1 = _pf(max_decals)
	_d_born = _pi(max_decals)
	_d_grow = _pi(max_decals)
	_d_seed = _pi(max_decals)
	_d_dir = _pv(max_decals)
	var c: Dictionary = p["colour"]
	_blood = _col(c["blood"])
	_dark = _col(c["blood_dark"])
	_sheen = _col(c["sheen"])


## A hit at `at` (px) travelling along `dir`: hit kind `kind` from the `hits` table.
func splash(at: Vector2, dir: Vector2, kind: String) -> void:
	var h: Dictionary = p["hits"][kind]
	var n: int = h["drops"]
	var cone_deg: float = h["cone_deg"]
	var cone: float = deg_to_rad(cone_deg)
	var base: float = dir.angle() if dir.length() > 0.001 else _rand() * TAU
	for i: int in n:
		var a: float = base + (_rand() - 0.5) * cone * (0.4 + 0.6 * _rand())
		var sp: float = _range(h["speed_px"]) * (0.6 + 0.4 * _rand())
		_spawn_drop(at + Vector2(_rand() - 0.5, _rand() - 0.5) * 3.0, Vector2.from_angle(a) * sp, h)
	var hit: int = _add_decal(at, _range(h["splat_px"]) * 1.4, 0)
	_d_dir[hit] = dir.normalized() * 0.5
	if h["pool"]:
		var pool: Dictionary = p["pool"]
		var r: Array = pool["radius_px"]
		var delay: int = pool["delay_ticks"]
		var grow: int = pool["grow_ticks"]
		var r0: float = r[0]
		var r1: float = r[1]
		var run: float = pool.get("run", 0.0)
		var i: int = _add_decal(at + dir.normalized() * 4.0, r1, grow, r0, delay)
		_d_dir[i] = dir.normalized() * run


## One drip from a wounded fighter at `at` (px), stretched along `move` (px per tick, may be zero).
func drip(at: Vector2, move: Vector2) -> void:
	var i: int = _add_decal(at, _range(p["drip"]["splat_px"]), 0)
	_d_dir[i] = move.normalized() * clampf(move.length() / 3.0, 0.0, 0.8)


## Decals on the ground now (splats + pools; capped by the budget).
func live_decals() -> int:
	var n: int = 0
	for r: float in _d_r1:
		n += 1 if r > 0.0 else 0
	return n


## True when a pool decal sits within `r` px of `at` (tests, evidence).
func has_pool_at(at: Vector2, r: float) -> bool:
	for i: int in range(_d_pos.size() - _pools, _d_pos.size()):
		if _d_r1[i] > 0.0 and _d_pos[i].distance_to(at) <= r:
			return true
	return false


func step_ticks(n: int) -> void:
	var ph: Dictionary = p["physics"]
	var drag: float = ph["drag"]
	var land: float = ph["land_speed_px"]
	for _t: int in n:
		tick += 1
		for i: int in _pos.size():
			if _life[i] <= 0:
				continue
			_pos[i] += _vel[i]
			_vel[i] *= drag
			_life[i] -= 1
			if _life[i] <= 0 or _vel[i].length() < land:
				_life[i] = 0
				drops -= 1
				var d: int = _add_decal(_pos[i], _size[i] * (1.2 + _rand()), 0)
				_d_dir[d] = _vel[i].normalized() * clampf(_vel[i].length() / 1.5, 0.3, 1.0)
	queue_redraw()


func _spawn_drop(at: Vector2, v: Vector2, h: Dictionary) -> void:
	var lt: Array = p["physics"]["life_ticks"]
	for k: int in _pos.size():
		var i: int = (_n + k) % _pos.size()
		if _life[i] <= 0:
			_pos[i] = at
			_vel[i] = v
			_size[i] = _range(h["drop_px"])
			_life[i] = roundi(_range(lt))
			_n = i + 1
			drops += 1
			return


## A decal of radius r1 (grows from r0 over `grow` ticks after `delay`). Splats and pools have
## their own rings (pools: the last max_pools slots), so droplets never evict a kill's pool.
func _add_decal(at: Vector2, r1: float, grow: int, r0: float = -1.0, delay: int = 0) -> int:
	var splats: int = _d_pos.size() - _pools
	var i: int = _d_next
	if grow > 0:
		i = splats + _p_next
		_p_next = (_p_next + 1) % _pools
	else:
		_d_next = (_d_next + 1) % splats
	_d_pos[i] = at
	_d_r1[i] = r1
	_d_r0[i] = r1 if r0 < 0.0 else r0
	_d_born[i] = tick + delay
	_d_grow[i] = grow
	_d_seed[i] = int(_rand() * 100000.0)
	_d_dir[i] = Vector2.ZERO
	return i


func _draw() -> void:
	var dc: Dictionary = p["decal"]
	var after: int = dc["fade_after_ticks"]
	var fade: int = dc["fade_ticks"]
	for i: int in decals:
		var age: int = tick - _d_born[i]
		if age < 0 or _d_r1[i] <= 0.0:
			continue
		var g: float = 1.0 if _d_grow[i] == 0 else clampf(float(age) / _d_grow[i], 0.0, 1.0)
		var r: float = lerpf(_d_r0[i], _d_r1[i], 1.0 - pow(1.0 - g, 2.0))
		var a: float = 1.0 - clampf(float(age - after) / fade, 0.0, 1.0)
		if _d_grow[i] > 0:
			var cols: PackedColorArray = [Color(_dark, a), Color(_blood, a), Color(_sheen, a * 0.9)]
			BloodMarks.pool(self, _d_pos[i], r, _d_dir[i], cols)
		else:
			BloodMarks.splat(self, _d_pos[i], r, _d_dir[i], Color(_blood, a))
	var trail: float = p["physics"]["trail"]
	for i: int in _pos.size():
		if _life[i] > 0:
			draw_line(_pos[i] - _vel[i] * trail, _pos[i], _blood, _size[i] * 1.4)
			draw_circle(_pos[i], _size[i], _blood)


func _rand() -> float:
	_k += 1
	return _hash(tick * 7919 + _k * 104729)


func _range(v: Variant) -> float:
	var r: Array = v
	var lo: float = r[0]
	var hi: float = r[1]
	return lerpf(lo, hi, _rand())


static func _hash(i: int) -> float:
	var x: int = (i * 1103515245 + 12345) & 0x7fffffff
	x = ((x >> 13) ^ x) * 1274126177 & 0x7fffffff
	return float(x % 100003) / 100003.0


static func _col(v: Variant) -> Color:
	var a: Array = v
	var r: float = a[0]
	var g: float = a[1]
	var b: float = a[2]
	return Color(r, g, b)


static func _pv(n: int) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	return out


static func _pf(n: int) -> PackedFloat32Array:
	var out: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	return out


static func _pi(n: int) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	@warning_ignore("return_value_discarded")
	out.resize(n)
	return out

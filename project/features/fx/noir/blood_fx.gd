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
## Optional Callable(px: Vector2) -> bool, true inside a wall/building: a droplet that flies into
## one stops at the wall and smears along it (a wall splat) instead of landing beyond it.
var solid: Callable = Callable()
var wall_hits: int = 0
## Microseconds the last _draw took (the riot budget, lane d5-combat).
var draw_us: int = 0
## Redraws since boot (the per-frame cost average: draw_us summed over draws / frames).
var draws: int = 0
## Redraw cadence (ticks) once nothing flies or grows and only the slow fade moves; 1 = every
## tick (noir's own scenes). The combat blood sets blood_fx.json game.settled_redraw_ticks.
var settled_every: int = 1
var _busy_until: int = 0
var _drawn_at: int = -1
var _pos: PackedVector2Array = PackedVector2Array()
var _vel: PackedVector2Array = PackedVector2Array()
var _size: PackedFloat32Array = PackedFloat32Array()
var _life: PackedInt32Array = PackedInt32Array()
var _ring: BloodDecals = null
var _n: int = 0
var _k: int = 0
## What is drawn: blood, or another fluid (use_fluid).
var _fluid: NoirFluid = null


func _init() -> void:
	p = NoirLook.read_params(PARAMS)
	var budget: Dictionary = p["budget"]
	var max_drops: int = budget["max_drops"]
	var max_decals: int = budget["max_decals"]
	var max_pools: int = budget["max_pools"]
	decals = max_decals
	_ring = BloodDecals.new(max_decals, max_pools)
	_pos = NoirPack.vec2s(max_drops)
	_vel = NoirPack.vec2s(max_drops)
	_size = NoirPack.floats(max_drops)
	_life = NoirPack.ints(max_drops)
	var colour: Dictionary = p["colour"]
	_fluid = NoirFluid.from(colour)


## Draws another fluid of the `fluids` table (e.g. "oil": white sparks in the air, black on the
## ground) instead of blood. False when the table has no such fluid.
func use_fluid(fluid: String) -> bool:
	var fluids: Dictionary = p.get("fluids", {})
	var f: Dictionary = fluids.get(fluid, {})
	if f.is_empty():
		return false
	_fluid = NoirFluid.from(f)
	return true


## Pools get an ink keyline `px` wide in `colour` (the D4/D5 print; 0 = noir's bare rim).
func set_ink(px: float, colour: Color) -> void:
	_ring.ink_px = px
	_ring.ink = colour


## Draws the splats as one MultiMesh (BloodSplatMesh, the GPU path the riot needs); returns it.
func use_splat_mesh() -> BloodSplatMesh:
	if _ring.mesh == null:
		_ring.mesh = BloodSplatMesh.new(_ring.size())
		var dc: Dictionary = p["decal"]
		var after: int = dc["fade_after_ticks"]
		var fade: int = dc["fade_ticks"]
		var floor_a: float = dc["min_alpha"]
		_ring.mesh.set_fade(after, fade, floor_a)
		add_child(_ring.mesh)
	_ring.mesh.colour = _fluid.ground
	return _ring.mesh


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
	_ring.set_dir(hit, dir.normalized() * 0.5)
	if h["pool"]:
		var pool: Dictionary = p["pool"]
		var r: Array = pool["radius_px"]
		var delay: int = pool["delay_ticks"]
		var grow: int = pool["grow_ticks"]
		var r0: float = r[0]
		var r1: float = r[1]
		var run: float = pool.get("run", 0.0)
		var i: int = _add_decal(at + dir.normalized() * 4.0, r1, grow, r0, delay)
		_ring.set_dir(i, dir.normalized() * run)


## One drip from a wounded fighter at `at` (px), stretched along `move` (px per tick, may be zero).
func drip(at: Vector2, move: Vector2) -> void:
	var i: int = _add_decal(at, _range(p["drip"]["splat_px"]), 0)
	_ring.set_dir(i, move.normalized() * clampf(move.length() / 3.0, 0.0, 0.8))


## Decals on the ground now (splats + pools; capped by the budget).
func live_decals() -> int:
	return _ring.live()


## True when a pool decal sits within `r` px of `at` (tests, evidence).
func has_pool_at(at: Vector2, r: float) -> bool:
	return _ring.has_pool_at(at, r)


func step_ticks(n: int) -> void:
	var ph: Dictionary = p["physics"]
	var drag: float = ph["drag"]
	var land: float = ph["land_speed_px"]
	for _t: int in n:
		tick += 1
		for i: int in _pos.size():
			if _life[i] <= 0 or (solid.is_valid() and _hit_wall(i)):
				continue
			_pos[i] += _vel[i]
			_vel[i] *= drag
			_life[i] -= 1
			if _life[i] <= 0 or _vel[i].length() < land:
				_life[i] = 0
				drops -= 1
				var d: int = _add_decal(_pos[i], _size[i] * (1.2 + _rand()), 0)
				_ring.set_dir(d, _vel[i].normalized() * clampf(_vel[i].length() / 1.5, 0.3, 1.0))
	# with the splat mesh a landing splat needs no redraw: only drops, pools and the fade do
	var busy: bool = tick <= _busy_until and _ring.mesh == null
	if drops > 0 or busy or tick - _drawn_at >= settled_every:
		_drawn_at = tick
		queue_redraw()


## A droplet into a wall: two splats at the contact smeared both ways along the wall, sized
## by the impact speed. False when the droplet flies free this tick.
func _hit_wall(i: int) -> bool:
	var nrm: Vector2 = BloodMarks.wall_normal(solid, _pos[i], _vel[i])
	if nrm == Vector2.ZERO:
		return false
	var at: Vector2 = BloodMarks.contact(solid, _pos[i], _vel[i])
	var r: float = _size[i] * (2.2 + _vel[i].length() / 2.5)
	for sgn: float in [1.0, -1.0]:
		var d: int = _add_decal(at + nrm * r * 0.3, r, 0)
		_ring.set_dir(d, nrm.orthogonal() * sgn)
	_life[i] = 0
	drops -= 1
	wall_hits += 1
	return true


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


## A decal of radius r1 (grows from r0 over `grow` ticks after `delay`), in BloodDecals' rings.
## One scatter draw per decal (its old per-decal seed), so the scatter sequence is unchanged.
func _add_decal(at: Vector2, r1: float, grow: int, r0: float = -1.0, delay: int = 0) -> int:
	var i: int = _ring.add(at, r1, grow, r0, tick + delay)
	_busy_until = maxi(_busy_until, tick + delay + grow + 1)
	@warning_ignore("return_value_discarded")
	_rand()
	return i


func _draw() -> void:
	var t0: int = Time.get_ticks_usec()
	var dc: Dictionary = p["decal"]
	_ring.draw(self, tick, decals, _fluid, dc)
	var trail: float = _fluid.trail if _fluid.trail >= 0.0 else p["physics"]["trail"]
	if drops > 0:
		var fx: Array = [_pos, _vel, _size, _life]
		if _fluid.case_px > 0.0:
			BloodBatch.drops(self, fx, trail, Color.BLACK, _fluid.case_px * 2.0)
		BloodBatch.drops(self, fx, trail, _fluid.flight, 0.0)
	draw_us = Time.get_ticks_usec() - t0
	draws += 1


func _rand() -> float:
	_k += 1
	return NoirPack.hash01(tick * 7919 + _k * 104729)


func _range(v: Variant) -> float:
	var r: Array = v
	var lo: float = r[0]
	var hi: float = r[1]
	return lerpf(lo, hi, _rand())

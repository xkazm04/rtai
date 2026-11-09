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
## Optional C++ step of the flight (BloodFlight.bulk), given when `solid` is the city's own map.
var bulk_step: Callable = Callable():
	set(c):
		bulk_step = c
		_flight.bulk = c
var wall_hits: int = 0
## Microseconds the last _draw took (the riot budget, lane d5-combat).
var draw_us: int = 0
## Redraws since boot (the per-frame cost average: draw_us summed over draws / frames).
var draws: int = 0
## Microseconds the last flying-drops redraw took (its own canvas item; lane gunplay, riot cost).
var drops_us: int = 0
var drops_draws: int = 0
## Redraw cadence (ticks) once nothing flies or grows and only the slow fade moves; 1 = every
## tick (noir's own scenes). The combat blood sets blood_fx.json game.settled_redraw_ticks.
var settled_every: int = 1
## How far (px) along the blow a kill's pool starts from the hit point (the D4/D5 city's dead
## slide there: CombatBlood sets it per kill; noir's own scenes keep the 4 px).
var pool_lead_px: float = 4.0
## A kill pool's full radius (px); 0 = blood_fx.json pool.radius_px. CombatBlood sets it
## from game.pool_radius_px when that key exists (a D4/D5-only size; noir keeps the table's).
var pool_r1_px: float = 0.0
var _busy_until: int = 0
var _drawn_at: int = -1
var _flight: BloodFlight = null
var _ring: BloodDecals = null
var _k: int = 0
## What is drawn: blood, or another fluid (use_fluid).
var _fluid: NoirFluid = null
## The flying drops on their own canvas item (parent's material), redrawn every tick while any
## fly, so the pools and decals under them redraw only when they change (lane gunplay: the riot
## re-recorded every pool each tick while 100 cops kept killing).
var _drops_view: Node2D = Node2D.new()
var _drops_drawn: bool = false


func _init() -> void:
	p = NoirLook.read_params(PARAMS)
	var budget: Dictionary = p["budget"]
	decals = budget["max_decals"]
	var max_pools: int = budget["max_pools"]
	var max_drops: int = budget["max_drops"]
	_ring = BloodDecals.new(decals, max_pools)
	_flight = BloodFlight.new(max_drops)
	var colour: Dictionary = p["colour"]
	_fluid = NoirFluid.from(colour)
	_drops_view.use_parent_material = true
	@warning_ignore("return_value_discarded")
	_drops_view.draw.connect(_draw_drops)
	add_child(_drops_view)


## Draws another fluid of the `fluids` table (e.g. "oil": white sparks in the air, black on the
## ground) instead of blood. False when the table has no such fluid.
func use_fluid(fluid: String) -> bool:
	var fluids: Dictionary = p.get("fluids", {})
	var f: Dictionary = fluids.get(fluid, {})
	if f.is_empty():
		return false
	_fluid = NoirFluid.from(f)
	return true


## Recolours the fluid's ground (and its flight, when the two were one): the palette's `blood`.
func set_ground(c: Color) -> void:
	if _fluid.flight == _fluid.ground:
		_fluid.flight = c
	_fluid.ground = c
	if _ring.mesh != null:
		_ring.mesh.colour = c


## Recolours the fluid's shadow (a pool's body): the palette's `blood_dark`.
func set_dark(c: Color) -> void:
	_fluid.dark = c


## The fluid's shadow (a pool's body; CorpseStains' dark spots follow it).
func dark() -> Color:
	return _fluid.dark


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
	_ring.mesh.set_halo(_fluid.halo, _fluid.halo_tone)
	return _ring.mesh


## The live fight's stain life (CorpseDecay stains): splats and pools start fading `after` ticks
## after they land and are gone `fade` ticks later (the table's decal row stays as shipped).
func set_decal_life(after: int, fade: int) -> void:
	p = p.duplicate(true)
	var dc: Dictionary = p["decal"]
	dc["fade_after_ticks"] = after
	dc["fade_ticks"] = maxi(fade, 1)
	if _ring.mesh != null:
		var floor_a: float = dc["min_alpha"]
		_ring.mesh.set_fade(after, maxi(fade, 1), floor_a)


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
		r1 = pool_r1_px if pool_r1_px > 0.0 else r1
		var run: float = pool.get("run", 0.0)
		var i: int = _add_decal(at + dir.normalized() * pool_lead_px, r1, grow, r0, delay)
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
		if drops > 0:
			_resolve(_flight.step(solid, drag, land))
	# with the splat mesh a landing splat needs no redraw: only drops, pools and the fade do
	var busy: bool = tick <= _busy_until and _ring.mesh == null
	if drops > 0 or _drops_drawn:
		_drops_view.queue_redraw()
	if busy or tick - _drawn_at >= settled_every:
		_drawn_at = tick
		queue_redraw()


## One tick's flight events, in slot order (the scatter hash is a counter): the decals they leave.
func _resolve(events: PackedInt32Array) -> void:
	for e: int in events:
		drops -= 1
		var i: int = e >> 1
		if e & 1 == BloodFlight.WALL:
			_hit_wall(i)
			continue
		var v: Vector2 = _flight.vel[i]
		var d: int = _add_decal(_flight.pos[i], _flight.size[i] * (1.2 + _rand()), 0)
		_ring.set_dir(d, v.normalized() * clampf(v.length() / 1.5, 0.3, 1.0))


## A droplet into a wall: two splats at the contact smeared both ways along the wall, sized
## by the impact speed.
func _hit_wall(i: int) -> void:
	var from: Vector2 = _flight.pos[i]
	var v: Vector2 = _flight.vel[i]
	var nrm: Vector2 = BloodMarks.wall_normal(solid, from, v)
	var at: Vector2 = BloodMarks.contact(solid, from, v)
	var r: float = _flight.size[i] * (2.2 + v.length() / 2.5)
	for sgn: float in [1.0, -1.0]:
		var d: int = _add_decal(at + nrm * r * 0.3, r, 0)
		_ring.set_dir(d, nrm.orthogonal() * sgn)
	wall_hits += 1


func _spawn_drop(at: Vector2, v: Vector2, h: Dictionary) -> void:
	var i: int = _flight.free_slot()
	if i < 0:
		return
	var size_px: float = _range(h["drop_px"])
	var f: Vector2 = BloodBatch.fine_k(h, _rand()) if h.has("fine") else Vector2.ONE
	_flight.put(i, at, v * f.y, size_px * f.x, roundi(_range(p["physics"]["life_ticks"])))
	drops += 1


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
	draw_us = Time.get_ticks_usec() - t0
	draws += 1


func _draw_drops() -> void:
	var t0: int = Time.get_ticks_usec()
	_drops_drawn = drops > 0
	if drops > 0:
		var trail: float = _fluid.trail if _fluid.trail >= 0.0 else p["physics"]["trail"]
		var fx: Array = [_flight.pos, _flight.vel, _flight.size, _flight.life]
		if _fluid.case_px > 0.0:
			BloodBatch.drops(_drops_view, fx, trail, Color.BLACK, _fluid.case_px * 2.0)
		BloodBatch.drops(_drops_view, fx, trail, _fluid.flight, 0.0)
	drops_us = Time.get_ticks_usec() - t0
	drops_draws += 1


func _rand() -> float:
	_k += 1
	return NoirPack.hash01(tick * 7919 + _k * 104729)


func _range(v: Variant) -> float:
	var r: Array = v
	var lo: float = r[0]
	var hi: float = r[1]
	return lerpf(lo, hi, _rand())

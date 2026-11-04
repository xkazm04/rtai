# gdlint: disable=max-public-methods
class_name CitySimRef
extends CitySimBackend
## The permanent GDScript reference of the bubble sim (NAT-06), ported from the cityscale spike's
## sim_gd.gd. Tier A (inside ra of the camera, or promoted): full sim. Tier B (to rb): lane and
## sidewalk following only. Beyond rb: despawned (the spawner refills at the bubble edge). The
## native CitySim must match it bit for bit (tests/parity).

var _s: CitySimState = CitySimState.new()
var _h: CitySimHash = CitySimHash.new(_s)
var _flow: CitySimFlow = CitySimFlow.new(_s)
var _body: CitySimBody = CitySimBody.new(_s, _h)
var _people: CitySimPeople = CitySimPeople.new(_s, _h, _flow, _body)
var _cars: CitySimCars = CitySimCars.new(_s, _h, _flow)
var _shots: CitySimShots = CitySimShots.new(_s, _h)
var _render: CitySimRender = CitySimRender.new(_s)


func _init() -> void:
	_s.init(1)


func backend_name() -> StringName:
	return &"gdscript"


func init(seed_value: int) -> void:
	_s.init(seed_value)
	_flow.reset()


func set_radii(ra: float, rb: float, riot: float) -> void:
	_s.ra = ra
	_s.rb = rb
	_s.riot_r = riot


func stamp_chunk(cx: int, cy: int, tiles: PackedByteArray, cells: PackedByteArray) -> void:
	SimArrays.copy_chunk(_s, cx, cy, tiles, cells)


func clear_chunk(cx: int, cy: int) -> void:
	SimArrays.copy_chunk(
		_s, cx, cy, CityChunk.zeros(CityChunk.TILES), CityChunk.zeros(CityChunk.CELLS)
	)


func cell_at(x: float, y: float) -> int:
	return _s.cell_at(x, y)


func tile_at(x: float, y: float) -> int:
	return _s.tile_at(x, y)


func spawn(spec: PackedFloat64Array) -> int:
	var i: int = _s.spawn(spec) if spec.size() == SimConst.SP_LEN else -1
	if i >= 0:
		_render.car_state[i] = 0
	return i


func set_riot_centre(i: int, x: float, y: float) -> void:
	_s.sx[i] = x
	_s.sy[i] = y


func kill(i: int) -> void:
	_s.kill(i)


func strike(i: int, vx: float, vy: float, lethal: bool) -> void:
	CitySimStrike.strike(_s, i, vx, vy, lethal)


func scare(x: float, y: float) -> void:
	_shots.scare(x, y)


func set_obstacles(xy: PackedFloat64Array) -> void:
	_s.obst = xy.slice(0, mini(xy.size() >> 1, SimConst.OBST_MAX) * 2)


func set_car_state(i: int, state: int) -> void:
	if i >= 0 and i < SimConst.CAP:
		_render.car_state[i] = state


func step(dt: float, camx: float, camy: float, tgx: float, tgy: float) -> void:
	_s.time += dt
	_body.knocks.clear()
	_tier(dt, camx, camy)
	_h.build(camx, camy)
	_flow.update(tgx, tgy)
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0:
			continue
		var k: int = _s.kind[i]
		if k == SimConst.K_PED:
			_people.ped(i, dt)
		elif k == SimConst.K_COP:
			_people.cop(i, dt, tgx, tgy)
		else:
			_cars.car(i, dt, tgx, tgy)
	_body.resolve()
	_shots.step(dt)
	_count()


func get_counters() -> PackedInt32Array:
	return _s.counters.duplicate()


func snapshot() -> PackedFloat64Array:
	return SimArrays.snapshot(_s)


func set_body(spec: PackedFloat64Array) -> void:
	_body.set_spec(spec)


func body_result() -> PackedFloat64Array:
	return _body.result()


func set_render(mms: Array[RID], clips: PackedInt32Array) -> void:
	_render.setup(mms, clips)


func write_render(vx0: float, vy0: float, vx1: float, vy1: float) -> void:
	_render.write(vx0, vy0, vx1, vy1)


func set_rig_slots(slots: PackedInt32Array) -> void:
	_render.set_rig_slots(slots)


func set_person_px(px: float) -> void:
	_render.person_px = px


func get_variants() -> PackedByteArray:
	return _s.variant.duplicate()


func get_render_counts() -> PackedInt32Array:
	return _render.counts.duplicate()


func flow_stats() -> PackedInt32Array:
	return _flow.stats.duplicate()


func flow_dist(x: float, y: float) -> int:
	return _flow.dist(x, y)


## Despawns dead bodies after 8 s (or at once in tier B) and re-tiers everyone by distance.
func _tier(dt: float, camx: float, camy: float) -> void:
	var ra2: float = _s.ra * _s.ra
	var rb2: float = _s.rb * _s.rb
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0:
			continue
		var k: int = _s.kind[i]
		if (k == SimConst.K_PED or k == SimConst.K_COP) and _s.mode[i] == SimConst.M_DEAD:
			_s.t2[i] += dt
			if _s.t2[i] > 8.0 or _s.tier[i] == 1:
				_s.kill(i)
				continue
		var ddx: float = _s.px[i] - camx
		var ddy: float = _s.py[i] - camy
		var d2: float = ddx * ddx + ddy * ddy
		if (_s.flags[i] & SimConst.F_PROMOTED) != 0:
			if d2 > rb2 * 2.56:
				_s.kill(i)
				continue
			_s.tier[i] = 0
		elif d2 < ra2:
			_s.tier[i] = 0
		elif d2 < rb2:
			_s.tier[i] = 1
		else:
			_s.kill(i)


func _count() -> void:
	var c: PackedInt32Array = SimArrays.i32(8, 0)
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0:
			continue
		c[_s.kind[i]] += 1
		c[SimConst.CN_TIER_A + _s.tier[i]] += 1
		var person: bool = _s.kind[i] == SimConst.K_PED or _s.kind[i] == SimConst.K_COP
		if _s.mode[i] == SimConst.M_DEAD and person:
			c[SimConst.CN_DEAD] += 1
	for k: int in SimConst.PCAP:
		c[SimConst.CN_PROJ] += _s.qalive[k]
	for j: int in 8:
		_s.counters[j] = c[j]

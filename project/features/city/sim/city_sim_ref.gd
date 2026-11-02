class_name CitySimRef
extends CitySimBackend
## The permanent GDScript reference of the bubble sim (NAT-06), ported from the cityscale spike's
## sim_gd.gd. Tier A (inside ra of the camera, or promoted): full sim. Tier B (to rb): lane and
## sidewalk following only. Beyond rb: despawned (the spawner refills at the bubble edge). The
## native CitySim must match it bit for bit (tests/parity).

var _s: CitySimState = CitySimState.new()
var _h: CitySimHash = CitySimHash.new(_s)
var _flow: CitySimFlow = CitySimFlow.new(_s)
var _people: CitySimPeople = CitySimPeople.new(_s, _h, _flow)
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
	_copy_chunk(cx, cy, tiles, cells)


func clear_chunk(cx: int, cy: int) -> void:
	_copy_chunk(cx, cy, CityChunk.zeros(CityChunk.TILES), CityChunk.zeros(CityChunk.CELLS))


func cell_at(x: float, y: float) -> int:
	return _s.cell_at(x, y)


func tile_at(x: float, y: float) -> int:
	return _s.tile_at(x, y)


func spawn(spec: PackedFloat64Array) -> int:
	return _s.spawn(spec) if spec.size() == SimConst.SP_LEN else -1


func set_riot_centre(i: int, x: float, y: float) -> void:
	_s.sx[i] = x
	_s.sy[i] = y


func kill(i: int) -> void:
	_s.kill(i)


func step(dt: float, camx: float, camy: float, tgx: float, tgy: float) -> void:
	_s.time += dt
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
	_shots.step(dt)
	_count()


func get_counters() -> PackedInt32Array:
	return _s.counters.duplicate()


func snapshot() -> PackedFloat64Array:
	var out: PackedFloat64Array = PackedFloat64Array()
	for i: int in SimConst.CAP:
		if _s.alive[i] == 0:
			continue
		(
			out
			. append_array(
				[
					i,
					_s.kind[i],
					_s.mode[i],
					_s.tier[i],
					_s.px[i],
					_s.py[i],
					_s.hx[i],
					_s.hy[i],
					_s.v[i],
					_s.phase[i],
					_s.t1[i],
					_s.t2[i],
					_s.dir[i],
					_s.ndir[i],
				]
			)
		)
	for k: int in SimConst.PCAP:
		if _s.qalive[k] != 0:
			out.append_array([SimConst.SNAP_PROJ_BASE + k, _s.qx[k], _s.qy[k]])
	return out


func set_render(mms: Array[RID], clips: PackedInt32Array) -> void:
	_render.setup(mms, clips)


func write_render(vx0: float, vy0: float, vx1: float, vy1: float) -> void:
	_render.write(vx0, vy0, vx1, vy1)


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


func _copy_chunk(cx: int, cy: int, tiles: PackedByteArray, cells: PackedByteArray) -> void:
	_s.map_version += 1
	var nt: int = SimConst.CHUNK_TILES
	var nc: int = SimConst.CHUNK_CELLS
	for ly: int in nt:
		for lx: int in nt:
			_s.tiles[(cy * nt + ly) * SimConst.TW + cx * nt + lx] = tiles[ly * nt + lx]
	var base: int = cy * nc * SimConst.W + cx * nc
	for ly: int in nc:
		var row: int = base + ly * SimConst.W
		var src: int = ly * nc
		for lx: int in nc:
			_s.cells[row + lx] = cells[src + lx]

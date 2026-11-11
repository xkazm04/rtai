extends GutTest
## Adversarial cell queries. The oracle scans slots, then orders by world cell and id;
## it never reads hash counts, starts, items or origins. Dead means alive == 0, as in test_sim_hash.

var _s: CitySimState
var _h: CitySimHash
var _cam: Vector2


func before_each() -> void:
	_s = CitySimState.new()
	_s.init(1)
	_h = CitySimHash.new(_s)
	_cam = Vector2.ZERO


func test_promoted_keep_radius_is_covered_in_all_octants_at_camera_cell_seams() -> void:
	var reach: float = _s.rb * 1.6
	for cam: Vector2 in _cameras():
		_s.alive.fill(0)
		for id: int in 16:
			var direction: Vector2 = Vector2.from_angle(TAU * id / 16.0)
			# Include the exact inclusive keep limit and a point just inside it.
			_place(id, cam + direction * reach)
			_place(id + 16, cam + direction * (reach - SimConst.HC / 64.0))
			_s.flags[id] = SimConst.F_PROMOTED
			_s.flags[id + 16] = SimConst.F_PROMOTED
		_build(cam)
		for id: int in 32:
			var at: Vector2 = Vector2(_s.px[id], _s.py[id])
			assert_has(_h.query(at.x, at.y, 0), id, "cam %s slot %d" % [cam, id])
			for radius: int in [0, 1, 2]:
				_check(at, radius)
				_check(at + Vector2.ONE * SimConst.HC, radius)


func test_negative_and_fractional_cell_seams_do_not_merge_or_lose_cells() -> void:
	var offsets: Array[float] = [-1.0, -1.0 / 64.0, 0.0, 1.0 / 64.0, 1.0]
	for cam: Vector2 in _cameras():
		_s.alive.fill(0)
		var id: int = 0
		for y: float in offsets:
			for x: float in offsets:
				_place(id, cam + Vector2(x, y) * SimConst.HC)
				id += 1
		_build(cam)
		for slot: int in id:
			for radius: int in [0, 1]:
				_check(Vector2(_s.px[slot], _s.py[slot]), radius)


func test_outside_actors_never_wrap_at_edges_corners_or_distant_rows() -> void:
	for cam: Vector2 in _cameras():
		_s.alive.fill(0)
		var lo: Vector2i = _origin(cam)
		var xs: Array[int] = _edge_cells(lo.x)
		var ys: Array[int] = _edge_cells(lo.y)
		var id: int = 0
		for y: int in ys:
			for x: int in xs:
				_place(id, _point(Vector2i(x, y)))
				id += 1
		_build(cam)
		for y: int in ys:
			for x: int in xs:
				for radius: int in [0, 1, 2]:
					_check(_point(Vector2i(x, y)), radius)
		_check(cam, SimConst.HW)


func test_queries_outside_every_side_clip_only_the_overlapping_square() -> void:
	var cam: Vector2 = Vector2(-7.75, 3.25) * SimConst.HC
	var lo: Vector2i = _origin(cam)
	var last: int = SimConst.HW - 1
	var id: int = 0
	for y: int in [0, 1, last - 1, last]:
		for x: int in [0, 1, last - 1, last]:
			_place(id, _point(lo + Vector2i(x, y)))
			id += 1
	_build(cam)
	for dy: int in [-1, 0, 1]:
		for dx: int in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			for gap: int in [1, 3, SimConst.HW]:
				var centre: Vector2i = lo + Vector2i(last >> 1, last >> 1)
				if dx != 0:
					centre.x = lo.x - gap if dx < 0 else lo.x + last + gap
				if dy != 0:
					centre.y = lo.y - gap if dy < 0 else lo.y + last + gap
				for radius: int in [0, gap - 1, gap, gap + 1, SimConst.HW * 2]:
					_check(_point(centre), radius)


func _place(id: int, at: Vector2) -> void:
	_s.alive[id] = 1
	_s.tier[id] = 0
	_s.px[id] = at.x
	_s.py[id] = at.y


func _build(cam: Vector2) -> void:
	_cam = cam
	_h.build(cam.x, cam.y)


func _cameras() -> Array[Vector2]:
	return [
		Vector2.ZERO,
		Vector2(7.0, -11.0) * SimConst.HC,
		Vector2(-7.0, -11.0) * SimConst.HC,
		Vector2(-1.0 / 64.0, 1.0 / 64.0) * SimConst.HC,
		Vector2(7.0 - 1.0 / 64.0, -11.0 + 1.0 / 64.0) * SimConst.HC,
		Vector2(-7.25, 11.75) * SimConst.HC,
	]


func _origin(cam: Vector2) -> Vector2i:
	var half: int = SimConst.HW >> 1
	return Vector2i(floori(cam.x / SimConst.HC) - half, floori(cam.y / SimConst.HC) - half)


func _edge_cells(lo: int) -> Array[int]:
	return [
		lo - SimConst.HW,
		lo - 1,
		lo,
		lo + 1,
		lo + SimConst.HW - 1,
		lo + SimConst.HW,
		lo + SimConst.HW * 2
	]


func _point(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2.ONE / 4.0) * SimConst.HC


func _cell(id: int) -> Vector2i:
	return Vector2i(floori(_s.px[id] / SimConst.HC), floori(_s.py[id] / SimConst.HC))


func _cell_before(a: int, b: int) -> bool:
	var ac: Vector2i = _cell(a)
	var bc: Vector2i = _cell(b)
	if ac.y != bc.y:
		return ac.y < bc.y
	if ac.x != bc.x:
		return ac.x < bc.x
	return a < b


func _check(at: Vector2, radius: int) -> void:
	var expected: Array[int] = []
	var lo: Vector2i = _origin(_cam)
	var centre: Vector2i = Vector2i(floori(at.x / SimConst.HC), floori(at.y / SimConst.HC))
	for id: int in SimConst.CAP:
		if _s.alive[id] == 0 or _s.tier[id] != 0:
			continue
		var cell: Vector2i = _cell(id)
		if cell.x < lo.x or cell.x >= lo.x + SimConst.HW:
			continue
		if cell.y < lo.y or cell.y >= lo.y + SimConst.HW:
			continue
		if absi(cell.x - centre.x) <= radius and absi(cell.y - centre.y) <= radius:
			expected.append(id)
	expected.sort_custom(_cell_before)
	assert_eq(
		_h.query(at.x, at.y, radius),
		expected,
		"cam %s query cell %s radius %d" % [_cam, centre, radius]
	)

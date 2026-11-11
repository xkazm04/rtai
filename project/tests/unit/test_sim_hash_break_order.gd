extends GutTest
## Adversarial cell queries (order, capacity, camera moves; split from
## test_sim_hash_break). The oracle scans slots, then orders by world cell and id;
## it never reads hash counts, starts, items or origins. Dead means alive == 0, as in test_sim_hash.

var _s: CitySimState
var _h: CitySimHash
var _cam: Vector2


func before_each() -> void:
	_s = CitySimState.new()
	_s.init(1)
	_h = CitySimHash.new(_s)
	_cam = Vector2.ZERO


func test_order_is_row_major_then_ascending_id_even_when_ids_run_backwards() -> void:
	var cam: Vector2 = Vector2(-0.25, -0.75) * SimConst.HC
	var centre: Vector2i = Vector2i(floori(cam.x / SimConst.HC), floori(cam.y / SimConst.HC))
	var expected: Array[int] = []
	for cell: int in 9:
		var row: int = floori(float(cell) / 3.0)
		var at: Vector2 = _point(centre + Vector2i(cell % 3 - 1, row - 1))
		# Lower ids belong to later cells; insertion order is also reversed.
		var low: int = (8 - cell) * 2
		_place(low + 1, at)
		_place(low, at + Vector2.ONE * SimConst.HC / 4.0)
		expected.append(low)
		expected.append(low + 1)
	for pass_index: int in 3:
		_build(cam)
		assert_eq(_h.query(cam.x, cam.y, 1), expected, "build %d" % pass_index)
		_check(cam, 1)


func test_full_capacity_rebuilds_remove_dead_and_other_tiers_without_stale_ids() -> void:
	for id: int in SimConst.CAP:
		_place(id, Vector2.ONE * SimConst.HC / 4.0)
	_build(Vector2.ZERO)
	_check(Vector2.ZERO, 0)
	for phase: int in 4:
		for id: int in SimConst.CAP:
			_s.alive[id] = 0 if (id + phase) % 5 == 0 else 1
			_s.tier[id] = (id + phase) % 3
			_s.flags[id] = SimConst.F_PROMOTED
			var cell: Vector2i = Vector2i((id + phase) % 7 - 3, (id * 3 + phase) % 7 - 3)
			var at: Vector2 = _point(cell)
			_s.px[id] = at.x
			_s.py[id] = at.y
		_build(Vector2.ZERO)
		for y: int in range(-4, 5):
			for x: int in range(-4, 5):
				_check(_point(Vector2i(x, y)), 1)
		_check(Vector2.ZERO, SimConst.HW)
	_s.alive.fill(0)
	_build(Vector2.ZERO)
	assert_eq(_h.query(0.0, 0.0, SimConst.HW), [], "empty rebuild after capacity churn")


func test_camera_rebases_drop_old_window_and_restore_identical_order_on_return() -> void:
	var travel: float = SimConst.HW * SimConst.HC * 2.0
	var cameras: Array[Vector2] = [Vector2.ZERO, Vector2(travel, -travel), Vector2.ZERO]
	for id: int in SimConst.CAP:
		var base: Vector2 = cameras[id % 2]
		_place(id, base + Vector2((id % 9) - 4, (id % 7) - 3) * SimConst.HC)
	var first: Array[int] = []
	for index: int in cameras.size():
		_build(cameras[index])
		_check(cameras[index], SimConst.HW)
		_check(cameras[1 - index % 2], 1)
		var result: Array[int] = _h.query(_cam.x, _cam.y, SimConst.HW)
		if index == 0:
			first.assign(result)
		elif index == 2:
			assert_eq(result, first, "returning camera gives identical arrays")


func _place(id: int, at: Vector2) -> void:
	_s.alive[id] = 1
	_s.tier[id] = 0
	_s.px[id] = at.x
	_s.py[id] = at.y


func _build(cam: Vector2) -> void:
	_cam = cam
	_h.build(cam.x, cam.y)


func _origin(cam: Vector2) -> Vector2i:
	var half: int = SimConst.HW >> 1
	return Vector2i(floori(cam.x / SimConst.HC) - half, floori(cam.y / SimConst.HC) - half)


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

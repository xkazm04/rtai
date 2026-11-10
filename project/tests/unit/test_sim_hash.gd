extends GutTest
## The reference sim's broad phase: live tier-A ids in camera-centred cells, with
## a deterministic order. Queries return square cell neighbourhoods,
## leaving exact distance checks to their callers.

var _state: CitySimState
var _hash: CitySimHash


func before_each() -> void:
	_state = CitySimState.new()
	_state.alive = SimArrays.u8(SimConst.CAP)
	_state.tier = SimArrays.u8(SimConst.CAP)
	_state.px = SimArrays.f64(SimConst.CAP)
	_state.py = SimArrays.f64(SimConst.CAP)
	_hash = CitySimHash.new(_state)


func test_empty_build_has_no_candidates() -> void:
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, SimConst.HW), [])


func test_only_live_tier_a_actors_are_candidates_including_last_slot() -> void:
	for id: int in [0, 1, 2, 3, SimConst.CAP - 1]:
		_actor(id, 0.25 * SimConst.HC, 0.25 * SimConst.HC)
	_state.alive[1] = 0
	_state.tier[2] = 1
	_state.tier[3] = 2
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, 0), [0, SimConst.CAP - 1])


func test_cells_are_half_open_and_floor_negative_coordinates() -> void:
	_actor(0, -0.25 * SimConst.HC, -0.25 * SimConst.HC)
	_actor(1, 0.0, 0.0)
	_actor(2, 0.75 * SimConst.HC, 0.75 * SimConst.HC)
	_actor(3, SimConst.HC, 0.0)
	_actor(4, 0.0, SimConst.HC)
	_actor(5, -SimConst.HC, -SimConst.HC)
	_hash.build(0.0, 0.0)
	assert_eq(_hash.query(-0.5 * SimConst.HC, -0.5 * SimConst.HC, 0), [0, 5])
	assert_eq(_hash.query(-SimConst.HC, -SimConst.HC, 0), [0, 5])
	assert_eq(_hash.query(0.0, 0.0, 0), [1, 2])
	assert_eq(_hash.query(0.75 * SimConst.HC, 0.75 * SimConst.HC, 0), [1, 2])
	assert_eq(_hash.query(SimConst.HC, 0.0, 0), [3])
	assert_eq(_hash.query(0.0, SimConst.HC, 0), [4])


func test_radius_is_an_inclusive_square_of_cells_in_stable_order() -> void:
	for y: int in range(-1, 2):
		for x: int in range(-1, 2):
			var id: int = 90 - ((y + 1) * 3 + x + 1)
			var at: Vector2 = _point(x, y)
			_actor(id, at.x, at.y)
	_actor(1, 0.75 * SimConst.HC, 0.75 * SimConst.HC)
	var outside: Array[Vector2] = [_point(-2, 0), _point(2, 0), _point(0, -2), _point(0, 2)]
	for i: int in outside.size():
		_actor(10 + i, outside[i].x, outside[i].y)
	_hash.build(0.0, 0.0)
	var first: Array[int] = _query_cell(0, 0, 1)
	assert_eq(_query_cell(0, 0, 0), [1, 86], "all candidates in the cell, not a point")
	assert_eq(_sorted(first), [1, 82, 83, 84, 85, 86, 87, 88, 89, 90], "the 3x3 cells only")
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, 1), first, "rebuilding the same state gives the same order")


func test_camera_window_spans_hw_cells_per_axis_around_the_camera_cell() -> void:
	for step: Vector2i in [Vector2i(1, 0), Vector2i(0, 1)]:
		var ks: Array[int] = _indexed_offsets(7, -4, step)
		assert_eq(ks.size(), SimConst.HW, "HW cells along %s" % step)
		assert_eq(ks[-1] - ks[0] + 1, SimConst.HW, "one contiguous run along %s" % step)
		assert_true(absi(ks[0] + ks[-1]) <= 1, "centred on the camera cell along %s" % step)


func test_queries_clip_each_edge_without_wrapping_into_another_row() -> void:
	_hash.build(0.0, 0.0)
	var lo: int = _hash.hgx  # a camera at the origin puts both axes' window origin here
	var hi: int = lo + SimConst.HW - 1
	var corners: Array[Vector2] = [_point(lo, lo), _point(hi, lo), _point(lo, hi), _point(hi, hi)]
	for id: int in corners.size():
		_actor(id, corners[id].x, corners[id].y)
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(lo - 1, lo, 1), [0], "left overlap")
	assert_eq(_query_cell(hi + 1, lo, 1), [1], "right overlap")
	assert_eq(_query_cell(lo, lo - 1, 1), [0], "top overlap")
	assert_eq(_query_cell(lo, hi + 1, 1), [2], "bottom overlap")
	assert_eq(_query_cell(lo - 1, lo - 1, 1), [0], "corner overlap")
	for at: Vector2 in [
		_point(lo - 2, lo), _point(hi + 2, lo), _point(lo, lo - 2), _point(lo, hi + 2)
	]:
		assert_eq(_hash.query(at.x, at.y, 1), [], "a disjoint query is empty")
	assert_eq(_sorted(_query_cell(0, 0, SimConst.HW)), [0, 1, 2, 3], "oversized queries clip")


func test_rebuild_replaces_old_membership_after_movement_death_and_tier_changes() -> void:
	for id: int in 4:
		_actor(id, 0.25 * SimConst.HC, 0.25 * SimConst.HC)
	_state.tier[3] = 1
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, 0), [0, 1, 2])
	_state.px[0] = 2.25 * SimConst.HC
	_state.py[0] = -1.75 * SimConst.HC
	_state.alive[1] = 0
	_state.tier[2] = 1
	_state.tier[3] = 0
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, 0), [3], "no stale ids or counts from the previous build")
	assert_eq(_query_cell(2, -2, 0), [0], "movement updates both cell coordinates")
	_state.alive.fill(0)
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, SimConst.HW), [], "an empty rebuild clears the index")


func test_moving_camera_rebuilds_the_window_and_indexes_newly_visible_actors() -> void:
	var shift: float = SimConst.HW * SimConst.HC
	_actor(0, 0.25 * SimConst.HC, 0.25 * SimConst.HC)
	_actor(1, shift + 0.25 * SimConst.HC, -shift + 0.25 * SimConst.HC)
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, SimConst.HW), [0])
	_hash.build(shift, -shift)
	assert_eq(_hash.query(shift, -shift, 0), [1], "the newly visible actor is indexed")
	assert_eq(_hash.query(0.0, 0.0, 0), [], "the old window is gone")
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, 0), [0], "returning restores the original window")


func test_a_full_capacity_cell_returns_every_slot_once_in_order() -> void:
	var expected: Array[int] = []
	for id: int in SimConst.CAP:
		_actor(id, 0.25 * SimConst.HC, 0.25 * SimConst.HC)
		expected.append(id)
	_hash.build(0.0, 0.0)
	assert_eq(_query_cell(0, 0, 0), expected)
	assert_eq(_query_cell(0, 0, 1), expected, "empty neighbouring cells add nothing")


func _actor(id: int, x: float, y: float) -> void:
	_state.alive[id] = 1
	_state.tier[id] = 0
	_state.px[id] = x
	_state.py[id] = y


func _point(x: int, y: int) -> Vector2:
	return Vector2((x + 0.25) * SimConst.HC, (y + 0.25) * SimConst.HC)


func _query_cell(x: int, y: int, radius: int) -> Array[int]:
	var at: Vector2 = _point(x, y)
	return _hash.query(at.x, at.y, radius)


func _sorted(ids: Array[int]) -> Array[int]:
	var out: Array[int] = []
	out.assign(ids)
	out.sort()
	return out


## One actor per offset k in [-HW, HW] from cell (cx, cy) along step, the camera in that cell;
## returns the sorted offsets the built window indexed.
func _indexed_offsets(cx: int, cy: int, step: Vector2i) -> Array[int]:
	_state.alive.fill(0)
	for k: int in range(-SimConst.HW, SimConst.HW + 1):
		var at: Vector2 = _point(cx + k * step.x, cy + k * step.y)
		_actor(k + SimConst.HW, at.x, at.y)
	var cam: Vector2 = _point(cx, cy)
	_hash.build(cam.x, cam.y)
	var out: Array[int] = []
	for id: int in _hash.query(cam.x, cam.y, SimConst.HW):
		out.append(id - SimConst.HW)
	return _sorted(out)

extends GutTest
## CityCrowdOcclusion: the baked crowd behind a lifted building is pasted over, the crowd in front
## and the cars are not, and a lying body gets a square patch.

const PX: float = SimConst.PX_PER_M


## A building 10 x 6 m whose ground rect starts at (0, 10) m, its roof lifted 4 m north.
func _bld() -> CityOccluders.Bld:
	var b: CityOccluders.Bld = CityOccluders.Bld.new()
	b.r = Rect2(Vector2(0.0, 10.0) * PX, Vector2(10.0, 6.0) * PX)
	b.area = Rect2(Vector2(0.0, 6.0) * PX, Vector2(10.0, 10.0) * PX)
	return b


## One snapshot row (SimConst.SNAP_STRIDE floats) for actor `id` of `kind` and `mode` at (x, y) m.
func _row(id: int, kind: int, mode: int, at: Vector2) -> PackedFloat64Array:
	var r: PackedFloat64Array = PackedFloat64Array()
	@warning_ignore("return_value_discarded")
	r.resize(SimConst.SNAP_STRIDE)
	r[0] = id
	r[1] = kind
	r[2] = mode
	r[4] = at.x
	r[5] = at.y
	return r


func _run(snap: PackedFloat64Array, out: Array[Rect2]) -> Array[Rect2]:
	var view: Rect2 = Rect2(Vector2(-20.0, -20.0) * PX, Vector2(60.0, 60.0) * PX)
	return CityCrowdOcclusion.patches(snap, [_bld()], view, out)


func test_a_walker_behind_the_roof_is_patched_inside_the_drawn_area() -> void:
	var out: Array[Rect2] = []
	var areas: Array[Rect2] = _run(_row(3, SimConst.K_PED, 0, Vector2(5.0, 8.0)), out)
	assert_eq(out.size(), 1)
	assert_eq(areas.size(), 1)
	assert_true(_bld().area.encloses(out[0]))
	assert_almost_eq(out[0].end.y, 8.0 * PX + Ink.LINE_PX, 0.01)


func test_the_crowd_in_front_and_the_cars_are_not_patched() -> void:
	var out: Array[Rect2] = []
	var snap: PackedFloat64Array = _row(1, SimConst.K_PED, 0, Vector2(5.0, 17.0))
	snap.append_array(_row(2, SimConst.K_CAR, 0, Vector2(5.0, 8.0)))
	snap.append_array(_row(4, SimConst.K_COP, 0, Vector2(30.0, 8.0)))
	assert_eq(_run(snap, out).size(), 0)
	assert_eq(out.size(), 0)


func test_a_cop_lying_behind_the_roof_gets_a_square_patch() -> void:
	var out: Array[Rect2] = []
	@warning_ignore("return_value_discarded")
	_run(_row(5, SimConst.K_COP, SimConst.M_DEAD, Vector2(5.0, 8.0)), out)
	assert_eq(out.size(), 1)
	var side: float = CityCrowdOcclusion.LYING_HALF_M * 2.0 * PX
	assert_almost_eq(out[0].size.x, side, 0.01)
	assert_almost_eq(out[0].size.y, side, 0.01)

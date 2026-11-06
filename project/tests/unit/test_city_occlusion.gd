extends GutTest

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")


func after_each() -> void:
	ViewMode._shared = _saved


func _occ() -> CityOcclusion:
	var tex: CityTextures = CityTextures.new({"textures": []})
	tex.names.assign(["road", "building_tall", "building_warehouse"])
	tex.size_px.assign([Vector2(256, 256), Vector2(269, 269), Vector2(525, 269)])
	var built: Array[bool] = [false, true, true]
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ChunkLift.TABLE))
	var lift: ChunkLift = ChunkLift.new()
	lift._setup(d, tex, built, "p70")
	var o: CityOcclusion = CityOcclusion.new()
	o._lift = lift
	o._tex = tex
	return o


## rows: (texture id, x m, y m) per command; a 1 in xf[3] marks a shadow command
func _chunk(rows: Array[Vector3], shadow_k: int = -1) -> CityChunk:
	var c: CityChunk = CityChunk.new()
	for i: int in rows.size():
		var r: Vector3 = rows[i]
		@warning_ignore("return_value_discarded")
		c.tex.append(int(r.x))
		for v: float in [r.y, r.z, 0.0, 1.0 if i == shadow_k else 0.0]:
			@warning_ignore("return_value_discarded")
			c.xf.append(v)
	return c


func test_only_buildings_are_collected_with_the_lift_above_them() -> void:
	var o: CityOcclusion = _occ()
	var out: Array[CityOcclusion.Bld] = []
	o._collect(
		_chunk([Vector3(0, 10, 10), Vector3(1, 10, 10), Vector3(1, 12, 10)], 2),
		Vector2(320, 320),
		out
	)
	assert_eq(out.size(), 1, "the road and the shadow command are not occluders")
	var b: CityOcclusion.Bld = out[0]
	var up: float = -ViewMode.shared().lift_px(o._lift.height_m[1]).y
	assert_gt(up, 1.0, "tilt70 lifts the roof")
	assert_eq(b.area.end.y, b.r.end.y, "the drawn area ends at the ground line")
	assert_almost_eq(b.area.position.y, b.r.position.y - up, 0.01, "and rises by the lift")
	o.free()


func test_a_building_in_front_of_a_hit_is_redrawn_after_it() -> void:
	var o: CityOcclusion = _occ()
	var out: Array[CityOcclusion.Bld] = []
	var far: Vector3 = Vector3(1, 10, 30)  # further south, its area clear of the hit
	o._collect(
		_chunk([Vector3(1, 10, 18), Vector3(1, 10, 10), Vector3(1, 60, 10), far]),
		Vector2(320, 320),
		out
	)
	var seen: Dictionary[Vector3, CityOcclusion.Bld] = {}
	for b: CityOcclusion.Bld in out:
		seen[Vector3(b.at.x, b.at.y, b.t)] = b
	var hit: Dictionary[Vector3, bool] = {Vector3(320, 320, 1): true}
	o._pick_draw_set(seen, hit)
	assert_eq(o._draw_set.size(), 2, "the hit and the overlapping building south of it")
	assert_eq(o._draw_set[0].at, Vector2(320, 320), "the hit first")
	assert_eq(o._draw_set[1].at, Vector2(320, 576), "the one in front last")
	o.free()


func test_the_silhouette_is_at_city_scale() -> void:
	var feet: Vector2 = Vector2(100, 200)
	var head: Vector2 = Vector2(100, 140)
	var city: Rect2 = _bounds(CityOcclusion.silhouette(feet, head))
	var arena: Rect2 = _bounds(PropOcclusion.silhouette(feet, head))
	assert_almost_eq(city.size.x, arena.size.x * SimConst.PX_PER_M / Ink.PX_PER_M, 0.5)
	assert_almost_eq(city.get_center().x, feet.x, 0.5, "centred on the feet")


func _bounds(p: PackedVector2Array) -> Rect2:
	var r: Rect2 = Rect2(p[0], Vector2.ZERO)
	for v: Vector2 in p:
		r = r.expand(v)
	return r

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
	o._ink.free()
	o.free()


func test_the_patch_is_the_body_inside_the_drawn_area_only() -> void:
	var area: Rect2 = Rect2(0, 100, 400, 200)  # a lifted roof and face from y 100 to 300
	var feet: Vector2 = Vector2(200, 120)  # behind it: the roof's lift covers the legs
	var head: Vector2 = feet - Vector2(0, CityOcclusion.BODY_H_M * SimConst.PX_PER_M)
	var patch: Rect2 = CityOcclusion.body_patch(feet, head, area)
	assert_eq(patch.position.y, 100.0, "cut at the roof's top edge: the head stays visible")
	assert_almost_eq(patch.end.y, feet.y + Ink.LINE_PX, 0.01, "down to the feet")
	var w: float = CityOcclusion.PATCH_W_M * SimConst.PX_PER_M + Ink.LINE_PX * 2.0
	assert_almost_eq(patch.size.x, w, 0.01, "the body and a held weapon wide")
	var clear: Rect2 = CityOcclusion.body_patch(Vector2(200, 40), Vector2(200, -14), area)
	assert_false(clear.has_area(), "a body far enough north is not covered")


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

extends GutTest
## CityOccluders' query (perf L20, L20b, L20c): the packed positions, the body filter and the
## column index return exactly what the plain scan keeps, in list order.

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")


func after_each() -> void:
	ViewMode._shared = _saved


func _occ() -> CityOccluders:
	var tex: CityTextures = CityTextures.new({"textures": []})
	tex.names.assign(["road", "building_tall", "building_warehouse"])
	tex.size_px.assign([Vector2(256, 256), Vector2(269, 269), Vector2(525, 269)])
	var built: Array[bool] = [false, true, true]
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ChunkLift.TABLE))
	var lift: ChunkLift = ChunkLift.new()
	lift._setup(d, tex, built, "p70")
	return CityOccluders.new(lift)


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


func test_collect_matches_the_reach_rule_over_every_building_in_order() -> void:
	var o: CityOccluders = _occ()
	var rows: Array[Vector3] = []
	for i: int in 300:  # a dense chunk: buildings on a jittered grid over its 128 m
		rows.append(Vector3(1 + i % 2, fmod(i * 7.31, 128.0), fmod(i * 3.77, 128.0)))
	var c: CityChunk = _chunk(rows)
	var reach: float = CityOccluders.REACH_M * SimConst.PX_PER_M
	for q: int in 40:
		var near_px: Vector2 = Vector2(fmod(q * 397.0, 4500.0), fmod(q * 211.0, 4500.0))
		var got: Array[CityOccluders.Bld] = []
		o.collect(c, near_px, got)
		var want: Array[CityOccluders.Bld] = []
		for b: CityOccluders.Bld in o.of_chunk(c):
			if absf(b.at.x - near_px.x) <= reach and absf(b.at.y - near_px.y) <= reach:
				want.append(b)
		assert_eq(got, want, "query %d: the same buildings, in list order" % q)


func test_collect_survives_the_cache_reset() -> void:
	var o: CityOccluders = _occ()
	var counts: Array[int] = []
	for k: int in CityOccluders.CACHE_MAX + 3:  # past CACHE_MAX the cache (and the positions) clear
		var out: Array[CityOccluders.Bld] = []
		o.collect(_chunk([Vector3(1, 10, 10), Vector3(2, 12 + k % 3, 10)]), Vector2(320, 320), out)
		counts.append(out.size())
	assert_eq(counts.count(2), counts.size(), "every chunk, before and after the reset")


func test_the_body_filter_drops_only_buildings_without_a_patch() -> void:
	var rows: Array[Vector3] = []
	for i: int in 300:
		rows.append(Vector3(1 + i % 2, fmod(i * 7.31, 128.0), fmod(i * 3.77, 128.0)))
	for view: String in ["tilt70", "tilt"]:  # combo eases to 55: a taller lift
		ViewMode._shared = ViewMode.of(view)
		var o: CityOccluders = _occ()
		var c: CityChunk = _chunk(rows)
		var feet: Array[Vector2] = []
		for q: int in 60:
			feet.append(Vector2(fmod(q * 397.0 + 13.0, 4096.0), fmod(q * 211.0 + 7.0, 4096.0)))
		var half: float = CityOcclusion.PATCH_W_M * SimConst.PX_PER_M * 0.5 + Ink.LINE_PX
		for k: int in 20:  # bodies at a building's edges, just touching it and a hair either side
			var r: Rect2 = o.of_chunk(c)[k * 13].r
			for e: float in [-0.5, 0.0, 0.5]:
				feet.append(Vector2(r.end.x + half + e, r.get_center().y))
				feet.append(Vector2(r.position.x - half + e, r.end.y + e))
		var counts: Vector2i = _filtered(o, c, feet)
		assert_gt(counts.x, 50, "%s: many bodies meet a building (the compare is not empty)" % view)
		assert_gt(counts.y, 1000, "%s: and the filter skips buildings" % view)


## Per body: the buildings with a patch, unfiltered vs filtered, must match in order. Returns
## (patches, buildings skipped by the filter).
func _filtered(o: CityOccluders, c: CityChunk, feet: Array[Vector2]) -> Vector2i:
	var counts: Vector2i = Vector2i.ZERO
	for at: Vector2 in feet:
		var head: Vector2 = at - Vector2(0.0, CityOcclusion.BODY_H_M * SimConst.PX_PER_M)
		var all: Array[CityOccluders.Bld] = []
		o.collect(c, at, all)
		var got: Array[CityOccluders.Bld] = []
		o.collect(c, at, got, CityOcclusion.body_box(at, head).grow(1.0))
		var want: Array[CityOccluders.Bld] = all.filter(
			func(b: CityOccluders.Bld) -> bool:
				return CityOcclusion.body_patch(at, head, b.area).has_area()
		)
		var kept: Array[CityOccluders.Bld] = got.filter(
			func(b: CityOccluders.Bld) -> bool:
				return CityOcclusion.body_patch(at, head, b.area).has_area()
		)
		assert_eq(kept, want, "body at %s: the same patches, in order" % at)
		counts += Vector2i(want.size(), all.size() - got.size())
	return counts


func test_a_wide_box_reads_each_building_once_over_its_columns() -> void:
	var o: CityOccluders = _occ()
	var rows: Array[Vector3] = []
	for i: int in 300:
		rows.append(Vector3(1 + i % 2, fmod(i * 7.31, 128.0), fmod(i * 3.77, 128.0)))
	var c: CityChunk = _chunk(rows)
	for q: int in 12:  # boxes over 1 to 6 columns, off the column grid
		var box: Rect2 = Rect2(300.0 * q + 37.0, 1500.0, 40.0 + 70.0 * q, 90.0)
		var near_px: Vector2 = box.get_center()
		var all: Array[CityOccluders.Bld] = []
		o.collect(c, near_px, all)
		var got: Array[CityOccluders.Bld] = []
		o.collect(c, near_px, got, box)
		var want: Array[CityOccluders.Bld] = all.filter(
			func(b: CityOccluders.Bld) -> bool:
				return (
					b.r.end.x >= box.position.x
					and b.r.position.x <= box.end.x
					and b.r.end.y >= box.position.y
				)
		)
		assert_eq(got, want, "box %d: every building the rule keeps, once, in list order" % q)
		assert_gt(want.size(), 0, "box %d is not empty" % q)

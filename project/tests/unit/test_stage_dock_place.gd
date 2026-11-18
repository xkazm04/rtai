extends GutTest
## Dock 9 on the city's dock_9 place (n18 districts item 5, --quest1-places): off keeps the whole
## stage on the fitted street; on moves exactly Dock 9's points onto open ground before the
## dock block's door and leaves every other stage point where it was.

var _street: StageLayout = null
var _dock: StageLayout = null


func before_all() -> void:
	_street = StageLayout.shipped(true, 0)
	_dock = StageLayout.shipped(true, 1)


func test_off_is_the_street_layout() -> void:
	assert_null(_street.dock)
	for id: String in _street.spawn_points:
		var p: Vector2 = _street.spawn_points[id]
		assert_eq(StageLayout.shipped(true).spawn_points[id], p, id)


func test_on_resolves_the_dock_9_place() -> void:
	assert_true(_dock.ok())
	assert_not_null(_dock.dock)
	assert_eq(str(_dock.dock.place["id"]), "dock_9")
	assert_eq(str(_dock.dock.place["zone"]), "docks")


func test_dock_points_move_and_the_rest_stay() -> void:
	var door: Vector2 = _dock.dock.place["door"]
	for id: String in _dock.spawn_points:
		var p: Vector2 = _dock.spawn_points[id]
		assert_true(_dock.dock.has(id), "every spawn point is Dock 9's: %s" % id)
		assert_lt(p.distance_to(door), 30.0, id)
	assert_lt(_dock.crates_at.distance_to(door), 30.0)
	for id: String in ["Dock 9 bonded storage", "Dock 9 vault cage"]:
		assert_lt(_dock.marker(id).at.distance_to(door), 30.0, id)
	for id: String in ["Factory Row corner", "Harbor Road", "The Toner Room"]:
		assert_eq(_dock.marker(id).at, _street.marker(id).at, id)
	assert_eq(_dock.rivet_start, _street.rivet_start)
	assert_eq(_dock.hide_at, _street.hide_at)


func test_every_dock_point_stands_on_open_ground() -> void:
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	var pts: Array[Vector2] = [_dock.crates_at]
	pts.append_array(_dock.spawn_points.values())
	pts.append_array(Array(_dock.metal))
	for p: Vector2 in pts:
		var code: int = _cell(gen, p)
		assert_true(
			code != SimConst.C_BUILD and code != SimConst.C_VOID, "%s on cell %d" % [p, code]
		)


func test_the_metal_keeps_its_spacing() -> void:
	assert_eq(_dock.metal.size(), _street.metal.size())
	for i: int in range(1, _dock.metal.size()):
		var a: float = _dock.metal[i].distance_to(_dock.metal[0])
		assert_almost_eq(a, _street.metal[i].distance_to(_street.metal[0]), 0.001)


func _cell(gen: CityGen, p: Vector2) -> int:
	var n: int = SimConst.CHUNK_CELLS
	var c: Vector2i = Vector2i(floori(p.x / n), floori(p.y / n))
	var ch: CityChunk = gen.gen_chunk(c.x, c.y)
	return ch.cells[(floori(p.y) - c.y * n) * n + floori(p.x) - c.x * n]

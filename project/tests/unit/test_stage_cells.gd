extends GutTest
## Quest 1 on the city: the walk cells Rivet collides with and the stage -> city mapping.

## A point on the driving lane of the east-west street quest 1 is laid along (always clear).
const LANE: Vector2 = Vector2(300.5, 268.5)
## The middle of the city block north of that street (a building tile).
const BLOCK: Vector2 = Vector2(292.0, 228.0)

var _cells: StageCells = StageCells.shipped()


func test_the_lane_is_clear_and_a_block_is_solid() -> void:
	assert_true(_cells.clear(LANE, 0.45))
	assert_true(_cells.solid(floori(BLOCK.x), floori(BLOCK.y)))
	assert_eq(_cells.code_at(-1, 5), SimConst.C_VOID, "off the map is void")


func test_push_out_leaves_a_point_clear() -> void:
	# a step's worth of overlap: the circle reaches 0.25 m into the first solid row north
	var row: int = _first_solid_row_north_of(LANE)
	var touching: Vector2 = Vector2(LANE.x, float(row) + 1.2)
	assert_false(_cells.clear(touching, 0.45))
	var out: Vector2 = _cells.push_out(touching, 0.45)
	assert_true(_cells.clear(out, 0.449), "pushed out of %s to %s" % [touching, out])
	assert_eq(_cells.push_out(LANE, 0.45), LANE, "a clear point does not move")


func test_swept_clear_along_the_lane_but_not_into_the_block() -> void:
	assert_true(_cells.swept_clear(LANE, LANE + Vector2(40.0, 0.0), 0.45))
	assert_false(_cells.swept_clear(LANE, BLOCK, 0.45))


func test_city_layout_maps_stage_points() -> void:
	var arena: StageLayout = StageLayout.shipped()
	var city: StageLayout = StageLayout.shipped(true)
	assert_true(city.ok())
	assert_eq(arena.w(Vector2(3.0, 4.0)), Vector2(3.0, 4.0), "the arena is the identity")
	assert_eq(city.rivet_start, city.origin + arena.rivet_start * city.squash)
	var m: String = "The Toner Room"
	assert_eq(city.marker(m).at, city.origin + arena.marker(m).at * city.squash)
	assert_eq(city.metal.size(), arena.metal.size())


func test_city_metal_keeps_its_offsets_around_mertz() -> void:
	var arena: StageLayout = StageLayout.shipped()
	var city: StageLayout = StageLayout.shipped(true)
	var post: String = StageLayout.METAL_ANCHOR
	for i: int in arena.metal.size():
		var was: Vector2 = arena.metal[i] - arena.spawn_points[post]
		var now: Vector2 = city.metal[i] - city.spawn_points[post]
		assert_almost_eq(now, was, Vector2.ONE * 1e-3)


func _first_solid_row_north_of(p: Vector2) -> int:
	var y: int = floori(p.y)
	while not _cells.solid(floori(p.x), y) and y > 0:
		y -= 1
	return y

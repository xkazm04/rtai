extends GutTest

const BOX: Rect2 = Rect2(-2, -1, 4, 2)


func test_each_face_offers_an_outward_ground_point_and_two_peeks() -> void:
	var solids: Dictionary[Rect2, String] = {BOX: "cover_low"}
	for n: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]:
		var face: Vector2 = BOX.get_center() + n * BOX.size * 0.5
		var spots: Array[CoverQuery.CoverSpot] = CoverQuery.near(face + n, 1.0, solids, 0.5, 0.8)
		assert_eq(spots.size(), 1)
		var spot: CoverQuery.CoverSpot = spots[0]
		assert_eq(spot.at, face + n * 0.5)
		assert_eq(spot.normal, n)
		assert_eq(spot.tangent.dot(n), 0.0)
		assert_true(spot.low and spot.protects_shots)
		assert_true(CoverQuery.protects(spot, face - n * 5.0))
		assert_false(CoverQuery.protects(spot, face + n * 5.0))
		var span: float = BOX.size.dot(spot.tangent.abs()) + 1.6
		assert_almost_eq((spot.edge_b - spot.edge_a).dot(spot.tangent), span, 0.00001)


func test_distance_then_geometry_break_ties_regardless_of_dictionary_order() -> void:
	var a: Rect2 = Rect2(-4, -1, 2, 2)
	var b: Rect2 = Rect2(2, -1, 2, 2)
	var c: Rect2 = Rect2(-1, 3, 2, 1)
	var first: Dictionary[Rect2, String] = {a: "cover_high", c: "bench", b: "wall_high"}
	var reverse: Dictionary[Rect2, String] = {b: "wall_high", c: "bench", a: "cover_high"}
	for solids: Dictionary[Rect2, String] in [first, reverse]:
		var spots: Array[CoverQuery.CoverSpot] = CoverQuery.near(Vector2.ZERO, 3.0, solids)
		assert_eq(spots.size(), 3)
		assert_eq(spots[0].box, a)
		assert_eq(spots[1].box, b)
		assert_eq(spots[2].box, c)
		assert_false(spots[0].low)
		assert_false(spots[2].protects_shots)
		assert_false(CoverQuery.protects(spots[2], Vector2(0, 6)))


func test_protection_matches_single_station_even_on_edges_and_corners() -> void:
	var walls: ArenaWalls = ArenaWalls.new()
	walls.boxes.append(BOX)
	var spot: CoverQuery.CoverSpot = CoverQuery.CoverSpot.new()
	spot.protects_shots = true
	spot.box = BOX
	var grid: Array[Vector2] = []
	for y: int in range(-2, 3):
		for x: int in range(-3, 4):
			grid.append(Vector2(x, y))
	for at: Vector2 in grid:
		spot.at = at
		for threat: Vector2 in grid:
			assert_eq(CoverQuery.protects(spot, threat), walls.blocks(threat, at))


func test_ties_compare_size_then_normal_and_never_precede_themselves() -> void:
	var small: CoverQuery.CoverSpot = CoverQuery.CoverSpot.new()
	var large: CoverQuery.CoverSpot = CoverQuery.CoverSpot.new()
	small.box = Rect2(2, 2, 1, 1)
	large.box = Rect2(2, 2, 2, 1)
	assert_true(small.nearer(large))
	assert_false(large.nearer(small))
	large.box = small.box
	small.normal = Vector2.UP
	large.normal = Vector2.DOWN
	assert_true(small.nearer(large))
	assert_false(large.nearer(small))
	assert_false(small.nearer(small))


func test_explicit_zero_peek_keeps_both_ends_at_the_corners() -> void:
	var solids: Dictionary[Rect2, String] = {BOX: "cover_high"}
	var radius: float = 0.5
	var face: Vector2 = Vector2(0, -1)
	var spots: Array[CoverQuery.CoverSpot] = CoverQuery.near(
		face + Vector2.UP, 3, solids, radius, 0
	)
	assert_eq(spots.size(), 1)
	if spots.size() == 1:
		assert_eq(spots[0].at, face + Vector2.UP * radius)
		assert_eq(spots[0].edge_a, spots[0].at + Vector2.LEFT * 2.0)
		assert_eq(spots[0].edge_b, spots[0].at + Vector2.RIGHT * 2.0)

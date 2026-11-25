extends GutTest


func test_full_circle_adds_the_foe_body_radius() -> void:
	var g: GhostN31Geometry = GhostN31Geometry.new(5.0, true, false, 0.9)
	var spot: Vector2 = Vector2(2, 1)
	var foe_r: float = 0.4
	assert_true(g.hits(spot, Vector2.RIGHT, spot + Vector2(0, 5.0 + foe_r - 0.01), foe_r))
	assert_false(g.hits(spot, Vector2.RIGHT, spot + Vector2(0, 5.0 + foe_r + 0.01), foe_r))
	assert_true(g.hits(spot, Vector2.RIGHT, spot + Vector2(-5.0, 0), foe_r), "no facing test")


func test_half_disc_matches_main() -> void:
	var g: GhostN31Geometry = GhostN31Geometry.shipped(0.9, 4.0)
	var spot: Vector2 = Vector2.ZERO
	assert_true(g.hits(spot, Vector2.RIGHT, Vector2(0.9 + 3.99, 0), 0.4))
	assert_false(g.hits(spot, Vector2.RIGHT, Vector2(0.9 + 4.01, 0), 0.4), "body not added")
	assert_false(g.hits(spot, Vector2.RIGHT, Vector2(-0.01, 0), 0.4), "behind the spot")


func test_centre_on_rivet_only_for_the_full_circle() -> void:
	var rivet: Vector2 = Vector2(-3, 0)
	var spot: Vector2 = Vector2(4, 0)
	assert_eq(GhostN31Geometry.new(5.0, true, true, 0.9).centre(spot, rivet), rivet)
	assert_eq(GhostN31Geometry.new(5.0, true, false, 0.9).centre(spot, rivet), spot)
	assert_eq(GhostN31Geometry.new(5.0, false, true, 0.9).centre(spot, rivet), spot)


func test_densest_picks_the_tight_group() -> void:
	var points: Array[Vector2] = [
		Vector2(0, 0), Vector2(20, 0), Vector2(0.5, 0), Vector2(0, 0.5), Vector2(-20, 3)
	]
	var picked: Array[int] = GhostN31Shapes.densest(points, 3)
	picked.sort()
	assert_eq(picked, [0, 2, 3] as Array[int])
	assert_true(GhostN31Shapes.densest(points, 6).is_empty())


func test_shape_round_trips_through_parse() -> void:
	var points: Array[Vector2] = [Vector2(1, 1), Vector2(3, 1), Vector2(2, 4), Vector2(2, -2)]
	var row: Dictionary = GhostN31Shapes.shape(points, [0, 1, 2, 3] as Array[int], Vector2(-6, 1))
	var text: String = JSON.stringify({"schema": GhostN31Shapes.SCHEMA, "sizes": {"4": [row]}})
	var parsed: Dictionary = GhostN31Shapes.parse(text)
	var back: Dictionary = parsed[4][0]
	var rivet: Vector2 = back.rivet
	assert_eq(rivet, Vector2(-8, 0))
	var foes: Array[Vector2] = back.foes
	assert_eq(foes[0], Vector2(-1, 0))
	assert_true(GhostN31Shapes.parse('{"schema": "other"}').is_empty())


func test_spread_keeps_first_and_last() -> void:
	assert_eq(GhostN31Shapes.spread([1, 2, 3, 4, 5, 6, 7], 3), [1, 4, 7])
	assert_eq(GhostN31Shapes.spread([1, 2], 5), [1, 2])

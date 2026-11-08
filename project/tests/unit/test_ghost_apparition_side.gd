extends GutTest
## n10 rivet: a speaking ghost stands at Rivet's left. Under a tilt a left pointing up the
## screen sat on his 1.65 m figure (quest 1, the Toner Room: the voice over his head).
## Planted fault: the old `fwd.orthogonal()` fails test_tilted_facing_right_clears_his_figure.


func after_each() -> void:
	GhostApparition.clear_figure = true


func test_tilted_facing_right_clears_his_figure() -> void:
	assert_eq(GhostApparition.side_of(Vector2.RIGHT, true), Vector2.LEFT)


func test_tilted_facing_left_keeps_the_spot_below_him() -> void:
	var side: Vector2 = GhostApparition.side_of(Vector2.LEFT, true)
	assert_almost_eq(side, Vector2.DOWN, Vector2.ONE * 0.001)


func test_tilted_facing_up_keeps_his_own_left() -> void:
	var side: Vector2 = GhostApparition.side_of(Vector2.UP, true)
	assert_almost_eq(side, Vector2.LEFT, Vector2.ONE * 0.001)


func test_the_top_view_keeps_the_facings_left() -> void:
	var side: Vector2 = GhostApparition.side_of(Vector2.RIGHT, false)
	assert_almost_eq(side, Vector2.UP, Vector2.ONE * 0.001)


func test_the_flag_brings_back_the_facings_left() -> void:
	GhostApparition.clear_figure = false
	var side: Vector2 = GhostApparition.side_of(Vector2.RIGHT, true)
	assert_almost_eq(side, Vector2.UP, Vector2.ONE * 0.001)

extends GutTest
## View lab: PropOcclusion patches the part of a body behind a prop that the prop's drawn area
## (its face and lifted top) covers, and nothing for a body clear of it.

const AREA: Rect2 = Rect2(0.0, -60.0, 200.0, 100.0)


func test_a_body_behind_a_wall_is_patched_inside_the_wall_only() -> void:
	var patch: Rect2 = PropOcclusion.body_patch(Vector2(100.0, -10.0), Vector2(100.0, -90.0), AREA)
	assert_true(patch.has_area())
	assert_true(AREA.encloses(patch), "never wider than the prop's drawn area")
	assert_almost_eq(patch.position.y, AREA.position.y, 0.001, "the head over the top stays")


func test_a_body_clear_of_the_wall_is_not_patched() -> void:
	var patch: Rect2 = PropOcclusion.body_patch(Vector2(400.0, -10.0), Vector2(400.0, -90.0), AREA)
	assert_false(patch.has_area())


func test_flat_views_make_no_occluder() -> void:
	assert_false(ViewMode.of("top").occlude, "attach() returns before making a node")
	assert_false(ViewMode.of("top_lift").occlude)
	assert_true(ViewMode.of("tilt").occlude)
	assert_false(ViewMode.of("tilt_noocclude").occlude)


func test_the_silhouette_is_as_wide_as_a_body_however_short() -> void:
	for h: float in [20.0, 80.0]:
		var fig: PackedVector2Array = PropOcclusion.silhouette(Vector2.ZERO, Vector2(0.0, -h))
		var w: float = 0.0
		for q: Vector2 in fig:
			w = maxf(w, absf(q.x) * 2.0)
		assert_almost_eq(w, PropOcclusion.SIL_W_M * Ink.PX_PER_M, 0.01)

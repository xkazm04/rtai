extends GutTest


func test_flat_view_keeps_dent_just_over_the_actors() -> void:
	assert_eq(GhostAttackViews.dent_dz(ViewMode.of("top")), 1)
	assert_eq(GhostAttackViews.dent_dz(null), 1)


func test_card_view_draws_dent_over_the_vehicles_band() -> void:
	var dz: int = GhostAttackViews.dent_dz(ViewMode.of("combo"))
	assert_gt(RenderLayers.z(&"actors") + dz, RenderLayers.z(&"vehicles"))
	assert_lt(RenderLayers.z(&"actors") + dz, RenderLayers.z(&"roof_occluders"))

extends GutTest
## The D5 twin of the crowd atlas (d5-cast, 2026-11-03): same layout and world cell as the D4 atlas,
## baked at or past the D5 tier's full zoom with its own overlay materials at full amount.


func test_d5_twin_keeps_the_world_cell() -> void:
	var d4: CrowdAtlas = CrowdAtlas.new()
	var d5: CrowdAtlas = CrowdAtlas.make_d5()
	assert_true(d5.d5)
	assert_false(d4.d5)
	assert_almost_eq(d5.cell_px / d5.bake_zoom, d4.cell_px / d4.bake_zoom, 0.001)
	assert_almost_eq(d5.cell_px / d5.bake_zoom, CrowdAtlas.cell_world_px(), 0.001)


func test_d5_twin_bakes_with_the_tier_at_full() -> void:
	var d5: CrowdAtlas = CrowdAtlas.make_d5()
	assert_true(d5.bake_zoom >= RigDetail.FULL_ZOOM)
	assert_gt(d5.cell_px, CrowdAtlas.CELL_PX)


func test_bake_materials_ignore_the_live_view() -> void:
	var mats: Array[ShaderMaterial] = CrowdBakeDetail.materials(2.0)
	assert_eq(mats.size(), 2)
	var amount: float = mats[0].get_shader_parameter("amount")
	assert_eq(amount, 1.0)
	var tint: float = mats[1].get_shader_parameter("tint")
	assert_eq(tint, 1.0)


func test_people_layer_shows_d4_until_the_twin_is_baked() -> void:
	var rigs: CharacterRigs = CharacterRigs.new()
	var was: bool = RigDetail.active
	RigDetail.active = true
	assert_eq(rigs.crowd_texture(), rigs.atlas.texture)
	RigDetail.active = was
	rigs.free()

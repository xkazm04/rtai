extends GutTest


func test_the_standing_stage_leaves_headroom_for_the_tallest_walker() -> void:
	var saved: ViewMode = ViewMode.shared()
	ViewMode.select("tilt70")
	var baker: CrowdBaker = autofree(CrowdBaker.new())
	var headroom: float = baker._centre(0).y
	var tallest: float = StreetWalkerCards.HEIGHT_M * CharacterRigs.PX_PER_M
	tallest *= 1.0 + StreetCrowdCards.SCALE_VAR
	assert_gt(headroom, tallest + StreetWalkerCards.BOB_PX, "cap, raised gait and clear border")
	ViewMode._shared = saved


func test_quad_cancels_the_capture_origin_and_projection() -> void:
	var atlas: CrowdAtlas = CrowdAtlas.new()
	for view_id: String in ["top", "tilt70", "tilt"]:
		atlas.bake_view = ViewMode.of(view_id)
		var m: ShaderMaterial = atlas.crowd_material()
		for clip: CrowdAtlas.Clip in [CrowdAtlas.Clip.IDLE, CrowdAtlas.Clip.DEATH]:
			var fall: bool = clip == CrowdAtlas.Clip.DEATH
			var shift: Vector2 = m.get_shader_parameter("fall_shift" if fall else "standing_shift")
			var pixel: Vector2 = Vector2(CrowdAtlas.anchor(atlas.bake_view, clip))
			assert_eq(pixel + shift * CrowdAtlas.CELL_PX, Vector2(CrowdAtlas.CENTRE))
			var squeeze: float = m.get_shader_parameter("fall_x") if fall else 1.0
			var ground: float = m.get_shader_parameter("ground_k")
			var zoom: Vector2 = CrowdAtlas.bake_scale(atlas.bake_view, clip)
			var world: Vector2 = zoom * CrowdAtlas.cell_world_px() / Vector2(squeeze, ground)
			assert_almost_eq(world, Vector2.ONE * CrowdAtlas.CELL_PX, Vector2.ONE * 0.0001)
	assert_lt(CrowdAtlas.CELL_PX * CrowdAtlas.CELL_PX, 2 * 128 * 128, "old tile memory x2")


func test_every_city_slot_recovers_its_live_walker_scale() -> void:
	var atlas: CrowdAtlas = CrowdAtlas.new()
	atlas.bake_view = ViewMode.of("tilt70")
	var mat: ShaderMaterial = atlas.crowd_material()
	var scales: PackedFloat32Array = mat.get_shader_parameter("body_scales")
	assert_eq(scales.size(), SimConst.CAP)
	for slot: int in scales.size():
		var drawn: float = scales[slot] * StreetCrowdCards.body_scale(-1)
		assert_almost_eq(drawn, StreetCrowdCards.body_scale(slot), 0.000001, "slot %d" % slot)

extends GutTest


func test_projection_tracks_the_takeoff_apex_and_touchdown() -> void:
	var vault: PlayerVault = PlayerMotion.shipped().vault
	var flat: ViewMode = ViewMode.of("top")
	for name_v: String in ["tilt", "tilt70", "combo"]:
		var view: ViewMode = ViewMode.of(name_v)
		for frame: int in [-1, vault.ticks - 1]:
			vault.frame = frame
			assert_eq(VaultView.projection(vault, view), Transform2D.IDENTITY)
			assert_eq(VaultView.projection(vault, flat), Transform2D.IDENTITY)
		vault.frame = (vault.ticks >> 1) - 1
		var apex: Transform2D = VaultView.projection(vault, view)
		assert_eq(apex.origin, view.lift_px(vault.apex_m))
		assert_eq(apex.get_scale(), Vector2.ONE)
		var top: Transform2D = VaultView.projection(vault, flat)
		assert_eq(top.origin, Vector2.ZERO)
		assert_almost_eq(top.get_scale().x, 1.12, 0.00001)


func test_tuck_hides_the_weapon_once_and_preserves_city_shadow_ground_points() -> void:
	var layer: Node2D = autofree(Node2D.new())
	var rigs: CharacterRigs = CharacterRigs.new()
	var shadow: RigCastShadows = RigCastShadows.new()
	layer.add_child(rigs)
	layer.add_child(shadow)
	var vault: PlayerVault = PlayerMotion.shipped().vault
	var at: Vector2 = Vector2(527.0, 508.0) * SimConst.PX_PER_M
	@warning_ignore("return_value_discarded")
	rigs.feed.put(0, 1, BodyPlan.Kind.RIVET, at, Vector2.ZERO)
	rigs.feed.flags[0] = RigFeed.Flag.GUN_OUT
	vault.frame = 0
	VaultView.feed(rigs, vault)
	assert_eq(rigs.feed.clip[0], int(RigClips.Clip.ROLL))
	assert_almost_eq(rigs.feed.clip_arg[0], vault.ticks * SimClock.TICK_DT, 0.000001)
	assert_false(rigs.feed.has_flag(0, RigFeed.Flag.GUN_OUT))
	assert_eq(shadow.to_local(at), Vector2.ZERO)
	var feet: Vector2 = at + Vector2(32.0, 0.0)
	assert_eq(shadow.to_global(shadow.to_local(feet)), feet)
	vault.frame = 8
	rigs.feed.clip[0] = RigClips.Clip.NONE
	VaultView.feed(rigs, vault)
	assert_eq(rigs.feed.clip[0], int(RigClips.Clip.NONE))
	vault.frame = -1
	VaultView.feed(rigs, vault)
	assert_eq(shadow.position, Vector2.ZERO)
	rigs.rest.free()
	rigs.pool().free()

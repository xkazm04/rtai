extends GutTest
## d8 chars: Tonnage stands on its legs under a tilted view (crown, head and hoses lifted by their
## heights, feet planted) and is exactly the flat rig straight down.

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared
	GhostLook.override_for_test(GhostLook.LEGACY)


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _saved


func _rig(view: String) -> TonnageRig:
	ViewMode._shared = ViewMode.of(view)
	var rig: TonnageRig = TonnageRig.new()
	add_child_autofree(rig)
	rig.pose()
	return rig


func test_straight_down_the_parts_sit_where_they_always_did() -> void:
	var rig: TonnageRig = _rig("top")
	assert_eq(rig._crown.position, Vector2.ZERO)
	assert_eq(rig._head.position, Vector2(1.12, 0.0) * TonnageRig.PX_PER_M)
	assert_eq(rig._hoses.position, Vector2(-0.55, 0.0) * TonnageRig.PX_PER_M)


func test_under_tilt_the_body_rises_and_the_feet_stay_planted() -> void:
	var flat: TonnageRig = _rig("top")
	var feet: Array[Vector2] = []
	for f: Sprite2D in flat._feet:
		feet.append(f.position)
	var rig: TonnageRig = _rig("tilt")
	assert_lt(rig._crown.position.y, -10.0, "the crown rides up the screen")
	assert_lt(rig._hoses.position.y, rig._crown.position.y, "the hoses ride above the crown")
	for i: int in 4:
		assert_eq(rig._feet[i].position, feet[i], "a standing foot stays on its ground point")


func test_spectral_tilts_show_one_custom_rest_cell() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for view: String in ["tilt70", "tilt"]:
		var rig: TonnageRig = _rig(view)
		assert_true(rig.drawn.own_body)
		assert_null(rig.drawn.sprite())
		rig.drawn.feed(0, -1, 72)
		var sheets: Array[String] = []
		for spr: Sprite2D in rig.find_children("ghost_drawn*", "Sprite2D", true, false):
			if spr.is_visible_in_tree():
				sheets.append(spr.texture.resource_path)
		var path: String = GhostDrawn.path_of(ViewMode.shared().art, "tonnage", "spectral_pose")
		assert_eq(sheets, [path], view)


func test_spectral_light_tracks_the_flipped_cell_through_a_slam() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var rig: TonnageRig = _rig("tilt70")
	var spectral: TonnageSpectral = rig._spectral
	rig.rotation = PI
	for age: int in [-1, 0, GhostDrawn.CUT_TICKS]:
		spectral._sample.stomp_age = age
		spectral.pose.step(spectral._sample, 1)
		spectral._present()
		var ink: Sprite2D = spectral._cell
		var light: Sprite2D = spectral._cell_light
		assert_eq(light.get_parent(), ink)
		assert_eq(light.texture, ink.texture)
		assert_eq(light.frame_coords, ink.frame_coords)
		assert_eq(light.offset, ink.offset)
		assert_eq(light.flip_h, ink.flip_h)
		assert_eq(light.global_transform, ink.global_transform)
		assert_almost_eq(ink.modulate.a, 0.88 if age < 0 else 0.55, 0.0001)
		assert_eq(
			(light.material as CanvasItemMaterial).blend_mode, CanvasItemMaterial.BLEND_MODE_ADD
		)


func test_spectral_top_parts_share_the_pose_opacity_and_additive_light() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var rig: TonnageRig = _rig("top")
	var spectral: TonnageSpectral = rig._spectral
	spectral._sample.stomp_age = 0
	spectral.pose.step(spectral._sample, 1)
	spectral._present()
	assert_almost_eq(spectral._parts.modulate.a, 0.55, 0.0001)
	assert_lt(spectral._glow.z_index, RenderLayers.z(&"blood"))
	for part: Sprite2D in spectral._parts.get_children():
		var light: Sprite2D = part.get_child(0) as Sprite2D
		assert_eq(light.texture, part.texture)
		assert_eq(light.global_transform, part.global_transform)
		assert_eq(
			(light.material as CanvasItemMaterial).blend_mode, CanvasItemMaterial.BLEND_MODE_ADD
		)


func test_chest_vapour_hangs_and_sways_only_on_the_spectral_body() -> void:
	var legacy: TonnageRig = _rig("tilt70")
	assert_false(legacy.drawn.own_body)
	assert_null(legacy.find_child("ChestVapour", true, false))
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var rig: TonnageRig = _rig("tilt70")
	var tail: GhostTail = rig.find_child("ChestVapour", true, false) as GhostTail
	assert_not_null(tail)
	if tail == null:
		return
	var points: PackedVector2Array = tail.points()
	assert_gt(points[-1].y, points[0].y)
	assert_lt(tail.get_index(), rig._spectral._cell.get_index())
	assert_lt(tail.get_index(), rig._spectral._parts.get_index())
	rig.advance(12.0 * SimClock.TICK_DT)
	assert_ne(tail.points()[6], points[6])


func test_spectral_hud_face_uses_the_front_carry_cut() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var face: Texture2D = GhostChipFace.face(&"tonnage")
	assert_eq(face.resource_path, GhostChipFace.DIR + "tonnage_spectral.png")


func test_profile_recoil_keeps_the_cruise_footprint_at_both_pitches() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for view: String in ["tilt70", "tilt"]:
		var rig: TonnageRig = _rig(view)
		var body: TonnageSpectral = rig._spectral
		body._sample.velocity = Vector2.RIGHT * 2.1
		body.pose.step(body._sample, 1)
		body._present()
		var cruise: Vector2 = body._cell.global_scale
		assert_eq(body._cell.frame_coords, Vector2i(1, 2))
		body._sample.hurt_age = 0
		body.pose.step(body._sample, 1)
		body._present()
		assert_eq(body._cell.frame_coords, Vector2i(3, 2))
		var fitted: Vector2 = body._cell.global_scale / cruise
		var cruise_px: Vector2 = Vector2(189, 209) if view == "tilt70" else Vector2(193, 213)
		var recoil_px: Vector2 = Vector2(213, 178) if view == "tilt70" else Vector2(222, 184)
		assert_almost_eq(recoil_px * fitted, cruise_px, Vector2.ONE * 0.02)

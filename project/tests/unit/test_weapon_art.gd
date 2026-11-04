extends GutTest
## features/combat/weapons/art: every weapon row loads its parts at the authored size, the grip
## and muzzle points sit inside the held part with the muzzle forward, make_held() puts the grip
## on the node origin at the drawn length, the fx frames resolve, unknown ids draw a placeholder.

const CORE: Array[StringName] = [
	&"pistol", &"machine_pistol", &"rocket_launcher", &"flamethrower", &"electro_gun", &"molotov"
]


func test_core_six_have_art_at_their_size() -> void:
	var art: WeaponArt = WeaponArt.new()
	for id: StringName in CORE:
		assert_true(art.has(id), "row %s" % id)
		var tex: Texture2D = art.held_texture(id)
		assert_gt(tex.get_width(), 64, "%s held is real art" % id)
		assert_gt(art.pickup_texture(id).get_width(), 64, "%s pickup" % id)
		assert_gt(art.icon_texture(id).get_width(), 64, "%s icon" % id)


func test_grip_and_muzzle_inside_the_part_muzzle_forward() -> void:
	var art: WeaponArt = WeaponArt.new()
	for id: StringName in CORE:
		var size: Vector2 = art.held_texture(id).get_size()
		var g: Vector2 = art.grip_px(id)
		var m: Vector2 = art.muzzle_px(id)
		assert_true(Rect2(Vector2.ZERO, size).has_point(g), "%s grip inside" % id)
		assert_true(Rect2(Vector2.ZERO, size).has_point(m), "%s muzzle inside" % id)
		assert_gt(art.muzzle_m(id).x, 0.05, "%s muzzle ahead of the grip" % id)
		assert_lt(absf(art.muzzle_m(id).y), 0.1, "%s muzzle on the bore line" % id)


func test_make_held_origin_is_the_grip_at_drawn_length() -> void:
	var art: WeaponArt = WeaponArt.new()
	var s: Sprite2D = art.make_held(&"pistol")
	assert_false(s.centered)
	assert_eq(s.offset, -art.grip_px(&"pistol"))
	var span_px: float = (art.muzzle_px(&"pistol").x - 0.0) * s.scale.x
	assert_lt(span_px, art.length_m(&"pistol") * WeaponArt.WORLD_PX_PER_M + 2.0)
	assert_almost_eq(art.rig_scale(&"pistol"), s.scale.x * 10.0, 0.0001)
	s.free()


func test_all_sixteen_have_held_art_with_the_muzzle_forward() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_eq(art.ids().size(), 16)
	for id: StringName in art.ids():
		assert_gt(art.held_texture(id).get_width(), 64, "%s held" % id)
		assert_gt(art.muzzle_m(id).x, 0.2, "%s tip ahead of the grip" % id)


func test_rocket_is_longer_than_the_pistol() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_gt(art.length_m(&"rocket_launcher"), 2.0 * art.length_m(&"pistol"))
	assert_eq(art.grip_class(&"rocket_launcher"), &"shoulder")
	assert_not_null(art.part_texture(&"flamethrower", "tank"))
	assert_null(art.part_texture(&"pistol", "tank"))


func test_fx_frames_resolve() -> void:
	var art: WeaponArt = WeaponArt.new()
	for id: StringName in CORE:
		if art.grip_class(id) == &"thrown":  # a throw has no muzzle flash (the wick burns)
			assert_eq(art.muzzle_fx(id), &"", "%s has no flash" % id)
		else:
			assert_eq(art.fx_frames(art.muzzle_fx(id)).size(), 3, "%s muzzle frames" % id)
		assert_gt(art.fx_frames(art.projectile_fx(id)).size(), 0, "%s projectile" % id)
	assert_eq(art.fx_frames(&"casing").size(), 1)
	assert_gt(art.fx_anchor(&"flash_pistol").x, 0.0)
	assert_almost_eq(art.fx_scale(), art.fx_draw_scale * 0.1, 0.0001)


func test_unknown_id_draws_a_placeholder() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_false(art.has(&"no_such_gun"))
	var tex: Texture2D = art.held_texture(&"no_such_gun")
	assert_not_null(tex)
	assert_eq(tex.get_size(), Vector2(32, 8))
	assert_false(art.has(&"no_such_gun"), "a miss does not add a row")


func test_every_ai_weapon_png_has_a_provenance_line() -> void:
	var root: String = ProjectSettings.globalize_path("res://").path_join("..").simplify_path()
	var log_path: String = root.path_join("steam/ai-provenance/2026-11.jsonl")
	var text: String = FileAccess.get_file_as_string(log_path)
	var missing: Array[String] = []
	var base: String = "res://features/combat/weapons/art"
	for sub: String in DirAccess.get_directories_at(base):
		if sub == "fx":
			continue  # procedural (tools/art/weapon_fx.py), not AI
		for file: String in DirAccess.get_files_at(base.path_join(sub)):
			var rel: String = "project/features/combat/weapons/art/%s/%s" % [sub, file]
			if file.get_extension() == "png" and not text.contains('"file": "%s"' % rel):
				missing.append(rel)
	assert_eq(missing, [] as Array[String], "weapon art without a provenance line")


func test_impact_cells_and_gore_stickers_resolve() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_eq(art.fx_frames(&"blast").size(), 4, "rocket blast frames")
	assert_eq(art.fx_frames(&"spark").size(), 3, "electro spark frames")
	assert_eq(art.fx_frames(&"scorch").size(), 1, "scorch decal")
	assert_eq(art.projectile_fx(&"gloria"), &"nail")
	var top: Array[StringName] = [&"gore_xray_top", &"gore_xray_top_jolt", &"gore_charred_top"]
	top.append(&"gore_charred_top_slump")
	for g: StringName in top + [&"gore_stump_round", &"gore_charred", &"gore_ash", &"gore_splash"]:
		assert_eq(art.fx_frames(g).size(), 1, "%s sticker" % g)
	assert_gt(art.fx_anchor(&"blast").x, 0.0)


func test_a_bottle_burst_is_told_from_a_rocket_blast_by_its_fire_patch() -> void:
	var areas: FightAreas = FightAreas.new()
	areas.add_patch(Vector2(4.0, 2.0), 2.2, 300, 10.0)
	assert_true(WeaponFxArt.is_fire_burst(Vector3(4.0, 2.0, 2.2), areas), "molotov: patch = splash")
	assert_false(WeaponFxArt.is_fire_burst(Vector3(9.0, 2.0, 3.5), areas), "rocket elsewhere")
	assert_false(WeaponFxArt.is_fire_burst(Vector3(4.0, 2.0, 12.0), areas), "nuke: patch 6 != 12")
	assert_false(WeaponFxArt.is_fire_burst(Vector3(4.0, 2.0, 2.2), null), "no areas: rocket look")


func test_magazine_guns_have_a_mag_part_held_inside_it() -> void:
	var art: WeaponArt = WeaponArt.new()
	for id: StringName in [&"pistol", &"machine_pistol", &"plasma_rifle", &"hand_cannon"]:
		var mag: Sprite2D = art.make_held(id, "mag")
		assert_not_null(mag, "%s has a mag" % id)
		if mag == null:
			continue
		var size: Vector2 = mag.texture.get_size()
		assert_gt(size.x, 40.0, "%s mag is real art, not the placeholder" % id)
		var grip: Vector2 = -mag.offset
		assert_true(
			Rect2(Vector2.ONE, size - Vector2.ONE * 2.0).has_point(grip), "%s grip inside" % id
		)
		assert_eq(mag.scale, Vector2.ONE * art.world_scale(id), "%s mag at the held scale" % id)
		mag.free()
	assert_null(art.make_held(&"rocket_launcher", "mag"), "a rocket tube has no magazine")


func test_held_part_has_a_paper_rim_under_it_unless_off() -> void:
	var art: WeaponArt = WeaponArt.new()
	var was: bool = WeaponArt.rim
	WeaponArt.rim = true
	var held: Sprite2D = art.make_held(&"pistol")
	assert_eq(held.get_child_count(), WeaponArt.RIM_DIRS, "one cream copy per direction")
	var rim: Sprite2D = held.get_child(0) as Sprite2D
	assert_eq(rim.z_index, -1, "under the part")
	assert_almost_eq(rim.position.length() * held.scale.x, WeaponArt.RIM_WORLD_PX, 0.001)
	held.free()
	WeaponArt.rim = false
	held = art.make_held(&"pistol")
	assert_eq(held.get_child_count(), 0, "--weapon-rim=off: no rim")
	held.free()
	WeaponArt.rim = was


func test_rocket_tubes_have_an_empty_part_on_the_same_grip() -> void:
	var art: WeaponArt = WeaponArt.new()
	for id: StringName in [&"rocket_launcher", &"mini_nuke"]:
		var held: Sprite2D = art.make_held(id)
		var empty: Sprite2D = art.make_held(id, "empty")
		assert_not_null(empty, "%s has an empty tube" % id)
		if empty == null:
			held.free()
			continue
		assert_eq(empty.texture.get_size(), held.texture.get_size(), "%s same canvas" % id)
		assert_eq(empty.offset, held.offset, "%s empty tube on the held grip" % id)
		assert_eq(empty.scale, held.scale, "%s empty tube at the held scale" % id)
		held.free()
		empty.free()
	assert_null(art.make_held(&"pistol", "empty"), "a pistol has no empty tube")


func test_hand_cannon_fires_a_fatter_round_than_the_pistol() -> void:
	var art: WeaponArt = WeaponArt.new()
	var pistol_k: float = art.round_k.get(&"pistol", 1.0)
	var cannon_k: float = art.round_k.get(&"hand_cannon", 1.0)
	assert_eq(pistol_k, 1.0, "rows without projectile_k draw at 1")
	assert_gt(cannon_k, 1.2, "the hand cannon's slug")
	var nuke_k: float = art.round_k.get(&"mini_nuke", 1.0)
	assert_gt(nuke_k, 1.2, "the mini-nuke's shell")
	assert_eq(
		art.projectile_fx(&"mini_nuke"), &"nuke_shell", "the mini-nuke lobs its own bomb cell"
	)
	assert_true(
		WeaponFxShell.SHELLS.has(art.projectile_fx(&"mini_nuke")), "drawn as a lobbed shell"
	)
	assert_gt(art.fx_frames(&"nuke_shell").size(), 0, "the bomb cell resolves")


func test_the_thrown_bottle_casts_the_shell_ellipse_at_bottle_size() -> void:
	var across_m: float = WeaponFxShell.SHADOW_M.x * 2.0 * WeaponFxArt.BOTTLE_SHADOW_K
	assert_between(across_m, 0.6, 1.2, "a bottle-sized ink ellipse, not the old 28 px dash")
	assert_lt(WeaponFxArt.BOTTLE_SHADOW_K, 1.0, "smaller than the shell's own shadow")


func test_the_rocket_blast_tears_into_smoke_wisps_after_the_ring() -> void:
	var ci: Node2D = autofree(Node2D.new())
	var b: Vector3 = Vector3(4.0, 2.0, 3.5)
	assert_false(WeaponFxShell.wisps(ci, b, WeaponFxShell.WISP_FROM - 1), "the sheet plays first")
	assert_true(WeaponFxShell.wisps(ci, b, FightAreas.VFX_KEEP_TICKS), "spent: drawn as nothing")
	assert_lt(WeaponFxShell.WISP_FROM, FightAreas.VFX_KEEP_TICKS, "the tail has ticks to live")
	WeaponFxShell.wisp_tail = false
	assert_false(WeaponFxShell.wisps(ci, b, WeaponFxShell.WISP_FROM + 2), "ring tail: the before")
	WeaponFxShell.wisp_tail = true


func test_the_electro_arc_has_a_bold_ink_stroke_under_its_paper() -> void:
	assert_true(WeaponFxElectro.arc_ink, "on by default (--arc-ink=off is the before)")
	assert_gt(WeaponFxElectro.ARC_INK_M, 0.0, "the ink outline is thickened round the paper arc")
	assert_eq(WeaponArt.new().fx_frames(&"arc").size(), 3, "three arc frames to ink")

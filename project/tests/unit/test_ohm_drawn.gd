extends GutTest


func test_jar_twin_tracks_the_shown_cell_on_both_sheets_and_the_mirrored_side() -> void:
	var sprite: Sprite2D = add_child_autofree(Sprite2D.new())
	var jars: OhmJars = OhmJars.new()
	sprite.add_child(jars)
	sprite.transform = Transform2D(0.17, Vector2(0.4, 0.45), 0.03, Vector2(96, 41))
	sprite.centered = false
	sprite.vframes = 5
	for pitch: String in ["p70", "p55"]:
		for kind: String in ["hover", "act"]:
			var path: String = "res://features/souls/art/view/%s/ohm_spec_%s" % [pitch, kind]
			sprite.texture = load(path + ".png") as Texture2D
			var mask: Texture2D = load(path + "_jars.png") as Texture2D
			sprite.hframes = 2 if kind == "hover" else 4
			sprite.offset = Vector2(-159, -227) if pitch == "p70" else Vector2(-177, -264)
			for flip: bool in [false, true]:
				sprite.flip_h = flip
				for cell: int in sprite.hframes * sprite.vframes:
					sprite.frame = cell
					jars.match_cell(sprite, mask)
					assert_eq(jars.texture, mask)
					assert_eq(jars.frame_coords, sprite.frame_coords)
					assert_eq(jars.flip_h, flip)
					assert_eq(jars.offset, sprite.offset)
					assert_eq(jars.global_transform, sprite.global_transform)


func test_authored_hover_keeps_its_hem_and_jar_twin_at_both_tilts() -> void:
	var saved: ViewMode = ViewMode._shared
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for pitch: String in ["tilt70", "tilt"]:
		ViewMode.select(pitch)
		var rig: OhmRig = OhmRig.new()
		var flight: GhostFlight = add_child_autofree(GhostFlight.make(OhmStage.ID))
		rig.drawn.flight = flight
		flight.mount(rig)
		flight.step(Vector2.ZERO, 0.0, 1)
		rig.tick = 36
		rig.pose()
		var shown: Sprite2D = rig.drawn.sprite()
		assert_eq(shown.texture.resource_path.get_file(), "ohm_spec_hover.png")
		assert_null(shown.material)
		assert_eq(shown.hframes, 2)
		assert_almost_eq(shown.global_rotation, deg_to_rad(3.0), 0.00001)
		for child: Node in shown.get_children():
			if child is OhmJars:
				assert_eq((child as OhmJars).global_transform, shown.global_transform)
	GhostLook.reset_for_test()
	ViewMode._shared = saved

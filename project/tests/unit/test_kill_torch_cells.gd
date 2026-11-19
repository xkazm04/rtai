extends GutTest
## Lane kills-new (n16): the molotov's own drawn cells (molotov_torch). The three cops kneel, hunch,
## lie face down burning and lie charred, turned along the run; the suit ped (his kneeling frames
## refused by the image filter) keeps the placeholder; the coded tongues stay over the drawn
## flames, lower; the p55 stitch and pin cells exist for the three cops.


func test_the_three_cops_burn_in_their_own_drawn_frames() -> void:
	var e: KillTrackRows.Extra = KillTrackRows.of(&"molotov_torch")
	assert_eq(e.cells_at.size(), 4, "kneeling, hunched, face down burning, charred")
	for kind: String in ["cop_patrol", "cop_riot", "swat"]:
		var row: String = {
			"cop_patrol": "cop/head_cap", "cop_riot": "cop/head_helmet", "swat": "cop/head_swat"
		}[kind]
		for art: String in ["p55", "p70"]:
			var path: String = "%s/%s_molotov_torch.png" % [art, kind]
			assert_eq(KillDeathCells.path_of(e, art, row), path)
			assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + path), path)
	assert_eq(KillDeathCells.path_of(e, "p70", "ped/head_hair"), "", "the suit keeps the fall")
	assert_eq(KillDeathCells.frame_at(e, roundi(e.num("cells_at", 0.0))), 2, "lies as he burns")
	assert_lt(e.cells_at[3], roundi(e.num("burn_to", 0.0)), "charred while the last flames die")


func test_the_drawn_frames_lie_along_the_run() -> void:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.dir = Vector2.RIGHT
	d.extra = KillTrackRows.of(&"molotov_torch")
	for frame: int in 4:
		var look: Vector2 = Vector2.from_angle(KillDeathCells.face_of(d, frame))
		assert_almost_eq(look, Vector2.RIGHT, Vector2.ONE * 0.0001, "frame %d" % frame)


func test_the_tongues_burn_lower_over_the_drawn_flames() -> void:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.extra = KillTrackRows.of(&"molotov_torch")
	var full: float = d.extra.num("flame_m", 0.0)
	assert_eq(KillTorchArt.flame_m_of(d), full, "the placeholder's tongues at full height")
	var own: Sprite2D = autofree(Sprite2D.new())
	own.set_meta(KillDeathCells.META, true)
	d.cells = own
	assert_gt(KillTorchArt.flame_m_of(d), 0.0, "they still flicker over the drawing")
	assert_lt(KillTorchArt.flame_m_of(d), full, "lower than the placeholder's")
	assert_eq(KillTorchArt.flame_m_of(d, false), 0.0, "none over the drawn kneel (no spike)")


func test_the_p55_stitch_and_pin_cells_name_the_three_cops() -> void:
	for id: StringName in [&"smg_stitch", &"nail_pin"]:
		var e: KillTrackRows.Extra = KillTrackRows.of(id)
		for kind: String in ["cop_patrol", "cop_riot", "swat"]:
			var file: String = "p55/%s_%s.png" % [kind, id]
			assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + file), file)
		assert_eq(KillDeathCells.path_of(e, "p55", "cop/head_helmet"), "p55/cop_riot_%s.png" % id)

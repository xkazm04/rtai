extends GutTest
## n9 it10 rivet: the drawn reload strip (RivetReload) and its cells.


func after_each() -> void:
	RivetReload.enabled = true


func _rig() -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var head: Node2D = Node2D.new()
	rig.add_child(head)
	rig.head = head
	return rig


func test_no_reload_or_no_strip_keeps_the_path() -> void:
	var rig: CutRig = _rig()
	var eq: String = RivetStrips.DIR + "p70/rivet_eq_pistol.png"
	assert_eq(RivetReload.path_or(rig, "p70", &"pistol", eq), eq, "no reload playing")
	rig.reload_k = 0.5
	assert_true(RivetReload.on(rig))
	var no_strip: String = RivetReload.path_or(rig, "p70", &"no_such_weapon", eq)
	assert_eq(no_strip, eq, "a weapon without a drawn reload keeps its strip")
	assert_eq(RivetReload.path_or(rig, "p70", &"", eq), eq, "bare claw: nothing to reload")
	RivetReload.enabled = false
	assert_false(RivetReload.on(rig), "--rivet-reload=off")
	rig.reload_k = -1.0
	RivetReload.enabled = true
	assert_false(RivetReload.on(rig))


func test_the_three_quarter_toward_right_plays_the_sequence_by_phase() -> void:
	var rig: CutRig = _rig()
	rig.head.rotation = PI * 0.25  # octant 1
	var want: Array[int] = [5, 5, 6, 7, 7]
	var ks: Array[float] = [0.0, 0.9, 1.2, 2.5, 9.0]
	for i: int in ks.size():
		rig.reload_k = ks[i]
		assert_eq(RivetReload.cell_of(rig, 1), Vector2i(want[i], 0), "phase %.1f" % ks[i])
	for o: int in [0, 2, 6, 7]:
		assert_eq(RivetReload.cell_of(rig, o), Vector2i(RivetFrames.EQ_OCT[o], 0), "facing %d" % o)


func test_shows_reads_the_card_strip() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	assert_false(RivetReload.shows(card))
	card.set_meta(RivetFrames.ON, RivetStrips.DIR + "p70/" + RivetReload.PREFIX + "pistol.png")
	assert_true(RivetReload.shows(card))
	assert_false(RivetReload.shows(null))


func test_the_drawn_reload_ships_for_each_family_at_both_pitches() -> void:
	var rig: CutRig = _rig()
	rig.reload_k = 1.5
	for art: String in ["p70", "p55"]:
		for weapon: StringName in [&"pistol", &"plasma_rifle", &"gatling"]:
			var eq: String = RivetStrips.DIR + art + "/rivet_eq_" + String(weapon) + ".png"
			var got: String = RivetReload.path_or(rig, art, weapon, eq)
			assert_eq(got.get_file(), RivetReload.PREFIX + String(weapon) + ".png", art)
			var tex: Texture2D = load(got) as Texture2D
			var left: Texture2D = load(got.replace(".png", "_left.png")) as Texture2D
			assert_eq(tex.get_width() % 8, 0, "%s %s: 8 cells" % [art, weapon])
			assert_eq(left.get_width() % RivetFrames.LEFT_CELLS, 0, "%s %s left" % [art, weapon])

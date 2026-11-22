extends GutTest
## n17 rivet-strike (DEFECTS #5): a lunging hit (lunge_ticks) draws the weapon's thrust strip from
## the lunge's first tick through its contact; other hits, and off, keep the wind-up/strike cells.

const DT: float = SimClock.TICK_DT


func before_each() -> void:
	# The katana thrust sheets still serve the original combo when selected in its table.
	var legacy: MeleeTable = MeleeTable.weapon(&"katana")
	legacy.single_swing = false
	RivetThrust._hits[&"katana"] = legacy.hits


func after_each() -> void:
	RivetThrust._hits.clear()
	RivetThrust.enabled = true
	RivetThrust.recover = true


func _rig(tick_in: int, ph_ticks: Vector3) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.clips.strike_ph = ph_ticks * DT
	rig.clips.strike_t = tick_in * DT
	return rig


func test_the_thrust_is_matched_by_its_wind_up_and_active_ticks() -> void:
	assert_eq(RivetThrust.lunge_ticks(&"katana", Vector3(7, 5, 22) * DT), 4, "katana_3")
	assert_eq(RivetThrust.lunge_ticks(&"katana", Vector3(5, 3, 9) * DT), 0, "katana_1: no lunge")
	assert_eq(RivetThrust.lunge_ticks(&"pistol", Vector3(7, 5, 22) * DT), 0, "a gun")


func test_it_spans_the_lunge_and_the_contact() -> void:
	var ph: Vector3 = Vector3(7, 5, 22)
	var on: Array[int] = []
	for tick_in: int in 20:
		if RivetThrust.thrusting(_rig(tick_in, ph), &"katana"):
			on.append(tick_in)
	assert_eq(on, [3, 4, 5, 6, 7, 8, 9, 10, 11] as Array[int], "lunge 3-6, active 7-11")
	assert_false(RivetThrust.thrusting(_rig(4, Vector3(5, 3, 9)), &"katana"), "a slash")


func test_path_swaps_only_the_equipped_strip_and_off_keeps_it() -> void:
	var eq: String = RivetStrips.DIR + "p70/rivet_eq_katana.png"
	var rig: CutRig = _rig(4, Vector3(7, 5, 22))
	var o: int = RivetFrames.oct_of(rig)
	var want: String = eq.trim_suffix(".png") + RivetThrust.FILE
	assert_eq(RivetThrust.path_or(rig, "p70", &"katana", eq), want if o in [0, 2, 4] else eq)
	var grid: String = RivetStrips.DIR + "p70/rivet_walk_katana.png"
	assert_eq(RivetThrust.path_or(rig, "p70", &"katana", grid), grid, "another strip stands")
	RivetThrust.enabled = false
	assert_eq(RivetThrust.path_or(rig, "p70", &"katana", eq), eq)


func test_the_strip_is_three_cells_of_the_equipped_strips_size() -> void:
	for art: String in ["p70", "p55"]:
		var eq: Texture2D = load(RivetStrips.DIR + art + "/rivet_eq_katana.png") as Texture2D
		var th: Texture2D = load(RivetStrips.DIR + art + "/rivet_eq_katana_thrust.png") as Texture2D
		assert_eq(th.get_width() / RivetThrust.CELLS, eq.get_width() / RivetFrames.EQ_CELLS, art)
		assert_eq(th.get_height(), eq.get_height(), art)


func test_the_before_flag_routes_through_cast_flags() -> void:
	var was: bool = CastFlags._read
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-thrust=off"]))
	assert_false(RivetThrust.enabled)
	CastFlags._read = was


func test_the_camera_cells_feet_are_its_drawn_boot_not_the_blade() -> void:
	# p70 cell 1: the planted boot right of the blade (x 256-287), the blade's tip lower (row 251)
	var img: Image = (
		(load(RivetStrips.DIR + "p70/rivet_eq_katana_thrust.png") as Texture2D).get_image()
	)
	if img.is_compressed():
		assert_eq(img.decompress(), OK)
	var cw: int = img.get_width() / RivetThrust.CELLS
	var low: int = 0
	for y: int in img.get_height():
		for x: int in range(256, 288):
			if img.get_pixel(cw + x, y).a > 0.5:
				low = maxi(low, y)
	var foot: float = RivetThrust.CAM_FEET["p70"]
	assert_almost_eq(float(img.get_height() - 1 - low), foot, 2.0)


func test_place_takes_the_facings_cell_unmirrored_on_its_boots() -> void:
	var path: String = RivetStrips.DIR + "p70/rivet_eq_katana_thrust.png"
	var want: Dictionary[int, int] = {0: RivetThrust.SIDE, 2: RivetThrust.CAM, 4: RivetThrust.LEFT}
	for o: int in want:
		var rig: CutRig = autoqfree(CutRig.new())
		rig.face_to = o * PI * 0.25
		var card: Sprite2D = autoqfree(Sprite2D.new())
		card.texture = load(path) as Texture2D
		card.set_meta(RivetFrames.ON, path)
		RivetThrust.place(rig, card, 1.0, 100.0)
		assert_eq(card.frame, want[o], "octant %d" % o)
		assert_false(card.flip_h, "octant %d: drawn, never mirrored" % o)
		var h: float = card.texture.get_height()
		var foot: float = RivetThrust.CAM_FEET["p70"] if o == 2 else RivetStrips.foot_px(path)
		assert_almost_eq(card.offset.y, foot - h, 0.01, "octant %d on its boots" % o)


func test_past_the_contact_the_recovery_strip_is_drawn_through_the_hold() -> void:
	var ph: Vector3 = Vector3(7, 5, 22)
	var on: Array[int] = []
	for tick_in: int in 40:
		if RivetThrust.recovering(_rig(tick_in, ph), &"katana"):
			on.append(tick_in)
	assert_eq(on[0], 12, "from the first tick past the contact")
	assert_eq(on.size(), 28, "every later tick: the clip clears strike_t itself at its end")
	assert_false(RivetThrust.recovering(_rig(14, Vector3(5, 3, 9)), &"katana"), "a slash")
	assert_false(RivetThrust.recovering(_rig(-1, ph), &"katana"), "no strike")


func test_the_recovery_path_and_its_before() -> void:
	var eq: String = RivetStrips.DIR + "p70/rivet_eq_katana.png"
	var rig: CutRig = _rig(14, Vector3(7, 5, 22))
	var want: String = eq.trim_suffix(".png") + RivetThrust.RECOVER_FILE
	assert_eq(RivetThrust.path_or(rig, "p70", &"katana", eq), want)
	var card: Sprite2D = autoqfree(Sprite2D.new())
	card.set_meta(RivetFrames.ON, want)
	assert_true(RivetThrust.shows(card))
	var was: bool = CastFlags._read
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-thrust-recover=off"]))
	CastFlags._read = was
	assert_false(RivetThrust.recover)
	assert_eq(RivetThrust.path_or(rig, "p70", &"katana", eq), eq, "off: the strike cell")


func test_the_recovery_strip_matches_and_its_camera_cell_stands_on_its_boots() -> void:
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/rivet_eq_katana_thrust_recover.png"
		var th: Texture2D = load(RivetStrips.DIR + art + "/rivet_eq_katana_thrust.png") as Texture2D
		var rec: Texture2D = load(path) as Texture2D
		assert_eq(rec.get_size(), th.get_size(), art)
		var rig: CutRig = autoqfree(CutRig.new())
		rig.face_to = PI * 0.5
		var card: Sprite2D = autoqfree(Sprite2D.new())
		card.texture = rec
		card.set_meta(RivetFrames.ON, path)
		RivetThrust.place(rig, card, 1.0, 100.0)
		assert_eq(card.frame, RivetThrust.CAM, art)
		var foot: float = RivetThrust.RECOVER_CAM_FEET[art]
		assert_almost_eq(card.offset.y, foot - rec.get_height(), 0.01, art + " on its boots")

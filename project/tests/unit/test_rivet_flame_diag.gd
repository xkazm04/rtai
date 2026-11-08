extends GutTest
## n9 rivet it5: the flamer's drawn diagonal fire cells (RivetStrips.diag_or, rivet_flame_diag.py).

const DIAG: String = "rivet_eq_flamethrower_diag.png"


func after_each() -> void:
	RivetStrips.cone = []
	RivetStrips.diag = true


func _rig(octant: int, firing: bool) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var head: Node2D = Node2D.new()
	rig.add_child(head)
	rig.head = head
	head.rotation = octant * PI * 0.25
	rig.set_meta(RivetFrames.FIRE, firing)
	return rig


func test_each_diagonal_octant_has_its_own_drawn_cell() -> void:
	var cells: Array[int] = []
	for o: int in [1, 7, 3, 5]:  # 3/4 toward right, away right, toward left, away left
		cells.append(RivetStrips.small_cell(o, RivetStrips.DIAG_CELLS))
	assert_eq(cells, [0, 1, 2, 3] as Array[int])
	for o: int in [0, 2, 4, 6]:
		assert_lt(RivetStrips.DIAG_CELL[o], 0, "octant %d fires its side or camera cell" % o)
	assert_eq(RivetStrips.small_cell(4, RivetFrames.LEFT_CELLS), 1, "a left strip is unchanged")


func test_a_diagonal_burst_takes_the_diagonal_strip_at_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		var eq: String = RivetStrips.strip_of(art, &"flamethrower")
		var path: String = RivetStrips.diag_or(_rig(1, true), art, &"flamethrower", eq)
		assert_eq(path, RivetStrips.DIR + art + "/" + DIAG)
		assert_eq(RivetStrips.cells_of(path, false), RivetStrips.DIAG_CELLS)
		assert_eq(RivetStrips.diag_or(_rig(1, false), art, &"flamethrower", eq), eq, "no shot")
		assert_eq(RivetStrips.diag_or(_rig(0, true), art, &"flamethrower", eq), eq, "the side")
		assert_eq(RivetStrips.diag_or(_rig(5, true), art, &"pistol", eq), eq, "no drawn diagonal")


func test_the_side_and_cone_flags_keep_the_equipped_strip() -> void:
	var eq: String = RivetStrips.strip_of("p70", &"flamethrower")
	RivetStrips.diag = false
	assert_eq(RivetStrips.diag_or(_rig(7, true), "p70", &"flamethrower", eq), eq)
	RivetStrips.diag = true
	RivetStrips.cone = RivetStrips.CONE_D9.duplicate()
	assert_eq(RivetStrips.diag_or(_rig(7, true), "p70", &"flamethrower", eq), eq)


func test_the_diagonal_strip_stands_on_its_foot_line_with_the_nozzle_measured() -> void:
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/" + DIAG
		var tex: Texture2D = load(path) as Texture2D
		var w: float = tex.get_width() / float(RivetStrips.DIAG_CELLS)
		var foot: float = RivetStrips.foot_px(path)
		assert_gt(foot, RivetFrames.PAD_PX, "a toward flame reaches below his feet")
		var feet_y: float = tex.get_height() - foot
		for c: int in RivetStrips.DIAG_CELLS:
			var p: Vector2 = RivetMuzzle.point(path, c)
			assert_lt(p.y, feet_y, "%s cell %d: the nozzle above the feet" % [art, c])
			var right: bool = c < 2
			assert_eq(p.x > w * 0.5, right, "%s cell %d: the nozzle on its flame's side" % [art, c])
	assert_eq(RivetStrips.foot_px(RivetStrips.DIR + "p70/" + RivetStrips.BASE), RivetFrames.PAD_PX)

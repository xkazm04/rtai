extends GutTest
## Lane n8 street: a dying walker's figure follows the hidden parts' head (StreetWalkerFall).

var _card: Sprite2D = null


func _dying_rig(head_at: Vector2) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.head = Node2D.new()
	rig.add_child(rig.head)
	add_child(rig)
	rig.head.position = Vector2(0.0, -40.0)
	var r: HumanReact = HumanReact.on(rig)
	r.kind = &"death_light"
	r.dying = true
	r.length = 1.0
	r.t = 0.0
	_card = autofree(Sprite2D.new())
	# the standing length is read at the first dying step
	var stand: Vector2 = StreetWalkerFall.pose(rig, _card)
	assert_eq(stand, Vector2(0.0, 1.0), "upright at the blow")
	rig.head.position = head_at
	r.t = StreetWalkerCards.DEATH_HOLD
	return rig


func test_not_dying_is_upright_and_full_length() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var card: Sprite2D = autofree(Sprite2D.new())
	assert_eq(StreetWalkerFall.pose(rig, card), Vector2(0.0, 1.0))


func test_at_the_swap_the_figure_lies_along_the_parts_head() -> void:
	var rig: CutRig = _dying_rig(Vector2(20.0, -20.0))
	var p: Vector2 = StreetWalkerFall.pose(rig, _card)
	assert_almost_eq(p.x, PI * 0.25, 0.001, "leans toward the head, screen right-up")
	assert_almost_eq(p.y, Vector2(20.0, -20.0).length() / 40.0, 0.001, "shortened as the parts")


func test_a_body_falling_north_shortens_without_a_lean() -> void:
	var rig: CutRig = _dying_rig(Vector2(0.0, -12.0))
	var p: Vector2 = StreetWalkerFall.pose(rig, _card)
	assert_almost_eq(p.x, 0.0, 0.001, "no screen-x tip")
	assert_almost_eq(p.y, StreetWalkerFall.MIN_LEN, 0.001, "foreshortened to the floor")


func test_the_fall_frames_run_buckle_mid_fall_lying() -> void:
	assert_eq(StreetWalkerFall.fall_frame(0.0), 0, "buckles at the blow")
	assert_eq(StreetWalkerFall.fall_frame(StreetWalkerFall.FALL_AT[1]), 1, "mid-fall")
	assert_eq(
		StreetWalkerFall.fall_frame(1.0), StreetWalkerFall.FALL_FRAMES - 1, "lies as a corpse"
	)


func test_only_the_dying_and_the_dead_draw_a_fall_grid() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var row: String = "ped/head_hood"
	assert_eq(StreetWalkerFall.grid_of(rig, "p70", row), "", "alive: the walk")
	rig.dead = true
	# it20: the hood has drawn in-betweens, so his dead grid is the 5-row one
	var hood: String = StreetFallBetween.swap("p70/" + str(StreetWalkerFall.table()["p70"][row]))
	assert_eq(StreetWalkerFall.grid_of(rig, "p70", row), hood, "dead: the grid")
	assert_eq(StreetWalkerFall.grid_of(rig, "p55", row), hood, "55: the 70 grid")
	assert_eq(StreetWalkerFall.grid_of(rig, "p70", "ped/head_none"), "", "a row with no grid")
	var cop: String = "cop/head_cap"
	var own: String = "p55/" + str(StreetWalkerFall.table()["p55"][cop])
	assert_eq(StreetWalkerFall.grid_of(rig, "p55", cop), own, "55: its own")


func test_every_fall_grid_exists_and_all_three_cops_have_one() -> void:
	for table: Dictionary in [StreetWalkerFall.FALLS, StreetWalkerFall.LONG_FALLS]:
		for art: String in table:
			var rows: Dictionary = table[art]
			for row: String in rows:
				var path: String = "res://features/characters/art/view/%s/%s" % [art, rows[row]]
				assert_true(ResourceLoader.exists(path), path)
	for art: String in StreetWalkerFall.FALLS:
		assert_eq(
			StreetWalkerFall.LONG_FALLS[art].keys(),
			StreetWalkerFall.FALLS[art].keys(),
			"LONG swaps files, never rows (%s)" % art
		)
	for row: String in ["cop/head_cap", "cop/head_helmet", "cop/head_swat"]:
		assert_true(StreetWalkerFall.FALLS["p70"].has(row), row + " falls as drawn at 70")
	assert_true(StreetWalkerFall.FALLS["p70"].has("thug"), "the robot thug powers down as drawn")

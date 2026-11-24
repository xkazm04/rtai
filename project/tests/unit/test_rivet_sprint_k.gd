extends GutTest
## The p55 bare sprint profile rows: a run_row_k factor that fades in from walk to sprint.


func _rig(speed_mps: float) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	var card: Sprite2D = Sprite2D.new()
	rig.add_child(card)
	rig.head_card = card
	var path: String = StrideMatch.ROOT + "p55/rivet_run8.png"
	card.texture = load(path)
	card.set_meta(RivetFrames.ON, path)
	card.hframes = 8
	card.vframes = 8
	rig.face_to = 0.0
	rig.speed_now = speed_mps * CharacterRigs.PX_PER_M
	return rig


func test_the_p55_sprint_profile_rows_scale_from_the_walk_speed_up_to_the_sprint() -> void:
	var grid: RivetGridStride = RivetGridStride.shared()
	assert_eq(grid.sprint_k("p55", 2, RivetGridStride.SPRINT_FROM_MPS), 1.0, "the walk")
	assert_almost_eq(grid.sprint_k("p55", 2, RivetGridStride.SPRINT_MPS), 0.98, 0.00001)
	assert_almost_eq(grid.sprint_k("p55", 6, RivetGridStride.SPRINT_MPS), 0.98, 0.00001)
	assert_almost_eq(grid.sprint_k("p55", 2, 12.0), 0.98, 0.00001, "above the sprint holds")
	assert_almost_eq(grid.sprint_k("p55", 2, 8.025), 0.99, 0.00001, "halfway blends")
	assert_eq(grid.sprint_k("p55", 1, 9.3), 1.0, "a row without a factor")
	assert_eq(grid.sprint_k("p70", 2, 9.3), 1.0, "p70 has none")


func test_the_sprint_factor_shortens_the_bare_cycle_only_at_sprint_speed() -> void:
	var walk_rig: CutRig = _rig(RivetGridStride.SPRINT_FROM_MPS)
	var table: Vector2 = RivetGridStride.shared().bare_run["p55"][2]
	assert_eq(RivetWalk._bare_cycles(walk_rig.head_card, "p55", walk_rig, 1.0), table)
	var rig: CutRig = _rig(RivetGridStride.SPRINT_MPS)
	var sprint: Vector2 = RivetWalk._bare_cycles(rig.head_card, "p55", rig, 1.0)
	assert_almost_eq(sprint.x, table.x * 0.98, 0.0001)
	assert_almost_eq(sprint.y, table.y * 0.98, 0.0001)


func test_bare_phase_carries_distance_across_unequal_stances_and_back() -> void:
	var cycles: Vector2 = Vector2(40.0, 80.0)
	assert_almost_eq(RivetWalk.bare_phase(0.25, 18.0, cycles), 0.6, 0.00001)
	assert_almost_eq(RivetWalk.bare_phase(0.6, -18.0, cycles), 0.25, 0.00001)
	assert_almost_eq(RivetWalk.bare_phase(0.9, 12.0, cycles), 0.1, 0.00001)
	assert_almost_eq(RivetWalk.bare_phase(0.1, -12.0, cycles), 0.9, 0.00001)

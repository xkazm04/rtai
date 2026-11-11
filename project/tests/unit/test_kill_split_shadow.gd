extends GutTest
## n16 kills-polish (DEFECTS 10): a blade half's flying shadow lies under the drawn half, through
## the half root's transform (the topple turns it), not at the root's origin; any other part keeps
## its shadow at its origin.


func test_a_part_without_the_meta_casts_at_its_origin() -> void:
	var part: Node2D = Node2D.new()
	part.position = Vector2(30.0, 40.0)
	assert_eq(KillSplitHalves.shadow_at(part), Vector2(30.0, 40.0))
	part.free()


func test_a_half_casts_under_its_drawn_centre_through_the_topple() -> void:
	var half: Node2D = Node2D.new()
	half.position = Vector2(100.0, 50.0)
	half.set_meta(KillSplitHalves.SHADOW, Vector2(0.0, -32.0))  # drawn 1 m above its root at 32
	assert_eq(KillSplitHalves.shadow_at(half), Vector2(100.0, 18.0), "upright: above the root")
	half.rotation = PI * 0.5  # toppled flat to screen right... (+90 deg turns -y to +x)
	var at: Vector2 = KillSplitHalves.shadow_at(half)
	assert_almost_eq(at.x, 132.0, 0.01, "lying: beside the root, where the half is drawn")
	assert_almost_eq(at.y, 50.0, 0.01)
	half.free()


func test_the_cut_marks_both_halves() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"katana")
	assert_gt(KillSplitHalves.SHADOW_IN_M, 0.0)
	assert_gt(row.cut_up_m, 0.0, "the halves are drawn above their roots: the shadow must follow")

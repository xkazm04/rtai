extends GutTest
## n7-king: King's gold leaf (print_part swap 5) is the boss plan's alone.


func test_the_boss_king_prints_gold_on_chest_and_arms() -> void:
	var p: BodyPlan = KingRigs.king_plan()
	assert_eq(p.torso_swap, KingRigs.GOLD_SWAP)
	assert_eq(p.arm_swap, KingRigs.GOLD_SWAP)


func test_the_plain_king_plan_and_the_thug_stay_steel() -> void:
	assert_eq(KingPlan.build().arm_swap, -1, "the enemy-ai robot thug is built from KingPlan")
	assert_eq(KingPlan.build().torso_swap, -1)
	assert_eq(ThugPlan.build().arm_swap, -1)


func test_the_rig_gives_the_gold_swap_to_its_forearm_materials() -> void:
	var rig: CutRig = CutRig.new()
	add_child_autofree(rig)
	rig.setup(KingRigs.king_plan(), RigVariant.rivet())
	var fore: Sprite2D = rig.sides[BodyPlan.R].fore
	var i: int = rig.sprites.find(fore)
	assert_true(i >= 0)
	assert_eq(rig.sprite_swaps[i], KingRigs.GOLD_SWAP)


## it8: the target's flat press plates on both arms (the boss plan only; KingPlan keeps the claw).
func test_the_boss_king_ends_both_arms_in_press_plates() -> void:
	var p: BodyPlan = KingRigs.king_plan()
	assert_eq(p.hand_open, "press_plate")
	assert_eq(p.hand_closed, "press_plate", "a closed claw cell would swap the plate back")
	assert_eq(p.fore_part[BodyPlan.R], "r_forearm_press", "the megaphone forearm is gone")
	assert_eq(KingPlan.build().hand_open, "claw_open", "the enemy-ai thug keeps Rivet's claw")


func test_the_press_parts_have_measured_pivots() -> void:
	var lib: PartLibrary = PartLibrary.of("king")
	for part: String in ["press_plate", "r_forearm_press", "megaphone"]:
		assert_true(lib.pivots_a.has(part), part)
		assert_not_null(lib.tex(part), part)
	assert_almost_eq(lib.span("r_forearm_press"), lib.span("l_forearm"), 0.5, "the same piston")

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

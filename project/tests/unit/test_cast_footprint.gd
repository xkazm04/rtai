extends GutTest
## n5-cast: one human footprint (the owner, 2026-11-04: cops "closer to crowd in their default
## state"). Spans in world px (part px x CutRig.SC x size_k), from the plans and parts.json.


func _span(p: BodyPlan, part: String) -> Vector2:
	return PartLibrary.of(p.art_dir).size(part) * CutRig.SC * p.size_k


func test_cop_shoulders_match_the_crowd() -> void:
	var cop: Vector2 = _span(HumanPlan.cop(), "torso")
	var ped: Vector2 = _span(HumanPlan.ped(), "torso")
	assert_between(cop.y / ped.y, 0.95, 1.15, "shoulder span, cop : ped")
	assert_between(cop.x / ped.x, 0.85, 1.15, "torso depth, cop : ped")


func test_cop_limbs_are_human_length() -> void:
	var cop: BodyPlan = HumanPlan.cop()
	var ped: BodyPlan = HumanPlan.ped()
	var leg_c: float = (cop.thigh_len + cop.shin_len) * cop.size_k
	var leg_p: float = (ped.thigh_len + ped.shin_len) * ped.size_k
	assert_between(leg_c / leg_p, 0.9, 1.15, "leg length, cop : ped")
	var arm_c: float = (cop.upper_len + cop.fore_len[0]) * cop.size_k
	var arm_p: float = (ped.upper_len + ped.fore_len[0]) * ped.size_k
	assert_between(arm_c / arm_p, 0.9, 1.15, "arm length, cop : ped")


## Iteration 11 (r2_a5 from straight above): the ped's head is a small mark inside the shoulders
## and its standing shoes stay under the coat; the cops keep their art scale.
func test_ped_plan_view_head_and_feet() -> void:
	var ped: BodyPlan = HumanPlan.ped()
	var lib: PartLibrary = PartLibrary.of(ped.art_dir)
	var head_w: float = lib.size("head_hat").x * ped.head_k
	assert_lt(head_w / lib.size("torso").y, 0.5, "widest ped head : shoulder span")
	var shoe_tip: float = ped.foot_fwd + lib.size("foot_flat").x * 0.5 * ped.foot_k
	assert_lt(shoe_tip, lib.size("torso").x * 0.5, "standing shoe tip inside the chest")
	assert_eq(HumanPlan.cop().head_k, 1.0, "cop head scale")

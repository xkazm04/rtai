extends GutTest
## features/souls HaulerLook: the tank grows and tints by the morph, `bulked` shortens the arms,
## and morph 0 puts Rivet's shared plan back to its exact base numbers.


func _rig() -> CutRig:
	var rig: CutRig = CutRig.new()
	rig.setup(RivetPlan.build(RivetPlan.FORM_BASE), RigVariant.rivet())
	autofree(rig)
	return rig


func _look(kind: String) -> HaulerLook:
	var t: Dictionary = PowerTable.load_default().hauler.duplicate()
	t["look"] = kind
	return HaulerLook.new(t)


func test_full_morph_reaches_the_hauler_form_size_and_tints_teal() -> void:
	var rig: CutRig = _rig()
	_look("scaled").apply(rig, 1.0)
	var want: float = CutRig.SC * RivetPlan.FORMS[RivetPlan.FORM_HAULER].x
	assert_almost_eq(rig.scale.x, want, 1e-4)
	assert_gt(rig.modulate.g, rig.modulate.r, "teal: green over red")


func test_bulked_shortens_the_arms_and_scaled_keeps_them() -> void:
	var rig: CutRig = _rig()
	var upper: float = rig.plan.upper_len
	var fore: float = rig.plan.fore_len[0]
	_look("scaled").apply(rig, 1.0)
	assert_eq(rig.plan.upper_len, upper)
	var bulked: HaulerLook = _look("bulked")
	bulked.apply(rig, 1.0)
	var k: float = PowerTable.load_default().hauler["look_arm_k"]
	assert_almost_eq(rig.plan.upper_len, upper * k, 1e-3)
	assert_almost_eq(rig.plan.fore_len[0], fore * k, 1e-3)


func test_morph_zero_restores_the_exact_base_plan() -> void:
	var rig: CutRig = _rig()
	var before: Array = [rig.plan.upper_len, rig.plan.fore_draw[1], rig.plan.hand_ready[0]]
	var look: HaulerLook = _look("bulked")
	look.apply(rig, 1.0)
	look.apply(rig, 0.37)
	look.apply(rig, 0.0)
	assert_eq([rig.plan.upper_len, rig.plan.fore_draw[1], rig.plan.hand_ready[0]], before)
	assert_almost_eq(rig.scale.x, CutRig.SC * RivetPlan.FORMS[RivetPlan.FORM_BASE].x, 1e-5)

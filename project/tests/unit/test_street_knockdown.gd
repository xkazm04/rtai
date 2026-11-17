extends GutTest
## n17 npc-react (DEFECTS 11): a living knockdown plays the person's fall grid down, lying and up.


func _rig(kind: StringName, progress: float, dying: bool = false) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	var r: HumanReact = HumanReact.on(rig)
	r.kind = kind
	r.length = 2.2
	r.t = progress * r.length
	r.dying = dying
	return rig


func test_a_knockdown_is_down_until_he_is_up_again() -> void:
	assert_true(StreetKnockdown.down(_rig(&"knockdown", 0.0)), "the hit's tick")
	assert_true(StreetKnockdown.down(_rig(&"knockdown", 0.5)), "lying")
	assert_false(StreetKnockdown.down(_rig(&"knockdown", StreetKnockdown.UP_END)), "back up")
	assert_true(StreetWalkerFall.down(_rig(&"knockdown", 0.5)), "the fall grid draws it")


func test_other_families_and_the_dying_are_not_a_knockdown() -> void:
	assert_false(StreetKnockdown.down(_rig(&"stagger", 0.1)))
	assert_false(StreetKnockdown.down(_rig(&"knockdown", 0.5, true)), "a death is the death's")
	assert_false(StreetWalkerFall.down(_rig(&"flinch", 0.1)), "a flinch stays on its feet")


func test_the_frames_go_down_lie_and_come_back_up() -> void:
	var lying: int = StreetWalkerFall.FALL_FRAMES - 1
	var frames: Array[int] = []
	for i: int in 101:
		var q: float = StreetKnockdown.fall_progress(i / 100.0 * StreetKnockdown.UP_END)
		frames.append(StreetWalkerFall.fall_frame(q))
	assert_eq(frames[0], 0, "buckles first")
	assert_eq(frames[50], lying, "lies")
	assert_eq(frames[100], 0, "the buckle again as he stands")
	var peak: int = frames.find(lying)
	for i: int in range(1, frames.size()):
		var step: int = frames[i] - frames[i - 1]
		assert_true(absi(step) <= 1, "one frame at a time (%d -> %d)" % [frames[i - 1], frames[i]])
		assert_true(step >= 0 if i <= peak else true, "only down before the lying frame")

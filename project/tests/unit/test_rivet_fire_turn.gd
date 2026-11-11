extends GutTest
## n17 rivet-strike (DEFECTS #10): the fire latch holds only in the octant the last round left
## in; a fresh round (the recoil) re-seats it; keep = the before.


func after_each() -> void:
	RivetFireTurn.enabled = true


func _rig(face: float) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.face_to = face
	rig.clips.recoil = 0.0
	rig.set_meta(RivetFrames.FIRE, false)
	return rig


func test_latch_holds_in_the_shot_octant_and_drops_on_a_turn() -> void:
	var rig: CutRig = _rig(0.0)
	assert_false(RivetFireTurn.latched(rig), "no shot, no latch")
	rig.set_meta(RivetFrames.FIRE, true)
	assert_true(RivetFireTurn.latched(rig), "the shot's own facing keeps its fire cell")
	rig.face_to = PI * 0.5  # he turns to the camera after the kill
	assert_false(RivetFireTurn.latched(rig), "no flash in a facing the round never left")


func test_a_fresh_round_reseats_the_latch() -> void:
	var rig: CutRig = _rig(0.0)
	@warning_ignore("return_value_discarded")
	RivetFireTurn.latched(rig)
	rig.set_meta(RivetFrames.FIRE, true)
	rig.face_to = PI * 0.5
	rig.clips.recoil = 1.0  # an automatic firing as it turns
	assert_true(RivetFireTurn.latched(rig), "a round in the new facing fires its cell")


func test_keep_is_the_before() -> void:
	RivetFireTurn.enabled = false
	var rig: CutRig = _rig(0.0)
	@warning_ignore("return_value_discarded")
	RivetFireTurn.latched(rig)
	rig.set_meta(RivetFrames.FIRE, true)
	rig.face_to = PI * 0.5
	assert_true(RivetFireTurn.latched(rig))


func test_a_decaying_kick_does_not_follow_a_turn() -> void:
	var rig: CutRig = _rig(0.0)
	@warning_ignore("return_value_discarded")
	RivetFireTurn.latched(rig)
	rig.clips.recoil = 1.0  # the round, facing right
	assert_true(RivetFireTurn.latched(rig))
	rig.clips.recoil = 0.6  # the kick decays as he turns to the camera (the kill, t339)
	rig.face_to = PI * 0.5
	assert_false(RivetFireTurn.latched(rig), "the old round's kick draws no fire cell there")

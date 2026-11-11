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
	assert_false(RivetFireTurn.held(rig), "no shot, no latch")
	rig.set_meta(RivetFrames.FIRE, true)
	assert_true(RivetFireTurn.held(rig), "the shot's own facing keeps its fire cell")
	rig.face_to = PI * 0.5  # he turns to the camera after the kill
	assert_false(RivetFireTurn.held(rig), "no flash in a facing the round never left")


func test_a_fresh_round_reseats_the_latch() -> void:
	var rig: CutRig = _rig(0.0)
	@warning_ignore("return_value_discarded")
	RivetFireTurn.held(rig)
	rig.set_meta(RivetFrames.FIRE, true)
	rig.face_to = PI * 0.5
	rig.clips.recoil = 1.0  # an automatic firing as it turns
	assert_true(RivetFireTurn.held(rig), "a round in the new facing fires its cell")


func test_keep_is_the_before() -> void:
	RivetFireTurn.enabled = false
	var rig: CutRig = _rig(0.0)
	@warning_ignore("return_value_discarded")
	RivetFireTurn.held(rig)
	rig.set_meta(RivetFrames.FIRE, true)
	rig.face_to = PI * 0.5
	assert_true(RivetFireTurn.held(rig))

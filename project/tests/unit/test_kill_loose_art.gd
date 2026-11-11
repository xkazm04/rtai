extends GutTest
## Lane kills-new (n16): the drawn loose headgear and scraps attach only where a card row exists.
## The top view draws no head card, so a kill there attaches nothing and raises no error (the
## n16 reel gate's top view hit `row_of` on a null head card at every new-style kill).


func test_no_head_card_attaches_nothing_and_does_not_fail() -> void:
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	var body: Node2D = Node2D.new()
	assert_null(rig.head_card, "the top view: no head card")
	KillLooseArt.attach(rig, body, KillTrackRows.of(&"gatling_shred"))
	assert_null(KillLooseArt.of(body), "no loose headgear")
	assert_null(KillLooseArt.of(body, KillLooseArt.SCRAPS), "no drawn scraps")
	body.free()
	rig.free()

extends GutTest
## n16 kills-polish (ray gun dissolve, KILLS ranking): a whole-figure walker card hangs under the
## rig's head, so GibCut.cut(whole) copied the whole man into the HAT piece and the kicked "cap"
## was the cop himself, spinning away unclipped while his masked body dissolved behind him. The
## figure stays in the BODY only; a head-only card (no walker meta) still goes with the hat.


func _rig() -> CutRig:
	var pool: RigPool = RigPool.new()
	add_child_autoqfree(pool)
	@warning_ignore("return_value_discarded")
	pool.prewarm(BodyPlan.Kind.PED, 1)
	return pool.acquire(BodyPlan.Kind.PED, RigVariant.crowd(0), Vector2(32, 32), 0.3)


func _card(rig: CutRig, walker: bool) -> Texture2D:
	var tex: PlaceholderTexture2D = PlaceholderTexture2D.new()
	tex.size = Vector2(8, 16)
	var card: Sprite2D = Sprite2D.new()
	card.texture = tex
	rig.head.add_child(card)
	if walker:
		card.set_meta(StreetWalkerCards.ON, "x_walk.png")
	rig.head_card = card
	return tex


func _holds(group: Node2D, tex: Texture2D) -> bool:
	for ch: Node in group.get_children():
		if ch is Sprite2D and (ch as Sprite2D).texture == tex:
			return true
	return false


func _free(groups: Array[Node2D]) -> void:
	for g: Node2D in groups:
		g.free()


func test_a_walker_card_is_the_body_not_the_hat() -> void:
	var rig: CutRig = _rig()
	var tex: Texture2D = _card(rig, true)
	assert_true(StreetWalkerCards.hides_parts(rig))
	var groups: Array[Node2D] = GibCut.cut(rig, true)
	assert_true(_holds(groups[SignatureKill.BODY], tex), "the man is in the body")
	assert_false(_holds(groups[SignatureKill.HAT], tex), "and not in the kicked cap")
	_free(groups)


func test_a_head_only_card_still_goes_with_the_hat() -> void:
	var rig: CutRig = _rig()
	var tex: Texture2D = _card(rig, false)
	var groups: Array[Node2D] = GibCut.cut(rig, true)
	assert_true(_holds(groups[SignatureKill.HAT], tex))
	_free(groups)

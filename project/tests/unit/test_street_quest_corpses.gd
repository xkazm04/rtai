extends GutTest

const BASE: Color = Color(1.0, 1.0, 1.0, 0.8)


func _decay() -> CorpseDecay:
	return CorpseDecay.shipped()


func test_a_fresh_corpse_lies_at_the_base_tint() -> void:
	assert_eq(StreetQuestCorpses.tint_of(0, BASE), BASE)
	var linger: int = _decay().bodies.linger_ticks
	assert_eq(StreetQuestCorpses.tint_of(linger, BASE), BASE, "still whole at the end of linger")


func test_it_inks_out_then_is_gone_after_the_fade() -> void:
	var d: CorpseDecay = _decay()
	var linger: int = d.bodies.linger_ticks
	var fade: int = d.bodies.fade_ticks
	var mid: Color = StreetQuestCorpses.tint_of(linger + roundi(fade * d.ink_k), BASE)
	assert_almost_eq(mid.r, ArtIds.INK.r, 0.01, "all ink by ink_k of the fade")
	assert_almost_eq(mid.a, BASE.a, 0.01, "the ink shows before the alpha goes")
	assert_eq(StreetQuestCorpses.tint_of(linger + fade, BASE).a, 0.0)
	assert_eq(StreetQuestCorpses.tint_of(linger + fade * 50, BASE).a, 0.0)


func test_the_tint_never_rises_with_age() -> void:
	var d: CorpseDecay = _decay()
	var last: float = 1.0
	for age: int in range(0, d.bodies.linger_ticks + d.bodies.fade_ticks + 2, 6):
		var a: float = StreetQuestCorpses.tint_of(age, BASE).a
		assert_true(a <= last + 0.0001, "alpha at %d" % age)
		last = a


func test_the_base_is_cast_views_down_fade() -> void:
	assert_eq(StreetQuestCorpses.BASE, CastView.DOWN_FADE)

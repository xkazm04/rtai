extends GutTest

const PPM: float = 32.0


func before_each() -> void:
	StreetDeadPlan.reset()


func _guard(id: int, facing: Vector2) -> Fighter:
	var h: Fighter = Fighter.new()
	h.id = id
	h.facing = facing
	return h


func test_the_blow_points_away_from_the_way_he_faced() -> void:
	for at: Vector2 in [Vector2(10, 20), Vector2(33, 7), Vector2(-40, 91)]:
		var blow: Vector2 = StreetQuestDeadPlan.blow_of(at, Vector2.RIGHT)
		assert_almost_eq(blow.length(), 1.0, 0.0001)
		assert_true(blow.dot(Vector2.LEFT) >= cos(StreetQuestCards.SPREAD) - 0.0001, "at %s" % at)


func test_the_pelvis_lies_along_the_blow_at_pelvis_k_of_standing() -> void:
	var at: Vector2 = Vector2(100, 200)
	var h: Fighter = _guard(7, Vector2.UP)
	var t: Transform2D = StreetQuestDeadPlan.transform_of(at, h, PPM)
	var blow: Vector2 = StreetQuestDeadPlan.blow_of(at, h.facing)
	var want: float = StreetDeadPlan.PELVIS_K * StreetQuestCards.body_m() * PPM
	assert_almost_eq((t.origin - at).length(), want, 0.01)
	assert_true((t.origin - at).normalized().dot(blow) > 0.999)
	var s: float = StreetQuestCards.body_m() * PPM / StreetWalkerFall.STILL_PX
	assert_almost_eq(t.get_scale().y, s, 0.0001, "the still strip's px per metre")


func test_neighbouring_corpses_lie_in_different_poses() -> void:
	var seen: Dictionary[int, bool] = {}
	for i: int in 5:
		var at: Vector2 = Vector2(400 + i * 12, 300)  # 5 bodies within NEAR_M of each other
		seen[StreetDeadPlan.pick(StreetQuestDeadPlan.ID_BASE - i, &"", at)] = true
	assert_eq(seen.size(), StreetDeadPlan.POSES)


func test_no_strip_keeps_the_drawn_frame() -> void:
	if ResourceLoader.exists(StreetQuestDeadPlan.PATH):
		pass_test("the strip is served: the plan path draws")
		return
	var canvas: Node2D = autofree(Node2D.new())
	var h: Fighter = _guard(3, Vector2.RIGHT)
	assert_false(StreetQuestDeadPlan.draw(canvas, Vector2.ZERO, h, PPM, 0))


func test_a_plan_corpse_lies_opaque_and_still_fades() -> void:
	assert_eq(StreetQuestDeadPlan.ground_tint(StreetQuestCorpses.BASE).a, 1.0)
	var half: Color = StreetQuestCorpses.BASE
	half.a *= 0.5
	assert_almost_eq(StreetQuestDeadPlan.ground_tint(half).a, 0.5, 0.001)
	assert_eq(StreetQuestDeadPlan.ground_tint(Color(1, 1, 1, 0)).a, 0.0)


func test_the_fall_slides_turns_and_lands_into_the_rest() -> void:
	var at: Vector2 = Vector2(100, 200)
	var h: Fighter = _guard(9, Vector2.UP)
	var rest: Transform2D = StreetQuestDeadPlan.transform_of(at, h, PPM)
	var blow: Vector2 = StreetQuestDeadPlan.blow_of(at, h.facing)
	var hit: Transform2D = StreetQuestDeadPlan.transform_of(at, h, PPM, 0)
	var short: float = (rest.origin - hit.origin).dot(blow)
	assert_almost_eq(short, StreetQuestDeadPlan.SLIDE_M * PPM, 0.01, "slides SLIDE_M into the rest")
	var turned: float = absf(angle_difference(hit.get_rotation(), rest.get_rotation()))
	assert_almost_eq(turned, StreetQuestDeadPlan.TWIST_RAD, 0.001, "turns TWIST_RAD into the rest")
	assert_gt(absf(hit.get_scale().y), absf(rest.get_scale().y), "lands from LAND_SCALE")
	var ticks: int = StreetQuestDeadPlan.FALL_TICKS
	var done: Transform2D = StreetQuestDeadPlan.transform_of(at, h, PPM, ticks)
	assert_almost_eq(done.origin.distance_to(rest.origin), 0.0, 0.001, "settled at FALL_TICKS")
	assert_true(
		StreetQuestDeadPlan.fall_left(6) < 1.0 - 6.0 / StreetQuestDeadPlan.FALL_TICKS, "eased out"
	)

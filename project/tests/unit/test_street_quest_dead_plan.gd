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
	assert_false(StreetQuestDeadPlan.draw(canvas, Vector2.ZERO, h, PPM, Color.WHITE))

extends GutTest

const PPM: float = 32.0


func before_each() -> void:
	StreetDeadPlan.reset()
	StreetQuestDeadPlan.reset()


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


func test_a_later_body_is_pushed_off_one_already_lying_and_the_first_stays() -> void:
	var a: Vector2 = Vector2(400, 300)
	var b: Vector2 = a + Vector2(0, 0.5 * PPM)
	var first: Fighter = _guard(1, Vector2.RIGHT)
	var second: Fighter = _guard(2, Vector2.RIGHT)
	var t1: Transform2D = StreetQuestDeadPlan.transform_of(a, first, PPM)
	var t2: Transform2D = StreetQuestDeadPlan.transform_of(b, second, PPM)
	var push: Vector2 = StreetQuestDeadPlan.push_of(StreetQuestDeadPlan.ID_BASE - 2, b, PPM)
	assert_almost_eq(
		push.length(), StreetQuestDeadPlan.PUSH_MAX_M * PPM, 0.01, "1.1 m owed, capped"
	)
	assert_true(push.normalized().dot(Vector2.DOWN) > 0.999, "away from the first body")
	assert_eq(StreetQuestDeadPlan.transform_of(a, first, PPM), t1, "the first never moves")
	assert_eq(StreetQuestDeadPlan.transform_of(b, second, PPM), t2, "the push is fixed")
	var far: Vector2 = a + Vector2(5.0 * PPM, 0)
	assert_eq(StreetQuestDeadPlan.push_of(StreetQuestDeadPlan.ID_BASE - 3, far, PPM), Vector2.ZERO)


func test_the_soak_spot_is_the_drawn_pelvis_when_the_plan_draws() -> void:
	var h: Fighter = _guard(4, Vector2.RIGHT)
	h.pos = Vector2(12.0, 30.0)
	h.hurt_tick = 0
	var got: Vector2 = StreetQuestDeadPlan.lying_m(h, 1000, PPM)
	if not ViewMode.shared().cards or not ResourceLoader.exists(StreetQuestDeadPlan.PATH):
		assert_eq(got, h.pos, "no plan pose: his own spot")
		return
	var t: Transform2D = StreetQuestDeadPlan.transform_of(h.pos * PPM, h, PPM, 1000)
	assert_almost_eq(got.x, t.origin.x / PPM, 0.0001)
	assert_almost_eq(got.y, t.origin.y / PPM, 0.0001)
	var off: float = got.distance_to(h.pos)
	assert_almost_eq(
		off, StreetDeadPlan.PELVIS_K * StreetQuestCards.body_m(), 0.01, "along the blow"
	)


func test_the_kill_pool_lies_under_the_settled_corpse() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	var reg: RngRegistry = RngRegistry.new(5)
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	var h: Fighter = _guard(6, Vector2.LEFT)
	h.pos = Vector2(20.0, 8.0)
	h.hurt_tick = 50
	arena.hostiles.append(h)  # alive: actor_killed fires before his hp drops
	var got: Vector2 = StreetQuestDeadPlan.pool_m(arena, 6, h.pos, false, PPM)
	assert_eq(got, StreetQuestDeadPlan.lying_m(h, 50 + StreetQuestDeadPlan.SETTLED, PPM))
	if ResourceLoader.exists(StreetQuestDeadPlan.PATH):
		assert_gt(got.distance_to(h.pos), 0.2, "the plan pelvis, not his standing spot")
	var spot: Vector2 = Vector2(1, 2)
	assert_eq(StreetQuestDeadPlan.pool_m(arena, 99, spot, false, PPM), spot, "no hostile: his spot")
	var on_rigs: Vector2 = StreetQuestDeadPlan.pool_m(arena, 6, h.pos, true, PPM)
	if not QuestGuardCast.ON:
		assert_eq(on_rigs, h.pos, "the rigs draw the dead: his own spot")
	ViewMode._shared = saved

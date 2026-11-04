extends GutTest


func _rig() -> Array:
	var t: PowerTable = PowerTable.load_default()
	var p: SoulPowers = SoulPowers.new(t)
	var h: HaulerForm = HaulerForm.new(t.hauler)
	h.bind(p)
	return [p, h]


func test_hauler_is_the_ghost_body_class_only_while_on() -> void:
	var r: Array = _rig()
	var p: SoulPowers = r[0]
	var h: HaulerForm = r[1]
	assert_eq(h.body_class, &"rivet_base")
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	assert_eq(h.body_class, &"rivet_ghost")
	assert_true(p.interrupt(&"car"))
	assert_eq(h.body_class, &"rivet_base")


func test_ghost_class_knocks_down_humans_and_robots_but_not_bosses() -> void:
	var b: BodyTable = BodyTable.load_default()
	assert_true(b.ok(), "; ".join(b.errors()))
	assert_eq(b.rule(&"rivet_ghost", &"human").run, &"knockdown")
	assert_eq(b.rule(&"rivet_ghost", &"robot").run, &"knockdown")
	assert_eq(b.rule(&"rivet_ghost", &"boss").run, &"blocked")
	var t: PowerTable = PowerTable.load_default()
	assert_lt(b.run_mps(&"rivet_ghost"), SoulTuning.num(t.hauler, &"top_mps"), "the tank can ram")


func test_morph_is_short_and_readable() -> void:
	var r: Array = _rig()
	var p: SoulPowers = r[0]
	var h: HaulerForm = r[1]
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	var n: int = 0
	while h.morph_k() < 1.0 and n < 600:
		h.step(Vector2.ZERO)
		n += 1
	assert_between(n, 6, 60, "morph between 0.1 and 1.0 s")


func test_heavy_movement_has_momentum_and_a_turn_limit() -> void:
	var r: Array = _rig()
	var p: SoulPowers = r[0]
	var h: HaulerForm = r[1]
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	for i: int in 120:
		h.step(Vector2.RIGHT)
	assert_almost_eq(h.vel.length(), h.num(&"top_mps"), 0.01)
	h.step(Vector2.LEFT)
	assert_gt(h.vel.x, 0.0, "a reverse does not flip in one tick")
	assert_true(h.ramming())


func test_stomp_knocks_down_inside_the_radius_then_cools() -> void:
	var r: Array = _rig()
	var p: SoulPowers = r[0]
	var h: HaulerForm = r[1]
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	var bodies: PackedVector2Array = [Vector2(1, 0), Vector2(0, 3.5), Vector2(9, 0)]
	var hits: Array[Dictionary] = h.stomp(Vector2.ZERO, bodies)
	assert_eq(hits.size(), 2)
	var push: Vector2 = hits[0]["push"]
	assert_gt(push.x, 0.0, "pushed away from the stomp")
	assert_eq(h.stomp(Vector2.ZERO, bodies).size(), 0, "stomp is on cooldown")


func test_no_stomp_in_base_form() -> void:
	var r: Array = _rig()
	var h: HaulerForm = r[1]
	assert_eq(h.stomp(Vector2.ZERO, PackedVector2Array([Vector2(1, 0)])).size(), 0)


func test_tank_rig_scale_matches_the_ghost_body_radius() -> void:
	var b: BodyTable = BodyTable.load_default()
	var tank: BodyPlan = RivetPlan.build(RivetPlan.FORM_HAULER)
	var body_k: float = b.radius(&"rivet_ghost") / b.radius(&"rivet_base")
	var k: float = tank.size_k / RivetPlan.BODY_SIZE_K
	assert_almost_eq(k, body_k, 0.05, "the art grows with the body")


func test_stomp_telegraphs_inside_the_readable_band_before_it_lands() -> void:
	var r: Array = _rig()
	var p: SoulPowers = r[0]
	var h: HaulerForm = r[1]
	assert_eq(p.try_activate(&"hauler"), SoulPowers.OK)
	assert_true(h.arm())
	assert_false(h.arm(), "one stomp at a time")
	var n: int = 0
	while not h.stomp_due() and n < 600:
		h.step(Vector2.ZERO)
		n += 1
	assert_between(n / 60.0, 0.25, 1.5, "wind-up seconds (realtime-combat-semantics band)")
	assert_eq(h.stomp(Vector2.ZERO, PackedVector2Array([Vector2(1, 0)])).size(), 1)
	assert_false(h.stomp_due())

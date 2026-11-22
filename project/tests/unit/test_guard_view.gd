extends GutTest

const FACING: Array[int] = [2, 1, 0, 1, 2, 3, 4, 3]
const FLIPPED: Array[bool] = [false, false, false, true, true, true, false, false]


func test_each_pitch_selects_every_facing_in_each_phase_at_the_standing_foot() -> void:
	var card: Sprite2D = add_child_autofree(Sprite2D.new())
	card.transform = Transform2D(0.6, Vector2(1.9, 0.7), 0.0, Vector2(40, 64))
	var previous_height: float = RivetFrames.height_k
	RivetFrames.height_k = 1.25
	for art: String in ["p70", "p55"]:
		var base: String = RivetStrips.DIR + art + "/" + RivetStrips.BASE
		var height: float = RivetFrames.HEIGHT_BY_ART.get(art, RivetFrames.HEIGHT_M)
		var scale_px: float = height * PlayerScale.k() * CharacterRigs.PX_PER_M
		scale_px *= RivetFrames.height_k / (RivetFrames.FIG_PX * RivetRes.of(base))
		for phase: int in 4:
			for octant: int in 8:
				PlayerGuardPose.apply(card, art, phase as PlayerGuardPose.Phase, octant)
				var pose: Sprite2D = card.get_node(PlayerGuardPose.CHILD)
				assert_eq(pose.frame, 5 * phase + FACING[octant])
				assert_eq(pose.flip_h, FLIPPED[octant])
		var sprite: Sprite2D = card.get_node(PlayerGuardPose.CHILD)
		assert_eq(sprite.texture.resource_path, RivetStrips.DIR + art + "/rivet_guard.png")
		assert_eq(sprite.hframes, 20)
		assert_false(sprite.centered)
		assert_true(sprite.use_parent_material)
		var width: float = sprite.texture.get_width() / 20.0
		var expected: Vector2 = Vector2(
			-width * 0.5, RivetStrips.foot_px(base) - sprite.texture.get_height()
		)
		assert_eq(sprite.offset, expected)
		assert_almost_eq(sprite.global_position, card.global_position, Vector2.ONE * 0.0001)
		assert_almost_eq(sprite.global_transform.x, Vector2.RIGHT * scale_px, Vector2.ONE * 0.0001)
		assert_almost_eq(sprite.global_transform.y, Vector2.DOWN * scale_px, Vector2.ONE * 0.0001)
		assert_eq(card.get_child_count(), 1)
	RivetFrames.height_k = previous_height


func test_lowered_and_unsupported_poses_release_the_card_at_its_existing_opacity() -> void:
	var card: Sprite2D = add_child_autofree(Sprite2D.new())
	card.self_modulate.a = 0.75
	PlayerGuardPose.apply(card, "", PlayerGuardPose.Phase.HELD, 0)
	PlayerGuardPose.apply(card, "p55", PlayerGuardPose.Phase.REST, 0)
	assert_eq(card.get_child_count(), 0)
	PlayerGuardPose.apply(card, "p70", PlayerGuardPose.Phase.LOW, 0)
	var sprite: Sprite2D = card.get_node(PlayerGuardPose.CHILD)
	assert_true(sprite.visible)
	assert_almost_eq(sprite.self_modulate.a, 0.75, 0.0001)
	assert_eq(card.self_modulate.a, 0.0)
	PlayerGuardPose.apply(card, "p70", PlayerGuardPose.Phase.MID, 0)
	PlayerGuardPose.apply(card, "p70", PlayerGuardPose.Phase.REST, 0)
	assert_false(sprite.visible)
	assert_almost_eq(card.self_modulate.a, 0.75, 0.0001)
	PlayerGuardPose.apply(card, "p55", PlayerGuardPose.Phase.HELD, 1)
	card.self_modulate.a = 0.5  # the live combo mix re-dressed the card
	PlayerGuardPose.apply(card, "p55", PlayerGuardPose.Phase.HELD, 2)
	assert_eq(card.self_modulate.a, 0.0)
	assert_almost_eq(sprite.self_modulate.a, 0.5, 0.0001)
	PlayerGuardPose.apply(card, "", PlayerGuardPose.Phase.HELD, 2)
	assert_false(sprite.visible)
	assert_almost_eq(card.self_modulate.a, 0.5, 0.0001)
	PlayerGuardPose.apply(card, "p55", PlayerGuardPose.Phase.LOW, 2)
	card.self_modulate.a = 1.0
	PlayerGuardPose.apply(card, "p55", PlayerGuardPose.Phase.REST, 2)
	assert_almost_eq(card.self_modulate.a, 1.0, 0.0001, "preserve a fresh mix on release")


func test_two_three_tick_in_betweens_in_both_directions() -> void:
	var view: PlayerGuardView = autofree(PlayerGuardView.new())
	var guard: PlayerGuard = PlayerGuard.new()
	var phases: Array[int] = []
	for tick: int in 16:
		guard.step(tick >= 1 and tick <= 8, true)
		var phase: PlayerGuardPose.Phase = view.phase_at(guard, tick)
		phases.append(phase)
		assert_eq(view.phase_at(guard, tick), phase, "repeat render at the same sim tick")
	assert_eq(phases, [-1, 0, 0, 0, 1, 1, 1, 2, 2, 1, 1, 1, 0, 0, 0, -1])
	guard.step(true, true)
	assert_eq(view.phase_at(guard, 20), PlayerGuardPose.Phase.MID, "five ticks elapsed")
	guard.step(false, true)
	assert_eq(view.phase_at(guard, 22), PlayerGuardPose.Phase.LOW, "partial raise reverses")


func test_a_broken_guard_draws_stagger_until_recovery() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(22).stream(&"combat")
	)
	var guard: PlayerGuard = PlayerGuard.new()
	var view: PlayerGuardView = autofree(PlayerGuardView.new())
	var card: Sprite2D = add_child_autofree(Sprite2D.new())
	var foe: Fighter = arena.spawn_guard(arena.rivet.pos + Vector2.RIGHT)
	arena.rivet.facing = arena.rivet.pos.direction_to(foe.pos)
	arena.guard = guard
	guard.step(true, true)
	assert_eq(view.phase_at(guard, 1), PlayerGuardPose.Phase.LOW)
	assert_eq(view.phase_at(guard, 9), PlayerGuardPose.Phase.HELD)
	for hit: int in ceili(guard.tuning.meter_max / guard.tuning.melee_drain):
		arena.damage(arena.rivet, 1.0, foe.id, &"baton", &"melee")
	assert_true(guard.broken())
	var duration: int = CombatTuning.ticks(guard.tuning.stagger_s)
	for i: int in duration:
		PlayerGuardPose.apply(card, "p70", view.phase_at(guard, 10 + i), 5)
		var sprite: Sprite2D = card.get_node(PlayerGuardPose.CHILD)
		assert_true(sprite.visible)
		assert_eq(sprite.frame, 18)
		assert_true(sprite.flip_h)
		guard.step(true, true)
	assert_eq(view.phase_at(guard, 10 + duration), PlayerGuardPose.Phase.REST)


func test_flat_guard_lowers_the_body_and_keeps_the_clip_inputs() -> void:
	var previous: ViewMode = ViewMode.shared()
	ViewMode.select("top")
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.setup(RivetPlan.build(), RigVariant.rivet())
	rig.drive(SimClock.TICK_DT)
	var body_scale: float = rig.body.scale.x
	var resting_hand: Vector2 = rig.sides[0].j_hand
	PlayerGuardView.pose(rig, PlayerGuardPose.Phase.HELD)
	assert_lt(rig.body.scale.x, body_scale)
	assert_ne(rig.sides[0].j_hand, resting_hand)
	assert_eq(rig.c_tuck, 0.0)
	assert_eq(rig.c_hands_up, 0.0)
	var guard_hand: Vector2 = rig.sides[0].j_hand
	PlayerGuardView.pose(rig, PlayerGuardPose.Phase.STAGGER)
	assert_ne(rig.sides[0].j_hand, guard_hand)
	assert_eq(rig.c_sprawl, 0.0)
	ViewMode._shared = previous

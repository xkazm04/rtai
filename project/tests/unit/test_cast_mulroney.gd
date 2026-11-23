extends GutTest

const SERGEANT: StringName = &"sergeant_mulroney"


func test_body_scale_follows_preview_row_at_both_pitches() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.sergeant_mulroney.enabled = true
	var cards: CastCards = CastCards.from_table(table)
	for pitch: String in ["p55", "p70"]:
		assert_eq(cards.lookup(SERGEANT, pitch).body_scale, 1.11)
		assert_eq(cards.lookup(&"rocket_trooper", pitch).body_scale, 1.0)


func test_far_walk_uses_measured_texel_scale_and_releases_for_attack() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.sergeant_mulroney.enabled = true
	var cards: CastCards = CastCards.from_table(table)
	var pose: CastCardPose = CastCardPose.new()
	var h: Fighter = Fighter.new()
	h.hp = 10
	h.facing = Vector2.RIGHT
	h.hurt_tick = -100
	var far: CastFarCard = autofree(CastFarCard.new())
	for art: String in ["p55", "p70"]:
		pose.sheets = cards.lookup(SERGEANT, art)
		assert_eq(pose.sheets.walk.get_file(), StreetMulroneyAnchors.WALK)
		if StreetMulroneyAnchors.WALK == StreetMulroneyAnchors.FOUR:
			continue
		h.pos = Vector2.ZERO
		pose.attack = -1
		far.draw_pose(pose, h, true, 0)
		assert_eq(far.vframes, 8)
		assert_eq(far._contact.step_m, StreetMulroneyAnchors.STEP_M)
		assert_almost_eq(far.offset.y, -224.0, 0.001)
		h.pos += Vector2.RIGHT * (StreetMulroneyAnchors.STEP_M + 0.0001)
		far.draw_pose(pose, h, true, 1)
		assert_eq(far.frame_coords, Vector2i(2, 1))
		far.draw_pose(pose, h, false, 2)
		assert_eq(far.position, h.pos * SimConst.PX_PER_M)
		assert_almost_eq(far.skew, 0.0, 0.001)
		pose.attack = 2
		far.draw_pose(pose, h, false, 3)
		assert_eq(far.frame_coords, Vector2i(2, 2))
		assert_eq(far.vframes, 4)
		assert_null(far._contact)


func test_tell_shot_and_both_halves_of_the_pump() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(22).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-20, -20, 40, 40), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ONE, SERGEANT)
	var mind: SquadMind = arena.squad_ai.mind_for(h)
	arena.tick = 23
	assert_eq(FoeCastView.attack_row(h, arena), -1)
	for left: int in [30, 1]:
		h.tell_left = left
		assert_eq(FoeCastView.attack_row(h, arena), 0)
	h.tell_left = 0
	mind.agent.shot_tick = arena.tick
	assert_eq(FoeCastView.attack_row(h, arena), 1)
	arena.tick += 1
	for progress: float in [0.0, 0.01, 0.49999]:
		FoeCastView.set_pump(h, progress)
		assert_eq(FoeCastView.attack_row(h, arena), 2)
	for progress: float in [0.5, 0.99, 1.0]:
		FoeCastView.set_pump(h, progress)
		assert_eq(FoeCastView.attack_row(h, arena), 3)
	FoeCastView.set_pump(h, -0.001)
	assert_eq(FoeCastView.attack_row(h, arena), -1)
	h.tell_left = 1
	assert_eq(FoeCastView.attack_row(h, arena), 0)


func test_pump_sample_belongs_to_one_fighter() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(1).stream(&"combat")
	)
	var a: Fighter = arena.spawn_guard(Vector2.ZERO)
	var b: Fighter = arena.spawn_guard(Vector2.ONE)
	a.archetype = SERGEANT
	b.archetype = SERGEANT
	FoeCastView.set_pump(a, 0.0, true)
	assert_eq(FoeCastView.attack_row(a, arena), 1, "yard discharge tick without a squad mind")
	FoeCastView.set_pump(a, 0.01)
	assert_eq(FoeCastView.attack_row(a, arena), 2)
	FoeCastView.set_pump(a, 0.8)
	assert_eq(FoeCastView.attack_row(a, arena), 3)
	assert_eq(FoeCastView.attack_row(b, arena), -1)
	FoeCastView.set_pump(a, -1.0)
	FoeCastView.set_pump(a, -1.0)
	assert_eq(FoeCastView.attack_row(a, arena), -1)

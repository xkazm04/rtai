extends GutTest

const TROOPER: StringName = &"rocket_trooper"


func test_shipped_cast_lists_each_pitch_and_action() -> void:
	var cards: CastCards = CastCards.shipped()
	for pitch: String in ["p70", "p55"]:
		var s: CastCards.Sheets = cards.lookup(TROOPER, pitch)
		assert_not_null(s)
		if s == null:
			continue
		var expected: Array[String] = ["armed_walk", "attack", "hit", "fall"]
		var rows: Array[int] = [4, 4, 1, 3]
		var paths: Array[String] = [s.walk, s.attack, s.hit, s.fall]
		for i: int in paths.size():
			assert_eq(
				paths[i], RigHeadCard.ART_DIR + "%s/rocket_trooper_%s.png" % [pitch, expected[i]]
			)
			var tex: Texture2D = load(paths[i]) as Texture2D
			assert_not_null(tex)
			assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0)
			assert_eq(tex.get_height() % rows[i], 0)
	assert_null(cards.lookup(TROOPER, "top"))
	assert_null(cards.lookup(&"swat", "p70"))


func test_disabled_archetype_releases_both_pitches() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	table.raw.archetypes.rocket_trooper.enabled = false
	var cards: CastCards = CastCards.from_table(table)
	assert_null(cards.lookup(TROOPER, "p55"))
	assert_null(cards.lookup(TROOPER, "p70"))


func test_stomp_is_optional_per_pitch_for_any_archetype() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	var cards: CastCards = CastCards.from_table(table)
	for pitch: String in ["p55", "p70"]:
		assert_eq(cards.lookup(TROOPER, pitch).stomp, "")
		var walker: CastCards.Sheets = cards.lookup(&"war_machine", pitch)
		assert_eq(walker.stomp, RigHeadCard.ART_DIR + pitch + "/war_machine_stomp.png")
		assert_true(ResourceLoader.exists(walker.stomp))
	table.raw.archetypes.rocket_trooper.p55.stomp = "trooper_stomp.png"
	var walker_pitch: Dictionary = table.raw.archetypes.war_machine.p70
	@warning_ignore("return_value_discarded")
	walker_pitch.erase("stomp")
	cards = CastCards.from_table(table)
	assert_true(table.ok())
	assert_eq(cards.lookup(TROOPER, "p55").stomp, RigHeadCard.ART_DIR + "p55/trooper_stomp.png")
	assert_eq(cards.lookup(TROOPER, "p70").stomp, "")
	assert_eq(cards.lookup(&"war_machine", "p70").stomp, "")


func test_tell_lock_shot_and_recovery_boundaries() -> void:
	var lock_ticks: int = 10
	for left: int in [60, lock_ticks + 1]:
		assert_eq(CastCardPose.attack_frame(left, lock_ticks, -1), 0)
	for left: int in [lock_ticks, 1]:
		assert_eq(CastCardPose.attack_frame(left, lock_ticks, -1), 1)
	assert_eq(CastCardPose.attack_frame(0, lock_ticks, -1), -1, "interrupted tell")
	assert_eq(CastCardPose.attack_frame(0, lock_ticks, 0), 2)
	for age: int in range(1, CastCardPose.RECOVERY_TICKS + 1):
		assert_eq(CastCardPose.attack_frame(0, lock_ticks, age), 3)
	assert_eq(CastCardPose.attack_frame(0, lock_ticks, CastCardPose.RECOVERY_TICKS + 1), -1)


func test_live_firing_tick_selects_the_discharge() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(22).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2(13, 0), TROOPER)
	h.cooldown = 0
	var saw: Array[bool] = [false, false, false, false]
	for tick: int in range(1, 361):
		arena.step(tick)
		var row: int = FoeCastView.attack_row(h, arena)
		if h.tell_left > 0:
			assert_eq(row, 1 if arena.guard_tell.locked(h) else 0)
		if not arena.shots.is_empty() and not saw[2]:
			assert_eq(row, 2, "first frame containing the launched round")
		if row >= 0:
			saw[row] = true
		if saw[3]:
			break
	assert_eq(saw, [true, true, true, true])


func test_carrier_steps_from_windup_to_shove_to_recovery() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(9).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ONE, &"shield_robot")
	var mind: SquadMind = arena.squad_ai.mind_for(h)
	h.swing_left = mind.agent.arch.telegraph_ticks
	assert_eq(FoeShieldCardView.attack_row(h, arena), 0)
	h.swing_left = 1
	assert_eq(FoeShieldCardView.attack_row(h, arena), 1)
	h.swing_left = 0
	mind.shield.lunge_left = FoeShield.LUNGE_TICKS
	assert_eq(FoeShieldCardView.attack_row(h, arena), 2)
	mind.shield.lunge_left = 0
	mind.agent.shot_tick = arena.tick
	assert_eq(FoeShieldCardView.attack_row(h, arena), 2)
	arena.tick += 1
	assert_eq(FoeShieldCardView.attack_row(h, arena), 3)
	for pitch: String in ["p55", "p70"]:
		var sheets: CastCards.Sheets = CastCards.shipped().lookup(h.archetype, pitch)
		assert_not_null(sheets)
		for path: String in [sheets.walk, sheets.attack, sheets.hit, sheets.fall]:
			assert_true(ResourceLoader.exists(path))

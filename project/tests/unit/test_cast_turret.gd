extends GutTest


func test_turret_rows_follow_tell_shot_and_cooling() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(32).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var turret: Fighter = arena.squad_ai.spawn_member(arena, Vector2.RIGHT * 6, &"sentry_turret")
	var mind: SquadMind = arena.squad_ai.mind_for(turret)
	turret.tell_left = 0
	assert_eq(FoeTurretCardView.attack_row(turret, mind, 60), 0)
	turret.tell_left = 1
	assert_eq(FoeTurretCardView.attack_row(turret, mind, 60), 1)
	mind.agent.shot_tick = 60
	assert_eq(FoeTurretCardView.attack_row(turret, mind, 60), 2)
	turret.tell_left = 0
	mind.turret.phase = FoeTurret.Phase.COOL
	assert_eq(FoeTurretCardView.attack_row(turret, mind, 61), 3)


func test_turret_grids_and_switch_at_both_pitches() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	for pitch: String in ["p70", "p55"]:
		var sheets: CastCards.Sheets = CastCards.shipped().lookup(&"sentry_turret", pitch)
		assert_not_null(sheets)
		if sheets == null:
			return
		for path: String in [sheets.attack, sheets.hit, sheets.fall]:
			var tex: Texture2D = StreetStrips.get_tex(path)
			assert_eq(tex.get_width(), FoeTurretCardView.CELL * RigHeadCard.FRAMES)
			var rows: int = 4 if path == sheets.attack else (1 if path == sheets.hit else 3)
			assert_eq(tex.get_height(), FoeTurretCardView.CELL * rows)
	table.raw.archetypes.sentry_turret.enabled = false
	var cards: CastCards = CastCards.from_table(table)
	assert_null(cards.lookup(&"sentry_turret", "p55"))
	assert_null(cards.lookup(&"sentry_turret", "p70"))

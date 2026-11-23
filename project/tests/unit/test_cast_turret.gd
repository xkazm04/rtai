extends GutTest

var _arena: CombatArena
var _turret: Fighter
var _mind: SquadMind
var _card: FoeTurretCardView
var _previous_mode: ViewMode


func before_each() -> void:
	_previous_mode = ViewMode.shared()
	ViewMode.select("combo")
	_arena = CombatArena.new(CombatTuning.shipped(), Events, RngRegistry.new(32).stream(&"combat"))
	_arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	_arena.squad_ai = ArenaSquad.new(_arena.guard_map)
	_turret = _arena.squad_ai.spawn_member(_arena, Vector2(6, 2), &"sentry_turret")
	_mind = _arena.squad_ai.mind_for(_turret)
	_card = add_child_autofree(FoeTurretCardView.new())


func after_each() -> void:
	ViewMode._shared = _previous_mode


func test_turret_rows_follow_tell_shot_and_cooling() -> void:
	_turret.tell_left = 0
	assert_eq(FoeTurretCardView.attack_row(_turret, _mind, 60), 0)
	_turret.tell_left = 1
	assert_eq(FoeTurretCardView.attack_row(_turret, _mind, 60), 1)
	_mind.agent.shot_tick = 60
	assert_eq(FoeTurretCardView.attack_row(_turret, _mind, 60), 2)
	_turret.tell_left = 0
	_mind.turret.phase = FoeTurret.Phase.COOL
	assert_eq(FoeTurretCardView.attack_row(_turret, _mind, 61), 3)
	_mind.turret = null
	assert_eq(FoeTurretCardView.attack_row(_turret, _mind, 60), 0)


func test_hit_expires_at_twelve_and_collapse_advances_inside_the_fall_sheet() -> void:
	var sheets: CastCards.Sheets = CastCards.current(&"sentry_turret")
	_turret.facing = Vector2.LEFT
	_turret.hurt_tick = 80
	_turret.tell_left = 1
	_expect(79, sheets.attack, Vector2i(2, 1))
	_expect(80, sheets.hit, Vector2i(2, 0))
	_expect(91, sheets.hit, Vector2i(2, 0))
	_expect(92, sheets.attack, Vector2i(2, 1))
	_turret.hp = 0
	_expect(80, sheets.fall, Vector2i(2, 0))
	_expect(85, sheets.fall, Vector2i(2, 1))
	_expect(90, sheets.fall, Vector2i(2, 2))


func test_mirrored_gun_and_fixed_apron_share_the_plate_ground_point() -> void:
	for pitch: String in ["p55", "p70"]:
		ViewMode.shared().art = pitch
		var sheets: CastCards.Sheets = CastCards.current(&"sentry_turret")
		_turret.facing = Vector2.LEFT
		_expect(60, sheets.attack, Vector2i(2, 0))
		assert_true(_card.flip_h)
		assert_false(_card.centered)
		assert_eq(_card.offset, Vector2(-128, -141))
		assert_eq(_card.position, _turret.pos * SimConst.PX_PER_M)
		var depth: float = 131.0 if pitch == "p55" else 138.0
		assert_almost_eq(
			_card.scale * Vector2(160, depth),
			Vector2.ONE * 1.4 * SimConst.PX_PER_M,
			Vector2.ONE * 0.001
		)
		_turret.facing = Vector2.DOWN
		_expect(61, sheets.attack, Vector2i(0, 0))
		assert_false(_card.flip_h)
		var apron: Sprite2D = _card.get_child(0) as Sprite2D
		assert_eq(apron.texture, _card.texture)
		assert_false(apron.flip_h)
		assert_eq(apron.position, Vector2(-128, 73))
		assert_eq(apron.region_rect, Rect2(0, 214, 256, 10))


func _expect(tick: int, path: String, cell: Vector2i) -> void:
	_arena.tick = tick
	_card.update_fighter(_turret, _arena, CastCards.current(&"sentry_turret"))
	assert_eq(_card.texture, StreetStrips.get_tex(path))
	assert_eq(_card.frame_coords, cell)
	assert_eq(
		Vector2i(_card.hframes, _card.vframes) * 256,
		Vector2i(StreetStrips.get_tex(path).get_size())
	)


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

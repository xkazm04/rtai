extends GutTest

const WALKER: StringName = &"war_machine"
var _previous_mode: ViewMode
var _previous_cards: CastCards
var _host: ArenaRobotRigs
var _h: Fighter
var _mind: SquadMind
var _table: DataTable


func before_each() -> void:
	_previous_mode = ViewMode.shared()
	_previous_cards = CastCards.shipped()
	ViewMode.select("combo")
	_table = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	_table.raw.archetypes.war_machine.enabled = true
	CastCards._library = CastCards.from_table(_table)
	_host = add_child_autofree(ArenaRobotRigs.new())
	_host.rigs = add_child_autofree(CharacterRigs.new())
	_host.arena = CombatArena.new(CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"war"))
	var arena: CombatArena = _host.arena
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	_h = arena.squad_ai.spawn_member(arena, Vector2(4, 6), WALKER)
	_mind = arena.squad_ai.mind_for(_h)
	_h.facing = Vector2.LEFT


func after_each() -> void:
	CastCards._library = _previous_cards
	ViewMode._shared = _previous_mode


func test_robot_host_swaps_rig_and_restores_main_with_row_off() -> void:
	_host._process(0.0)
	var rig: CutRig = _host.rig_for(_h.id)
	var card: FoeWarCardView = rig.get_meta(FoeWarCardView.CARD)
	assert_false(rig.visible)
	assert_true(card.visible)
	assert_true(card.flip_h)
	assert_eq(card.position, _h.pos * SimConst.PX_PER_M)
	assert_eq(card.frame_coords, Vector2i(2, StreetWalkerCards.STAND_FRAME))
	_host.consumed[_h.id] = true
	_host._process(0.0)
	assert_false(card.visible)
	_host.consumed.clear()
	_table.raw.archetypes.war_machine.enabled = false
	CastCards._library = CastCards.from_table(_table)
	_host._process(0.0)
	assert_true(rig.visible)
	assert_false(card.visible)


func test_both_pitches_follow_weapon_recovery_hit_and_wreck() -> void:
	for pitch: String in ["p55", "p70"]:
		ViewMode.shared().art = pitch
		var sheets: CastCards.Sheets = CastCards.current(WALKER)
		assert_eq(sheets.stomp, RigHeadCard.ART_DIR + pitch + "/war_machine_stomp.png")
		_h.hp = 50
		_h.hurt_tick = -1000
		_check_attack(sheets, false)
		_check_attack(sheets, true)
		_h.hurt_tick = _host.arena.tick
		_expect(sheets.hit, 0)
		_h.hp = 0
		_expect(sheets.fall, 0)
		_host.arena.tick += 5
		_expect(sheets.fall, 1)
		_host.arena.tick += 5
		_expect(sheets.fall, 2)


func test_held_walk_cell_plants_its_foot_and_next_contact_advances() -> void:
	_host._process(0.0)
	var card: FoeWarCardView = _host.rig_for(_h.id).get_meta(FoeWarCardView.CARD)
	var start: Vector2 = card.position
	_h.pos.x += 0.1
	_host._process(0.0)
	assert_eq(card.position, start)
	_h.pos.x += 0.3
	_host._process(0.0)
	assert_eq(card.frame_coords.y, 1)
	assert_eq(card.position, _h.pos * SimConst.PX_PER_M)
	assert_true(card._shadow.is_visible_in_tree())
	assert_eq(card._shadow.get_child_count(), RigCastShadows.CONTACT_RINGS.size())


func test_stomp_without_art_keeps_the_locomotion_pose() -> void:
	var sheets: CastCards.Sheets = CastCards.current(WALKER)
	sheets.stomp = ""
	_mind.walker.attack = _mind.agent.arch.alt_weapon
	_mind.agent.enter(EnemyAgent.State.WINDUP, 1)
	_expect(sheets.walk, StreetWalkerCards.STAND_FRAME)
	_mind.agent.enter(EnemyAgent.State.RECOVER)
	_h.cooldown = 1
	_expect(sheets.walk, StreetWalkerCards.STAND_FRAME)


func test_walker_card_projects_the_boot_line_and_two_point_six_metre_body() -> void:
	for deg: int in [55, 70]:
		ViewMode.shared().pitch_deg = deg
		ViewMode.shared().art = "p%d" % deg
		_expect(CastCards.current(WALKER).walk, StreetWalkerCards.STAND_FRAME)
		var card: FoeWarCardView = _host.rig_for(_h.id).get_meta(FoeWarCardView.CARD)
		assert_false(card.centered)
		assert_eq(card.offset, Vector2(-144, -264))
		var projected: Vector2 = card.scale * Vector2(1.0, sin(deg_to_rad(deg))) * 200.0
		var tall: float = 2.6 * CastCards.current(WALKER).body_scale  # n29: one value per row
		assert_almost_eq(projected, Vector2.ONE * tall * SimConst.PX_PER_M, Vector2.ONE * 0.001)


func test_recovery_glow_tracks_the_printed_grille_at_both_pitches() -> void:
	for deg: int in [55, 70]:
		ViewMode.shared().art = "p%d" % deg
		var cannon: Array[Vector2i] = [Vector2i(104, 148), Vector2i(104, 168), Vector2i(142, 170)]
		var stomp: Array[Vector2i] = [Vector2i(100, 140), Vector2i(120, 156), Vector2i(144, 176)]
		if deg == 55:
			cannon = [Vector2i(98, 126), Vector2i(108, 148), Vector2i(144, 154)]
			stomp = [Vector2i(92, 136), Vector2i(94, 146), Vector2i(142, 160)]
		_check_grilles(false, cannon)
		_check_grilles(true, stomp)


func _check_grilles(stomp: bool, centres: Array[Vector2i]) -> void:
	var sheets: CastCards.Sheets = CastCards.current(WALKER)
	var e: EnemyAgent = _mind.agent
	_mind.walker.attack = e.arch.alt_weapon if stomp else e.arch.weapon
	e.enter(EnemyAgent.State.RECOVER)
	e.shot_tick = _host.arena.tick - CastCardPose.RECOVERY_TICKS
	var directions: Array[Vector2] = [Vector2.LEFT, Vector2(-1, -1), Vector2.UP]
	var path: String = sheets.stomp if stomp else sheets.attack
	_h.cooldown = 1
	for i: int in directions.size():
		_h.facing = directions[i]
		_expect(path, 3, i + 2)
		var card: FoeWarCardView = _host.rig_for(_h.id).get_meta(FoeWarCardView.CARD)
		var vent: Sprite2D = card._vent
		assert_not_null(vent)
		if vent == null:
			return
		assert_true(vent.visible)
		assert_eq(vent.texture, card.texture)
		assert_almost_eq(vent.modulate.a, 1.0 / _mind.walker.attack.cooldown_ticks, 0.001)
		var centre: Vector2 = Vector2(centres[i])
		var origin: Vector2 = Vector2(i + 2, 3) * 288.0
		assert_eq(vent.region_rect, Rect2(origin + centre - Vector2(9, 10.5), Vector2(18, 21)))
		var mount: Vector2 = card.offset + centre
		assert_eq(vent.flip_h, i < 2)
		assert_eq(vent.position, Vector2(-mount.x if i < 2 else mount.x, mount.y))
	_h.cooldown = 0
	_expect(path, 3, 4)
	var cold: FoeWarCardView = _host.rig_for(_h.id).get_meta(FoeWarCardView.CARD)
	assert_false(cold._vent.visible)


func _check_attack(sheets: CastCards.Sheets, stomp: bool) -> void:
	var e: EnemyAgent = _mind.agent
	var path: String = sheets.stomp if stomp else sheets.attack
	_mind.walker.attack = e.arch.alt_weapon if stomp else e.arch.weapon
	e.enter(
		EnemyAgent.State.WINDUP, e.arch.alt_telegraph_ticks if stomp else e.arch.telegraph_ticks
	)
	_expect(path, 3 if stomp else 0)
	e.timer = floori(e.timer * 0.5) + 1
	_expect(path, 3 if stomp else 0)
	e.timer -= 1
	_expect(path, 0 if stomp else 1)
	e.enter(EnemyAgent.State.RECOVER)
	e.shot_tick = _host.arena.tick
	_h.cooldown = _mind.walker.attack.cooldown_ticks
	_expect(path, 1 if stomp else 2)
	_host.arena.tick += 1
	_expect(path, 2 if stomp else 3)
	_host.arena.tick += CastCardPose.RECOVERY_TICKS - 2
	_expect(path, 2 if stomp else 3)
	_host.arena.tick += 1
	_expect(path, 3)


func _expect(path: String, row: int, column: int = 2) -> void:
	_host._process(0.0)
	var card: FoeWarCardView = _host.rig_for(_h.id).get_meta(FoeWarCardView.CARD)
	assert_eq(card.texture.resource_path, path)
	assert_eq(card.frame_coords, Vector2i(column, row))
	assert_eq(Vector2i(card.hframes, card.vframes) * 288, Vector2i(card.texture.get_size()))
	if _mind.agent.state == EnemyAgent.State.WINDUP:
		assert_true(card._vent == null or not card._vent.visible)

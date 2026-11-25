extends GutTest
## n30 combat (owner, decisions 1598): a killed card foe falls on his own fall sheet when the kill
## style has none (KillFallCells.attach -> KillCardFall); a style with own cells keeps them; a
## street walker keeps the generic grid; `--kill-card-fall=grid` (KillCardFall.set_on(0)) is the
## before; a card row whose sheet is missing or does not split keeps the generic grid.

const SERGEANT: StringName = &"sergeant_mulroney"
## The card rows on, and the one the cast lane may turn on.
const ROWS: Array[StringName] = [
	&"sergeant_mulroney", &"appliance_warden", &"contractor", &"rocket_trooper", &"robot_thug"
]
const MISSING: String = "res://features/characters/art/view/p70/nobody_fall.png"

var _mode: ViewMode


func before_each() -> void:
	_mode = ViewMode.shared()
	ViewMode.select("combo")
	KillCardFall.set_on(1)


func after_each() -> void:
	ViewMode._shared = _mode
	KillCardFall.set_on(-1)


## A near card foe of `archetype` on a pooled rig, posed one tick (FoeCastView's near path).
func _card_foe(archetype: StringName) -> CutRig:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(bus, data, 3)
	var host: ArenaRigs = autofree(ArenaRigs.new())
	add_child_autofree(host.rigs)
	host.rigs.setup(ctx)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, ctx.rng.stream(&"combat"))
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ZERO, archetype)
	@warning_ignore("return_value_discarded")
	arena.squad_ai.mind_for(h)
	var view: FoeCastView = FoeCastView.attach(host, arena)
	host._put(0, h, BodyPlan.Kind.COP)
	host.rigs.feed.looks[0] = RigVariant.SWAT
	view.feed(h, 0)
	host.react.apply(host.rigs)
	host.rigs.step_ticks(1)
	view._process(0.0)
	return host.rigs.rig_for(h.id)


## A kill style with no own cells (the track only).
func _bare() -> KillTrackRows.Extra:
	return KillTrackRows.Extra.new()


func _attach(rig: CutRig, extra: KillTrackRows.Extra) -> Sprite2D:
	var body: Node2D = autofree(Node2D.new())
	return KillFallCells.attach(rig, body, Vector2.RIGHT, extra)


func _generic(rig: CutRig) -> String:
	var art: String = ViewMode.shared().art
	return StreetWalkerCards.DIR + StreetWalkerFall.path_of(art, StreetWalkerCards.row_of(rig))


func _want_scale(rig: CutRig, path: String) -> float:
	var art: String = path.trim_prefix(StreetWalkerCards.DIR).get_slice("/", 0)
	var h: float = StreetWalkerCards.HEIGHT_BY_ART.get(art, StreetWalkerCards.HEIGHT_M)
	var k: float = CastCardPose.of(rig).sheets.scale_of(rig.actor_id)
	return h * CharacterRigs.PX_PER_M * k / StreetWalkerFall.STILL_PX


func test_a_card_foe_falls_on_his_own_sheet_at_his_card_scale() -> void:
	for archetype: StringName in [SERGEANT, &"appliance_warden", &"contractor"]:
		var rig: CutRig = _card_foe(archetype)
		var pose: CastCardPose = CastCardPose.of(rig)
		assert_not_null(pose, str(archetype))
		var cells: Sprite2D = _attach(rig, _bare())
		assert_not_null(cells, str(archetype))
		if pose == null or cells == null:
			continue
		assert_eq(cells.texture.resource_path, pose.sheets.fall, str(archetype))
		assert_ne(cells.texture.resource_path, _generic(rig), str(archetype))
		assert_eq(cells.hframes, RigHeadCard.FRAMES)
		assert_eq(cells.vframes, StreetWalkerFall.FALL_FRAMES)
		assert_false(KillDeathCells.owns(cells))
		assert_almost_eq(cells.scale.x, _want_scale(rig, pose.sheets.fall), 1e-5, str(archetype))


func test_a_style_with_own_cells_keeps_them() -> void:
	var rig: CutRig = _card_foe(SERGEANT)
	var extra: KillTrackRows.Extra = KillTrackRows.Extra.new()
	extra.cells_at = PackedInt32Array([0, 4, 14])
	extra.grids = {"p70": {"*": "contractor_fall.png"}, "p55": {"*": "contractor_fall.png"}}
	var cells: Sprite2D = _attach(rig, extra)
	assert_not_null(cells)
	if cells != null:
		assert_true(KillDeathCells.owns(cells))
		assert_string_ends_with(cells.texture.resource_path, "/contractor_fall.png")
		assert_eq(cells.vframes, 3)


## The shipped stitch (machine pistol) has cells for the street rows only: his rig's row
## (cop/head_swat) would draw a SWAT man's stitch, so a card foe falls on his own sheet.
func test_street_row_cells_are_not_his_own() -> void:
	var rig: CutRig = _card_foe(SERGEANT)
	var extra: KillTrackRows.Extra = KillTrackRows.of(&"smg_stitch")
	var row: String = StreetWalkerCards.row_of(rig)
	assert_ne(KillDeathCells.path_of(extra, "p70", row), "", "the stitch draws his street row")
	var cells: Sprite2D = _attach(rig, extra)
	assert_not_null(cells)
	if cells != null:
		assert_eq(cells.texture.resource_path, CastCardPose.of(rig).sheets.fall)
		assert_false(KillDeathCells.owns(cells))


func test_the_grid_flag_keeps_the_street_row_cells() -> void:
	KillCardFall.set_on(0)
	var rig: CutRig = _card_foe(SERGEANT)
	var extra: KillTrackRows.Extra = KillTrackRows.of(&"smg_stitch")
	var want: String = KillDeathCells.path_of(extra, "p70", StreetWalkerCards.row_of(rig))
	var cells: Sprite2D = _attach(rig, extra)
	assert_not_null(cells)
	if cells != null:
		assert_eq(cells.texture.resource_path, StreetWalkerCards.DIR + want)
		assert_true(KillDeathCells.owns(cells))


func test_the_grid_flag_keeps_the_generic_grid() -> void:
	KillCardFall.set_on(0)
	var rig: CutRig = _card_foe(SERGEANT)
	assert_eq(KillCardFall.path_of(rig), "")
	var cells: Sprite2D = _attach(rig, _bare())
	assert_not_null(cells)
	if cells != null:
		assert_eq(cells.texture.resource_path, _generic(rig))


func test_a_row_without_a_usable_sheet_keeps_the_generic_grid() -> void:
	var rig: CutRig = _card_foe(SERGEANT)
	var pose: CastCardPose = CastCardPose.of(rig)
	var own: CastCards.Sheets = CastCards.Sheets.new()
	own.body_scale = pose.sheets.body_scale
	own.fall = MISSING
	pose.sheets = own  # a copy: the shipped library's sheets stay as they are
	assert_eq(KillCardFall.path_of(rig), "")
	var cells: Sprite2D = _attach(rig, _bare())
	assert_not_null(cells)
	if cells != null:
		assert_eq(cells.texture.resource_path, _generic(rig))
		assert_almost_eq(cells.scale.x, _want_scale(rig, _generic(rig)), 1e-5)


func test_a_street_walker_keeps_the_generic_grid() -> void:
	var pool: RigPool = RigPool.new()
	add_child_autoqfree(pool)
	@warning_ignore("return_value_discarded")
	pool.prewarm(BodyPlan.Kind.PED, 1)
	var rig: CutRig = pool.acquire(BodyPlan.Kind.PED, RigVariant.crowd(0), Vector2.ZERO, 0.0)
	rig.actor_id = 7
	rig.drive(SimClock.TICK_DT)
	assert_null(CastCardPose.of(rig))
	assert_eq(KillCardFall.path_of(rig), "")
	for row: String in ["ped/head_hair", "cop/head_swat", "thug"]:
		assert_eq(KillCardFall.cells_row("", row), row, row)
		var want: String = StreetWalkerFall.path_of("p70", row)
		assert_eq(KillCardFall.grid("", "p70", row), want, row)


func test_usable_takes_only_a_splitting_fall_sheet_under_the_view_dir() -> void:
	assert_eq(KillCardFall.usable(MISSING), "")
	assert_eq(KillCardFall.usable("res://elsewhere/sergeant_mulroney_fall.png"), "")
	var walk: String = StreetWalkerCards.DIR + "p70/sergeant_mulroney_armed_walk.png"
	assert_eq(KillCardFall.usable(walk), "")
	var fall: String = StreetWalkerCards.DIR + "p70/sergeant_mulroney_fall.png"
	assert_eq(KillCardFall.usable(fall), "p70/sergeant_mulroney_fall.png")


## The routing per card row (evidence): every row's fall sheet at both pitches is usable.
func test_every_card_row_has_a_usable_fall_sheet() -> void:
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	var rows: Dictionary = table.object(table.raw, "archetypes")
	for id: StringName in ROWS:
		var row: Dictionary = rows.get(String(id), {})
		for pitch: String in ["p70", "p55"]:
			var paths: Dictionary = row.get(pitch, {})
			var full: String = RigHeadCard.ART_DIR + pitch + "/" + str(paths.get("fall", ""))
			assert_ne(KillCardFall.usable(full), "", "%s %s" % [id, pitch])

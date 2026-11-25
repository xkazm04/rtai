extends GutTest
## Robot thug A: the card replaces his robot rig's drawing only; sim state is only read.


func after_each() -> void:
	CastCards._library = null


func test_thug_row_is_off_and_his_rig_draws_as_before() -> void:
	CastCards._library = null
	assert_null(CastCards.shipped().lookup(FoeThugCardView.ID, "p70"))
	assert_null(CastCards.shipped().lookup(FoeThugCardView.ID, "p55"))
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.archetype = FoeThugCardView.ID
	h.machine = true
	assert_true(FoeThugCardView.show_rig(host, h, rig, true))
	assert_false(FoeThugCardView.show_rig(host, h, rig, false))
	assert_false(rig.has_meta(FoeThugCardView.CARD))


func test_thug_card_walks_the_eight_at_both_pitches() -> void:
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	var cards: CastCards = CastCards.shipped()
	for pitch: String in ["p55", "p70"]:
		var sheets: CastCards.Sheets = cards.lookup(FoeThugCardView.ID, pitch)
		assert_not_null(sheets)
		assert_true(sheets.walk.ends_with(CastThugAnchors.EIGHT), pitch)
		assert_true(CastCards.anchored(sheets.walk))
		assert_true(CastCards.padded(sheets.attack))
		assert_true(CastCards.padded(sheets.hit))
		assert_false(CastCards.padded(sheets.fall))
		assert_almost_eq(sheets.scale_of(7), sheets.body_scale, 1e-6)
		assert_eq(CastCardKinds.four_of(CastThugAnchors.EIGHT), CastThugAnchors.FOUR)
		assert_gt(CastCardKinds.foe_step(CastThugAnchors.EIGHT), 0.0)


func test_thug_anchors_cover_every_cell() -> void:
	for low: bool in [false, true]:
		var marks: Array[Vector4] = CastCardKinds.foe_marks(CastThugAnchors.EIGHT, low)
		assert_eq(marks.size(), RigHeadCard.FRAMES * 8)
		for mark: Vector4 in marks:
			assert_true(is_finite(mark.x) and is_finite(mark.y), str(mark))
			assert_lt(mark.w, 0.0, "the torso sits above the sole pivot")


func test_thug_walk_is_selectable_by_one_value() -> void:
	assert_true(CastThugAnchors.WALK in [CastThugAnchors.EIGHT, CastThugAnchors.FOUR])
	var table: DataTable = DataTable.open(CastCards.TABLE, CastCards.SCHEMA)
	for listed: String in [CastThugAnchors.FOUR, CastThugAnchors.EIGHT]:
		var row: Dictionary = {
			"armed_walk": listed,
			"attack": "robot_thug_attack.png",
			"fall": "robot_thug_fall.png",
			"hit": "robot_thug_hit.png",
		}
		var sheets: CastCards.Sheets = CastCards._sheets(table, row, "p70")
		assert_true(sheets.walk.ends_with("/" + CastThugAnchors.WALK), listed)


func test_thug_card_shows_hides_his_rig_and_draws_walk_hit_fall() -> void:
	var previous: ViewMode = ViewMode.shared()
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	ViewMode.select("combo")
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.archetype = &"robot_gunner_x"
	h.machine = true
	assert_true(FoeThugCardView.show_rig(host, h, rig, true))
	assert_false(rig.has_meta(FoeThugCardView.CARD))
	h.archetype = FoeThugCardView.ID
	h.hp = 10.0
	h.pos = Vector2(3, 4)
	h.facing = Vector2.LEFT
	assert_false(FoeThugCardView.show_rig(host, h, rig, true))
	var card: FoeThugCardView = rig.get_meta(FoeThugCardView.CARD)
	assert_true(card.visible)
	assert_eq(card.position, h.pos * SimConst.PX_PER_M)
	assert_eq(card.texture.resource_path, card.pose.sheets.walk)
	h.hurt_tick = host.arena.tick
	card.update_fighter(h, host.arena)
	assert_eq(card.texture.resource_path, card.pose.sheets.hit)
	h.hp = 0.0
	host.arena.tick += SimClock.TICK_RATE * 2
	card.update_fighter(h, host.arena)
	assert_eq(card.texture.resource_path, card.pose.sheets.fall)
	ViewMode._shared = previous


func test_thug_rings_sit_on_the_ground_point_after_a_walk_and_a_stop() -> void:
	var previous: ViewMode = ViewMode.shared()
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	ViewMode.select("combo")
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.archetype = FoeThugCardView.ID
	h.hp = 10.0
	h.facing = Vector2.DOWN
	for step: int in 6:
		h.pos = Vector2(3.0 + 0.1 * step, 4.0)
		assert_false(FoeThugCardView.show_rig(host, h, rig, true))
	var card: FoeThugCardView = rig.get_meta(FoeThugCardView.CARD)
	for _stand: int in 2:
		assert_false(FoeThugCardView.show_rig(host, h, rig, true))
		var ring: Vector2 = card.to_global(card._shadow.position)
		assert_lt(ring.distance_to(h.pos * SimConst.PX_PER_M), 1.0)
	ViewMode._shared = previous

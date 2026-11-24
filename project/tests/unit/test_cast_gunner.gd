extends GutTest
## Robot gunner A: the card replaces his robot rig's drawing only; sim state is only read.


func test_gunner_card_walks_the_eight_at_both_pitches() -> void:
	CastMulroneyPreview.enable(FoeGunnerCardView.ID)
	var cards: CastCards = CastCards.shipped()
	for pitch: String in ["p55", "p70"]:
		var sheets: CastCards.Sheets = cards.lookup(FoeGunnerCardView.ID, pitch)
		assert_not_null(sheets)
		assert_true(sheets.walk.ends_with(CastGunnerAnchors.EIGHT), pitch)
		assert_true(CastCards.anchored(sheets.walk))
		assert_true(CastCards.padded(sheets.attack))
		assert_false(CastCards.padded(sheets.fall))
		assert_eq(CastCardKinds.four_of(CastGunnerAnchors.EIGHT), CastGunnerAnchors.FOUR)
		assert_eq(CastCardKinds.foe_marks(CastGunnerAnchors.EIGHT, pitch == "p55").size(), 40)
	CastCards._library = null


func test_gunner_card_draws_walk_hit_fall_and_leaves_other_robots_alone() -> void:
	var previous: ViewMode = ViewMode.shared()
	CastMulroneyPreview.enable(FoeGunnerCardView.ID)
	ViewMode.select("combo")
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.archetype = &"war_machine_x"
	h.machine = true
	assert_true(FoeGunnerCardView.show_rig(host, h, rig, true))
	assert_false(rig.has_meta(FoeGunnerCardView.CARD))
	h.archetype = FoeGunnerCardView.ID
	h.hp = 10.0
	h.pos = Vector2(3, 4)
	h.facing = Vector2.LEFT
	assert_false(FoeGunnerCardView.show_rig(host, h, rig, true))
	var card: FoeGunnerCardView = rig.get_meta(FoeGunnerCardView.CARD)
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
	CastCards._library = null


func test_gunner_row_is_on_after_the_n28_audit() -> void:
	CastCards._library = null
	assert_not_null(CastCards.shipped().lookup(FoeGunnerCardView.ID, "p70"))

extends GutTest


func test_door_overlay_requires_both_robot_ownership_and_an_active_card() -> void:
	var previous: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var h: Fighter = Fighter.new()
	h.archetype = &"shield_robot"
	h.machine = true
	assert_true(FoeShieldCardView.enabled(h))
	h.brain_owned = true
	assert_false(FoeShieldCardView.enabled(h))
	h.brain_owned = false
	ViewMode.select("top")
	assert_false(FoeShieldCardView.enabled(h))
	ViewMode._shared = previous


func test_robot_card_uses_ground_position_damage_ticks_and_the_render_switch() -> void:
	var previous: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.archetype = &"shield_robot"
	h.machine = true
	h.hp = 10.0
	h.pos = Vector2(3, 4)
	h.facing = Vector2.LEFT
	assert_false(FoeShieldCardView.show_rig(host, h, rig, true))
	var card: FoeShieldCardView = rig.get_meta(FoeShieldCardView.CARD)
	assert_true(card.visible)
	assert_true(card.flip_h)
	assert_eq(card.position, h.pos * SimConst.PX_PER_M)
	assert_eq(card.texture.resource_path, card.pose.sheets.walk)
	_check_walk_contact(card, h, host.arena)
	h.hurt_tick = host.arena.tick
	card.update_fighter(h, host.arena)
	assert_eq(card.texture.resource_path, card.pose.sheets.hit)
	h.hp = 0.0
	host.arena.tick += SimClock.TICK_RATE
	card.update_fighter(h, host.arena)
	assert_eq(card.texture.resource_path, card.pose.sheets.fall)
	assert_eq(card.frame_coords.y, 2)
	assert_false(FoeShieldCardView.show_rig(host, h, rig, false))
	assert_false(card.visible)
	ViewMode.select("top")
	assert_true(FoeShieldCardView.show_rig(host, h, rig, true))
	assert_false(card.visible)
	ViewMode._shared = previous


func _check_walk_contact(card: FoeShieldCardView, h: Fighter, arena: CombatArena) -> void:
	h.pos.x += 0.04
	card.update_fighter(h, arena)
	var planted: Vector2 = card.position
	h.pos.x += 0.04
	card.update_fighter(h, arena)
	assert_eq(card.position, planted)
	h.pos += Vector2.RIGHT * CastDoorAnchors.WALK_STEP_M
	card.update_fighter(h, arena)
	assert_eq(card.frame_coords, Vector2i(2, 1))
	var reach: float = CastDoorAnchors.WALK_STEP_M * 2.0 * SimConst.PX_PER_M
	assert_lt(card.position.distance_to(h.pos * SimConst.PX_PER_M), reach)


func test_door_and_gunner_cards_flash_with_their_rig() -> void:
	for card: CastFarCard in [FoeShieldCardView.new(), FoeGunnerCardView.new()]:
		autofree(card)
		var rig: CutRig = autofree(CutRig.new())
		card.sync_tint(rig.is_tinted())
		assert_null(card.material)
		rig.set_tint(true)
		card.sync_tint(rig.is_tinted())
		assert_eq(card.material, PartMaterials.get_mat(PartMaterials.PartKind.PART, true, 0))
		rig.set_tint(false)
		card.sync_tint(rig.is_tinted())
		assert_null(card.material)


func test_walk_switch_swaps_only_the_four_drawing_door_walk() -> void:
	var dir: String = RigHeadCard.ART_DIR + "p70"
	var four: String = dir.path_join(CastDoorAnchors.FOUR)
	assert_eq(FoeShieldCardView.walk_sheet(four), dir.path_join(CastDoorAnchors.WALK))
	var eight: String = dir.path_join(CastDoorAnchors.EIGHT)
	assert_eq(FoeShieldCardView.walk_sheet(eight), eight)
	var attack: String = dir.path_join("shield_robot_attack.png")
	assert_eq(FoeShieldCardView.walk_sheet(attack), attack)
	assert_eq(CastDoorAnchors.SHEET, CastDoorAnchors.WALK)
	assert_eq(CastDoorAnchors.EIGHT70.size(), 40)
	assert_eq(CastDoorAnchors.EIGHT55.size(), 40)
	assert_eq(CastDoorAnchors.FOUR70.size(), 20)
	var low: bool = CastDoorAnchors.WALK == CastDoorAnchors.FOUR
	assert_eq(CastDoorAnchors.WALK70, CastDoorAnchors.FOUR70 if low else CastDoorAnchors.EIGHT70)


func test_door_card_draws_the_selected_walk() -> void:
	var previous: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.archetype = &"shield_robot"
	h.machine = true
	h.hp = 10.0
	@warning_ignore("return_value_discarded")
	FoeShieldCardView.show_rig(host, h, rig, true)
	var card: FoeShieldCardView = rig.get_meta(FoeShieldCardView.CARD)
	assert_eq(card.pose.sheets.walk.get_file(), CastDoorAnchors.WALK)
	ViewMode._shared = previous

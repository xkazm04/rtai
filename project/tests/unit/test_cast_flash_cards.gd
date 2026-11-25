extends GutTest
## The turret and war machine cards flash with their rig like the gunner, shield and thug cards.

const LIT: PartMaterials.PartKind = PartMaterials.PartKind.PART

var _previous_mode: ViewMode
var _previous_cards: CastCards


func test_turret_card_flashes_with_its_rig() -> void:
	var card: FoeTurretCardView = add_child_autofree(FoeTurretCardView.new())
	var rig: CutRig = autofree(CutRig.new())
	card.sync_tint(rig.is_tinted())
	assert_null(card.material)
	rig.set_tint(true)
	card.sync_tint(rig.is_tinted())
	assert_eq(card.material, PartMaterials.get_mat(LIT, true, 0))
	rig.set_tint(false)
	card.sync_tint(rig.is_tinted())
	assert_null(card.material)


func test_war_card_flashes_with_its_rig_and_the_vent_keeps_its_glow() -> void:
	var card: FoeWarCardView = add_child_autofree(FoeWarCardView.new())
	var rig: CutRig = autofree(CutRig.new())
	card.texture = ImageTexture.create_from_image(
		Image.create(1440, 1152, false, Image.FORMAT_RGBA8)
	)
	card.hframes = RigHeadCard.FRAMES
	card.vframes = StreetWalkerCards.STRIDE_FRAMES
	card.frame_coords = Vector2i(3, 3)
	card._louvres(1.0, false)
	var glow: Material = card._vent.material
	assert_not_null(glow)
	card.sync_tint(rig.is_tinted())
	assert_null(card.material)
	rig.set_tint(true)
	card.sync_tint(rig.is_tinted())
	assert_eq(card.material, PartMaterials.get_mat(LIT, true, 0))
	assert_eq(card._vent.material, glow)
	rig.set_tint(false)
	card.sync_tint(rig.is_tinted())
	assert_null(card.material)
	assert_eq(card._vent.material, glow)


func test_far_card_sync_tint_follows_the_rig() -> void:
	var card: CastFarCard = add_child_autofree(CastFarCard.new())
	card.sync_tint(true)
	assert_eq(card.material, PartMaterials.get_mat(LIT, true, 0))
	card.sync_tint(false)
	assert_null(card.material)


func test_turret_show_rig_lights_and_clears_the_card_with_the_rig() -> void:
	var rig: CutRig = _host_rig()
	var host: ArenaRobotRigs = rig.get_parent()
	var h: Fighter = _fighter(&"sentry_turret")
	rig.set_tint(true)
	assert_false(FoeTurretCardView.show_rig(host, h, rig, true))
	var card: FoeTurretCardView = rig.get_meta(FoeTurretCardView.CARD)
	assert_eq(card.material, PartMaterials.get_mat(LIT, true, 0))
	rig.set_tint(false)
	assert_false(FoeTurretCardView.show_rig(host, h, rig, true))
	assert_null(card.material)
	_restore()


func test_war_show_rig_lights_and_clears_the_card_with_the_rig() -> void:
	var rig: CutRig = _host_rig()
	var host: ArenaRobotRigs = rig.get_parent()
	var h: Fighter = _fighter(&"war_machine")
	rig.set_tint(true)
	assert_false(FoeWarCardView.show_rig(host, h, rig, true))
	var card: FoeWarCardView = rig.get_meta(FoeWarCardView.CARD)
	assert_eq(card.material, PartMaterials.get_mat(LIT, true, 0))
	rig.set_tint(false)
	assert_false(FoeWarCardView.show_rig(host, h, rig, true))
	assert_null(card.material)
	_restore()


func _host_rig() -> CutRig:
	_previous_mode = ViewMode.shared()
	_previous_cards = CastCards._library
	ViewMode.select("combo")
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	return rig


func _fighter(id: StringName) -> Fighter:
	var h: Fighter = Fighter.new()
	h.archetype = id
	h.machine = true
	h.hp = 10.0
	h.pos = Vector2(3, 4)
	h.facing = Vector2.LEFT
	return h


func _restore() -> void:
	ViewMode._shared = _previous_mode
	CastCards._library = _previous_cards

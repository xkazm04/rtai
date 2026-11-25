extends GutTest
## The turret and war machine cards flash with their rig like the gunner, shield and thug cards.

const LIT: PartMaterials.PartKind = PartMaterials.PartKind.PART


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

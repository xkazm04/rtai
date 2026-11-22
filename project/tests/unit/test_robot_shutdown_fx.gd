extends GutTest


func test_wreck_keeps_source_texture_and_discards_the_printed_sticker() -> void:
	var wreck: RobotShutdownFx = autofree(RobotShutdownFx.new())
	wreck.add_child(wreck.pivot)
	wreck.pivot.add_child(wreck.chassis)
	var plate: Sprite2D = Sprite2D.new()
	var halo: Sprite2D = Sprite2D.new()
	var texture: Texture2D = FoeShieldView.TORSO
	plate.texture = texture
	plate.material = PartMaterials.get_mat(PartMaterials.PartKind.LIMB, false, 0)
	halo.material = PartMaterials.get_mat(PartMaterials.PartKind.HALO, false, 0)
	wreck.chassis.add_child(plate)
	wreck.chassis.add_child(halo)
	wreck._expose_steel()
	assert_same(plate.texture, texture)
	assert_true(plate.visible)
	assert_null(plate.material)
	assert_false(halo.visible)

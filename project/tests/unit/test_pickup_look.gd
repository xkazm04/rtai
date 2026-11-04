extends GutTest
## weapon-art it21: a gun on the ground draws its own flat fills in an ink outline, not the PART
## print that turned it into an ink smudge; `--pickup-print=on` keeps the print (the before).


func _pickup(id: StringName) -> Sprite2D:
	var art: WeaponArt = WeaponArt.new()
	var s: Sprite2D = Sprite2D.new()
	s.texture = art.pickup_texture(id)
	s.scale = Vector2.ONE * art.length_m(id) * SimConst.PX_PER_M / float(s.texture.get_width())
	return s


func after_each() -> void:
	PickupLook.printed = false


func test_default_is_flat_fills_in_an_ink_outline() -> void:
	var s: Sprite2D = _pickup(&"hand_cannon")
	PickupLook.dress(s)
	assert_null(s.material, "no print material on the pickup")
	assert_eq(s.get_child_count(), PickupLook.OUTLINE_DIRS)
	var ink: Sprite2D = s.get_child(0) as Sprite2D
	assert_true(ink.show_behind_parent, "the outline draws under the gun")
	assert_eq(ink.modulate, PaletteTokens.shared().color(&"ink"))
	var reach: float = ink.position.length() * s.scale.x
	assert_almost_eq(reach, PickupLook.OUTLINE_WORLD_PX, 0.001, "1 world px out")
	s.free()


func test_print_flag_keeps_the_before() -> void:
	PickupLook.printed = true
	var s: Sprite2D = _pickup(&"rocket_launcher")
	PickupLook.dress(s)
	assert_not_null(s.material, "--pickup-print=on: the PART print")
	assert_eq(s.get_child_count(), 0)
	s.free()

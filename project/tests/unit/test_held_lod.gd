extends GutTest
## features/combat/weapons/art/held_lod.gd: the kinetic guns draw their re-toned `small` cell in
## the claw below held_small_below_ppm (the print's posterize zoom) and their full art above it,
## on the same canvas and grip, rim included; `--held-small=off` keeps the full art.

const KINETIC: Array[StringName] = [&"pistol", &"machine_pistol", &"hand_cannon", &"gloria"]

var _view_was: float = 0.0


func before_each() -> void:
	_view_was = PartMaterials.view_px


func after_each() -> void:
	PartMaterials.view_px = _view_was
	HeldLod.enabled = true


func test_kinetic_guns_swap_to_the_small_cell_at_gameplay_zoom() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_gt(art.held_small_below_ppm, 48.0, "48 px/m draws the small cell")
	assert_lt(art.held_small_below_ppm, 64.0, "64 px/m keeps the full art")
	for id: StringName in KINETIC:
		var held: HeldLod = art.make_held(id) as HeldLod
		assert_not_null(held, "%s held part is a HeldLod" % id)
		if held == null:
			continue
		assert_eq(held.small.get_size(), held.full.get_size(), "%s same canvas" % id)
		PartMaterials.view_px = CutRig.SC * 1.5  # 48 px/m
		held._pick()
		assert_eq(held.texture, held.small, "%s small at 48 px/m" % id)
		assert_eq((held.get_child(0) as Sprite2D).texture, held.small, "%s rim follows" % id)
		PartMaterials.view_px = CutRig.SC * 2.0  # 64 px/m
		held._pick()
		assert_eq(held.texture, held.full, "%s full art at 64 px/m" % id)
		held.free()


func test_off_flag_and_other_weapons_keep_the_full_art() -> void:
	var art: WeaponArt = WeaponArt.new()
	PartMaterials.view_px = CutRig.SC * 1.0
	HeldLod.enabled = false
	var held: HeldLod = art.make_held(&"pistol") as HeldLod
	held._pick()
	assert_eq(held.texture, held.full, "--held-small=off")
	held.free()
	var tube: Sprite2D = art.make_held(&"rocket_launcher")
	assert_false(tube is HeldLod, "no small cell: a plain sprite")
	tube.free()
	var mag: Sprite2D = art.make_held(&"pistol", "mag")
	assert_false(mag is HeldLod, "extra parts stay plain")
	mag.free()

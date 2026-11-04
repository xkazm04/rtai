extends GutTest
## features/combat/weapons/art/held_lod.gd: the held weapons (all but the molotov, the
## flamethrower and the plasma sword, which print light already) draw their re-toned `small` cell in
## the claw below held_small_below_ppm (the print's posterize zoom) and their full art above it,
## on the same canvas and grip, rim included; `--held-small=off` keeps the full art.

const RETONED: Array[StringName] = [
	&"pistol",
	&"machine_pistol",
	&"hand_cannon",
	&"gloria",
	&"rocket_launcher",
	&"electro_gun",
	&"katana",
	&"electro_baton",
	&"plasma_rifle",
	&"chainsaw",
	&"ray_gun",
	&"homing_shard",
	&"mini_nuke"
]

var _view_was: float = 0.0


func before_each() -> void:
	_view_was = PartMaterials.view_px


func after_each() -> void:
	PartMaterials.view_px = _view_was
	HeldLod.enabled = true


func test_held_weapons_swap_to_the_small_cell_at_gameplay_zoom() -> void:
	var art: WeaponArt = WeaponArt.new()
	assert_gt(art.held_small_below_ppm, 48.0, "48 px/m draws the small cell")
	assert_lt(art.held_small_below_ppm, 64.0, "64 px/m keeps the full art")
	for id: StringName in RETONED:
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
	var bottle: Sprite2D = art.make_held(&"molotov")
	assert_false(bottle is HeldLod, "no small cell: a plain sprite")
	bottle.free()
	var mag: Sprite2D = art.make_held(&"pistol", "mag")
	assert_false(mag is HeldLod, "extra parts stay plain")
	mag.free()


func test_an_empty_tube_set_by_a_view_maps_to_its_small_cell() -> void:
	var art: WeaponArt = WeaponArt.new()
	var held: HeldLod = art.make_held(&"rocket_launcher") as HeldLod
	var hollow: Texture2D = art.part_texture(&"rocket_launcher", "empty")
	var hollow_small: Texture2D = art.part_texture(&"rocket_launcher", "empty_small")
	assert_not_null(hollow_small, "the empty tube has a small cell")
	PartMaterials.view_px = CutRig.SC * 1.5
	held._pick()
	held.texture = hollow  # what HeldTube.apply does after the shot
	held._pick()
	assert_eq(held.texture, hollow_small, "the empty tube, small at 48 px/m")
	held._pick()
	assert_eq(held.texture, hollow_small, "stable frame to frame")
	held.texture = art.held_texture(&"rocket_launcher")  # reloaded
	held._pick()
	assert_eq(held.texture, held.small, "loaded again: the small loaded tube")
	PartMaterials.view_px = CutRig.SC * 2.0
	held._pick()
	assert_eq(held.texture, held.full, "64 px/m: full art")
	held.free()


func test_no_stand_in_hides_a_weapons_own_held_art() -> void:
	# it13: a stale art_stand_in (gloria -> pistol) drew the pistol for her after her art landed.
	var art: WeaponArt = WeaponArt.new()
	var arsenal: ArsenalTable = ArsenalTable.shipped()
	for weapon: StringName in arsenal.art_stand_in:
		assert_false(art.has(weapon), "%s has its own held art; drop its art_stand_in" % weapon)
	assert_eq(arsenal.art_id(&"gloria"), &"gloria", "Gloria draws her own art")

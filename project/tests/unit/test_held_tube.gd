extends GutTest
## rivet-arsenal: the rocket tube shows empty from the shot until the next rocket goes in.


func test_empty_from_the_shot_until_the_load_phase_ends() -> void:
	assert_false(HeldTube.is_empty(1, 1, -1.0), "loaded, no reload: warhead shown")
	assert_true(HeldTube.is_empty(0, 1, -1.0), "spent, reload not started: empty")
	assert_true(HeldTube.is_empty(0, 1, 0.5), "magazine out phase: empty")
	assert_true(HeldTube.is_empty(0, 1, 1.9), "rocket on its way in: still empty")
	assert_false(HeldTube.is_empty(0, 1, 2.0), "rocket in: loaded")
	assert_false(HeldTube.is_empty(0, 1, 2.5), "cocking: loaded")


func test_no_magazine_never_empty() -> void:
	assert_false(HeldTube.is_empty(0, 0, 0.5), "a weapon without a magazine never shows empty")


func test_apply_swaps_the_rocket_launcher_art_and_its_rim() -> void:
	var art: WeaponArt = WeaponArt.new()
	var s: Sprite2D = art.make_held(&"rocket_launcher")
	var loaded: Texture2D = s.texture
	HeldTube.apply(s, art, &"rocket_launcher", true)
	var hollow: Texture2D = art.part_texture(&"rocket_launcher", "empty")
	assert_not_null(hollow, "weapon-art ships the empty tube")
	assert_eq(s.texture, hollow)
	for child: Node in s.get_children():
		assert_eq((child as Sprite2D).texture, hollow, "the rim follows")
	HeldTube.apply(s, art, &"rocket_launcher", false)
	assert_eq(s.texture, loaded, "the warhead comes back")
	s.free()


## Planted fault: a pistol has no `empty` part, so apply leaves its art alone.
func test_planted_pistol_has_no_empty_part() -> void:
	var art: WeaponArt = WeaponArt.new()
	var s: Sprite2D = art.make_held(&"pistol")
	var loaded: Texture2D = s.texture
	HeldTube.apply(s, art, &"pistol", true)
	assert_eq(s.texture, loaded)
	s.free()

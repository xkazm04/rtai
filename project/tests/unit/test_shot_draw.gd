extends GutTest


func test_large_rocket_palette_follows_the_shooter() -> void:
	var rocket: Shot = Shot.new()
	rocket.weapon = &"rocket_launcher"
	rocket.size = Shot.LARGE
	var hostile: Array[Color] = [EnemyRoundLook.LARGE_RIM, EnemyRoundLook.LARGE_CORE]
	assert_false(hostile.has(ShotDraw.rim(rocket)))
	assert_false(hostile.has(ShotDraw.core(rocket)))
	assert_false(hostile.has(ShotDraw.EXHAUST))
	assert_false(hostile.has(ShotDraw.EXHAUST_CORE))
	rocket.from_rivet = false
	assert_eq([ShotDraw.rim(rocket), ShotDraw.core(rocket)], hostile)


func test_only_rivets_typed_rocket_draws_launcher_exhaust() -> void:
	var host: Node2D = autofree(Node2D.new())
	var rocket: Shot = Shot.new()
	rocket.spec = WeaponSpec.new()
	rocket.spec.kind = WeaponSpec.Kind.ROCKET
	rocket.size = Shot.LARGE
	rocket.pos = Vector2.RIGHT * 4.0
	rocket.vel = Vector2.RIGHT
	var surface: WeaponFxColour = WeaponFxColour.attach(host, WeaponFxCells.COLOUR_DIR)
	var previous: WeaponFxColour = WeaponFxArt.colour
	WeaponFxArt.colour = surface
	rocket.from_rivet = false
	assert_false(WeaponFxArt.shot(host, rocket, 12))
	assert_false(host.has_meta(ShotDraw.LAYER))
	rocket.from_rivet = true
	assert_true(WeaponFxArt.shot(host, rocket, 12))
	assert_true(host.has_meta(ShotDraw.LAYER))
	WeaponFxArt.colour = previous
	surface.release()

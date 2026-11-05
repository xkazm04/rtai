extends GutTest
## n5-look made Rivet's held part follow his body size (rivet_arsenal.json held_size_ref); the
## owner's look-4 pick (2026-11-05, over cast-3) ships held_size_ref 0: every gun keeps its class
## size whatever Rivet's size_k. The follow-the-body path stays one data value away.


func test_shipped_guns_keep_their_class_size() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	assert_true(a.ok(), str(a.errors))
	assert_eq(a.held_size_ref, 0.0, "look-4: held guns keep their class size")
	for size_k: float in [0.9, 1.1, 1.2, 1.6]:
		assert_eq(a.held_k(&"pistol", size_k), a.grip_of(&"pistol").held_scale)
		assert_eq(a.held_k(&"gatling", size_k), a.grip_of(&"gatling").held_scale)


func test_planted_follow_ref_scales_with_the_body() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	a.held_size_ref = 1.2
	var g: ArsenalTable.Grip = a.grip_of(&"pistol")
	assert_almost_eq(a.held_k(&"pistol", 1.2), g.held_scale, 0.0001)
	assert_lt(a.held_k(&"pistol", 0.97), g.held_scale, "planted: cast-3 shrinks the gun")


func test_unknown_weapon_is_one() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	assert_eq(a.held_k(&"no_such_gun", 0.5), 1.0)

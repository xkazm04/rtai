extends GutTest
## n5-look: Rivet's held part follows his body size (rivet_arsenal.json held_size_ref).


func test_approved_size_keeps_the_class_scale() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	assert_true(a.ok(), str(a.errors))
	var g: ArsenalTable.Grip = a.grip_of(&"pistol")
	assert_almost_eq(a.held_k(&"pistol", a.held_size_ref), g.held_scale, 0.0001)


func test_slimmer_body_carries_a_smaller_gun() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	var g: ArsenalTable.Grip = a.grip_of(&"pistol")
	var k: float = a.held_k(&"pistol", 0.97)
	assert_almost_eq(k, g.held_scale * 0.97 / a.held_size_ref, 0.0001)
	assert_lt(k, g.held_scale)


func test_zero_ref_is_the_class_scale_alone() -> void:
	var a: ArsenalTable = ArsenalTable.shipped()
	a.held_size_ref = 0.0
	assert_eq(a.held_k(&"pistol", 0.5), a.grip_of(&"pistol").held_scale)
	assert_eq(a.held_k(&"no_such_gun", 0.5), 1.0)

extends GutTest
## n7-melee: Dent's car bomb flings the rocket blast's slabs (WeaponFxDebris through DentView,
## ghost_attacks.json dent blast_debris, view only); 0 = the before (the fireball and ring alone).


func test_the_car_bomb_throws_debris() -> void:
	var v: DentView = autofree(DentView.new())
	assert_true(v.debris_on, "dent blast_debris 1: the blast flings slabs")


func test_the_slabs_draw_at_the_view_scale() -> void:
	var v: DentView = autofree(DentView.new())
	v.ppm = 32.0
	assert_almost_eq(v.debris_scale(), 32.0 / 48.0, 0.0001, "Ink's 48 px/m world -> 32 px/m")
	v.ppm = 48.0
	assert_almost_eq(v.debris_scale(), 1.0, 0.0001)


func test_the_slabs_land_past_the_car_bombs_ring() -> void:
	var radius_m: float = GhostAttacks.shipped().num(&"dent", &"blast_radius_m")
	assert_gt(WeaponFxDebris.fly(radius_m, 1.0, 0.0), radius_m, "out past the ring")
	assert_gt(WeaponFxDebris.rules().chunks, 0)

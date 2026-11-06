extends GutTest
## parcels.crate_damage (the owner call): 0 by default, a landing crate is harmless and no hit is
## made; above 0, the crate's footprint hits where it lands, with no fireball drawn.

const AT: Vector2 = Vector2(4.0, 2.0)


func _land_crate(damage: float) -> ServoParcels:
	var t: ServoTuning = ServoTuning.shipped()
	t.crate_damage = damage
	var p: ServoParcels = ServoParcels.new()
	p.setup(t)
	p.drop(AT, ServoParcels.CRATE, 1)
	p.step()
	return p


func test_harmless_crates_land_without_a_hit() -> void:
	assert_eq(
		ServoTuning.shipped().crate_damage, 12.0, "owner 2026-11-06: a landing crate deals 12"
	)
	var p: ServoParcels = _land_crate(0.0)
	assert_eq(p.blasts.size(), 0, "no hit from a landing crate")
	assert_eq(p.crates.size(), 1, "the crate still lands")


func test_a_hurting_crate_hits_its_footprint_without_a_boom() -> void:
	var p: ServoParcels = _land_crate(12.0)
	assert_eq(p.blasts.size(), 1, "one landing hit")
	assert_almost_eq(p.blasts[0].damage, 12.0, 0.001)
	assert_almost_eq(p.blasts[0].radius_m, ServoTuning.shipped().crate_m * 0.5, 0.001, "the box")
	assert_eq(p.crates.size(), 1, "and the crate stays as an obstacle")
	p.step()
	assert_eq(p.blasts.size(), 0, "the hit lives one step")
	assert_eq(p.booms.size(), 0, "no fireball for a crate")

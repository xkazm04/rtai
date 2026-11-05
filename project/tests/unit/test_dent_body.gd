extends GutTest
## features/souls DentBody on the car ride (ghost-powers REQUEST 7): braced on the roof (no walk at
## the car's speed), a buck on each strike, a hop on the blast.


func _body() -> DentBody:
	var b: DentBody = DentBody.new()
	add_child_autofree(b)
	b.setup(null)
	b.step(true, Vector2.ZERO, 0.0, 1, 0)
	return b


func test_riding_stands_braced_at_the_cars_speed() -> void:
	var b: DentBody = _body()
	b.riding = true
	b.step(true, Vector2(8.0 * SimConst.PX_PER_M * SimClock.TICK_DT, 0.0), 0.0, 1, 1)
	var rig: CutRig = b.get_child(1) as CutRig
	assert_eq(rig.vel_in, Vector2.ZERO, "the car moves him, his legs do not")


func test_a_strike_bucks_and_a_blast_hops_then_both_settle() -> void:
	var b: DentBody = _body()
	b.strikes = 1
	b.step(true, Vector2.ZERO, 0.0, 1, 1)
	assert_gt(b.scale.x, 1.0, "the strike pops him")
	for i: int in 20:
		b.step(true, Vector2.ZERO, 0.0, 1, 2 + i)
	assert_almost_eq(b.scale.x, 1.0, 0.001, "the buck settles")
	b.blasts = 1
	for i: int in 15:
		b.step(true, Vector2.ZERO, 0.0, 1, 30 + i)
	assert_gt(b.scale.x, 1.25, "mid-hop he is up near the camera")
	for i: int in 20:
		b.step(true, Vector2.ZERO, 0.0, 1, 50 + i)
	assert_almost_eq(b.scale.x, 1.0, 0.001, "and lands")

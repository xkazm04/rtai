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


func test_every_halo_carries_an_ink_keyline_under_every_halo() -> void:
	var b: DentBody = _body()
	var rig: CutRig = b.get_child(1) as CutRig
	assert_gt(rig.halos.size(), 0)
	for h: Sprite2D in rig.halos:
		assert_eq(h.get_child_count(), 1, "one keyline per cream halo")
		var k: Sprite2D = h.get_child(0) as Sprite2D
		assert_eq(k.texture, h.texture)
		assert_eq(h.z_index + k.z_index, GhostRim.KEY_Z, "under the limb (-16) and body (-1) halos")
		assert_gt(k.scale.y, 1.0, "wider than its halo")


func test_no_keyline_when_switched_off() -> void:
	GhostRim.keyline_on = false
	var b: DentBody = _body()
	GhostRim.keyline_on = true
	var rig: CutRig = b.get_child(1) as CutRig
	for h: Sprite2D in rig.halos:
		assert_eq(h.get_child_count(), 0, "the A/B before: no keyline")

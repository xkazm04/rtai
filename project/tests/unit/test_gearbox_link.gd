extends GutTest


func _link() -> GearboxLink:
	return GearboxLink.new(PowerTable.load_default().gearbox)


func test_soft_lock_takes_the_car_nearest_the_reticle_in_range() -> void:
	var g: GearboxLink = _link()
	var cars: PackedVector2Array = [Vector2(10, 0), Vector2(11, 1), Vector2(80, 0)]
	assert_eq(g.pick(Vector2.ZERO, Vector2(11, 0.8), cars), 1)
	assert_eq(g.pick(Vector2.ZERO, Vector2(80, 0), cars), GearboxLink.NONE, "out of range")
	assert_eq(g.pick(Vector2.ZERO, Vector2(10, 9), cars), GearboxLink.NONE, "reticle too far")


func test_linked_car_drives_toward_the_reticle() -> void:
	var g: GearboxLink = _link()
	assert_true(g.link(0, Vector2.ZERO, 0.0))
	var target: Vector2 = Vector2(0, 30)
	for i: int in 90:
		g.step(target)
	assert_lt(g.pos.distance_to(target), 20.0)
	assert_gt(g.pos.y, 1.0, "it turned toward the reticle")


func test_fast_contact_wrecks_and_slows_rivet_only_while_linked() -> void:
	var g: GearboxLink = _link()
	assert_eq(g.rivet_move_k(), 1.0)
	assert_true(g.link(0, Vector2.ZERO, 0.0))
	assert_lt(g.rivet_move_k(), 1.0, "Rivet is slowed while steering")
	assert_false(g.contact(), "a standing car does not wreck")
	for i: int in 60:
		g.step(Vector2(100, 0))
	assert_true(g.contact())
	assert_false(g.linked())
	assert_eq(g.rivet_move_k(), 1.0)


func test_link_drops_when_the_power_ends() -> void:
	var t: PowerTable = PowerTable.load_default()
	var p: SoulPowers = SoulPowers.new(t)
	var g: GearboxLink = GearboxLink.new(t.gearbox)
	g.bind(p)
	assert_eq(p.try_activate(&"gearbox"), SoulPowers.OK)
	assert_true(g.link(2, Vector2.ZERO, 0.0))
	assert_true(p.interrupt(&"hit"))
	assert_false(g.linked())

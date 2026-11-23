extends GutTest

var bond: GhostBond
var hud: GhostFormHud
var ring: GhostBondRing


func before_each() -> void:
	var table: GhostFormTable = GhostFormTable.load_default()
	table.master_at = 10.0
	table.per_kill = 2.0
	table.per_stun = 0.5
	bond = GhostBond.new(table)
	hud = autofree(GhostFormHud.new())
	ring = GhostBondRing.mount(hud, bond)


func test_partial_arc_uses_only_this_ghosts_bond_and_the_configured_threshold() -> void:
	bond.record(&"ohm", 1, 1)
	assert_eq(GhostBondRing.fill_fraction(bond, &"ohm"), 0.25)
	assert_eq(GhostBondRing.fill_fraction(bond, &"dent"), 0.0)
	assert_almost_eq(ring.angles(&"ohm").x, -PI / 2.0, 0.00001)
	assert_almost_eq(ring.angles(&"ohm").y, 0.0, 0.00001)
	assert_same(ring.get_parent(), hud)
	assert_true(hud.draw.is_connected(ring.queue_redraw))


func test_full_bond_opens_the_crown_until_the_mastery_card_closes_it() -> void:
	bond.record(&"ohm", 30, 0)
	assert_eq(GhostBondRing.fill_fraction(bond, &"ohm"), 1.0)
	var ready: Vector2 = ring.angles(&"ohm")
	assert_almost_eq(ready.x, -PI / 2.0 + PI / 12.0, 0.00001)
	assert_almost_eq(ready.y, 1.5 * PI - PI / 12.0, 0.00001)
	assert_true(bond.master(&"ohm"))
	var mastered: Vector2 = ring.angles(&"ohm")
	assert_almost_eq(mastered.x, -0.5 * PI, 0.00001)
	assert_almost_eq(mastered.y - mastered.x, TAU, 0.00001)
	bond.enabled = false
	assert_eq(GhostBondRing.fill_fraction(bond, &"ohm"), 0.0)


func test_slot_centers_follow_the_same_desktop_and_compact_layout_as_the_faces() -> void:
	assert_eq(GhostFormLayout.new().chip_center(1080, 0), Vector2(47, 984))
	assert_eq(GhostFormLayout.new().chip_center(720, 3), Vector2(221, 624))
	assert_eq(GhostFormLayout.compact().chip_center(800, 0), Vector2(33, 728))

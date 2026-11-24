extends GutTest

const CENTER: Vector2 = Vector2(47, 984)
const RADIUS: float = 22.5

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
	hud.layout = GhostFormLayout.new()
	hud.order = [&"ohm", &"dent"]
	hud.locked[&"ohm"] = false


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


func _kinds(cmds: Array[Dictionary]) -> Array:
	return cmds.map(func(c: Dictionary) -> StringName: return c[&"kind"])


func _kind(cmd: Dictionary) -> StringName:
	return cmd[&"kind"]


func _color(cmd: Dictionary) -> Color:
	return cmd[&"color"]


func _vec(cmd: Dictionary) -> Vector2:
	return cmd[&"center"]


func _num(cmd: Dictionary, key: StringName) -> float:
	return cmd[key]


func _assert_arc(
	cmd: Dictionary, span: Vector2, color: Color, width: float, radius: float = RADIUS
) -> void:
	var got: Array[float] = [
		_num(cmd, &"radius"), _num(cmd, &"from"), _num(cmd, &"to"), _num(cmd, &"width")
	]
	var want: Array[float] = [radius, span.x, span.y, width]
	assert_eq(_kind(cmd), &"arc")
	assert_eq(_vec(cmd), CENTER)
	assert_eq(_color(cmd), color)
	for i: int in got.size():
		assert_almost_eq(got[i], want[i], 0.00001)


func test_plan_empty_bond_is_the_ink_underlay_and_the_track_only() -> void:
	var cmds: Array[Dictionary] = ring.plan(1080.0)
	assert_eq(cmds.size(), 2)
	var full: Vector2 = Vector2(-PI / 2.0, -PI / 2.0 + TAU)
	_assert_arc(cmds[0], full, GhostBondRing.INK, GhostBondRing.STROKE + 2.0)
	_assert_arc(cmds[1], full, GhostBondRing.TRACK, 1.0)
	for cmd: Dictionary in cmds:
		assert_ne(_color(cmd), GhostBondRing.TEAL)


func test_plan_half_bond_adds_one_teal_arc_over_half_the_circle() -> void:
	bond.record(&"ohm", 2, 2)
	var cmds: Array[Dictionary] = ring.plan(1080.0)
	assert_eq(_kinds(cmds), [&"arc", &"arc", &"arc"])
	_assert_arc(cmds[2], Vector2(-PI / 2.0, PI / 2.0), GhostBondRing.TEAL, GhostBondRing.STROKE)


func test_plan_ready_bond_opens_the_gap_and_puts_the_diamond_and_dot_in_it() -> void:
	bond.record(&"ohm", 30, 0)
	var cmds: Array[Dictionary] = ring.plan(1080.0)
	assert_eq(_kinds(cmds), [&"arc", &"arc", &"arc", &"poly", &"dot"])
	var gap: Vector2 = Vector2(-PI / 2.0 + PI / 12.0, 1.5 * PI - PI / 12.0)
	_assert_arc(cmds[2], gap, GhostBondRing.TEAL, GhostBondRing.STROKE)
	var crown: Vector2 = CENTER + Vector2.UP * RADIUS
	var points: PackedVector2Array = cmds[3][&"points"]
	assert_eq(
		points,
		PackedVector2Array(
			[
				crown + Vector2(0, -5),
				crown + Vector2(4, 0),
				crown + Vector2(0, 5),
				crown + Vector2(-4, 0)
			]
		)
	)
	assert_eq(_color(cmds[3]), GhostBondRing.TEAL)
	assert_eq(_vec(cmds[4]), crown)
	assert_eq(_num(cmds[4], &"radius"), 1.5)
	assert_eq(_color(cmds[4]), GhostBondRing.INK)


func test_plan_mastered_bond_is_a_closed_teal_circle_without_the_crown() -> void:
	bond.record(&"ohm", 30, 0)
	assert_true(bond.master(&"ohm"))
	var cmds: Array[Dictionary] = ring.plan(1080.0)
	assert_eq(_kinds(cmds), [&"arc", &"arc", &"arc"])
	_assert_arc(
		cmds[2], Vector2(-PI / 2.0, -PI / 2.0 + TAU), GhostBondRing.TEAL, GhostBondRing.STROKE
	)


func test_plan_is_empty_when_the_bond_is_off_and_skips_locked_chips() -> void:
	bond.record(&"ohm", 30, 0)
	bond.enabled = false
	assert_eq(ring.plan(1080.0).size(), 0)
	bond.enabled = true
	hud.locked[&"ohm"] = true
	assert_eq(ring.plan(1080.0).size(), 0)


func test_plan_puts_each_unlocked_chip_on_its_own_slot_centre() -> void:
	hud.locked[&"dent"] = false
	var cmds: Array[Dictionary] = ring.plan(720.0)
	assert_eq(cmds.size(), 4)
	var layout: GhostFormLayout = hud.layout
	assert_eq(_vec(cmds[0]), layout.chip_center(720.0, 0))
	assert_eq(_vec(cmds[2]), layout.chip_center(720.0, 1))
	var radius: float = _num(cmds[2], &"radius")
	assert_almost_eq(radius, layout.chip_r - 3.5, 0.0001)

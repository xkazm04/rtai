extends GutTest
## n16 tools: the kill reel's --sig-dir turns a solo KillLab's guards about Rivet's spot (dev only).


func _lab(solo: Vector2) -> KillLab:
	var lab: KillLab = KillLab.new()
	lab.solo = solo
	var g: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, solo + KillLab.SOLO_OFF, 100.0)
	lab.guards.append(g)
	@warning_ignore("return_value_discarded")
	lab.spots.append(g.pos)
	return lab


func test_ninety_degrees_puts_the_guard_south_of_rivet() -> void:
	var lab: KillLab = _lab(Vector2(10.0, 10.0))
	KillLabTurn.apply(lab, 90.0)
	var want: Vector2 = Vector2(10.0, 10.0) + KillLab.SOLO_OFF.rotated(PI / 2.0)
	assert_almost_eq(lab.guards[0].pos, want, Vector2(0.001, 0.001))
	assert_almost_eq(lab.spots[0], want, Vector2(0.001, 0.001), "the tether follows the turn")
	assert_gt(lab.guards[0].pos.y, 12.0, "south is +y (screen down)")


func test_zero_degrees_and_a_line_lab_are_untouched() -> void:
	var lab: KillLab = _lab(Vector2(10.0, 10.0))
	KillLabTurn.apply(lab, 0.0)
	assert_eq(lab.guards[0].pos, Vector2(10.0, 10.0) + KillLab.SOLO_OFF)
	var line: KillLab = _lab(Vector2(10.0, 10.0))
	line.solo = Vector2.INF
	KillLabTurn.apply(line, 90.0)
	assert_eq(line.guards[0].pos, Vector2(10.0, 10.0) + KillLab.SOLO_OFF, "no solo spot: no turn")

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


## A wall east of x = 16 (x is metres): every point at or past it is pushed back.
func _east_wall(p: Vector2) -> Vector2:
	return Vector2(16.0, p.y) if p.x >= 16.0 else p


func test_sig_wall_stands_the_guard_gap_short_of_the_wall_along_the_shot() -> void:
	var lab: KillLab = _lab(Vector2(10.0, 10.0))
	var deg: float = KillLabTurn.wall(lab, _east_wall, 1.0)
	assert_false(is_nan(deg), "the wall 6 m east is found")
	var g: Vector2 = lab.guards[0].pos
	var dir: Vector2 = (g - lab.solo).normalized()
	var behind: float = KillLabTurn.first_wall_m(g, dir, _east_wall)
	var tol: float = KillLabTurn.WALL_PROBE_M + 0.01
	assert_almost_eq(behind, 1.0, tol, "the wall ~1 m behind him along the shot")
	assert_eq(lab.spots[0], g, "the tether follows")
	assert_gte(g.distance_to(lab.solo), KillLabTurn.WALL_MIN_GUARD_M)


func test_sig_wall_without_a_wall_leaves_the_guard() -> void:
	var lab: KillLab = _lab(Vector2(10.0, 10.0))
	var open: Callable = func(p: Vector2) -> Vector2: return p
	assert_true(is_nan(KillLabTurn.wall(lab, open, 1.0)))
	assert_eq(lab.guards[0].pos, Vector2(10.0, 10.0) + KillLab.SOLO_OFF)


func test_from_args_routes_sig_wall_and_sig_dir() -> void:
	var lab: KillLab = _lab(Vector2(10.0, 10.0))
	KillLabTurn.from_args(lab, _east_wall, ArenaArgs.parse(PackedStringArray(["--sig-wall=1.5"])))
	var g: Vector2 = lab.guards[0].pos
	var behind: float = KillLabTurn.first_wall_m(g, (g - lab.solo).normalized(), _east_wall)
	assert_almost_eq(behind, 1.5, KillLabTurn.WALL_PROBE_M + 0.01)
	var turned: KillLab = _lab(Vector2(10.0, 10.0))
	KillLabTurn.from_args(turned, _east_wall, ArenaArgs.parse(PackedStringArray(["--sig-dir=90"])))
	assert_gt(turned.guards[0].pos.y, 12.0, "--sig-dir still turns")


func test_sig_wound_lets_every_guard_live_through_a_blow() -> void:
	var lab: KillLab = KillLab.new()
	var g: Fighter = Fighter.new()
	lab.guards.append(g)
	lab.spots = PackedVector2Array([Vector2.ZERO])
	KillLabTurn.from_args(lab, Callable(), ArenaArgs.parse(PackedStringArray(["--sig-wound"])))
	assert_eq(g.hp, KillLabTurn.WOUND_HP)
	assert_gt(g.hp - KillLab.BLADE_DAMAGE, 0.0, "the blade's blow wounds")
	var plain: Fighter = Fighter.new()
	lab.guards[0] = plain
	KillLabTurn.from_args(lab, Callable(), ArenaArgs.parse(PackedStringArray([])))
	assert_eq(plain.hp, 1.0, "without the arg: untouched")

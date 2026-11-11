extends GutTest
## n16 kills-polish: the plasma sword's bloodless kill leaves the hot blade's path burned into the
## street (row scorch_line_m), along the cut; the katana (it bleeds) and the other rows leave none.


class Canvas:
	extends Node2D
	var mark: KillMarks.Mark = null

	func _draw() -> void:
		KillMarkArt.scorch(self, mark, 32.0)


func _mark(weapon: StringName) -> KillMarks.Mark:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(weapon)
	var marks: KillMarks = KillMarks.new()
	var rng: RandomNumberGenerator = RngRegistry.new(5).stream(&"brutality")
	return marks.leave(row, Vector2(3.0, 4.0), Vector2(0.6, 0.8), 10, rng)


func test_the_plasma_sword_leaves_a_scorch_line_along_the_cut() -> void:
	var m: KillMarks.Mark = _mark(&"plasma_sword")
	assert_gt(m.line_m, 0.5)
	assert_eq(m.dir, Vector2(0.6, 0.8), "along the cut it was given")
	assert_eq(m.drops.size(), 0, "bloodless")


func test_the_katana_and_the_rocket_leave_no_scorch_line() -> void:
	assert_eq(_mark(&"katana").line_m, 0.0)
	assert_eq(_mark(&"rocket_launcher").line_m, 0.0)


func test_the_line_prints_without_errors() -> void:
	var c: Canvas = Canvas.new()
	c.mark = _mark(&"plasma_sword")
	add_child_autofree(c)
	c.queue_redraw()
	await wait_physics_frames(2)
	assert_true(is_instance_valid(c))

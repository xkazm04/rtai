extends GutTest
## n16 kills-polish item 3 (asset lane A7): the ray gun leaves a drawn ash heap with a skull and
## the empty clothes, navy for a cop, grey for anyone else; it draws without errors.


class Canvas:
	extends Node2D
	var axis: Vector2 = Vector2.RIGHT

	func _draw() -> void:
		KillRemainsArt.draw(
			self, Vector2(40, 40), axis, Vector3(1.0, 32.0, 0.6), KillRemainsArt.NAVY
		)
		KillRemainsArt.draw(
			self, Vector2(40, 40), axis, Vector3(0.0, 32.0, 1.0), KillRemainsArt.GREY
		)


func test_the_clothes_follow_the_kind() -> void:
	assert_eq(KillRemainsArt.set_of("cop_patrol"), KillRemainsArt.NAVY)
	assert_eq(KillRemainsArt.set_of("cop_riot"), KillRemainsArt.NAVY)
	assert_eq(KillRemainsArt.set_of("swat"), KillRemainsArt.NAVY)
	assert_eq(KillRemainsArt.set_of("ped_hood"), KillRemainsArt.GREY)
	assert_eq(KillRemainsArt.set_of(""), KillRemainsArt.GREY, "no head card (the top view): grey")


func test_the_sheet_holds_four_cells() -> void:
	assert_eq(KillRemainsArt.ART.get_width(), KillRemainsArt.ART.get_height() * 4 * 8 / 5)


func test_drawn_by_default() -> void:
	assert_false(KillRemainsArt.plain())


func test_it_draws_both_ways_without_errors() -> void:
	var drawn: Array[Canvas] = []
	for axis: Vector2 in [Vector2.RIGHT, Vector2.LEFT]:
		var c: Canvas = Canvas.new()
		c.axis = axis
		add_child_autofree(c)
		c.queue_redraw()
		drawn.append(c)
	await wait_physics_frames(2)
	for c: Canvas in drawn:
		assert_true(is_instance_valid(c))


func test_the_eaten_body_takes_its_shadow_with_it() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	table.gore_full = SignatureKillTable.gore_from_args("full")
	var kills: SignatureKills = SignatureKills.new(table, RngRegistry.new(3).stream(&"brutality"))
	var fx: KillDissolveFx = KillDissolveFx.new()
	fx.kills = kills
	var row: SignatureKill = table.for_weapon(&"ray_gun")
	var body: Node2D = Node2D.new()
	fx.add(9, body, row, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.left(9, SignatureKill.BODY), 1.0, "standing")
	kills.tick = row.hitstop_ticks + row.stand_ticks + row.crumble_ticks + 1
	assert_eq(fx.left(9, SignatureKill.BODY), 0.0, "eaten: no shadow")
	assert_eq(fx.left(9, SignatureKill.HAT), 1.0, "the cap keeps its shadow")
	assert_eq(fx.left(8, SignatureKill.BODY), 1.0, "another kill")
	body.free()
	fx.free()

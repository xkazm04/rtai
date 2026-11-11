extends GutTest
## n16 kills-polish: the plasma hole sits the row's hole_up_m above the body group's centre (at the
## chest, not the hips), the ring on it, while the body itself stays where KillView placed it.


func _punch(up_m: float) -> Node2D:
	var body: Node2D = Node2D.new()
	body.name = "body"
	body.add_child(Sprite2D.new())
	var kills: SignatureKills = SignatureKills.new(
		SignatureKillTable.load_table(), RngRegistry.new(5).stream(&"brutality")
	)
	var root: Node2D = KillHoleFx.punch(body, kills, 64.0, up_m)
	add_child_autofree(root)
	return root


func test_the_plasma_row_lifts_the_hole_to_the_chest() -> void:
	var row: SignatureKill = SignatureKillTable.load_table().for_weapon(&"plasma_rifle")
	assert_not_null(row)
	assert_gt(row.hole_up_m, 0.0)


func test_the_hole_and_its_ring_move_up_and_the_body_stays() -> void:
	var lay: Node2D = _punch(0.4).get_child(0) as Node2D
	var mask: Sprite2D = lay.get_child(0) as Sprite2D
	var ring: KillHoleFx = lay.get_child(1) as KillHoleFx
	assert_almost_eq(mask.position, Vector2(0.0, -0.4 * 64.0), Vector2.ONE * 0.01)
	assert_eq(ring.position, mask.position, "the ring on the hole")
	var body: Node2D = mask.get_child(0) as Node2D
	var at: Vector2 = (mask.transform * body.transform).origin
	assert_almost_eq(at, Vector2.ZERO, Vector2.ONE * 0.01, "the body where it was placed")


func test_no_lift_is_the_before() -> void:
	var lay: Node2D = _punch(0.0).get_child(0) as Node2D
	assert_eq((lay.get_child(0) as Node2D).position, Vector2.ZERO)


## n16 item 3 (asset lane A4): the ring is the drawn one (three frames hot -> amber -> char).
func test_the_drawn_ring_is_on_and_three_square_frames_across() -> void:
	assert_false(KillHoleFx.plain())
	assert_eq(KillHoleFx.ART.get_width(), KillHoleFx.ART.get_height() * 3)
	assert_lt(KillHoleFx.ART_HOLE_PX, KillHoleFx.ART.get_height() * 0.5)

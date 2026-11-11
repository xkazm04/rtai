extends GutTest
## n16 kills-polish: a blade split's halves fall away from each other about their ground points once
## the hit-stop (and a saw's grind) ends, eased in over TOPPLE_TICKS to the row's split_topple_deg.


func _parts() -> Array[Node2D]:
	var parts: Array[Node2D] = []
	@warning_ignore("return_value_discarded")
	parts.resize(SignatureKill.PIECE_IDS.size())
	var a: Node2D = autofree(Node2D.new())
	var b: Node2D = autofree(Node2D.new())
	a.position = Vector2(10.0, 0.0)
	b.position = Vector2(-10.0, 0.0)
	parts[SignatureKill.HALF_A] = a
	parts[SignatureKill.HALF_B] = b
	return parts


func test_no_topple_without_a_degree_or_two_halves() -> void:
	assert_null(KillSplitHalves.topple(_parts(), 0, 0.0))
	var one: Array[Node2D] = _parts()
	one[SignatureKill.HALF_B] = null
	assert_null(KillSplitHalves.topple(one, 0, 80.0))


func test_nothing_turns_before_the_start() -> void:
	var parts: Array[Node2D] = _parts()
	KillSplitHalves.topple(parts, 10, 80.0).pose(10)
	assert_eq(parts[SignatureKill.HALF_A].rotation, 0.0)


func test_each_half_falls_away_from_the_other_to_the_row_degree() -> void:
	var parts: Array[Node2D] = _parts()
	var t: KillSplitHalves.Topple = KillSplitHalves.topple(parts, 10, 80.0)
	t.pose(10 + KillSplitHalves.TOPPLE_TICKS)
	assert_almost_eq(parts[SignatureKill.HALF_A].rotation, deg_to_rad(80.0), 0.0001, "right half")
	assert_almost_eq(parts[SignatureKill.HALF_B].rotation, -deg_to_rad(80.0), 0.0001, "left half")


func test_the_fall_eases_in() -> void:
	var parts: Array[Node2D] = _parts()
	KillSplitHalves.topple(parts, 0, 80.0).pose(KillSplitHalves.TOPPLE_TICKS / 2)
	assert_almost_eq(parts[SignatureKill.HALF_A].rotation, deg_to_rad(80.0) * 0.25, 0.0001)


func test_the_blade_rows_topple() -> void:
	var table: SignatureKillTable = SignatureKillTable.load_table()
	for weapon: StringName in [&"katana", &"plasma_sword", &"chainsaw", &"kerf_slice"]:
		assert_gt(table.for_weapon(weapon).split_topple_deg, 0.0, String(weapon))

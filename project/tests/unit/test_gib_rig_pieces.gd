extends GutTest
## n16 kills-polish (owner n15 verdict): a victim gibbed as a rig (the lone rocket shot's thug and
## hooded ped: parts drawn, no card, so GibCardCut never cut them) flies its kind's drawn pieces.


func _rig(row: String) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.head_card = autofree(Sprite2D.new())
	rig.head_card.set_meta(&"street_row", row)
	return rig


func _groups() -> Array[Node2D]:
	var out: Array[Node2D] = []
	for k: int in 6:
		var g: Node2D = autofree(Node2D.new())
		for j: int in 2:
			var part: Sprite2D = Sprite2D.new()
			part.name = "part%d" % j
			part.z_index = k + j
			g.add_child(part)
		out.append(g)
	return out


func test_the_thug_and_the_hood_fly_their_drawn_pieces_as_rigs() -> void:
	for row: String in ["thug", "ped/head_hood"]:
		var groups: Array[Node2D] = _groups()
		assert_true(GibCardPieces.dress_rig(_rig(row), groups), row)
		var m: float = GibCardPieces.RIG_TORSO_M * CharacterRigs.PX_PER_M / GibCardPieces.TORSO_PX
		for k: int in 6:
			assert_eq(groups[k].get_child_count(), 1, "%s piece %d: one drawn piece" % [row, k])
			var s: Sprite2D = groups[k].get_child(0) as Sprite2D
			var cell: float = GibCardPieces.CELL
			assert_eq(s.region_rect, Rect2(cell * k, 0.0, cell, cell))
			assert_eq(s.texture, load(GibCardPieces.GRIDS[row]))
			assert_eq(s.z_index, k + 1, "on the group's top z")
			assert_almost_eq(s.scale.x, m, 0.0001)


func test_a_kind_without_pieces_keeps_its_rig_parts() -> void:
	var groups: Array[Node2D] = _groups()
	assert_false(GibCardPieces.dress_rig(_rig("ped/head_none"), groups))
	assert_eq(groups[1].get_child_count(), 2)
	assert_eq(groups[1].get_child(0).name, "part0")


func test_a_rig_without_a_head_card_keeps_its_rig_parts() -> void:
	var rig: CutRig = autofree(CutRig.new())  # the top view: no head card (reel gate, top pass)
	var groups: Array[Node2D] = _groups()
	assert_false(GibCardPieces.dress_rig(rig, groups))

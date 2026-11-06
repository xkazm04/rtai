extends GutTest


func test_both_boss_arenas_are_dressed_north_to_south() -> void:
	for arena: String in ["king_boulevard", "depot"]:
		var d: BossDressing = autofree(BossDressing.from_table(arena))
		assert_not_null(d, arena)
		assert_gt(d.ids.size(), 8, "%s has its kit along both edges" % arena)
		for i: int in d.feet.size() - 1:
			assert_true(d.feet[i].y <= d.feet[i + 1].y, "drawn north to south")


func test_every_piece_has_its_55_art() -> void:
	var d: BossDressing = autofree(BossDressing.from_table("depot"))
	for id: String in d.ids:
		var p: String = "res://features/city/art/view/p55/dress_%s.png" % id
		assert_true(ResourceLoader.exists(p), p)


func test_an_undressed_arena_gets_none() -> void:
	assert_null(BossDressing.from_table("no_such_arena"))


func test_the_flat_view_attaches_none() -> void:
	if not ViewMode.shared().is_flat():
		pass_test("the run's view is angled")
		return
	var floor: Node2D = autofree(Node2D.new())
	var parent: Node2D = autofree(Node2D.new())
	parent.add_child(floor)
	assert_null(BossDressing.attach(floor, "depot", Vector2.ZERO), "top is untouched")

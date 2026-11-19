extends GutTest


func after_each() -> void:
	GhostLook.reset_for_test()


func test_shipped_rows_default_to_legacy() -> void:
	GhostLook.override_for_test(&"")
	for id: StringName in GhostFormTable.load_default().order:
		assert_eq(GhostLook.of(id), GhostLook.LEGACY, str(id))
	assert_eq(GhostLook.of(&"missing"), GhostLook.LEGACY)


func test_override_selects_spectral_for_every_form() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for id: StringName in GhostFormTable.load_default().order:
		assert_true(GhostLook.spectral(id), str(id))


func test_unknown_override_uses_legacy() -> void:
	GhostLook.override_for_test(&"misspelled")
	assert_eq(GhostLook.of(&"kerf"), GhostLook.LEGACY)


func test_spectral_host_keeps_the_standing_column_on_the_walk_grid() -> void:
	var d: GhostDrawn = GhostDrawn.new("tonnage", 3.3, 235.0, 190.5)
	d._steps = GhostStride.table_of("tonnage", "p70")
	var host: Node2D = add_child_autofree(Node2D.new())
	var stand: int = roundi(GhostDrawn.STAND_COL * d._steps.size() / float(GhostDrawn.COLS))
	d.hover = true
	for tick: int in 12:
		host.position += Vector2(16.0, 2.0)
		assert_eq(d._column(host, 1.0, 2), stand)
	assert_eq(d._phase, 0.0)
	assert_false(d._running)

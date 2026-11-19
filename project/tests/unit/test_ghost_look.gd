extends GutTest

var _forms: GhostFormTable
var _flags: Dictionary[String, String]
var _unknown: Array[String]


func before_each() -> void:
	_forms = GhostLook._forms
	_flags = LaunchArgs._values.duplicate()
	_unknown = LaunchArgs._unknown.duplicate()


func after_each() -> void:
	LaunchArgs._values = _flags
	LaunchArgs._unknown = _unknown
	GhostLook._forms = _forms
	GhostLook.reset_for_test()


func test_each_form_uses_its_own_row_without_an_override() -> void:
	GhostLook.override_for_test(&"")
	var forms: GhostFormTable = GhostFormTable.load_default()
	for id: StringName in forms.order:
		assert_eq(GhostLook.of(id), forms.form(id).look, str(id))
	assert_eq(GhostLook.of(&"missing"), GhostLook.LEGACY)


func test_missing_and_unknown_row_fields_use_the_legacy_default() -> void:
	var table: DataTable = DataTable.open(GhostFormTable.PATH, GhostFormTable.SCHEMA)
	var row: Dictionary = table.array(table.raw, "forms")[0]
	assert_true(row.erase("look"))
	assert_eq(GhostFormDef.from_row(table, row).look, GhostLook.LEGACY)
	row["look"] = "mist"
	assert_eq(GhostFormDef.from_row(table, row).look, GhostLook.LEGACY)
	row["look"] = "spectral"
	assert_eq(GhostFormDef.from_row(table, row).look, GhostLook.SPECTRAL)


func test_launch_flag_wins_over_independent_form_defaults() -> void:
	GhostLook._forms = GhostFormTable.load_default()
	GhostLook._forms.form(&"kerf").look = GhostLook.SPECTRAL
	GhostLook._forms.form(&"ohm").look = GhostLook.LEGACY
	LaunchArgs.parse(["--ghost-look=legacy"])
	assert_false(GhostLook.spectral(&"kerf"))
	LaunchArgs.parse(["--ghost-look=spectral"])
	assert_true(GhostLook.spectral(&"ohm"))
	LaunchArgs.parse(["--ghost-look=mist"])
	assert_false(GhostLook.spectral(&"kerf"))
	LaunchArgs.parse([])
	assert_true(GhostLook.spectral(&"kerf"))
	assert_false(GhostLook.spectral(&"ohm"))


func test_override_selects_spectral_for_every_form() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for id: StringName in GhostFormTable.load_default().order:
		assert_true(GhostLook.spectral(id), str(id))


func test_unknown_override_uses_legacy() -> void:
	GhostLook.override_for_test(&"misspelled")
	assert_eq(GhostLook.of(&"kerf"), GhostLook.LEGACY)


func test_missing_hover_tuning_keeps_the_ground_rig_available() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	var layer: Node2D = add_child_autofree(Node2D.new())
	var body: Node2D = Node2D.new()
	var drawn: GhostDrawn = GhostDrawn.new("missing", 1.0, 1.0, 1.0)
	GhostFormBodies._attach_body(layer, body, drawn, &"missing")
	assert_eq(body.get_parent(), layer)
	assert_false(drawn.hover)
	assert_null(drawn.flight)


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

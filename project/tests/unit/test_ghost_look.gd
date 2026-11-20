extends GutTest

var _forms: GhostFormTable
var _flags: Dictionary[String, String]
var _unknown: Array[String]
var _view: ViewMode


func before_each() -> void:
	_forms = GhostLook._forms
	_flags = LaunchArgs._values.duplicate()
	_unknown = LaunchArgs._unknown.duplicate()
	_view = ViewMode._shared


func after_each() -> void:
	LaunchArgs._values = _flags
	LaunchArgs._unknown = _unknown
	ViewMode._shared = _view
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


func test_hover_loads_combat_and_standing_cells_and_can_return_to_the_run_grid() -> void:
	ViewMode.select("tilt70")
	var kerf: GhostDrawn = GhostDrawn.new("kerf", 1.8, 180.0, 173.0, 388.0)
	var host: Node2D = add_child_autofree(Node2D.new())
	kerf.hover = true
	assert_true(kerf.step(host, [], SimConst.PX_PER_M, 1.0))
	assert_not_null(kerf._walk)
	assert_not_null(kerf._act)
	assert_null(kerf._run)
	kerf.hover = false
	assert_true(kerf.step(host, [], SimConst.PX_PER_M, 1.0))
	assert_not_null(kerf._run)
	assert_eq(host.get_node("ghost_drawn"), kerf._spr, "the trace sees the replacement sprite")
	var tonnage: GhostDrawn = GhostDrawn.new("tonnage", 3.3, 235.0, 190.5)
	tonnage.hover = true
	var press: Node2D = add_child_autofree(Node2D.new())
	assert_true(tonnage.step(press, [], SimConst.PX_PER_M, 1.0))
	assert_null(tonnage._walk._profile_mid)
	assert_true(tonnage._walk._intervals.is_empty(), "hover skips the gait in-betweens")


func test_a_form_can_release_the_bridge_after_its_shared_cell_was_shown() -> void:
	ViewMode.select("tilt70")
	var host: Node2D = add_child_autofree(Node2D.new())
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	var drawn: GhostDrawn = GhostDrawn.new("kerf", 1.8, 150.0, 173.0)
	drawn.hover = true
	drawn.release_fade()
	drawn.flight = flight
	flight.step(Vector2.ZERO, 0.0, 1)
	assert_true(drawn.step(host, [], 32.0, 1.0, 0.0))
	assert_not_null(drawn.sprite().material)
	drawn.release_fade()
	assert_null(drawn.sprite().material)
	assert_eq(flight.tail._socket_width, 0.0)


func test_last_hurt_tick_tracks_the_combat_feed() -> void:
	var acts: GhostDrawnActs = GhostDrawnActs.new()
	assert_eq(acts.hurt_tick(), -1)
	acts.feed(0, 10, 12)
	assert_eq(acts.hurt_tick(), 10)
	acts.feed(1, 14, 17)
	assert_eq(acts.hurt_tick(), 14)

extends GutTest
## Exercise the custom drawer through both sheet pitches and a mounted flight body.

var _saved: ViewMode


func before_each() -> void:
	_saved = ViewMode._shared
	GhostLook.override_for_test(GhostLook.SPECTRAL)


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _saved


func _mount(view: String) -> TonnageRig:
	ViewMode._shared = ViewMode.of(view)
	var rig: TonnageRig = TonnageRig.new()
	var flight: GhostFlight = GhostFlight.make(&"tonnage")
	rig.drawn.flight = flight
	rig.drawn.hover = true
	flight.mount(rig)
	add_child_autofree(flight)
	flight.step(Vector2(400, 100), 0.0, 1)
	rig.advance(SimClock.TICK_DT)
	return rig


func test_column_starts_inside_the_painted_belly_at_both_tilts() -> void:
	for view: String in ["tilt", "tilt70"]:
		var rig: TonnageRig = _mount(view)
		var ink: Sprite2D = rig._spectral._cell
		var flight: GhostFlight = rig.drawn.flight
		var waist: Vector2 = ink.to_local(flight.tail.points()[0])
		assert_almost_eq(waist, Vector2(-44, -91), Vector2.ONE * 0.01, view)
		ViewMode._shared = ViewMode.of("top")
		flight.step(Vector2(400, 100), 0.0, 1)
		rig.advance(SimClock.TICK_DT)
		var row: GhostHoverRow = GhostHoverRow.of(&"tonnage")
		var root_px: Vector2 = flight.shadow.global_position + flight.hover.lag_px
		root_px += row.tail.anchor_m * SimConst.PX_PER_M * flight.body_scale()
		assert_almost_eq(flight.tail.points()[0], root_px, Vector2.ONE * 0.01, "overhead socket")


func test_eight_headings_use_their_painted_row_on_each_pose_and_act_sheet() -> void:
	for view: String in ["tilt", "tilt70"]:
		var rig: TonnageRig = _mount(view)
		var body: TonnageSpectral = rig._spectral
		for oct: int in 8:
			rig.rotation = oct * PI / 4.0
			for acting: bool in [false, true]:
				body.pose.act = acting
				var sheet: String = "spectral_act" if acting else "spectral_pose"
				var path: String = GhostDrawn.path_of(ViewMode.shared().art, "tonnage", sheet)
				for col: int in 3 if acting else 4:
					body.pose.column = col
					body._present()
					var ink: Sprite2D = body._cell
					assert_eq(ink.texture.resource_path, path)
					assert_eq(ink.frame_coords, Vector2i(col, RigHeadCard.OCT_FRAME[oct]))
					assert_eq(ink.flip_h, RigHeadCard.OCT_FLIP[oct] == 1)
					assert_eq(ink.offset, Vector2(-192.0, -315.0))

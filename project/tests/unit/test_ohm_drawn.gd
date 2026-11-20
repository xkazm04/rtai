extends GutTest

const HOVER_ROWS: Array = [
	"toward", "toward_right", "right", "away_right", "away", "away_left", "left", "toward_left"
]
const HOVER_ROW_BY_OCTANT: Array[int] = [2, 1, 0, 7, 6, 5, 4, 3]


func test_hud_face_follows_ohms_selected_look() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	assert_eq(GhostChipFace.face(OhmStage.ID).resource_path, GhostChipFace.DIR + "ohm_spectral.png")
	GhostLook.override_for_test(GhostLook.LEGACY)
	assert_eq(GhostChipFace.face(OhmStage.ID).resource_path, GhostChipFace.DIR + "ohm.png")
	GhostLook.reset_for_test()


func test_jar_twin_tracks_the_shown_cell_on_both_sheets_and_the_mirrored_side() -> void:
	var sprite: Sprite2D = add_child_autofree(Sprite2D.new())
	var jars: OhmJars = OhmJars.new()
	sprite.add_child(jars)
	sprite.transform = Transform2D(0.17, Vector2(0.4, 0.45), 0.03, Vector2(96, 41))
	sprite.centered = false
	for pitch: String in ["p70", "p55"]:
		for kind: String in ["hover", "act"]:
			var path: String = "res://features/souls/art/view/%s/ohm_spec_%s" % [pitch, kind]
			sprite.texture = load(path + ".png") as Texture2D
			var mask: Texture2D = load(path + "_jars.png") as Texture2D
			sprite.hframes = 2 if kind == "hover" else 4
			sprite.vframes = 8 if kind == "hover" else 5
			sprite.offset = Vector2(-159, -227) if pitch == "p70" else Vector2(-177, -264)
			for flip: bool in [false, true]:
				sprite.flip_h = flip
				for cell: int in sprite.hframes * sprite.vframes:
					sprite.frame = cell
					jars.match_cell(sprite, mask)
					assert_eq(jars.texture, mask)
					assert_eq(jars.frame_coords, sprite.frame_coords)
					assert_eq(jars.flip_h, flip)
					assert_eq(jars.offset, sprite.offset)
					assert_eq(jars.global_transform, sprite.global_transform)


func test_authored_hover_keeps_its_hem_and_jar_twin_at_both_tilts() -> void:
	var saved: ViewMode = ViewMode._shared
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for pitch: String in ["tilt70", "tilt"]:
		ViewMode.select(pitch)
		var rig: OhmRig = OhmRig.new()
		var flight: GhostFlight = add_child_autofree(GhostFlight.make(OhmStage.ID))
		rig.drawn.flight = flight
		flight.mount(rig)
		flight.step(Vector2.ZERO, 0.0, 1)
		rig.tick = 36
		rig.pose()
		var shown: Sprite2D = rig.drawn.sprite()
		assert_eq(shown.texture.resource_path.get_file(), "ohm_spec_hover.png")
		assert_null(shown.material)
		assert_eq(shown.hframes, 2)
		assert_almost_eq(shown.global_rotation, deg_to_rad(3.0), 0.00001)
		for child: Node in shown.get_children():
			if child is OhmJars:
				assert_eq((child as OhmJars).global_transform, shown.global_transform)
	GhostLook.reset_for_test()
	ViewMode._shared = saved


func test_each_spectral_hover_turn_and_left_strike_use_their_own_sheet_rows() -> void:
	var saved: ViewMode = ViewMode._shared
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		var dir: String = GhostDrawn.ART_DIR.path_join(ViewMode.shared().art)
		var meta: Dictionary = JSON.parse_string(
			FileAccess.get_file_as_string(dir.path_join("ohm_spec_cells.json"))
		)
		var hover: Dictionary = meta.sheets.hover
		var act: Dictionary = meta.sheets.act
		var hover_rows: Array = hover.rows
		var act_rows: Array = act.rows
		assert_eq(hover_rows, HOVER_ROWS)
		assert_eq(act_rows, HOVER_ROWS.slice(0, 5))
		var rig: OhmRig = OhmRig.new()
		var flight: GhostFlight = add_child_autofree(GhostFlight.make(OhmStage.ID))
		rig.drawn.flight = flight
		flight.mount(rig)
		for col: int in 2:
			flight.step(Vector2.RIGHT * col * 2.0, 0.0, 1)
			for oct: int in 8:
				rig.global_rotation = oct * PI / 4.0
				rig.pose()
				var cell: Vector2i = Vector2i(col, HOVER_ROW_BY_OCTANT[oct])
				_check_cell(rig, hover, "hover", cell, false)
		rig.global_rotation = PI
		rig.drawn.feed(1, -1, 12, false, 12)
		rig.pose()
		_check_cell(rig, act, "act", Vector2i(1, 2), true)
		rig.drawn.feed(1, -1, 50)
		rig.pose()
		_check_cell(rig, hover, "hover", Vector2i(1, 6), false)
	GhostLook.reset_for_test()
	ViewMode._shared = saved


func _check_cell(rig: OhmRig, meta: Dictionary, kind: String, cell: Vector2i, flip: bool) -> void:
	var sprite: Sprite2D = rig.drawn.sprite()
	assert_eq(sprite.texture.resource_path.get_file(), "ohm_spec_%s.png" % kind)
	assert_eq(sprite.frame_coords, cell)
	assert_eq(sprite.flip_h, flip)
	var rows: Array = meta.rows
	assert_eq(sprite.vframes, rows.size())
	var jars: OhmJars = rig._spectral._jars
	assert_eq(jars.texture.resource_path.get_file(), "ohm_spec_%s_jars.png" % kind)
	assert_eq(jars.frame_coords, cell)
	assert_eq(jars.vframes, sprite.vframes)
	assert_eq(jars.flip_h, flip)
	var columns: Array = meta.columns
	var index: int = cell.y * columns.size() + cell.x
	var fork: Dictionary = meta.forks_row_major[index]
	var tips: PackedVector2Array = OhmFork.unpack(fork)
	var actual: PackedVector2Array = rig._spectral._fork.points_on(sprite)
	for i: int in tips.size():
		var p: Vector2 = tips[i]
		if flip:
			p.x = sprite.texture.get_width() / float(sprite.hframes) - p.x
		assert_true(actual[i].is_equal_approx(sprite.offset + p), "fork attachment %s" % cell)
	var top: Vector3 = jars._ink.get_shader_parameter(&"top_px")
	var row_y: float = cell.y * jars.texture.get_height() / float(jars.vframes)
	for i: int in 3:
		var box: Variant = meta.jar_boxes_row_major[index][i]
		if box != null:
			var y: float = box[1]
			assert_eq(top[i], row_y + y, "jar coverage starts in the shown row")

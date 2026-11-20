extends GutTest

const CELL: int = 8

var _saved_view: ViewMode
var _serial: int = 0
var _card: String
var _drawn: GhostDrawn
var _host: Node2D
var _flight: GhostFlight
var _textures: Array[Texture2D] = []


func before_each() -> void:
	_saved_view = ViewMode._shared
	ViewMode.select("tilt70")
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	_serial += 1
	_card = "fixture_%d_%d" % [get_instance_id(), _serial]
	_drawn = GhostDrawn.new(_card, 1.0, 100.0, CELL)
	_host = add_child_autofree(Node2D.new())
	_flight = add_child_autofree(GhostFlight.make(&"ohm"))
	_drawn.flight = _flight
	_drawn.hover = true
	_flight.step(Vector2.ZERO, 0.0, 1)


func after_each() -> void:
	_textures.clear()
	GhostLook.reset_for_test()
	ViewMode._shared = _saved_view


## Runtime PNGs have no editor import. Register the decoded texture at this test card's path.
func _sheet(kind: String, cols: int, rows: int = GhostDrawn.ROWS) -> Texture2D:
	var img: Image = Image.create_empty(cols * CELL, rows * CELL, false, Image.FORMAT_RGBA8)
	for col: int in cols:
		img.fill_rect(
			Rect2i(col * CELL, 0, CELL, img.get_height()), Color.from_hsv(col / float(cols), 1, 1)
		)
	var path: String = TestTmp.dir(_card).path_join(kind + ".png")
	assert_eq(img.save_png(path), OK)
	var tex: ImageTexture = ImageTexture.create_from_image(Image.load_from_file(path))
	tex.take_over_path(GhostDrawn.path_of("p70", _card, kind))
	_textures.append(tex)
	return tex


func _show(look: float = 0.0) -> Sprite2D:
	assert_true(_drawn.step(_host, [], SimConst.PX_PER_M, 1.0, look))
	return _drawn.sprite()


func test_own_body_preserves_rig_parts_and_flight_then_releases_the_standing_cell() -> void:
	var walk: Texture2D = _sheet("walk8", 8)
	var part: Sprite2D = add_child_autofree(Sprite2D.new())
	assert_eq(_show().texture, walk)
	assert_eq(_drawn.sprite().frame_coords.x, GhostDrawn.STAND_COL)
	_drawn.own_body = true
	assert_null(_drawn.sprite())
	_drawn.feed(0, -1, 1, true)
	for show_part: bool in [true, false]:
		part.visible = show_part
		_flight.step(Vector2.RIGHT * 10, 0.0, 1)
		assert_false(_drawn.step(_host, [part], SimConst.PX_PER_M, 1.0))
		assert_eq(part.visible, show_part)
		assert_null(_drawn.sprite())
		assert_eq(_drawn.act_col(), GhostDrawn.WINDUP_COL)
	assert_false(_flight.tail.points().is_empty())
	_drawn.own_body = false
	assert_eq(_show().texture, walk)
	assert_eq(_drawn.sprite().frame_coords.x, GhostDrawn.STAND_COL)


func test_auto_pose_uses_flight_speed_and_combat_overrides_an_explicit_pose() -> void:
	var poses: Texture2D = _sheet("spec_hover", 2)
	var acts: Texture2D = _sheet("spec_act", 4)
	assert_eq(_show().texture, poses)
	assert_eq(_drawn.sprite().frame_coords.x, 0)
	var half_mps: float = 0.5 * SimConst.PX_PER_M * SimClock.TICK_DT
	_flight.step(Vector2.RIGHT * half_mps, 0.0, 1)
	assert_eq(_show().frame_coords.x, 1, "cruise begins at 0.5 m/s")
	_drawn.pose = 0
	assert_eq(_show().frame_coords.x, 0)
	_drawn.feed(0, -1, 60)
	_drawn.feed(1, -1, 61)
	assert_eq(_show().texture, acts)
	assert_eq(_drawn.sprite().frame_coords.x, GhostDrawn.CUT_COL)
	_drawn.feed(1, -1, 80)
	assert_eq(_show().texture, poses)
	assert_eq(_drawn.sprite().frame_coords.x, 0)
	assert_eq(_drawn._phase, 0.0)
	assert_null(_drawn._run)


func test_four_poses_use_drawn_left_rows_and_fall_back_to_legacy_combat() -> void:
	assert_not_null(_sheet("spec_hover", 4))
	var left: Texture2D = _sheet("spec_hover_left", 4, GhostSheet.LEFT_ROWS)
	var acts: Texture2D = _sheet("act", 4)
	_drawn.pose = 3
	assert_eq(_show(PI).texture, left)
	assert_eq(_drawn.sprite().frame_coords, Vector2i(3, 1))
	assert_false(_drawn.sprite().flip_h)
	_drawn.feed(0, 20, 20)
	assert_eq(_show(PI).texture, acts)
	assert_eq(_drawn.sprite().frame_coords.x, GhostDrawn.HIT_COL)
	assert_true(_drawn.sprite().flip_h)


func test_missing_pose_uses_the_legacy_standing_cell_with_a_spectral_act() -> void:
	var walk: Texture2D = _sheet("walk8", 8)
	var special: Texture2D = _sheet("spec_act", 4)
	var legacy: Texture2D = _sheet("act", 4)
	_drawn.pose = 1
	assert_eq(_show().texture, walk)
	assert_eq(_drawn.sprite().frame_coords.x, GhostDrawn.STAND_COL)
	_drawn.feed(1, -1, 20, true)
	assert_eq(_show().texture, special)
	_drawn.hover = false
	assert_eq(_show().texture, legacy)


func test_a_single_pose_always_uses_zero_and_mirrors_without_a_left_sheet() -> void:
	var only: Texture2D = _sheet("spec_hover", 1)
	_drawn.pose = 3
	assert_eq(_show(PI).texture, only)
	assert_true(_drawn.sprite().flip_h)
	assert_eq(_drawn.sprite().frame_coords.x, 0)
	_drawn.pose = -1
	_flight.step(Vector2.RIGHT * 8.0, 0.0, 1)
	assert_eq(_show().frame_coords.x, 0)


func test_spectral_ohm_skips_instant_anticipation_and_keeps_the_delayed_windup() -> void:
	var flags: Dictionary[String, String] = LaunchArgs._values.duplicate()
	GhostLook.reset_for_test()
	LaunchArgs._values["--ghost-look"] = "spectral"
	var ohm: GhostDrawn = GhostDrawn.new("ohm", 1.0, 100.0, 8.0)
	assert_eq(ohm.instant_windup, 0)
	ohm.feed(0, -1, 60)
	ohm.feed(1, -1, 61)
	assert_eq(ohm.act_col(), GhostDrawn.CUT_COL)
	ohm.feed(1, -1, 90, true)
	assert_eq(ohm.act_col(), GhostDrawn.WINDUP_COL)
	ohm.feed(2, -1, 93, false, 93)
	assert_eq(ohm.act_col(), GhostDrawn.CUT_COL)
	LaunchArgs._values["--ghost-look"] = "legacy"
	var legacy: GhostDrawn = GhostDrawn.new("ohm", 1.0, 100.0, 8.0)
	LaunchArgs._values = flags
	assert_gt(legacy.instant_windup, 0)
	legacy.feed(0, -1, 60)
	legacy.feed(1, -1, 61)
	assert_eq(legacy.act_col(), GhostDrawn.WINDUP_COL)


func test_overlay_reads_this_ticks_projected_ribbon_before_draw() -> void:
	var tail: GhostTail = _flight.tail
	var row: GhostHoverRow = GhostHoverRow.of(&"ohm")
	_flight.position = Vector2(19.0, -4.0)
	_flight.scale = Vector2.ONE * 2.0
	tail.reset(Vector2(12.0, 30.0), 0.0, 1.0)
	var pts: PackedVector2Array = tail.points()
	var widths: PackedFloat32Array = tail.half_widths()
	assert_eq(pts.size(), row.tail.segments + 1)
	assert_eq(widths.size(), pts.size())
	var root: Vector2 = Vector2(12.0, 30.0) + ViewMode.shared().lift_px(1.0)
	assert_almost_eq(pts[0], tail.to_global(root), Vector2.ONE * 0.001)
	assert_almost_eq(pts[-1], tail.to_global(tail._chain[-1]), Vector2.ONE * 0.001)
	assert_almost_eq(widths[0], row.tail.width_m * SimConst.PX_PER_M, 0.001)
	assert_eq(widths[-1], 0.0)
	pts[0] = Vector2.INF
	tail.step(Vector2(14.0, 30.0), 0.0, 3.0, 1.0, 1)
	assert_almost_eq(tail.points()[0], tail.to_global(root + Vector2(2, 0)), Vector2.ONE * 0.001)


func test_legacy_cell_cut_and_tail_socket_follow_the_displayed_belt() -> void:
	_flight = add_child_autofree(GhostFlight.make(&"kerf"))
	_drawn.flight = _flight
	_flight.step(Vector2.ZERO, 0.0, 1)
	var legacy: Texture2D = _sheet("walk8", 8)
	var stand: Sprite2D = _show()
	assert_eq(stand.texture, legacy)
	var cell: Vector2 = stand.texture.get_size() / Vector2(stand.hframes, stand.vframes)
	var belt: Vector2 = stand.offset + cell * Vector2(0.5, 1.0 - _flight.fade_from())
	assert_almost_eq(_flight.tail.points()[0], stand.to_global(belt), Vector2.ONE * 0.001)
	var mat: ShaderMaterial = stand.material as ShaderMaterial
	assert_eq(mat.shader, preload("res://features/souls/ghost_fade.gdshader"))
	var phase: float = mat.get_shader_parameter(&"flow")
	_flight.step(Vector2(120, 20), 2.1, 0)
	var held: float = (_show().material as ShaderMaterial).get_shader_parameter(&"flow")
	assert_eq(held, phase)
	_flight.step(Vector2.RIGHT, 0.0, 1)
	held = (_show().material as ShaderMaterial).get_shader_parameter(&"flow")
	assert_gt(held, phase)


func test_authored_spectral_cells_bypass_the_legacy_leg_cut() -> void:
	assert_eq(_sheet("spec_hover", 2), _show().texture)
	assert_null(_drawn.sprite().material)
	assert_eq(_flight.tail._socket_width, 0.0)

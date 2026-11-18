extends GutTest
## Exercise the worn ghost's sprite, including act priority and the drawn left hit rows.

const ROW: Array[int] = [2, 1, 0, 1, 2, 3, 4, 3]

var _saved_view: ViewMode
var _host: Node2D


func before_each() -> void:
	_saved_view = ViewMode.shared()
	_host = add_child_autofree(Node2D.new())


func after_each() -> void:
	ViewMode._shared = _saved_view


func _check_cell(d: GhostDrawn, oct: int, back: bool) -> void:
	var left: bool = oct >= 3 and oct <= 5
	var suffix: String = "act_hitback" if back else ("act_left" if left else "act")
	var path: String = GhostDrawn.path_of(ViewMode.shared().art, d.card_name, suffix)
	var row: int = oct - 3 if left and not back else ROW[oct]
	var col: int = 0 if back else GhostDrawn.HIT_COL
	assert_eq(d._spr.texture.resource_path, path, "%s octant %d" % [d.card_name, oct])
	assert_eq(d._spr.frame_coords, Vector2i(col, row))
	assert_eq(d._spr.flip_h, back and left)


func _check_blow(d: GhostDrawn, oct: int, direction: Vector2, back: bool) -> void:
	d.blow = direction
	d.feed(0, 20, 20)
	assert_true(d.step(_host, [], 32.0, 1.0, oct * PI / 4.0))
	_check_cell(d, oct, back)


func test_front_side_unknown_and_back_blows_select_the_cell_in_every_facing() -> void:
	for view: String in ["combo", "tilt"]:
		ViewMode.select(view)
		for form: String in ["dent", "ohm"]:
			var d: GhostDrawn = GhostDrawn.new(form, 1.8, 180.0, 180.0)
			for oct: int in 8:
				var facing: Vector2 = Vector2.from_angle(oct * PI / 4.0)
				_check_blow(d, oct, -facing, false)
				_check_blow(d, oct, facing.orthogonal(), false)
				_check_blow(d, oct, Vector2.ZERO, false)
				_check_blow(d, oct, facing * 3.0, true)


func test_kerf_and_tonnage_keep_their_usual_hit_for_a_blow_from_behind() -> void:
	ViewMode.select("combo")
	for form: String in ["kerf", "tonnage"]:
		var d: GhostDrawn = GhostDrawn.new(form, 1.8, 180.0, 180.0)
		for oct: int in 8:
			_check_blow(d, oct, Vector2.from_angle(oct * PI / 4.0), false)


func test_only_hits_inside_the_rear_cone_switch() -> void:
	ViewMode.select("combo")
	var d: GhostDrawn = GhostDrawn.new("dent", 1.8, 180.0, 180.0)
	_check_blow(d, 0, Vector2.from_angle(deg_to_rad(59.0)), true)
	_check_blow(d, 0, Vector2(0.5, sqrt(0.75)), false)
	_check_blow(d, 0, Vector2.from_angle(deg_to_rad(61.0)), false)
	d.blow = Vector2.RIGHT
	d.feed(1, 21, 21)
	assert_true(d.step(_host, [], 32.0, 1.0, 0.0))
	assert_eq(d._spr.texture.resource_path, GhostDrawn.path_of("p70", "dent", "act"))
	assert_eq(d._spr.frame_coords.x, GhostDrawn.CUT_COL)


func test_switch_off_shows_the_original_hit_in_all_eight_octants() -> void:
	ViewMode.select("combo")
	var d: GhostDrawn = GhostDrawn.new("ohm", 1.8, 180.0, 180.0)
	for oct: int in 8:
		_check_blow(d, oct, Vector2.from_angle(oct * PI / 4.0), true)
		d._show_cell(d._act, oct, GhostDrawn.HIT_COL, false)
		_check_cell(d, oct, false)


func test_ohms_windup_interrupts_a_rear_hit_then_returns_to_walk() -> void:
	ViewMode.select("combo")
	var d: GhostDrawn = GhostDrawn.new("ohm", 1.55, 126.0, 180.0)
	_check_blow(d, 0, Vector2.RIGHT, true)
	d.feed(1, 20, 21)
	assert_true(d.step(_host, [], 32.0, 1.0, 0.0))
	assert_eq(d._spr.texture.resource_path, GhostDrawn.path_of("p70", "ohm", "act"))
	assert_eq(d._spr.frame_coords, Vector2i(0, 2))
	d.feed(1, 20, 40)
	assert_true(d.step(_host, [], 32.0, 1.0, 0.0))
	assert_eq(d._spr.texture.resource_path, GhostDrawn.path_of("p70", "ohm"))

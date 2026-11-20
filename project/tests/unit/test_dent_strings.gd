extends GutTest

const PPM: float = 32.0
const HALF: Vector2 = Vector2(3.2 * 0.36, 1.6 * 0.55)
const LEFT: Vector2 = Vector2(22, -12)
const RIGHT: Vector2 = Vector2(22, 12)

var car: VehicleBody
var s: DentStrings
var vm: ViewMode


class InkRecorder:
	extends DentStrapCanvas
	var strokes: Array[PackedVector2Array] = []
	var widths: Array[float] = []
	var colors: Array[Color] = []
	var rings: Array[Vector2] = []

	func _init() -> void:
		super(null)

	func stroke(points: PackedVector2Array, color: Color, width: float) -> void:
		strokes.append(points)
		widths.append(width)
		colors.append(color)

	func ring(c: Vector2, _r: float, _color: Color, _width: float) -> void:
		rings.append(c)


func before_each() -> void:
	car = VehicleBody.new(1, null, Vector2(5, 0), Vector2.RIGHT)
	s = DentStrings.new(DentStrap.new(HaulerLook.TEAL, VehicleView.CAR_H_M))
	vm = ViewMode.of("top")
	_place(10, 0.0)


func _place(tick: int, turn: float, hits: int = 0) -> void:
	s.strap.advance(car, tick, 0.0, -1)
	var left: Vector2 = LEFT + DentStringSteer.offset_m(-1, turn, Vector2.RIGHT, vm) * PPM
	var right: Vector2 = RIGHT + DentStringSteer.offset_m(1, turn, Vector2.RIGHT, vm) * PPM
	s.strap.place(right, PPM, false, vm)
	s.place(left, turn, hits, vm)


func test_top_four_endpoints_rotate_with_car_and_keep_the_hand_pairing() -> void:
	car.head = Vector2.DOWN
	_place(11, 0.0)
	for i: int in 4:
		var local: Vector2 = Vector2(HALF.x if i % 2 else -HALF.x, -HALF.y if i < 2 else HALF.y)
		var path: PackedVector2Array = s.path(i)
		assert_eq(path.size(), 2)
		assert_eq(path[0], LEFT if i < 2 else RIGHT)
		assert_almost_eq(path[-1], (car.pos + local.rotated(PI / 2)) * PPM, Vector2.ONE * 0.001)


func test_inside_roof_dips_only_in_tilt_and_steering_takes_up_both_inside_strings() -> void:
	for turn: float in [-1.0, 1.0]:
		var inside: int = 0 if turn < 0.0 else 2
		var outside: int = 2 - inside
		vm = ViewMode.of("tilt70")
		_place(12, 0.0)
		var rest: Vector2 = s.corner(inside)
		var far: Vector2 = s.corner(outside)
		var roof: Vector2 = car.pos * PPM + vm.lift_px(VehicleView.CAR_H_M)
		_place(13, turn)
		var dip: Vector2 = rest.direction_to(roof) * 0.15 * PPM + vm.lift_px(0.15)
		assert_almost_eq(s.corner(inside), rest + dip, Vector2.ONE * 0.001)
		assert_eq(s.corner(outside), far)
		for i: int in 2:
			assert_lt(_length(s.path(inside + i)), _length(s.path(outside + i)))
		vm = ViewMode.of("top")
		_place(14, 0.0)
		rest = s.corner(inside)
		_place(15, turn)
		assert_eq(s.corner(inside), rest)


func _length(points: PackedVector2Array) -> float:
	var distance: float = 0.0
	for i: int in range(1, points.size()):
		distance += points[i - 1].distance_to(points[i])
	return distance


func test_heading_rate_wrap_repeated_and_skipped_ticks_and_new_link() -> void:
	var steer: DentStringSteer = DentStringSteer.new()
	car.head = Vector2.from_angle(deg_to_rad(179.0))
	steer.sample(car, 50, 120.0)
	assert_eq(steer.turn, 0.0)
	car.head = Vector2.from_angle(deg_to_rad(-179.0))
	steer.sample(car, 52, 120.0)
	assert_almost_eq(steer.turn, 0.5, 0.001)
	steer.sample(car, 52, 120.0)
	assert_almost_eq(steer.turn, 0.5, 0.001)
	car.head = Vector2.from_angle(deg_to_rad(168.0))
	steer.sample(car, 53, 120.0)
	assert_eq(steer.turn, -1.0)
	steer.sample(null, 54, 120.0)
	steer.sample(car, 55, 120.0)
	assert_eq(steer.turn, 0.0)


func test_each_line_falls_for_21_ticks_and_fades_over_nine() -> void:
	s.strap.advance(null, 11, 0.0, -1)
	for age: int in [0, 7, 21, 25, 29, 30]:
		s.strap.advance(null, 11 + age, 0.0, -1)
		for i: int in 4:
			var path: PackedVector2Array = s.path(i)
			var straight: Vector2 = path[0].lerp(path[-1], 0.5)
			var mid: Vector2 = straight if path.size() == 2 else path[8]
			var sag: float = 0.65 * PPM * minf(age / 21.0, 1.0)
			assert_almost_eq(mid, straight + Vector2.DOWN * sag, Vector2.ONE * 0.001)
		assert_almost_eq(s.strap.fray(), clampf((age - 21.0) / 9, 0.0, 1.0), 0.001)
		assert_eq(s.strap.showing(), age < 30)


func test_contact_shakes_the_span_only_then_settles() -> void:
	var still: PackedVector2Array = s.path(3)
	_place(13, 0.0, 1)
	var hit: PackedVector2Array = s.path(3)
	assert_eq(hit[0], still[0])
	assert_eq(hit[-1], still[-1])
	assert_gt(hit[4].distance_to(hit[0].lerp(hit[-1], 0.25)), 0.01)
	s.strap.reduced = true
	assert_eq(s.path(3), still)
	_place(21, 0.0, 1)
	assert_eq(s.path(3), still)


func test_spectral_view_selects_four_lines_and_legacy_keeps_its_own_attack() -> void:
	LaunchArgs.parse(["--dent-tether=strings"])
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	for look: String in ["spectral", "legacy"]:
		GhostLook.override_for_test(look)
		var view: DentView = DentView.new()
		view.stage = stage
		view.dent = stage.pilot.dent
		add_child_autofree(view)
		assert_eq(view._legacy != null, look == "legacy")
		if look == "spectral":
			assert_not_null(view._tether.strings)
		else:
			assert_null(view._tether)
	GhostLook.reset_for_test()
	LaunchArgs.parse()


func test_live_painter_lays_glow_ink_core_and_eyelets_on_the_four_paths() -> void:
	var recorder: InkRecorder = InkRecorder.new()
	var amber: Color = s.strap.fill_at(1.0)
	s.paint(recorder, amber)
	assert_eq(recorder.strokes.size(), 12)
	assert_eq(recorder.rings.size(), 8)
	for i: int in 4:
		assert_eq(recorder.strokes[3 * i], s.path(i))
		assert_eq(recorder.widths.slice(3 * i, 3 * i + 3), [4.0, 1.5, 1.0])
		assert_eq(
			recorder.colors.slice(3 * i, 3 * i + 3), [Color(amber, 0.16), DentRoof.INK, amber]
		)
		assert_eq(recorder.rings[2 * i], s.corner(i))
		assert_eq(recorder.rings[2 * i + 1], s.corner(i))


func test_released_strings_follow_both_hands_and_remember_the_roof() -> void:
	s.strap.advance(null, 11, 0.0, -1)
	var travel: Vector2 = Vector2(12, 15)
	s.strap.place(RIGHT + travel, PPM, false, vm)
	s.place(LEFT + travel, 1.0, 0, vm)
	for i: int in 4:
		assert_eq(s.path(i)[0], (LEFT if i < 2 else RIGHT) + travel)
	assert_eq(s.turn, 0.0)
	assert_eq(s.strap.ground_m, car.pos)

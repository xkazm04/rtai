extends GutTest


class Recorder:
	extends DentStrapCanvas
	var ops: Array[String] = []
	var paths: Array[PackedVector2Array] = []
	var widths: Array[float] = []
	var stroke_colors: Array[Color] = []
	var line_starts: Array[Vector2] = []
	var line_ends: Array[Vector2] = []
	var plates: Array[Rect2] = []
	var plate_colors: Array[Color] = []
	var origins: Array[Vector2] = []
	var yaws: Array[float] = []

	func _init() -> void:
		super(null)

	func stroke(path: PackedVector2Array, col: Color, width: float) -> void:
		ops.push_back("stroke")
		paths.append(path)
		widths.append(width)
		stroke_colors.append(col)

	func line(a: Vector2, b: Vector2, _color: Color, _width: float) -> void:
		ops.push_back("line")
		line_starts.append(a)
		line_ends.append(b)

	func circle(_c: Vector2, _radius: float, _color: Color) -> void:
		ops.push_back("disc")

	func polygon(_points: PackedVector2Array, _color: Color) -> void:
		ops.push_back("quarter")

	func rect(bounds: Rect2, col: Color) -> void:
		ops.push_back("plate")
		plates.append(bounds)
		plate_colors.append(col)

	func pose(origin: Vector2, yaw: float) -> void:
		ops.push_back("pose")
		origins.append(origin)
		yaws.append(yaw)


func _held() -> DentStrap:
	var s: DentStrap = DentStrap.new(Color.DARK_TURQUOISE, 1.4)
	var car: VehicleBody = VehicleBody.new(1, null, Vector2.RIGHT * 4, Vector2.DOWN)
	s.advance(car, 1, 10.0, -1)
	s.advance(car, 2, 10.0, -1)
	s.place(Vector2.ZERO, 32.0, true, ViewMode.shared())
	s.roof_px = Vector2.RIGHT * 128.0
	return s


func test_belt_strokes_and_steel_buckle_overlay_the_quartered_roof() -> void:
	var s: DentStrap = _held()
	var rec: Recorder = Recorder.new()
	s.paint(rec, Color.DARK_TURQUOISE, DentStrap.AQUA)
	assert_eq(
		rec.ops.slice(0, 8),
		["disc", "disc", "disc", "quarter", "quarter", "stroke", "stroke", "stroke"]
	)
	assert_eq(rec.ops.slice(-6), ["pose", "plate", "plate", "plate", "line", "pose"])
	assert_eq(rec.stroke_colors, [DentRoof.INK, Color.DARK_TURQUOISE, DentStrap.AQUA])
	assert_almost_eq(rec.widths[0], 15.36, 0.001)
	assert_almost_eq(rec.widths[1], 11.36, 0.001)
	assert_almost_eq(rec.widths[2], 2.08, 0.001)
	for path: PackedVector2Array in rec.paths:
		assert_eq(path[0], Vector2.ZERO)
		assert_eq(path[-1], Vector2.RIGHT * 128.0)
		assert_eq(path[8], Vector2.RIGHT * 64.0)
	assert_eq(rec.origins, [s.roof_px, Vector2.ZERO])
	assert_almost_eq(rec.yaws[0], PI / 2.0, 0.00001)
	assert_eq(rec.yaws[1], 0.0)
	assert_eq(rec.plate_colors, [DentRoof.INK, DentRoof.STEEL, DentRoof.SLOT])
	assert_almost_eq(rec.plates[1].size, Vector2.ONE * 18.56, Vector2.ONE * 0.001)


func test_weave_steps_towards_the_roof_and_stays_within_the_belt() -> void:
	var s: DentStrap = _held()
	var rec: Recorder = Recorder.new()
	s.paint(rec, Color.DARK_TURQUOISE, DentStrap.AQUA)
	assert_almost_eq(rec.line_starts[0].x, 0.0, 0.001)
	assert_almost_eq(rec.line_starts[1].x, 10.56, 0.001)
	s.reduced = false
	# Isolate the travelling weave from the lateral tremble.
	var table: DataTable = DataTable.open(DentLook.PATH, DentLook.SCHEMA)
	var row: Dictionary = table.array(table.raw, "rows")[0]
	s.look = DentLook.new(table, row)
	s.look.strap_tremble_m = 0.0
	rec = Recorder.new()
	s.paint(rec, Color.DARK_TURQUOISE, DentStrap.AQUA)
	assert_almost_eq(rec.line_starts[0], Vector2(1.60, 5.68), Vector2.ONE * 0.002)
	assert_almost_eq(rec.line_ends[0], Vector2(4.44, -5.68), Vector2.ONE * 0.002)
	assert_almost_eq(rec.line_starts[1].x, 12.16, 0.002)
	assert_eq(rec.line_starts.size(), 13)


func test_loose_fibres_and_steel_plate_fade_from_the_car_end() -> void:
	var s: DentStrap = _held()
	s.advance(null, 3, 0.0, -1)
	s.advance(null, 27, 0.0, -1)
	var rec: Recorder = Recorder.new()
	s.paint(rec, Color.DARK_TURQUOISE, DentStrap.AQUA)
	var end: float = 2.0 / 3.0
	var tip: Vector2 = s.point(end)
	assert_almost_eq(rec.paths[1][-1], tip, Vector2.ONE * 0.001)
	assert_almost_eq(rec.line_starts[-3], tip, Vector2.ONE * 0.001)
	assert_almost_eq(rec.line_starts[-4].distance_to(tip), s.width_px() * 0.23, 0.001)
	assert_almost_eq(rec.line_ends[-3].distance_to(tip), s.width_px() * 1.1, 0.001)
	assert_almost_eq(rec.plate_colors[1].a, end, 0.001)

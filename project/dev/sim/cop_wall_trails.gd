extends SceneTree
## n18 police item 1 evidence (dev tool, dev/ is not exported): the reference sim's real cop code
## (CitySimRef) on the hand-made wall map of test_city_cop_sight (a 3 m building wall at x
## 300..302 with an 8 m gap at y 320..327, all else sidewalk). Each start runs alone (its own
## sim) toward the goal east of the wall; draws every cop's trail at 16 px/m, writes <out>.png and
## <out>.json (per cop: start, ticks to cross the wall, -1 = never, and the last position).
## Same script on any tree with CitySimRef, so a before/after pair is this file in two worktrees.
## Usage: godot --headless --path project -s res://dev/sim/cop_wall_trails.gd -- --out=<abs path
## without extension> [--ticks=1500]

const KNOWN_FLAGS: Array[String] = ["--out", "--ticks"]
const ORIGIN: Vector2 = Vector2(280.0, 278.0)  # metres, top-left of the picture
const SIZE_M: Vector2 = Vector2(36.0, 56.0)
const PPM: int = 16
const WALL_X: int = 300
const GAP_Y0: int = 320
const GAP_Y1: int = 328
const GOAL: Vector2 = Vector2(305.5, 290.5)
const CAM: Vector2 = Vector2(305.0, 300.0)
## 9 m and 6 m (inside the stand-off) behind the wall, as the unit test; then 8 m north-west and
## 11 m south-west, where the old straight steer also met the wall.
const STARTS: Array[Vector2] = [
	Vector2(296.5, 290.5), Vector2(297.5, 290.5), Vector2(294.5, 284.5), Vector2(296.5, 300.5)
]
const TRAIL_RGB: Array[Color] = [
	Color(0.35, 0.6, 1.0), Color(0.2, 0.9, 1.0), Color(0.6, 0.5, 1.0), Color(0.85, 0.9, 1.0)
]
const VERMILION: Color = Color(0.89, 0.26, 0.2)


func _initialize() -> void:
	var opts: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var k: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(k):
			printerr("cop_wall_trails: unknown argument %s" % arg)
			quit(2)
			return
		opts[k] = arg.substr(k.length() + 1)
	if not opts.has("--out"):
		printerr("cop_wall_trails: --out=<path without extension> is required")
		quit(2)
		return
	var ticks: int = str(opts.get("--ticks", "1500")).to_int()
	var img: Image = _draw_map()
	var rows: Array = []
	for i: int in STARTS.size():
		rows.append(_run(STARTS[i], ticks, img, TRAIL_RGB[i]))
	_dot(img, GOAL, 5, VERMILION)
	var out: String = opts["--out"]
	var ok: bool = img.save_png(out + ".png") == OK
	var f: FileAccess = FileAccess.open(out + ".json", FileAccess.WRITE)
	ok = ok and f != null and f.store_string(JSON.stringify({"ticks": ticks, "cops": rows}, " "))
	printerr("cop_wall_trails: %s" % JSON.stringify(rows))
	quit(0 if ok else 1)


func _run(start: Vector2, ticks: int, img: Image, rgb: Color) -> Dictionary:
	var sim: CitySimRef = CitySimRef.new()
	sim.init(7)
	_paint(sim)
	var slot: int = sim.spawn(
		PackedFloat64Array([SimConst.K_COP, start.x, start.y, 0.0, 1.0, 7, 0, 3.4, 0.0, 0])
	)
	var crossed: int = -1
	var p: Vector2 = start
	for t: int in ticks:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
		p = _pos(sim, slot)
		if crossed < 0 and p.x > WALL_X + 3.0:
			crossed = t + 1
		_dot(img, p, 1, rgb)
	_dot(img, start, 3, rgb)
	return {"start": [start.x, start.y], "crossed_tick": crossed, "last": [p.x, p.y]}


func _paint(sim: CitySimRef) -> void:
	var n: int = SimConst.CHUNK_CELLS
	var tiles: PackedByteArray = CityChunk.zeros(CityChunk.TILES)
	tiles.fill(SimConst.T_PLAZA)
	var cells: PackedByteArray = CityChunk.zeros(CityChunk.CELLS)
	cells.fill(SimConst.C_WALK)
	for ly: int in n:
		if _gap(2 * n + ly):
			continue
		for x: int in range(WALL_X, WALL_X + 3):
			cells[ly * n + (x - 2 * n)] = SimConst.C_BUILD
	sim.stamp_chunk(2, 2, tiles, cells)


func _draw_map() -> Image:
	var w: int = int(SIZE_M.x) * PPM
	var h: int = int(SIZE_M.y) * PPM
	var img: Image = Image.create(w, h, false, Image.FORMAT_RGB8)
	img.fill(Color(0.6, 0.6, 0.58))
	for my: int in int(SIZE_M.y):
		var y: int = int(ORIGIN.y) + my
		if _gap(y):
			continue
		var x0: int = (WALL_X - int(ORIGIN.x)) * PPM
		img.fill_rect(Rect2i(x0, my * PPM, 3 * PPM, PPM), Color(0.16, 0.15, 0.14))
	return img


func _dot(img: Image, at: Vector2, r: int, rgb: Color) -> void:
	var c: Vector2i = Vector2i(((at - ORIGIN) * PPM).round())
	img.fill_rect(Rect2i(c - Vector2i(r, r), Vector2i(2 * r + 1, 2 * r + 1)), rgb)


static func _gap(y: int) -> bool:
	return y >= GAP_Y0 and y < GAP_Y1


static func _pos(sim: CitySimRef, slot: int) -> Vector2:
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size(), SimConst.SNAP_STRIDE):
		if int(snap[r]) == slot:
			return Vector2(snap[r + 4], snap[r + 5])
	return Vector2(-1, -1)

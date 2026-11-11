extends SceneTree
## t-4 evidence (dev tool, dev/ is not exported): drives the reference sim's real car code
## (CitySimCars + CitySimCarRoute) on a small hand-made map that the generated city never makes:
## a road that ends at a plaza (east), at a kerb (north) and at the unloaded edge (west, south).
## Draws every car's trail over the tiles at 4 px/m, marks each U-turn, writes <out>.png and a
## JSON summary (<out>.json: U-turns per car with where). Same script runs on any tree that has
## the CitySimCars API, so a before/after pair is this file run in two worktrees.
## Usage: godot --headless --path project -s res://dev/sim/car_route_trails.gd -- --out=<abs path
## without extension> [--seconds=60]

const KNOWN_FLAGS: Array[String] = ["--out", "--seconds"]
const ORIGIN: Vector2i = Vector2i(96, 96)  # first tile drawn
const SIZE: Vector2i = Vector2i(40, 28)  # tiles drawn
const PX_PER_TILE: int = 32  # 4 px/m
const ROAD_ROW: int = 110
const ROAD_COL: int = 112
const TILE_RGB: Dictionary = {
	0: Color(0.02, 0.02, 0.02),
	1: Color(0.25, 0.25, 0.27),
	2: Color(0.25, 0.25, 0.27),
	3: Color(0.36, 0.36, 0.38),
	4: Color(0.62, 0.62, 0.6),
	5: Color(0.62, 0.62, 0.6),
	6: Color(0.33, 0.29, 0.25),
	7: Color(0.72, 0.64, 0.46),
}
const CAR_RGB: Array[Color] = [
	Color(1.0, 0.85, 0.1), Color(0.95, 0.95, 0.95), Color(0.75, 0.4, 1.0)
]

var _s: CitySimState
var _cars: CitySimCars


func _initialize() -> void:
	var opts: Dictionary = _args()
	if not opts.has("--out"):
		printerr("car_route_trails: --out=<path without extension> is required")
		quit(2)
		return
	_s = CitySimState.new()
	_s.init(7)
	_build_map()
	_cars = CitySimCars.new(_s, CitySimHash.new(_s), CitySimFlow.new(_s))
	var spawned: Array[int] = [
		_spawn(Vector2(100 * 8 + 4, ROAD_ROW * 8 + 4), 0),
		_spawn(Vector2(ROAD_COL * 8 + 4, 117 * 8 + 4), 3),
		_spawn(Vector2(122 * 8 + 4, ROAD_ROW * 8 + 4), 2),
	]
	var img: Image = _draw_tiles()
	var summary: Array = _run(spawned, str(opts.get("--seconds", "60")).to_int() * 60, img)
	var out: String = str(opts["--out"])
	var err: Error = img.save_png(out + ".png")
	var f: FileAccess = FileAccess.open(out + ".json", FileAccess.WRITE)
	var stored: bool = f.store_string(
		JSON.stringify({"cars": summary, "hw": SimConst.HW}, "  ", false)
	)
	f.close()
	printerr("car_route_trails: wrote %s.png and .json (png %d, json %s)" % [out, err, stored])
	quit(0 if err == OK and stored else 1)


func _args() -> Dictionary:
	var opts: Dictionary = {}
	for a: String in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.split("=", true, 1)
		if not KNOWN_FLAGS.has(kv[0]):
			printerr("car_route_trails: unknown arg %s" % a)
			quit(2)
		opts[kv[0]] = kv[1] if kv.size() > 1 else ""
	return opts


func _put_tile(tx: int, ty: int, t: int) -> void:
	_s.tiles[ty * SimConst.TW + tx] = t


func _build_map() -> void:
	for ty: int in range(ORIGIN.y + 2, ORIGIN.y + SIZE.y - 2):
		for tx: int in range(ORIGIN.x + 2, ORIGIN.x + SIZE.x - 2):
			_put_tile(tx, ty, SimConst.T_BLOCK)
	for tx: int in range(98, 126):
		_put_tile(tx, ROAD_ROW, SimConst.T_ROAD_H)
	for ty: int in range(100, 120):
		_put_tile(ROAD_COL, ty, SimConst.T_ROAD_V)
	_put_tile(ROAD_COL, ROAD_ROW, SimConst.T_INTER)
	for ty: int in range(ROAD_ROW - 2, ROAD_ROW + 3):
		for tx: int in range(126, 131):
			_put_tile(tx, ty, SimConst.T_PLAZA)
	for tx: int in range(ROAD_COL - 1, ROAD_COL + 2):
		_put_tile(tx, 99, SimConst.T_CURB)
	_put_tile(97, ROAD_ROW, SimConst.T_VOID)
	_put_tile(ROAD_COL, 120, SimConst.T_VOID)


func _spawn(at: Vector2, direction: int) -> int:
	var spec: PackedFloat64Array = PackedFloat64Array()
	var grown: int = spec.resize(SimConst.SP_LEN)
	spec[SimConst.SP_KIND] = SimConst.K_CAR
	spec[SimConst.SP_X] = at.x
	spec[SimConst.SP_Y] = at.y
	spec[SimConst.SP_DX] = CitySimState.DX[direction]
	spec[SimConst.SP_DY] = CitySimState.DY[direction]
	spec[SimConst.SP_VMAX] = 10.0
	var centre: float = at.y if direction == 0 or direction == 2 else at.x
	spec[SimConst.SP_LANE] = centre + CitySimState.LANE_OFF[direction]
	spec[SimConst.SP_DIR] = direction
	assert(grown == OK)
	return _s.spawn(spec)


func _draw_tiles() -> Image:
	var img: Image = Image.create(
		SIZE.x * PX_PER_TILE, SIZE.y * PX_PER_TILE, false, Image.FORMAT_RGB8
	)
	for ty: int in SIZE.y:
		for tx: int in SIZE.x:
			var t: int = _s.tiles[(ORIGIN.y + ty) * SimConst.TW + ORIGIN.x + tx]
			var r: Rect2i = Rect2i(
				tx * PX_PER_TILE, ty * PX_PER_TILE, PX_PER_TILE - 1, PX_PER_TILE - 1
			)
			var c: Color = TILE_RGB.get(t, Color.BLACK)
			img.fill_rect(r, c)
	return img


## Steps every car `ticks` times at SimClock.TICK_DT, dotting its trail every 3 ticks and boxing
## each U-turn (a direction change by 2). Returns one summary row per car.
func _run(spawned: Array[int], ticks: int, img: Image) -> Array:
	var rows: Array = []
	for i: int in spawned:
		rows.append({"car": i, "start_dir": _s.dir[i], "uturns": [], "alive_at_end": true})
	for t: int in ticks:
		for n: int in spawned.size():
			var i: int = spawned[n]
			if _s.alive[i] == 0:
				rows[n]["alive_at_end"] = false
				continue
			var before: int = _s.dir[i]
			_cars.car(i, SimClock.TICK_DT, 0.0, 0.0)
			var p: Vector2 = _pixel(i)
			if absi(_s.dir[i] - before) == 2:
				var turns: Array = rows[n]["uturns"]
				turns.append(_uturn(i, t))
				img.fill_rect(Rect2i(int(p.x) - 6, int(p.y) - 6, 13, 13), CAR_RGB[n])
			elif t % 3 == 0:
				img.fill_rect(Rect2i(int(p.x) - 1, int(p.y) - 1, 3, 3), CAR_RGB[n])
	return rows


## Where car i just U-turned, and the tile 18 m ahead of it in its old direction (why it turned).
func _uturn(i: int, t: int) -> Dictionary:
	var back: int = _s.dir[i]
	var ahead: int = _s.tile_at(
		_s.px[i] - CitySimState.DX[back] * 18.0, _s.py[i] - CitySimState.DY[back] * 18.0
	)
	return {
		"tick": t,
		"x_m": snappedf(_s.px[i], 0.1),
		"y_m": snappedf(_s.py[i], 0.1),
		"tile_ahead": ahead
	}


func _pixel(i: int) -> Vector2:
	var k: float = PX_PER_TILE / 8.0
	return Vector2((_s.px[i] - ORIGIN.x * 8.0) * k, (_s.py[i] - ORIGIN.y * 8.0) * k)

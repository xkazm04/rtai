class_name CityHeadlights
extends RefCounted
## Car lights from the sim (lights.json `car_lights`, core/render/README.md): on a grade listed in
## `grades` (night), the `max_cars` cars nearest the focus within `radius_m` carry a `headlight`
## cone per `lamps_m` offset (car frame, metres, nose along +x) and police cars a `siren` at
## `siren_m`. Fed the snapshot CityFxFeed already reads (once per sim tick); held lights are moved
## onto the picked cars, the rest released. Off-grade (day) it holds nothing and costs one check.

const TABLE: String = "res://data/tables/lights.json"
## Ticks a refused add (the light budget was full) waits before the slots try again.
const BACKOFF_TICKS: int = 30

var lights: LightLayer
var grades: PackedStringArray = PackedStringArray()
var max_cars: int = 0
var radius_m: float = 0.0
var lamps: PackedVector2Array = PackedVector2Array()
var siren: Vector2 = Vector2.ZERO
## Lights held now (headlights + sirens); the cost probe reads it.
var held: int = 0
var last_us: int = 0
## Light handles per car slot: lamps.size() headlights, then the siren (-1 = none held).
var _h: PackedInt32Array = PackedInt32Array()
var _tick: int = 0
var _retry_at: int = -1


func _init(layer: LightLayer, text: String = "") -> void:
	lights = layer
	var parser: JSON = JSON.new()
	var src: String = text if text != "" else FileAccess.get_file_as_string(TABLE)
	if parser.parse(src) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	var row: Dictionary = d.get("car_lights", {})
	var g: Array = row.get("grades", [])
	grades = PackedStringArray(g)
	var cap: float = row.get("max_cars", 0)
	max_cars = int(cap)
	radius_m = row.get("radius_m", 0.0)
	var lamp_rows: Array = row.get("lamps_m", [])
	for p: Array in lamp_rows:
		@warning_ignore("return_value_discarded")
		lamps.push_back(_vec(p))
	var s: Array = row.get("siren_m", [0.0, 0.0])
	siren = _vec(s)
	@warning_ignore("return_value_discarded")
	_h.resize(max_cars * (lamps.size() + 1))
	_h.fill(-1)


static func _vec(p: Array) -> Vector2:
	var x: float = p[0]
	var y: float = p[1]
	return Vector2(x, y)


## Re-places the car lights from `snap` (CitySimBackend.snapshot()) around `focus_m` at `tick`.
func observe(snap: PackedFloat64Array, focus_m: Vector2, tick: int) -> void:
	var on: bool = grades.has(String(lights.grade))
	if not on and held == 0:
		return  # day with every light already released: one check
	var t0: int = Time.get_ticks_usec()
	var cars: Array[Vector2i] = []
	if on:
		cars = _nearest(snap, focus_m)
	held = 0
	_tick = tick
	for c: int in max_cars:
		var r: int = cars[c].y if c < cars.size() else -1
		_place(c, snap, r)
	last_us = Time.get_ticks_usec() - t0


## (squared distance in cm, record offset) of the nearest cars, at most max_cars.
func _nearest(snap: PackedFloat64Array, focus_m: Vector2) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var r2: float = radius_m * radius_m
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		var kind: int = int(snap[r + 1])
		if kind != SimConst.K_CAR and kind != SimConst.K_PCAR:
			continue
		var d2: float = Vector2(snap[r + 4], snap[r + 5]).distance_squared_to(focus_m)
		if d2 <= r2:
			out.append(Vector2i(int(d2 * 100.0), r))
	out.sort()
	return out.slice(0, max_cars)


## Car slot `c` onto the snapshot record at `r` (-1 = release the slot's lights).
func _place(c: int, snap: PackedFloat64Array, r: int) -> void:
	var police: bool = r >= 0 and int(snap[r + 1]) == SimConst.K_PCAR
	var xf: Transform2D = Transform2D()
	if r >= 0:
		var ang: float = atan2(snap[r + 7], snap[r + 6])
		xf = Transform2D(ang, Vector2(snap[r + 4], snap[r + 5]))
	var k0: int = c * (lamps.size() + 1)
	for j: int in lamps.size():
		_hold(k0 + j, &"headlight", r >= 0, xf, lamps[j])
	_hold(k0 + lamps.size(), &"siren", police, xf, siren)


## Holds (adds or moves) light `k` of `kind` at `at_m` in the car frame `xf`, or releases it.
func _hold(k: int, kind: StringName, on: bool, xf: Transform2D, at_m: Vector2) -> void:
	if not on:
		if _h[k] >= 0:
			lights.remove(_h[k])
			_h[k] = -1
		return
	var pos_px: Vector2 = (xf * at_m) * SimConst.PX_PER_M
	if _h[k] < 0:
		if _tick < _retry_at:
			return  # the budget refused an add lately: no retry every tick
		_h[k] = lights.add(kind, pos_px, xf.get_rotation(), _tick)
		if _h[k] < 0:
			_retry_at = _tick + BACKOFF_TICKS
	else:
		lights.move(_h[k], pos_px, xf.get_rotation())
	held += 1 if _h[k] >= 0 else 0

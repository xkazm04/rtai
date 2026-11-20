class_name GhostTailWisps
extends Node2D
## Detached filaments keep their birth points as the body turns or stops.

const LIFE: int = 46
var _born: PackedInt32Array = []
var _origin: PackedVector2Array = []
var _wind: PackedVector2Array = []
var _clock: int = 0


func _init(count: int) -> void:
	@warning_ignore("return_value_discarded")
	_born.resize(count)
	@warning_ignore("return_value_discarded")
	_origin.resize(count)
	@warning_ignore("return_value_discarded")
	_wind.resize(count)
	clear()


func clear() -> void:
	_born.fill(-LIFE)
	_clock = 0
	queue_redraw()


func step(tick: int, edge: Vector2, drift: Vector2) -> void:
	_clock = tick
	if not _born.is_empty():
		var interval: int = ceili(float(LIFE) / _born.size())
		if tick % interval == 0:
			var slot: int = floori(float(tick) / interval) % _born.size()
			_born[slot] = tick
			_origin[slot] = edge
			_wind[slot] = drift
	queue_redraw()


func _draw() -> void:
	for i: int in _born.size():
		var age: float = float(_clock - _born[i]) / LIFE
		if age < 0.0 or age >= 1.0:
			continue
		var alpha: float = sin(PI * age)
		var wind: Vector2 = _wind[i]
		var side: Vector2 = wind.normalized().orthogonal()
		var centre: Vector2 = _origin[i] + wind * age + ViewMode.shared().lift_px(age * 0.65)
		centre += side * (sin(age * 5.0 + i) - sin(float(i))) * SimConst.PX_PER_M * 0.12
		var pts: PackedVector2Array = []
		for j: int in 7:
			var k: float = float(j) / 6.0
			var curl: float = sin(k * TAU + age * 5.0 + i) * alpha * 0.07
			@warning_ignore("return_value_discarded")
			pts.append(centre + wind * (k - 0.5) * 0.25 + side * curl * SimConst.PX_PER_M)
		draw_polyline(pts, Color(0.10, 0.65, 0.58, alpha * 0.32), 2.8, true)
		draw_polyline(pts, Color(0.60, 1.0, 0.88, alpha * 0.55), 1.0, true)

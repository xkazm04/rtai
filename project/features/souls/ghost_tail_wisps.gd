class_name GhostTailWisps
extends Node2D
## Short-lived puffs shed from the moving tip. Travel is bounded even during a blink.

const LIFE: int = 21
var _born: PackedInt32Array = []
var _origin: PackedVector2Array = []
var _wind: PackedVector2Array = []
var _clock: int = 0
var _tip: Vector2
var _reach: float


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


func follow_tip(tip: Vector2, reach_px: float) -> void:
	_tip = tip
	_reach = reach_px


func step(tick: int, edge: Vector2, drift: Vector2) -> void:
	_clock = tick
	if not _born.is_empty():
		var interval: int = ceili(float(LIFE) / _born.size())
		if tick % interval == 0:
			var slot: int = floori(float(tick) / interval) % _born.size()
			_born[slot] = tick
			_origin[slot] = edge - _tip
			_wind[slot] = drift
	queue_redraw()


func _draw() -> void:
	for i: int in _born.size():
		var age: float = float(_clock - _born[i]) / LIFE
		if age < 0.0 or age >= 1.0:
			continue
		var alpha: float = sin(PI * age)
		var wind: Vector2 = _wind[i]
		var drift: Vector2 = wind * (age * LIFE * SimClock.TICK_DT)
		var rise: Vector2 = ViewMode.shared().lift_px(age * 0.20)
		var centre: Vector2 = _tip + (_origin[i] + drift + rise).limit_length(_reach)
		var radius: float = (0.065 + 0.022 * (i % 3) + age * 0.07) * SimConst.PX_PER_M
		for coat: int in range(5, 0, -1):
			var k: float = coat / 5.0
			draw_circle(centre, radius * k, Color(0.38, 0.92, 0.82, alpha * 0.11), true, -1, true)

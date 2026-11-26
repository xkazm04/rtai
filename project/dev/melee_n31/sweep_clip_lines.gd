class_name SweepClipLines
extends Node2D
## n31 melee 02p4 dev overlay: the sector this tick's hit tests (cream 4 px outline, dark
## under-stroke, 0.25 fill; it fades 10 ticks) and each struck dummy flashing, in metres.
const INK: Color = Color(0.957, 0.925, 0.847)
## A dark under-stroke so the cream line reads on the pale pavement too.
const UNDER: Color = Color(0.08, 0.09, 0.11, 0.85)
const FADE_TICKS: int = 10
const FILL_ALPHA: float = 0.25
const FLASH_TICKS: int = 8
const STEPS: int = 24

## This tick's tested sector: centre (m), facing angle + the arc's from/to (rad), radius (m).
var _now: Dictionary = {}
var _last: Dictionary = {}
var _since_last: int = 1000
## Struck dummies: centre (m), radius (m), ticks since struck.
var _flash_at: PackedVector2Array = PackedVector2Array()
var _flash_r: PackedFloat32Array = PackedFloat32Array()
var _flash_age: PackedInt32Array = PackedInt32Array()


## One tick: `sector` is empty when the hit tested nothing this tick.
func show_tick(sector: Dictionary) -> void:
	_now = sector
	if not sector.is_empty():
		_last = sector
		_since_last = 0
	else:
		_since_last += 1
	for i: int in range(_flash_age.size() - 1, -1, -1):
		_flash_age[i] += 1
		if _flash_age[i] >= FLASH_TICKS:
			_flash_at.remove_at(i)
			_flash_r.remove_at(i)
			_flash_age.remove_at(i)
	queue_redraw()


func flash(at_m: Vector2, radius_m: float) -> void:
	@warning_ignore("return_value_discarded")
	_flash_at.append(at_m)
	@warning_ignore("return_value_discarded")
	_flash_r.append(radius_m)
	@warning_ignore("return_value_discarded")
	_flash_age.append(-1)


func _draw() -> void:
	if not _now.is_empty():
		_sector(_now, Color(INK, FILL_ALPHA), UNDER, INK)
	elif _since_last < FADE_TICKS:
		var k: float = 1.0 - float(_since_last) / FADE_TICKS
		_sector(_last, Color(INK, FILL_ALPHA * k), Color(UNDER, UNDER.a * k), Color(INK, k))
	for i: int in _flash_age.size():
		var fade: float = 1.0 - float(_flash_age[i]) / FLASH_TICKS
		var px: Vector2 = _flash_at[i] * SimConst.PX_PER_M
		var r: float = _flash_r[i] * SimConst.PX_PER_M
		draw_arc(px, r, 0.0, TAU, 32, Color(UNDER, fade), 5.0)
		draw_arc(px, r, 0.0, TAU, 32, Color(INK, fade), 3.0)


func _sector(s: Dictionary, fill: Color, under: Color, ink: Color) -> void:
	var at: Vector2 = s["at"]
	var aim: float = s["aim"]
	var arc: Vector2 = s["arc"]
	var r: float = s["reach"]
	var pts: PackedVector2Array = PackedVector2Array([at * SimConst.PX_PER_M])
	for i: int in STEPS + 1:
		var ang: float = aim + lerpf(arc.x, arc.y, float(i) / STEPS)
		@warning_ignore("return_value_discarded")
		pts.append((at + Vector2.from_angle(ang) * r) * SimConst.PX_PER_M)
	@warning_ignore("return_value_discarded")
	pts.append(at * SimConst.PX_PER_M)
	draw_colored_polygon(pts.slice(0, pts.size() - 1), fill)
	draw_polyline(pts, under, 6.0, true)
	draw_polyline(pts, ink, 4.0, true)

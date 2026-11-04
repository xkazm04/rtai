class_name MeleeSmearView
extends Node2D
## combat-notes: the smear of a melee cut on Rivet's held weapon (live game, RivetHeldView feeds
## it each frame): a fan between the blade's last angles about the grip, from the hilt to the
## tip, pale with an ink edge on the leading side, so a 3-tick cut reads as one arc at 32-48
## px/m. While the cut runs (MeleeSwing.cutting) it keeps the last KEEP angles; after it, the
## whole fan lingers LINGER frames while it fades, then one old angle drops per frame (a 2-tick
## cut read as a flicker at 48 px/m real time when it wiped at once). Render only, no RNG.

const KEEP: int = 4
## Frames the finished cut's fan stays whole (fading) before it wipes; 0 = the iteration-3 wipe.
const LINGER: int = 4
const STEPS: int = 5
const HILT_U: float = 0.3
const EDGE_PX: float = 2.0
## The ink band's alpha (at the newest step) and the pale core's radial span.
const INK_A: float = 0.35
const CORE_IN: float = 0.45
const CORE_OUT: float = 0.92
const STEEL: Color = Color(0.93, 0.91, 0.86, 0.55)
const HOT: Color = Color(1.0, 0.96, 0.78, 0.7)
const SPARK: Color = Color(0.9, 0.93, 1.0, 0.6)

var tint: Color = STEEL
var _grip: Vector2 = Vector2.ZERO
var _len: float = 0.0
var _angles: PackedFloat32Array = PackedFloat32Array()
var _after: int = 0


## This frame's blade: `grip` (global), `rot` (global, +x along the blade), `len_px` long;
## `on` while the cut runs.
func feed(grip: Vector2, rot: float, len_px: float, on: bool) -> void:
	_grip = to_local(grip)
	_len = len_px
	if on:
		_after = 0
		@warning_ignore("return_value_discarded")
		_angles.append(rot - global_rotation)
		while _angles.size() > KEEP:
			_angles.remove_at(0)
	elif not _angles.is_empty():
		_after += 1
		if _after > LINGER:
			_angles.remove_at(0)
	queue_redraw()


## Angles in the fan now (0 = nothing drawn).
func steps() -> int:
	return _angles.size()


## The fan's alpha share: 1 while cutting, fading through the linger and the wipe.
func fade() -> float:
	return clampf(1.0 - float(_after) / float(LINGER + KEEP + 1), 0.0, 1.0)


## The weapon's smear colour by melee id (the plasma blade hot cream, the baton's spark).
static func tint_of(weapon: StringName) -> Color:
	if weapon == &"plasma_sword":
		return HOT
	if weapon == &"electro_baton":
		return SPARK
	return STEEL


func clear() -> void:
	_angles.clear()
	_after = 0
	queue_redraw()


func _draw() -> void:
	var n: int = _angles.size()
	for i: int in range(1, n):
		var a0: float = _angles[i - 1]
		var a1: float = _angles[i]
		var age: float = float(n - i) / float(KEEP)
		var col: Color = Color(tint, tint.a * (1.0 - 0.5 * age) * fade())
		# an ink band under a pale core: the ink reads on the cream pavement, the core on the dark
		# arena floor (a pale smear alone vanished on the city's light ground)
		draw_colored_polygon(_band(a0, a1, HILT_U, 1.0), Color(Ink.INK, INK_A * col.a / tint.a))
		var core: PackedVector2Array = _band(a0, a1, CORE_IN, CORE_OUT)
		draw_colored_polygon(core, col)
		draw_polyline(core.slice(0, STEPS + 1), Color(Ink.INK, col.a), EDGE_PX, true)  # the rim


## The sector band between angles a0 and a1 from radius u0 to u1 (shares of the blade's length).
func _band(a0: float, a1: float, u0: float, u1: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	for s: int in STEPS + 1:
		@warning_ignore("return_value_discarded")
		pts.append(_grip + Vector2.from_angle(lerpf(a0, a1, float(s) / STEPS)) * _len * u1)
	for s: int in range(STEPS, -1, -1):
		@warning_ignore("return_value_discarded")
		pts.append(_grip + Vector2.from_angle(lerpf(a0, a1, float(s) / STEPS)) * _len * u0)
	return pts

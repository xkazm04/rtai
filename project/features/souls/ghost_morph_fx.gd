class_name GhostMorphFx
extends Node2D
## The transformation's effects, drawn over the body from GhostForms' progress (k 0..1, stage):
## a teal burst ring that blows out from the body, teal seams that crack open across the figure
## (stage 0) and close on the new form (stage 1), steam puffs that roll out at the swap, and
## sparks thrown along fixed spokes (deterministic: no RNG, the angles come from the spoke index).
## The form-to-form switch is the same burst, short and without the steam (the teal flash).
## beat() is the camera punch (zoom 1 + BEAT_ZOOM at the swap, easing out); reduced motion turns the
## punch and the spark travel off and keeps a static ring (the read stays, the motion goes).
## Units: world px at PX_PER_M around this node's origin (the body's centre).

const PX_PER_M: float = 32.0
const TEAL: Color = Color(0.18, 0.77, 0.71)
const TEAL_HI: Color = Color(0.72, 1.0, 0.95)
const STEAM: Color = Color(0.93, 0.9, 0.84)
const SPARK: Color = Color(1.0, 0.86, 0.45)
const INK: Color = Color(0.106, 0.082, 0.09)
const SPOKES: int = 14
const SEAMS: int = 7
const BEAT_ZOOM: float = 0.06

var reduced_motion: bool = false
## The ring's reach in metres (the form's footprint grows it: Tonnage blows out wider).
var reach_m: float = 2.0
var _k: float = 1.0
var _stage: int = 0
var _on: bool = false
var _flash: bool = false


## Feeds one frame of the running transformation; on = false hides everything.
func show_progress(on: bool, k: float, stage: int, flash: bool) -> void:
	_on = on
	_k = k
	_stage = stage
	_flash = flash
	queue_redraw()


## The camera zoom factor for this frame (1.0 when off or under reduced motion).
func beat() -> float:
	if not _on or reduced_motion:
		return 1.0
	var d: float = absf(_k - 0.5)
	return 1.0 + BEAT_ZOOM * maxf(0.0, 1.0 - d * 4.0)


func _draw() -> void:
	if not _on:
		return
	var r: float = reach_m * PX_PER_M
	var ring_k: float = 0.6 if reduced_motion else smoothstep(0.0, 1.0, _k)
	var fade: float = 1.0 - smoothstep(0.6, 1.0, _k)
	draw_circle(Vector2.ZERO, r * 0.55, Color(TEAL, 0.22 * fade))
	draw_arc(Vector2.ZERO, r * (0.25 + 0.75 * ring_k), 0.0, TAU, 48, Color(TEAL, 0.9 * fade), 4.0)
	draw_arc(Vector2.ZERO, r * (0.2 + 0.6 * ring_k), 0.0, TAU, 48, Color(TEAL_HI, 0.6 * fade), 1.5)
	_seams(r)
	if not _flash:
		_steam(r)
	_sparks(r, fade)


## Teal cracks across the body: they open through stage 0 and close through stage 1.
func _seams(r: float) -> void:
	var open: float = 1.0 - absf(_k - 0.5) * 2.0
	if open <= 0.0:
		return
	for i: int in SEAMS:
		var a: float = TAU * float(i) / float(SEAMS) + 0.4
		var a2: float = a + 0.35 * (1.0 if i % 2 == 0 else -1.0)
		var p0: Vector2 = Vector2.from_angle(a) * r * 0.08
		var p1: Vector2 = Vector2.from_angle(a) * r * 0.3 * open
		var p2: Vector2 = p1 + Vector2.from_angle(a2) * r * 0.15 * open
		var w: float = 3.0 * open + 1.0
		draw_polyline(PackedVector2Array([p0, p1, p2]), INK, w + 2.0)
		draw_polyline(PackedVector2Array([p0, p1, p2]), TEAL_HI, w)


## Steam rolls out from the swap (past the midpoint) as pale puffs with an ink rim.
func _steam(r: float) -> void:
	var t: float = clampf((_k - 0.4) / 0.6, 0.0, 1.0)
	if t <= 0.0 or t >= 1.0:
		return
	for i: int in 8:
		var a: float = TAU * (float(i) + 0.5) / 8.0
		var travel: float = 0.35 if reduced_motion else 0.3 + 0.5 * t
		var at: Vector2 = Vector2.from_angle(a) * r * travel
		var rad: float = r * (0.09 + 0.08 * t) * (1.0 if i % 2 == 0 else 0.75)
		var alpha: float = 0.85 * (1.0 - t)
		draw_circle(at, rad + 1.5, Color(INK, alpha * 0.6))
		draw_circle(at, rad, Color(STEAM, alpha))


## Sparks fly out along fixed spokes as short streaks (static dots under reduced motion).
func _sparks(r: float, fade: float) -> void:
	for i: int in SPOKES:
		var a: float = TAU * float(i) / float(SPOKES) + 0.21 * float(i % 3)
		var speed: float = 0.7 + 0.3 * float((i * 5) % 7) / 6.0
		var d: float = 0.5 if reduced_motion else 0.15 + _k * speed
		var head: Vector2 = Vector2.from_angle(a) * r * d
		var tail: Vector2 = Vector2.from_angle(a) * r * maxf(0.0, d - 0.12)
		var c: Color = SPARK if i % 3 != 0 else TEAL_HI
		draw_line(tail, head, Color(c, fade), 2.0)

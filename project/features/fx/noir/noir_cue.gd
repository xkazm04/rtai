class_name NoirCue
extends Node2D
## D-Noir objective cue (lane noir): in noir a cue reads by value and shape, not hue, so a ringing
## objective is drawn as bold WHITE arcs in an ink casing: white pops on the black street, and the
## casing keeps it readable on paper. The D4 ring is vermilion, which the noir pass prints as ink
## (a faint rimmed outline). Same geometry as the D4 ring (3 arcs pulsing outward), drawn over it.
## Render only: the host calls show_ring() with the sim's tick, or hide().

const PULSE_TICKS: int = 30
const ARCS: int = 3
const LINE_PX: float = 4.0
const CASE_PX: float = 3.0

var px_per_m: float = 48.0
var _at: Vector2 = Vector2.ZERO
var _tick: int = 0


## Rings at `at` (this node's local px), pulsing on the caller's tick.
func show_ring(at: Vector2, tick: int) -> void:
	_at = at
	_tick = tick
	visible = true
	queue_redraw()


## Where the ring is (local px).
func ring_at() -> Vector2:
	return _at


## Arc k's radius (px) at the current tick.
func radius(k: int) -> float:
	var pulse: float = float(_tick % PULSE_TICKS) / float(PULSE_TICKS)
	return (0.8 + k * 0.5 + pulse * 0.5) * px_per_m


func _draw() -> void:
	for layer: int in 2:
		var w: float = LINE_PX + (CASE_PX * 2.0 if layer == 0 else 0.0)
		var c: Color = Color.BLACK if layer == 0 else Color.WHITE
		for k: int in ARCS:
			draw_arc(_at, radius(k), -2.4, -0.7, 16, c, w, true)

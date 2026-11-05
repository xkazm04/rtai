class_name GhostAura
extends Node2D
## ghost-forms: the possessed glow under a light ghost form (Dent, Kerf, Ohm; TARGETS.md: "teal soul
## seams and glow marking it as possessed"): a soft teal pool on the floor under the body that
## breathes slowly, brighter while the form moves. Teal belongs to the souls only. Render-side,
## driven by the sim tick (no frame delta); reduced motion holds it still.

const TEAL: Color = GhostMorphFx.TEAL
## The pool's outer radius against the form's footprint radius, and its rings (inner = denser).
const REACH_K: float = 2.4
const RINGS: int = 5
const ALPHA: float = 0.11
## The breath: period (ticks) and depth (0..1).
const BREATH_TICKS: int = 96
const BREATH: float = 0.3

## The form's footprint radius in px (ghost_forms.json radius_m x PX_PER_M).
var radius_px: float = 14.0
var reduced_motion: bool = false
var _k: float = 1.0


## One frame: the sim tick and the form's speed against its top speed (0..1).
func sync(tick: int, move_k: float) -> void:
	var breath: float = 0.0 if reduced_motion else sin(TAU * float(tick) / BREATH_TICKS)
	var k: float = (1.0 - BREATH * 0.5 + breath * BREATH * 0.5) * (0.8 + 0.4 * move_k)
	if absf(k - _k) > 0.01:
		_k = k
		queue_redraw()


func _draw() -> void:
	var outer: float = radius_px * REACH_K
	for i: int in RINGS:
		var r: float = outer * (1.0 - float(i) / float(RINGS) * 0.75)
		draw_circle(Vector2.ZERO, r, Color(TEAL, ALPHA * _k))

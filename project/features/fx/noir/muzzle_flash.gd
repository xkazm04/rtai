class_name MuzzleFlash
extends Node2D
## D-Noir muzzle flash (lane noir): every new round leaves a white starburst at the muzzle for
## `ticks` ticks, ink-rimmed so it reads on paper too, and the first tick "lights the scene":
## lit() is true, and the caller drops the noir threshold for that frame (more of the frame
## prints as paper). Fed shot positions and directions in world px; stepped on the fixed tick.

const SPIKES: int = 8
const MAX_FLASHES: int = 16
## Photosensitivity guard: at most one lit frame per LIT_GAP ticks (0.33 s, under 3 flashes a
## second) however many rounds are fired; the starbursts themselves are not capped.
const LIT_GAP: int = 20

## The shared flash budget (ImpactFrame.budget): the light also spends from it, so kill beats
## and rounds cannot add up past the limit; null = only LIT_GAP applies.
var budget: FlashBudget = null

var ticks: int = 2
var radius_px: float = 26.0
var _at: PackedVector2Array = PackedVector2Array()
var _dir: PackedVector2Array = PackedVector2Array()
var _age: PackedInt32Array = PackedInt32Array()
var _lit: bool = false
var _lit_at: Vector2 = Vector2.ZERO
var _since_lit: int = LIT_GAP


func fire(at_px: Vector2, dir: Vector2) -> void:
	if _at.size() >= MAX_FLASHES:
		return
	@warning_ignore("return_value_discarded")
	_at.append(at_px)
	@warning_ignore("return_value_discarded")
	_dir.append(dir.normalized())
	@warning_ignore("return_value_discarded")
	_age.append(0)
	if _since_lit >= LIT_GAP and (budget == null or budget.spend(FlashBudget.LIGHT_COST)):
		_lit = true
		_lit_at = at_px
		_since_lit = 0
	queue_redraw()


## True on the tick a round was fired (one frame of light).
func lit() -> bool:
	return _lit


## Where the last round lit the scene (world px).
func lit_at() -> Vector2:
	return _lit_at


func step_ticks(n: int) -> void:
	_lit = false
	_since_lit += n
	for i: int in range(_age.size() - 1, -1, -1):
		_age[i] += n
		if _age[i] >= ticks:
			_at.remove_at(i)
			_dir.remove_at(i)
			_age.remove_at(i)
	queue_redraw()


func _draw() -> void:
	var ink: Color = Color(0.03, 0.03, 0.035)
	var paper: Color = Color(0.97, 0.96, 0.93)
	for i: int in _at.size():
		var r: float = radius_px * (1.0 if _age[i] == 0 else 0.6)
		var base: float = _dir[i].angle()
		draw_circle(_at[i], r * 0.36, ink)
		for pass_i: int in 2:
			var grow: float = 1.0 + 0.25 * (1 - pass_i)
			for k: int in SPIKES:
				var a: float = base + TAU * k / SPIKES
				var along: float = absf(cos(a - base))
				var tip: Vector2 = Vector2.from_angle(a) * r * (0.5 + 0.8 * along * along) * grow
				var side: Vector2 = Vector2.from_angle(a + PI * 0.5) * r * 0.16 * grow
				var tri: PackedVector2Array = [_at[i] + side, _at[i] + tip, _at[i] - side]
				draw_colored_polygon(tri, ink if pass_i == 0 else paper)
			draw_circle(_at[i], r * 0.3 * grow, ink if pass_i == 0 else paper)

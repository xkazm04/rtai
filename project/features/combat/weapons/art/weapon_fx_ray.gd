class_name WeaponFxRay
extends RefCounted
## weapon-art's ray gun round: a train of paper hoops (the `ray_ring` cells) strung back along the
## beam from its head, each squashed along the travel so it reads as a ring flying edge-on, the
## rings widening and fading toward the tail. Until iteration 8 the ray gun (a BOLT row) drew the
## electro gun's lightning cells, so its ring art was never seen. Render only: reads the shot.

## Rings per round, their spacing along the beam (m) and their squash along the travel.
const RINGS: int = 4
const GAP_M: float = 0.9
const SQUASH: float = 0.42
## Each ring further back draws this much wider and this much fainter (n5-look: FADE 0.2 -> 0.12,
## the tail ring at 0.64 alpha: at 0.4 the acid green printed olive over the dark slab).
const GROW: float = 0.18
const FADE: float = 0.12
## Each hoop is drawn first in ink (WeaponFxElectro.ink_cell, the electro bolt's thickened outline):
## the thin paper hoops read faint on cream paving at 32 px/m (call 3). `--ray-ink=off` = before.
## The hoops' ink reaches RAY_INK_M out (less than the bolt's: at 0.06 m they read as dark tyres).
const RAY_INK_M: float = 0.035

## The ray's projectile_fx values. n5-look (r2_w4): "ray_beam" draws one straight acid-green beam
## (the `ray_beam` cells, tools/art/ray_beam.py) stretched back from the head over at most BEAM_M,
## as the electro arc's cells; "ray_ring" = the hoop train below (the before).
const FX: Array[StringName] = [&"ray_ring", &"ray_beam"]
const BEAM_M: float = 3.0
## The beam cell's span in part px, tail anchor to the round head.
const BEAM_SPAN_PX: float = 296.0

static var ray_ink: bool = not OS.get_cmdline_user_args().has("--ray-ink=off")


## Draws the round in the `fx` style with its head at `at` (m) flying along `dir`.
static func draw(
	ci: CanvasItem, fx: StringName, at: Vector2, dir: Vector2, went: float, tick: int
) -> void:
	if fx == &"ray_beam":
		draw_beam(ci, at, dir, went, tick)
	else:
		draw_round(ci, at, dir, went, tick)


## The beam from the head back toward the gun: at most BEAM_M, never behind the CLEAR_M mark.
static func draw_beam(ci: CanvasItem, at: Vector2, dir: Vector2, went: float, tick: int) -> void:
	var len_m: float = minf(BEAM_M, went - WeaponFxArt.CLEAR_M)
	if len_m <= 0.0:
		return
	var span: float = len_m * Ink.PX_PER_M / (BEAM_SPAN_PX * WeaponFxArt.cell_scale())
	var tail: Vector2 = at - dir * len_m
	WeaponFxArt.draw_cell(ci, &"ray_beam", tick % 3, tail, dir.angle(), Vector2(span, 1.0))


## Draws the ring train ("ray_ring") with its head at `at` (m) flying along `dir`; `went` = flown.
static func draw_round(ci: CanvasItem, at: Vector2, dir: Vector2, went: float, tick: int) -> void:
	var ang: float = dir.angle()
	for k: int in RINGS:
		var back: float = GAP_M * float(k)
		if back > went - WeaponFxArt.CLEAR_M:
			break
		var size: float = 1.0 + GROW * float(k)
		var frame: int = mini(k, 2) if tick % 2 == 0 else mini(k + 1, 2)
		var a: float = 1.0 - FADE * float(k)
		if ray_ink:
			var scale: Vector2 = Vector2(SQUASH, 1.0) * size * WeaponFxArt.cell_scale()
			var xf: Transform2D = Transform2D(ang, scale, 0.0, Ink.px(at - dir * back))
			WeaponFxElectro.ink_cell(ci, &"ray_ring", frame, xf, Vector2(RAY_INK_M, a))
		WeaponFxArt.draw_cell(
			ci, &"ray_ring", frame, at - dir * back, ang, Vector2(SQUASH, 1.0) * size, a
		)

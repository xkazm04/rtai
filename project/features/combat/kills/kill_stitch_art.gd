class_name KillStitchArt
extends RefCounted
## The machine pistol's death (lane kills-new, style `stitch`), render only: the rounds walk up the
## body - `spurts` hits from the hip to the neck, `gap` ticks apart (row fx) - each one an ink hole
## on him and a red spurt out of his back along the shot (the jerks are the row's pose track); on
## the last one he whirls once (his drawn facings turn a full circle, `whirl_ticks`) and drops
## across the shot. The holes ride the body to the street. Red is blood only. No RNG.

const BLOOD: Color = KillMarkArt.BLOOD
const BLOOD_DARK: Color = KillMarkArt.BLOOD_DARK
## A spurt's life (ticks) and reach (m).
const SPURT_TICKS: int = 6
const SPURT_M: float = 0.45


## The facing (world rad, the way his drawn fall grid falls) this tick: under the blow through the
## stitch, then one whole turn over `whirl_ticks` from `whirl_from` (row fx) onto the fall side.
static func facing(d: KillNewStyles.Death, age: int) -> float:
	var from: float = d.extra.num("whirl_from", 10.0)
	var ticks: float = maxf(1.0, d.extra.num("whirl_ticks", 8.0))
	var a0: float = d.dir.angle()
	var a1: float = d.fall.angle()
	var turn: float = wrapf(a1 - a0, 0.0, TAU) + TAU  # one whole turn and on to the fall side
	var u: float = clampf((float(age) - from) / ticks, 0.0, 1.0)
	return a0 + turn * u


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var a: int = age - d.row.hitstop_ticks
	for n: int in _spurts(d):
		var t: int = a - n * _gap(d)
		if t < 0:
			return
		var at: Vector2 = d.xf * (d.feet + Vector2(_side(d, n), -d.height * _height(d, n)))
		ci.draw_circle(at, ci.ppm * 0.045, Ink.INK)
		ci.draw_circle(at, ci.ppm * 0.025, BLOOD_DARK)
		if t < SPURT_TICKS:
			_spurt(ci, d, at, n, float(t + 1) / float(SPURT_TICKS))


static func _spurt(
	ci: KillNewStyles, d: KillNewStyles.Death, at: Vector2, n: int, k: float
) -> void:
	for j: int in 3:
		var spread: float = (KillNewStyles.h(d.serial, n * 5 + j) - 0.5) * 0.5
		var run: float = SPURT_M * ci.ppm * k * (0.45 + 0.3 * j)
		var p: Vector2 = at + d.dir.rotated(spread) * run
		var r: float = ci.ppm * (0.04 - 0.008 * j) * (1.15 - 0.5 * k)
		ci.draw_circle(p, r + 1.0, BLOOD_DARK)
		ci.draw_circle(p, r, BLOOD)


static func _spurts(d: KillNewStyles.Death) -> int:
	return maxi(1, roundi(d.extra.num("spurts", 4)))


static func _gap(d: KillNewStyles.Death) -> int:
	return maxi(1, roundi(d.extra.num("gap", 3)))


## Share of the standing height of spurt `n` (hip -> neck).
static func _height(d: KillNewStyles.Death, n: int) -> float:
	var lo: float = d.extra.num("from_h", 0.42)
	var hi: float = d.extra.num("to_h", 0.82)
	return lerpf(lo, hi, float(n) / float(maxi(1, _spurts(d) - 1)))


## A spurt's side-step across the body (px), so the stitch zigzags a little.
static func _side(d: KillNewStyles.Death, n: int) -> float:
	return (KillNewStyles.h(d.serial, n + 300) - 0.5) * d.height * 0.12

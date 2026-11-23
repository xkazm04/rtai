class_name OhmBoltDraw
extends RefCounted
## Draw the resolved path in order. Every link has its own envelope on the simulation clock.

const LINK_TICKS: int = 2
const FIRST_K: float = 0.6
const FORK_K: float = 1.0
const PRONG_K: float = 0.24
const JOIN_M: float = 0.34
const FLARE_TICKS: int = 3
const AMBER: Color = Color("#ffb000")


static func delay(index: int, calm: bool) -> int:
	return 0 if calm else index * LINK_TICKS


static func fade(age: int, index: int, calm: bool) -> float:
	var since: int = age - delay(index, calm)
	if since < 0:
		return 0.0
	return maxf(0.0, 1.0 - since * SimClock.TICK_DT / OhmView.HANG_S)


static func width(index: int) -> float:
	return FIRST_K if index == 0 else FORK_K


static func stroke(canvas: Node2D, pts: PackedVector2Array, fade_k: float, k: float) -> void:
	canvas.draw_polyline(pts, Color(OhmView.INK, 0.75 * fade_k), OhmView.INK_W * k, true)
	canvas.draw_polyline(pts, Color(OhmView.TEAL, fade_k), OhmView.TEAL_W * k, true)
	canvas.draw_polyline(pts, Color(OhmView.WHITE, fade_k), OhmView.CORE_W * k, true)


## Contacts are clipped at both rims, including very short hops between overlapping rings.
static func link(ink: OhmView, points: PackedVector2Array, index: int, age: int) -> void:
	var alpha: float = fade(age, index, ink.reduced_motion)
	if alpha <= 0.0:
		return
	var a: Vector2 = points[0]
	var b: Vector2 = points[1]
	var beat: int = index if ink.reduced_motion else index + floori(age / 2.0)
	var span: float = a.distance_to(b)
	var jag_m: float = minf(OhmView.JAG_M * 0.65, span * 0.15 / ink.ppm)
	ink.stroke(ink.jag(a, b, beat, jag_m), alpha, width(index))


static func prongs(ink: OhmView, tips: PackedVector2Array, join: Vector2, alpha: float) -> void:
	for i: int in 2:
		ink.stroke(PackedVector2Array([tips[i], join]), alpha, PRONG_K)

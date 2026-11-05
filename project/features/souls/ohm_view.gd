class_name OhmView
extends Node2D
## Ohm on the arena's actor layer (lane ghost-powers), render only; reads the pilot's OhmStage
## (looked up each frame: the reel sets it after the views attach). While the soul is on: small
## teal sparks crawling at the electrode fingertips. Each bolt, for HANG_S: a jagged teal bolt
## under an ink rim with a white-hot core, two prongs from the two electrode fingertips (the form
## row's anchors) meeting in the first body, and forking on
## along OhmStage.bolt_path, re-jagged every other tick, with a white flash disc at each body.
## Reduced motion: one still jag, no flicker.

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const WHITE: Color = Color(0.92, 1.0, 0.97)
const HANG_S: float = 0.22
const JAG_M: float = 0.32
const STEP_M: float = 0.55
## The bolt's strokes in px (ink rim, teal body, white core): heavy enough to read at 32 px/m on
## the city's asphalt (was 7 / 4 / 1.5).
const INK_W: float = 10.0
const TEAL_W: float = 6.0
const CORE_W: float = 2.5
## The fingertip prongs are thinner (x PRONG_K) so the electrode arm stays visible under them;
## they join PRONG_M ahead of the fingertips, where the full bolt goes on to the first body.
const PRONG_K: float = 0.5
const PRONG_M: float = 0.9

var stage: CollectCallStage = null
var ppm: float = 32.0
var reduced_motion: bool = false


func _process(_delta: float) -> void:
	queue_redraw()


func ohm() -> OhmStage:
	return stage.pilot.ohm if stage != null and stage.pilot != null else null


func _draw() -> void:
	var o: OhmStage = ohm()
	if o == null:
		return
	if o.on():
		_sparks()
	if o.bolt_tick < 0:
		return
	var age: float = (stage.tick - o.bolt_tick) * SimClock.TICK_DT
	if age > HANG_S or o.bolt_path.size() < 2:
		return
	var fade: float = 1.0 - age / HANG_S
	var beat: int = 0 if reduced_motion else (stage.tick / 2)
	var prongs: PackedVector2Array = o.tips(stage.arena.rivet.pos, o.bolt_aim)
	for i: int in o.bolt_path.size() - 1:
		var src: int = o.bolt_from[i + 1] if o.bolt_from.size() > i + 1 else i
		var b: Vector2 = o.bolt_path[i + 1] * ppm
		if src <= 0:  # the fingertips: one prong from each electrode into the first body
			var mid: Vector2 = (prongs[0] + prongs[1]) * 0.5
			var reach: float = minf(PRONG_M, mid.distance_to(o.bolt_path[i + 1]) * 0.5)
			var join: Vector2 = (mid + o.bolt_aim * reach) * ppm
			_stroke(_jag(prongs[0] * ppm, join, beat + i), fade, PRONG_K)
			_stroke(_jag(prongs[1] * ppm, join, beat + i + 7), fade, PRONG_K)
			_stroke(_jag(join, b, beat + i + 3), fade, 1.0)
		else:
			_stroke(_jag(o.bolt_path[src] * ppm, b, beat + i), fade, 1.0)
		draw_circle(b, 0.3 * ppm * fade, Color(WHITE, 0.8 * fade))


func _stroke(pts: PackedVector2Array, fade: float, k: float) -> void:
	draw_polyline(pts, Color(INK, 0.75 * fade), INK_W * k, true)
	draw_polyline(pts, Color(TEAL, fade), TEAL_W * k, true)
	draw_polyline(pts, Color(WHITE, fade), CORE_W * k, true)


## A jagged line a -> b: kinks every STEP_M, offset across the line by a hash of (seed, kink).
func _jag(a: Vector2, b: Vector2, seed_i: int) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array([a])
	var n: int = maxi(2, ceili(a.distance_to(b) / (STEP_M * ppm)))
	var side: Vector2 = (b - a).orthogonal().normalized()
	for k: int in range(1, n):
		var h: float = sin(float(seed_i * 31 + k * 17) * 12.9898) * 43758.5453
		var off: float = (h - floorf(h) - 0.5) * 2.0 * JAG_M * ppm
		@warning_ignore("return_value_discarded")
		pts.append(a.lerp(b, float(k) / n) + side * off)
	@warning_ignore("return_value_discarded")
	pts.append(b)
	return pts


func _sparks() -> void:
	var rivet: Fighter = stage.arena.rivet
	var f: Vector2 = rivet.facing.normalized()
	var tips: PackedVector2Array = ohm().tips(rivet.pos, f)
	var beat: int = 0 if reduced_motion else stage.tick / 3
	for i: int in 2:
		var side: float = -1.0 if i == 0 else 1.0
		var at: Vector2 = tips[i] * ppm
		var tip: Vector2 = at + f.rotated(side * (0.4 + 0.3 * float(beat % 3))) * 0.3 * ppm
		draw_line(at, tip, TEAL, 2.0, true)
		draw_circle(at, 2.5, WHITE)

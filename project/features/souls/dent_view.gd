class_name DentView
extends Node2D
## Dent on the arena's actor layer (lane ghost-powers), render only. While a car is seized: a
## soul-teal tether from Rivet's hands (HANDS_M ahead) to the car, sagging and trembling, and a
## heat halo round the car that climbs from a dull amber to white-hot with DentStage.heat (the
## pulse quickens once the overload is armed). On the blast: an ink shock ring with a hot core
## over BLAST_S (reduced motion: no core flash, the ring only). Reads the DentStage only.

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const WARM: Color = Color("#C9822E")
const HOT: Color = Color(1.0, 0.97, 0.86)
const HANDS_M: float = 0.5
const SAG_M: float = 0.6
const SEGMENTS: int = 14
const BLAST_S: float = 0.45

var dent: DentStage = null
var stage: CollectCallStage = null
var ppm: float = 32.0
var reduced_motion: bool = false


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if dent == null or stage == null:
		return
	if dent.car != null:
		var rivet: Fighter = stage.arena.rivet
		var hands: Vector2 = (rivet.pos + rivet.facing.normalized() * HANDS_M) * ppm
		_halo(dent.car.pos * ppm, dent.heat)
		_tether(hands, dent.car.pos * ppm)
	if dent.blast_tick >= 0:
		var age: float = (stage.tick - dent.blast_tick) * SimClock.TICK_DT
		if age <= BLAST_S:
			_blast(dent.blast_at * ppm, age / BLAST_S)


func _tether(a: Vector2, b: Vector2) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var side: Vector2 = (b - a).orthogonal().normalized()
	for i: int in SEGMENTS + 1:
		var t: float = float(i) / SEGMENTS
		var sag: float = sin(t * PI) * SAG_M * ppm * 0.4
		var shake: float = 0.0 if reduced_motion else sin(stage.tick * 0.9 + i * 1.7) * 2.0
		@warning_ignore("return_value_discarded")
		pts.push_back(a.lerp(b, t) + side * (sag + shake))
	draw_polyline(pts, Color(INK, 0.7), 5.0)
	draw_polyline(pts, TEAL, 2.0)
	draw_circle(b, 4.0, TEAL)


func _halo(c: Vector2, heat: float) -> void:
	var armed: bool = heat >= dent.num(&"arm_k")
	var rate: float = 0.5 if armed else 0.2
	var pulse: float = 0.5 + 0.5 * sin(stage.tick * rate) if not reduced_motion else 0.6
	var col: Color = WARM.lerp(HOT, heat)
	var r: float = (1.6 + 0.4 * heat) * ppm
	draw_circle(c, r, Color(col, (0.1 + 0.3 * heat) * (0.6 + 0.4 * pulse)))
	draw_arc(c, r, 0.0, TAU, 40, Color(col, 0.4 + 0.5 * heat), 2.0 + 2.0 * heat)


func _blast(c: Vector2, k: float) -> void:
	var r: float = dent.num(&"blast_radius_m") * ppm * (1.0 - pow(1.0 - k, 3.0))
	if not reduced_motion:
		draw_circle(c, r * 0.55, Color(HOT, 0.85 * (1.0 - k)))
	draw_arc(c, r, 0.0, TAU, 48, Color(INK, 1.0 - k), lerpf(10.0, 2.0, k))

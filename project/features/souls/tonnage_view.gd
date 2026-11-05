class_name TonnageView
extends Node2D
## Tonnage's slam on the arena's actor layer (lane ghost-powers), render only: the telegraph and
## the landing. Over the wind-up the press head's footprint (a square die plate, PLATE_M wide)
## inks in where the slam will land, its edge a soul-teal line and a shrinking inner square (the
## head dropping); on landing HaulerMarks draws the shock ring and the D5 street crack. Reads the
## HaulerStage only. Reduced motion: the footprint is drawn whole (no shrinking square).

const PLATE_M: float = 1.8
const INK: Color = Color(0.09, 0.08, 0.07)

var hauler: HaulerStage = null
var stage: CollectCallStage = null
var ppm: float = 32.0
var reduced_motion: bool = false
## False leaves the landing ring and crack to the caller (quest 1's CastView draws them already).
var marks: bool = true


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if hauler == null or stage == null:
		return
	var form: HaulerForm = hauler.form
	if form.on and form.windup_k() > 0.0:
		_telegraph(hauler.slam_point(stage) * ppm, form.windup_k())
	if marks and hauler.stomp_tick >= 0:
		var age: float = (stage.tick - hauler.stomp_tick) * SimClock.TICK_DT
		var radius: float = form.num(&"stomp_radius_m")
		HaulerMarks.draw(self, hauler.stomp_at * ppm, age, radius, ppm, hauler.stomp_tick)


## The die plate's footprint at `c` (px), `k` 0..1 through the wind-up.
func _telegraph(c: Vector2, k: float) -> void:
	var half: float = PLATE_M * 0.5 * ppm
	var plate: Rect2 = Rect2(c - Vector2(half, half), Vector2(half, half) * 2.0)
	draw_rect(plate, Color(INK, 0.12 + 0.3 * k))
	draw_rect(plate, Color(HaulerMarks.TEAL, 0.35 + 0.6 * k), false, 2.0)
	if reduced_motion:
		return
	var inner: float = half * (1.0 - k) + 4.0
	var drop: Rect2 = Rect2(c - Vector2(inner, inner), Vector2(inner, inner) * 2.0)
	draw_rect(drop, Color(INK, 0.5 + 0.5 * k), false, lerpf(2.0, 6.0, k))

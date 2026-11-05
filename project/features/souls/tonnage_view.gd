class_name TonnageView
extends Node2D
## Tonnage's slam on the arena's actor layer (lane ghost-powers), render only: the telegraph and
## the landing. Over the wind-up the press head's footprint (a square die plate, PLATE_M wide)
## inks in where the slam will land, its edge a soul-teal line and a shrinking inner square (the
## head dropping); on landing HaulerMarks draws the shock ring and the D5 street crack. Reads the
## HaulerStage only. Reduced motion: the footprint is drawn whole (no shrinking square).
## The plate lands under the press body (it stands 0.9 m ahead, inside the 3x form's footprint), so
## the wind-up also marks the shockwave's reach on the street: a dashed soul-teal ring at
## stomp_radius_m that the press's shadow (an ink wash) fills from the plate outward as the head
## drops. Reduced motion: the ring and a flat wash, no fill.

const PLATE_M: float = 1.8
const INK: Color = Color(0.09, 0.08, 0.07)
const DASHES: int = 28

var hauler: HaulerStage = null
var stage: CollectCallStage = null
var ppm: float = 32.0
var reduced_motion: bool = false
## False leaves the landing ring and crack to the caller (quest 1's CastView draws them already).
var marks: bool = true
## False drops the reach ring (the plate only, as before iteration 8; dev `--no-tele-ring`).
var reach_ring: bool = not OS.get_cmdline_user_args().has("--no-tele-ring")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if hauler == null or stage == null:
		return
	var form: HaulerForm = hauler.form
	if form.on and form.windup_k() > 0.0:
		var at: Vector2 = hauler.slam_point(stage) * ppm
		if reach_ring:
			_reach(at, form.num(&"stomp_radius_m") * ppm, form.windup_k())
		_telegraph(at, form.windup_k())
	if marks:
		RamMarks.draw_all(self, hauler, stage.tick, ppm)  # n7-melee: the ram's contact marks
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


## The shockwave's reach at `c`: radius `r` px, `k` 0..1 through the wind-up.
func _reach(c: Vector2, r: float, k: float) -> void:
	var fill: float = r if reduced_motion else r * k
	draw_circle(c, fill, Color(INK, 0.1 + 0.12 * k))
	if not reduced_motion:
		draw_arc(c, fill, 0.0, TAU, 48, Color(INK, 0.35 + 0.4 * k), 2.0)
	var span: float = TAU / DASHES
	for i: int in DASHES:
		var a: float = span * i
		draw_arc(c, r, a, a + span * 0.55, 6, Color(HaulerMarks.TEAL, 0.45 + 0.5 * k), 2.5)

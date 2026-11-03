class_name PowersRing
extends Node2D
## The Hauler on the city view (dev clip): HaulerLook grows and tints Rivet's rig by the morph
## (the stomp wind-up swells it); this node draws the stomp's landing in the inked look: a rough
## ink shock ring (deterministic per-vertex wobble) with a thin soul-teal edge, and grit flung
## outward, all over SHOCK_S. No telegraph circle: the swell and the camera carry the read.

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const SHOCK_S: float = 0.4
## The landing slam pose: in fast, held, out over this long.
const SLAM_S: float = 0.35
const VERTS: int = 48
const GRIT: int = 18

var hauler: HaulerCity = null
var look: HaulerLook = null
var rig: CutRig = null
var tick: int = 0


func sync(p_tick: int, p_rig: CutRig) -> void:
	tick = p_tick
	rig = p_rig
	var slam: float = 0.0
	if hauler.stomp_tick >= 0:
		var age: float = (tick - hauler.stomp_tick) * SimClock.TICK_DT
		slam = clampf(1.0 - absf(age - SLAM_S * 0.25) / SLAM_S, 0.0, 1.0)
	look.apply(rig, hauler.form.morph_k(), hauler.form.windup_k(), slam)
	queue_redraw()


func _draw() -> void:
	if hauler.stomp_tick < 0:
		return
	var age: float = (tick - hauler.stomp_tick) * SimClock.TICK_DT
	if age > SHOCK_S:
		return
	var k: float = age / SHOCK_S
	var grow: float = 1.0 - pow(1.0 - k, 3.0)
	var r: float = hauler.form.num(&"stomp_radius_m") * SimConst.PX_PER_M * grow
	var c: Vector2 = hauler.stomp_at * SimConst.PX_PER_M
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in VERTS + 1:
		var a: float = TAU * i / VERTS
		var wob: float = 1.0 + 0.07 * sin(a * 7.0 + 1.3) + 0.04 * sin(a * 13.0)
		@warning_ignore("return_value_discarded")
		pts.push_back(c + Vector2.from_angle(a) * r * wob)
	draw_polyline(pts, Color(INK, 1.0 - k), lerpf(9.0, 2.0, k))
	draw_polyline(pts, Color(TEAL, 0.8 * (1.0 - k)), 1.5)
	for g: int in GRIT:
		var a: float = TAU * g / GRIT + 0.4 * sin(g * 2.1)
		var d: float = r * (0.55 + 0.5 * absf(sin(g * 3.7)))
		draw_circle(c + Vector2.from_angle(a) * d, lerpf(3.0, 1.0, k), Color(INK, 1.0 - k))

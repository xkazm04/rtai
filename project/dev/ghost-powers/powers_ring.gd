class_name PowersRing
extends Node2D
## The Hauler on the city view (dev clip): HaulerLook grows and tints Rivet's rig by the morph
## (the stomp wind-up swells it); this node draws the stomp's landing through HaulerMarks (shock
## ring, grit, the D5 crack). No telegraph circle: the swell and the camera carry the read.

## The landing slam pose: in fast, held, out over this long.
const SLAM_S: float = 0.35

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
	var c: Vector2 = hauler.stomp_at * SimConst.PX_PER_M
	var radius: float = hauler.form.num(&"stomp_radius_m")
	HaulerMarks.draw(self, c, age, radius, SimConst.PX_PER_M, hauler.stomp_tick)

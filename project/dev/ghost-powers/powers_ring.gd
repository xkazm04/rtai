class_name PowersRing
extends Node2D
## The Hauler's look on the city view (dev clip): scales Rivet's rig by the morph (base size_k to
## the hauler FORMS row), tints it toward the souls' teal, draws the stomp telegraph (a thin ring
## closing in) and the shockwave (a teal ring growing to the stomp radius over SHOCK_S).

const TEAL: Color = Color(0.18, 0.80, 0.76)
const SHOCK_S: float = 0.35
const TINT_K: float = 0.55

var hauler: HaulerCity = null
var rig: CutRig = null
var tick: int = 0


func sync(p_tick: int, p_rig: CutRig) -> void:
	tick = p_tick
	rig = p_rig
	if rig != null:
		var k: float = hauler.form.morph_k()
		var base: float = RivetPlan.FORMS[RivetPlan.FORM_BASE].x
		var big: float = RivetPlan.FORMS[RivetPlan.FORM_HAULER].x / base
		var bump: float = 1.0 + 0.12 * hauler.form.windup_k()
		rig.scale = Vector2.ONE * CutRig.SC * base * lerpf(1.0, big, k) * bump
		rig.modulate = Color.WHITE.lerp(TEAL, TINT_K * k)
	queue_redraw()


func _draw() -> void:
	var px: float = SimConst.PX_PER_M
	var f: HaulerForm = hauler.form
	if f.windup_k() > 0.0 and rig != null:
		var r: float = f.num(&"stomp_radius_m") * (1.0 - 0.6 * f.windup_k())
		draw_arc(rig.position, r * px, 0.0, TAU, 64, TEAL, 2.0)
	if hauler.stomp_tick < 0:
		return
	var age: float = (tick - hauler.stomp_tick) * SimClock.TICK_DT
	if age > SHOCK_S:
		return
	var k: float = age / SHOCK_S
	var col: Color = Color(TEAL, 1.0 - k)
	draw_arc(hauler.stomp_at * px, f.num(&"stomp_radius_m") * px * k, 0.0, TAU, 64, col, 6.0)

class_name HaulerLook
extends RefCounted
## The Hauler tank on Rivet's own cutout rig (ASK ghost-powers-2; powers.json hauler.look): the
## rig grows from the base FORMS size to the hauler row by the form's morph_k and tints toward
## the souls' teal. `bulked` also shortens both arm segments (lengths, draw lengths and the guard
## hand targets) to look_arm_k, a squat press-bot read instead of base Rivet's long arms grown.
## The plan is Rivet's shared plan (one Rivet): the base numbers are kept and restored exactly.

const TEAL: Color = Color(0.18, 0.80, 0.76)
const BULKED: StringName = &"bulked"
## The stomp wind-up swells the tank by this much at the end of the telegraph.
const WINDUP_SWELL: float = 0.12

var look: StringName = BULKED
var _t: Dictionary = {}
var _plan: BodyPlan = null
var _upper: float = 0.0
var _upper_draw: float = 0.0
var _fore: PackedFloat32Array = PackedFloat32Array()
var _fore_draw: PackedFloat32Array = PackedFloat32Array()
var _hand: Array[Vector3] = []


func _init(tuning: Dictionary) -> void:
	_t = tuning
	look = StringName(str(tuning.get("look", BULKED)))


## Applies the look to `rig` for the morph k (0 = base Rivet, 1 = the tank) and wind-up wk.
func apply(rig: CutRig, k: float, wk: float = 0.0) -> void:
	if rig == null:
		return
	var base: float = RivetPlan.FORMS[RivetPlan.FORM_BASE].x
	var big: float = RivetPlan.FORMS[RivetPlan.FORM_HAULER].x / base
	var swell: float = 1.0 + WINDUP_SWELL * wk
	rig.scale = Vector2.ONE * CutRig.SC * base * lerpf(1.0, big, k) * swell
	rig.modulate = Color.WHITE.lerp(TEAL, SoulTuning.num(_t, &"look_tint_k") * k)
	if look == BULKED:
		_arms(rig.plan, lerpf(1.0, SoulTuning.num(_t, &"look_arm_k"), k))


## Arm segment scale on the plan (1 = the base numbers, restored exactly).
func _arms(plan: BodyPlan, ak: float) -> void:
	if plan != _plan:
		_keep(plan)
	plan.upper_len = _upper * ak
	plan.upper_draw = _upper_draw * ak
	for s: int in 2:
		plan.fore_len[s] = _fore[s] * ak
		plan.fore_draw[s] = _fore_draw[s] * ak
		plan.hand_ready[s] = _hand[s] * Vector3(ak, 1.0, 1.0)


func _keep(plan: BodyPlan) -> void:
	_plan = plan
	_upper = plan.upper_len
	_upper_draw = plan.upper_draw
	_fore = plan.fore_len.duplicate()
	_fore_draw = plan.fore_draw.duplicate()
	_hand = plan.hand_ready.duplicate()

class_name HaulerLook
extends RefCounted
## The Hauler tank on Rivet's own cutout rig (ASK ghost-powers-2; powers.json hauler.look): the
## rig grows from the base FORMS size to the hauler row by the form's morph_k and tints toward
## the souls' teal. `bulked` also shortens both arm segments (lengths, draw lengths and the guard
## hand targets) to look_arm_k, a squat press-bot read instead of base Rivet's long arms grown.
## The stomp is posed on the same plan: the wind-up raises both claws overhead (wk), the landing
## slams them forward and down to the ground (slam_k). The plan is Rivet's shared plan (one
## Rivet): the base numbers are kept and restored exactly.

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
var _relax: Array[Vector3] = []


func _init(tuning: Dictionary) -> void:
	_t = tuning
	look = StringName(str(tuning.get("look", BULKED)))


## Applies the look to `rig` for the morph k (0 = base Rivet, 1 = the tank), the stomp wind-up
## wk and the landing slam_k (each 0..1).
func apply(rig: CutRig, k: float, wk: float = 0.0, slam_k: float = 0.0) -> void:
	if rig == null:
		return
	var base: float = RivetPlan.FORMS[RivetPlan.FORM_BASE].x
	var big: float = RivetPlan.FORMS[RivetPlan.FORM_HAULER].x / base
	var swell: float = 1.0 + WINDUP_SWELL * wk
	rig.scale = Vector2.ONE * CutRig.SC * base * lerpf(1.0, big, k) * swell
	rig.modulate = Color.WHITE.lerp(TEAL, SoulTuning.num(_t, &"look_tint_k") * k)
	var ak: float = lerpf(1.0, SoulTuning.num(_t, &"look_arm_k"), k) if look == BULKED else 1.0
	_arms(rig.plan, ak, wk, slam_k)


## Arm segment scale on the plan (1 = the base numbers, restored exactly).
func _arms(plan: BodyPlan, ak: float, wk: float, slam_k: float) -> void:
	if plan != _plan:
		_keep(plan)
	plan.upper_len = _upper * ak
	plan.upper_draw = _upper_draw * ak
	for s: int in 2:
		plan.fore_len[s] = _fore[s] * ak
		plan.fore_draw[s] = _fore_draw[s] * ak
		var sh: Vector3 = plan.shoulder[s]
		var reach: float = plan.upper_len + plan.fore_len[s]
		var up: Vector3 = Vector3(sh.x + 30.0, sh.y * 0.55, 200.0)
		var down: Vector3 = Vector3(sh.x + reach * 0.9, sh.y * 0.6, -320.0)
		var r: Vector3 = (_hand[s] * Vector3(ak, 1.0, 1.0)).lerp(up, wk).lerp(down, slam_k)
		plan.hand_ready[s] = r
		plan.hand_relax[s] = _relax[s].lerp(up, wk).lerp(down, slam_k)


func _keep(plan: BodyPlan) -> void:
	_plan = plan
	_upper = plan.upper_len
	_upper_draw = plan.upper_draw
	_fore = plan.fore_len.duplicate()
	_fore_draw = plan.fore_draw.duplicate()
	_hand = plan.hand_ready.duplicate()
	_relax = plan.hand_relax.duplicate()

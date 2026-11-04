class_name SignatureKill
extends RefCounted
## One row of signature_kills.json (lane brutality): the one-shot kill an advanced weapon plays on
## a human. Speeds in m/s, spin in deg/s, timings in 60 Hz ticks. Missing optional fields keep
## the defaults below, so a new style can land with only its own keys.

const PIECE_IDS: PackedStringArray = ["head", "torso", "arm_l", "arm_r", "leg_l", "leg_r"]

var id: StringName = &""
var weapon: StringName = &""
var style: StringName = &"gib"
var pieces: PackedInt32Array = PackedInt32Array()
var launch_mps: Vector2 = Vector2(5.0, 10.0)
var up_mps: Vector2 = Vector2(3.0, 6.0)
var spin_dps: Vector2 = Vector2(360.0, 1080.0)
var cone_deg: float = 75.0
var bounce: float = 0.35
var ground_drag: float = 6.0
var hitstop_ticks: int = 0
var flash_ticks: int = 0
var scorch_radius_m: float = 0.0
var spray: int = 0


static func from_dict(t: DataTable, d: Dictionary) -> SignatureKill:
	var k: SignatureKill = SignatureKill.new()
	k.id = StringName(t.text(d, "id"))
	k.weapon = StringName(t.text(d, "weapon"))
	k.style = StringName(t.text(d, "style"))
	for v: Variant in d.get("pieces", []):
		var at: int = PIECE_IDS.find(str(v))
		if at >= 0:
			@warning_ignore("return_value_discarded")
			k.pieces.append(at)
	k.launch_mps = t.vec(d, "launch_mps") if d.has("launch_mps") else k.launch_mps
	k.up_mps = t.vec(d, "up_mps") if d.has("up_mps") else k.up_mps
	k.spin_dps = t.vec(d, "spin_dps") if d.has("spin_dps") else k.spin_dps
	k.cone_deg = _num(t, d, "cone_deg", k.cone_deg)
	k.bounce = _num(t, d, "bounce", k.bounce)
	k.ground_drag = _num(t, d, "ground_drag", k.ground_drag)
	k.hitstop_ticks = roundi(_num(t, d, "hitstop_ticks", 0.0))
	k.flash_ticks = roundi(_num(t, d, "flash_ticks", 0.0))
	k.scorch_radius_m = _num(t, d, "scorch_radius_m", 0.0)
	k.spray = roundi(_num(t, d, "spray", 0.0))
	return k


static func _num(t: DataTable, d: Dictionary, key: String, fallback: float) -> float:
	return t.num(d, key) if d.has(key) else fallback

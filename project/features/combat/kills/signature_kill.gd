class_name SignatureKill
extends RefCounted
## One row of signature_kills.json (lane brutality): the one-shot kill an advanced weapon plays on
## a human. Speeds in m/s, spin in deg/s, timings in 60 Hz ticks. Missing optional fields keep
## the defaults below, so a new style can land with only its own keys.

## Gib parts (0-5), or the whole body in one piece plus the cap knocked off it (6-7), or the
## body cut in two along a blade's line (8-9, the split style).
const PIECE_IDS: PackedStringArray = [
	"head", "torso", "arm_l", "arm_r", "leg_l", "leg_r", "body", "hat", "half_a", "half_b"
]
const BODY: int = 6
const HAT: int = 7
const HALF_A: int = 8
const HALF_B: int = 9

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
## The spray fan's width (degrees); 0 = the pieces' cone.
var spray_cone_deg: float = 0.0
## The burn style's char: ticks the charred body stands smoking, ticks it crumbles to ash,
## and the ash heap's radius (metres) it leaves.
var stand_ticks: int = 0
var crumble_ticks: int = 0
var ash_m: float = 0.0
## The split style's cut: degrees between the blow's approach and the cut line (the slash runs
## diagonally shoulder to hip; the sign alternates kill by kill).
var cut_deg: float = 0.0
## The chainsaw's grind: ticks the cut body stays held together, shaking and spraying, before
## the halves fall apart (0 = they leave at once).
var grind_ticks: int = 0
## Extra speed (m/s) for the hat alone, thrown off to one side of the shot (alternating kill by
## kill): the ray gun knocks the cap off the dust heap onto the bare street.
var hat_kick_mps: float = 0.0
## A split's cut edge: raw (red), hot (cream, cauterised) or soul (teal-white, Kerf's beam);
## empty = by the row's spray (none = hot).
var edge: StringName = &""


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
	k.spray_cone_deg = _num(t, d, "spray_cone_deg", 0.0)
	k.stand_ticks = roundi(_num(t, d, "stand_ticks", 0.0))
	k.crumble_ticks = roundi(_num(t, d, "crumble_ticks", 0.0))
	k.ash_m = _num(t, d, "ash_m", 0.0)
	k.cut_deg = _num(t, d, "cut_deg", 0.0)
	k.grind_ticks = roundi(_num(t, d, "grind_ticks", 0.0))
	k.hat_kick_mps = _num(t, d, "hat_kick_mps", 0.0)
	k.edge = StringName(str(d.get("edge", "")))
	return k


## True when the row throws the whole body (blowback) instead of gib parts.
func whole_body() -> bool:
	return pieces.has(BODY)


static func _num(t: DataTable, d: Dictionary, key: String, fallback: float) -> float:
	return t.num(d, key) if d.has(key) else fallback

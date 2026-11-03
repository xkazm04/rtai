class_name BodyPlan
extends RefCounted
## One character's cutout body plan, in PART PIXELS (1 part px = 0.1 world px; 32 world px = 1 m).
## +x = forward, +y = the character's right. Per-side values are indexed L = 0, R = 1.
## Ported from the spike's CharDefs dictionaries (gtai-spike evolve/project/game/chardefs.gd).

enum Kind { RIVET, COP, PED }

const L: int = 0
const R: int = 1

var kind: Kind = Kind.RIVET
var name: String = ""
var art_dir: String = ""
var size_k: float = 1.0

var torso_part: String = "torso"
var torso_pos: Vector2 = Vector2.ZERO
var torso_z: int = 6
## The torso's print palette swap (print_part.gdshader `swap`; -1 = none).
var torso_swap: int = -1
var head_part: String = "head"
var head_pos: Vector2 = Vector2.ZERO
var head_z: int = 12
var head_swap: int = -1
var pelvis_part: String = "pelvis"
var pelvis_pos: Vector2 = Vector2.ZERO
var pelvis_z: int = 4
var collar_part: String = ""
var collar_pos: Vector2 = Vector2.ZERO
var collar_z: int = 7

var hip_y: float = 0.0
var hip_z: float = 0.0
var thigh_part: PackedStringArray = PackedStringArray(["thigh", "thigh"])
var thigh_len: float = 0.0
var thigh_draw: float = 0.0
var shin_part: PackedStringArray = PackedStringArray(["shin", "shin"])
var shin_len: float = 0.0
var shin_draw: float = 0.0
var foot_part: PackedStringArray = PackedStringArray(["foot_flat", "foot_flat"])
var foot_toeoff: PackedStringArray = PackedStringArray()
var foot_fwd: float = 0.0
var z_foot: int = 1
var z_shin: int = 2
var z_thigh: int = 3

var shoulder: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
var upper_part: PackedStringArray = PackedStringArray(["upperarm", "upperarm"])
var upper_len: float = 0.0
var upper_draw: float = 0.0
var fore_part: PackedStringArray = PackedStringArray(["forearm", "forearm"])
var fore_len: PackedFloat32Array = PackedFloat32Array([0.0, 0.0])
var fore_draw: PackedFloat32Array = PackedFloat32Array([0.0, 0.0])
var endon_below: float = 0.45
var endon_upper_len: float = 0.0
var endon_fore_len: float = 0.0
var endon_upper: PackedStringArray = PackedStringArray()
var endon_fore: PackedStringArray = PackedStringArray()
var endon_round: bool = false
var hand_ready: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
var hand_relax: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
var arm_above: int = 10
var arm_below: int = 5

## Rivet's left hand is a clamp claw with three cells; empty = no hand part.
var hand_open: String = ""
var hand_closed: String = ""
var hand_pistol: String = ""
var hand_gap: float = 2.0
## The hand cell's scale (RivetPlan's proportions: T2's claw is smaller than the day's art).
var hand_k: float = 1.0
## The arm segments' drawn thickness (scale across the bone; the hand cell is not thinned).
var arm_w: float = 1.0
var gun_arm: int = -1
var gun_cell: String = ""
var melee_arm: int = L
var shield_part: String = ""
var shield_pos: Vector2 = Vector2.ZERO

var hose_tex: String = ""
var hose_from: Vector2 = Vector2.ZERO
var hose_along: float = 0.25
var hose_n: int = 9
var hose_width: float = 34.0
var hose_bulge: float = 260.0

var ready_stance: bool = true
var gait_scale: float = 1.0
## Twin-stick hips (RigHips): 0 = the hips stay on the facing; 1 = they turn to the walk.
var hip_follow: float = 0.0
var hip_twist_max: float = deg_to_rad(70.0)
## Rivet's cream rods print as one flat value at gameplay scale; flat bold human limbs do not.
var limb_lod: bool = true


func has_collar() -> bool:
	return collar_part != ""


func has_hand() -> bool:
	return hand_open != ""


func has_hose() -> bool:
	return hose_tex != ""


func has_endon() -> bool:
	return not endon_upper.is_empty()


func has_toeoff() -> bool:
	return not foot_toeoff.is_empty()


func side_sign(side: int) -> float:
	return -1.0 if side == L else 1.0

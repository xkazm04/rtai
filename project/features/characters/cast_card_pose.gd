class_name CastCardPose
extends RefCounted
## A fighter's render sample. A full rig uses its own gait and reactions. An off-pool card keeps
## the same loadout and uses distance travelled and the fighter's last damaging tick.

const META: StringName = &"cast_card_pose"
## The single shot tick has its own drawing. Hold recovery briefly as he starts relocating.
const RECOVERY_TICKS: int = 6

var actor_id: int
var sheets: CastCards.Sheets
var attack: int = -1
var hit_hold: float = 0.0
var death_length: float = 0.3
var opens_on_hit: bool = true
var walked: float = 0.0
var previous: Vector2 = Vector2.INF


static func attack_frame(tell_left: int, lock_ticks: int, shot_age: int) -> int:
	if tell_left > 0:
		return 1 if tell_left <= lock_ticks else 0
	if shot_age == 0:
		return 2
	if shot_age > 0 and shot_age <= RECOVERY_TICKS:
		return 3
	return -1


func travel(to: Vector2) -> void:
	if previous.is_finite():
		walked += previous.distance_to(to)
	previous = to


func bind(rig: CutRig) -> bool:
	if rig.head_card == null or of(rig) == self:
		return false
	rig.head_card.set_meta(META, self)
	return true


static func of(rig: CutRig) -> CastCardPose:
	var card: Sprite2D = rig.head_card
	if card == null or not card.has_meta(META):
		return null
	var pose: CastCardPose = card.get_meta(META)
	return pose if pose.actor_id == rig.actor_id else null


static func strip(rig: CutRig) -> String:
	var pose: CastCardPose = of(rig)
	return pose.path_for(rig) if pose != null else StreetWalkerCards.strip_of(rig)


func path_for(rig: CutRig) -> String:
	if rig.react != null and rig.react.active():
		if not StreetWalkerHit.grid_of(rig, "cop/head_swat").is_empty():
			return sheets.hit
	if StreetWalkerFall.down(rig):
		return sheets.fall
	return sheets.attack if attack >= 0 else sheets.walk


static func row(rig: CutRig, stride: int) -> int:
	var pose: CastCardPose = of(rig)
	return pose.attack if pose != null and pose.attack >= 0 else stride


static func rest_row(rig: CutRig) -> String:
	var pose: CastCardPose = of(rig)
	return "" if pose != null else StreetWalkerCards.row_of(rig)

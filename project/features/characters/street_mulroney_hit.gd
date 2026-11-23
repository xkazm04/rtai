class_name StreetMulroneyHit
extends RefCounted
## The flat boot's bottom outline band in each shipped hit cell. The 70-degree
## rear view lifts its right boot towards the camera, below the planted left shoe.
const HIT: String = "sergeant_mulroney_hit.png"
const SOLE70: Array[Vector2] = [
	Vector2(89, 188.5),
	Vector2(91.5, 188.5),
	Vector2(89, 188.5),
	Vector2(93, 188.5),
	Vector2(90.5, 179.5)
]
const SOLE55: Array[Vector2] = [
	Vector2(87.5, 188.5),
	Vector2(88.5, 188.5),
	Vector2(87.5, 188.5),
	Vector2(86.5, 188.5),
	Vector2(87, 188.5)
]


static func living(rig: CutRig) -> bool:
	if rig.react == null or rig.react.dying or rig.dead:
		return false
	var pose: CastCardPose = CastCardPose.of(rig)
	return pose != null and pose.sheets.hit.get_file() == HIT


static func anchor(card: Sprite2D) -> void:
	var low: bool = card.texture.resource_path.get_base_dir().get_file() == "p55"
	var sole: Vector2 = SOLE55[card.frame_coords.x] if low else SOLE70[card.frame_coords.x]
	if card.flip_h:
		sole.x = card.texture.get_width() / float(card.hframes) - sole.x
	card.offset = -sole

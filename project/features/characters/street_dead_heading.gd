class_name StreetDeadHeading
extends RefCounted
## n10 world (the owner's note: "we cannot allow falling into any direction"): a corpse's head only
## ever lies along one of a few screen headings, picked by the blow's screen direction, never the
## plan pose turned to any angle; no head points at the camera (the face upside down). Pose E (head
## right in its cell) only lies across the screen, unrotated, mirrored for its side. The pose's own
## silhouette lies under it as a contact shadow. View only. ENABLED false = n9's free turn.
const ENABLED: bool = true
## The blow's screen octant (0 right, 1 down-right, 2 down, 3 down-left, 4 left, 5 up-left, 6 up,
## 7 up-right) -> the head's screen heading in degrees. The three toward-camera octants turn away.
const HEAD_DEG: PackedFloat32Array = [0.0, 0.0, -90.0, 180.0, 180.0, -135.0, -90.0, -45.0]
## Poses B and D (odd) lie on these instead: neighbours never share a pose (StreetDeadPlan.pick), so
## a group shot from one side does not lie in one row. Equal to HEAD_DEG = one heading per blow.
const HEAD_DEG_ODD: PackedFloat32Array = [-45.0, -45.0, -135.0, -135.0, -135.0, -90.0, -45.0, -90.0]
const ACROSS_POSE: int = 4
## n9's free turn off the blow (rad, the person's hash), when ENABLED is false.
const JITTER_RAD: float = 0.4
const SHADOW_NODE: String = "DeadShadow"
const SHADOW_M: float = 0.12
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.45)  # ChunkView.SHADOW


## The blow's octant on the screen (the ground squashed by the view's pitch).
static func octant(blow: Vector2) -> int:
	var screen: Vector2 = Vector2(blow.x, blow.y * ViewMode.shared().ground_k())
	return posmod(roundi(screen.angle() / (PI * 0.25)), HEAD_DEG.size())


## The unit direction the head lies in, on the ground (a vertical blow: `hash_flip` picks the side
## of a pose that only lies across).
static func head_of(blow: Vector2, pose: int, hash_flip: bool) -> Vector2:
	if not ENABLED:
		return blow
	if pose == ACROSS_POSE:
		var right: bool = blow.x > 0.0 if absf(blow.x) > 0.001 else hash_flip
		return Vector2.RIGHT if right else Vector2.LEFT
	var table: PackedFloat32Array = HEAD_DEG_ODD if pose % 2 == 1 else HEAD_DEG
	return Vector2.from_angle(deg_to_rad(table[octant(blow)]))


## Whether the cell draws mirrored: the across pose by its side, the others by the person's hash.
static func flipped(head: Vector2, pose: int, hash_flip: bool) -> bool:
	return head.x < 0.0 if ENABLED and pose == ACROSS_POSE else hash_flip


## The cell's rotation that lays pose `pose` (mirrored by `flip`) with its head along `head`.
static func angle_of(head: Vector2, pose: int, flip: bool) -> float:
	var cell: float = StreetDeadPlan.HEAD_ANGLE[pose]
	return head.angle() - (PI - cell if flip else cell)


## The person's turn off the heading (rad): none in the drawn set, n9's jitter when off.
static func jitter(actor_hash: int) -> float:
	if ENABLED:
		return 0.0
	return JITTER_RAD * (float(posmod(actor_hash >> 4, 1001)) / 500.0 - 1.0)


## How far the contact shadow lies from the body (px, down the sun's ground direction).
static func shadow_off(px_per_m: float) -> Vector2:
	return ViewMode.shared().cast_dir() * SHADOW_M * px_per_m if ENABLED else Vector2.ZERO


## Lays the pose's silhouette under `plan` (`card`'s lying sprite), shifted by shadow_off.
static func shade(card: Sprite2D, plan: Sprite2D) -> void:
	if not ENABLED:
		return
	var sh: Sprite2D = card.get_node_or_null(SHADOW_NODE) as Sprite2D
	if sh == null:
		sh = Sprite2D.new()
		sh.name = SHADOW_NODE
		sh.hframes = plan.hframes
		sh.modulate = SHADOW
		card.add_child(sh)
		card.move_child(sh, plan.get_index())
	sh.texture = plan.texture
	sh.frame = plan.frame
	sh.flip_h = plan.flip_h
	var t: Transform2D = plan.global_transform
	t.origin += shadow_off(CharacterRigs.PX_PER_M)
	sh.global_transform = t


## Removes the contact shadow from `card`.
static func unshade(card: Sprite2D) -> void:
	var sh: Node = card.get_node_or_null(SHADOW_NODE)
	if sh != null:
		card.remove_child(sh)
		sh.queue_free()

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
## The body's near side, the height of it a 70-degree camera sees below the drawn pose (m), as the
## same silhouette in shade; 0 = none. A plan pose has no side of its own to show.
const SIDE_NODE: String = "DeadSide"
const SIDE_M: float = 0.16
const SIDE_TINT: Color = Color(0.36, 0.32, 0.36, 1.0)


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


## The share of the slide still to go at the death family's progress p (1 at the lying frame).
static func fall_left(p: float) -> float:
	var t0: float = StreetWalkerFall.FALL_AT[StreetWalkerFall.FALL_FRAMES - 1]
	var t: float = clampf((p - t0) / maxf(StreetDeadPlan.SLIDE_END - t0, 0.001), 0.0, 1.0)
	return (1.0 - t) * (1.0 - t)


## The landing's rock back (rad) at progress p.
static func settle(p: float) -> float:
	var a: float = StreetDeadPlan.SLIDE_END
	var u: float = clampf((p - a) / (StreetDeadPlan.SETTLE_END - a), 0.0, 1.0)
	return StreetDeadPlan.SETTLE_RAD * sin(PI * u) * (1.0 - u)


## Where the body drawn at `centre` lies with `left` of its fall to go: eased off its neighbours
## (StreetQuestDeadPush, n10: the riot's near bodies as Dock 9's), never into a wall.
static func resting(actor: int, centre: Vector2, left: float) -> Vector2:
	var push: Vector2 = StreetQuestDeadPush.push_of(
		actor, centre, CharacterRigs.PX_PER_M, StreetDeadPlan.solid
	)
	return centre + push * (1.0 - left)


## How far the contact shadow lies from the body (px, down the sun's ground direction).
static func shadow_off(px_per_m: float) -> Vector2:
	return ViewMode.shared().cast_dir() * SHADOW_M * px_per_m if ENABLED else Vector2.ZERO


## The near side's offset below the pose (px): the pose's height on the ground, as the view lifts.
static func side_off(px_per_m: float) -> Vector2:
	var world: Vector2 = -ViewMode.shared().lift_px(SIDE_M)
	return world * px_per_m / SimConst.PX_PER_M if ENABLED else Vector2.ZERO


## Lays the pose's silhouette under `plan` (`card`'s lying sprite): the shadow, then the near side
## (`with_side` false: art drawn for this camera has its own).
static func shade(card: Sprite2D, plan: Sprite2D, with_side: bool = true) -> void:
	if not ENABLED:
		return
	_under(card, plan, SHADOW_NODE, SHADOW).global_transform = _moved(
		plan, shadow_off(CharacterRigs.PX_PER_M)
	)
	if not with_side:
		return
	_under(card, plan, SIDE_NODE, SIDE_TINT).global_transform = _moved(
		plan, side_off(CharacterRigs.PX_PER_M)
	)


## The contact shadow and the near side off `card`.
static func unshade(card: Sprite2D) -> void:
	for node: String in [SHADOW_NODE, SIDE_NODE]:
		var sh: Node = card.get_node_or_null(node)
		if sh != null:
			card.remove_child(sh)
			sh.queue_free()


static func _moved(plan: Sprite2D, by: Vector2) -> Transform2D:
	var t: Transform2D = plan.global_transform
	t.origin += by
	return t


## `card`'s child `node_name`, drawn just under `plan` in `tint`, showing plan's cell.
static func _under(card: Sprite2D, plan: Sprite2D, node_name: String, tint: Color) -> Sprite2D:
	var sh: Sprite2D = card.get_node_or_null(node_name) as Sprite2D
	if sh == null:
		sh = Sprite2D.new()
		sh.name = node_name
		sh.modulate = tint
		card.add_child(sh)
		card.move_child(sh, plan.get_index())
	sh.frame = 0
	sh.hframes = plan.hframes
	sh.vframes = plan.vframes
	sh.texture = plan.texture
	sh.frame = plan.frame
	sh.flip_h = plan.flip_h
	return sh

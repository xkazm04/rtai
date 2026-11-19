class_name PropLying
extends RefCounted
## A fallen rig can reach a tall prop with its shoulders, weapon or lying card even when its
## feet and head socket are clear. PropOcclusion uses their bounds to decide which props to redraw.

## false: a corpse is boxed as standing again (n8's look; for a before/after).
const ON: bool = true
## Half a lying body's width (m) round its ground-to-head line, the shoulders and a held weapon.
const HALF_W_M: float = 0.45


## The part of `rig`'s screen box inside a prop's drawn `area` (po's local px): a standing body's
## feet-to-head box (PropOcclusion.body_patch), a dead one's lying box.
static func patch(po: Node2D, rig: CutRig, feet: Vector2, head: Vector2, area: Rect2) -> Rect2:
	if not ON or not rig.dead or rig.head == null:
		return PropOcclusion.body_patch(feet, head, area)
	var box: Rect2 = lying_box(feet, po.to_local(rig.head.global_position))
	if rig.head_card != null:
		var card: Sprite2D = rig.head_card.get_node_or_null(StreetDeadPlan.NODE) as Sprite2D
		if card != null and card.texture != null and card.is_visible_in_tree():
			var to_prop: Transform2D = po.global_transform.affine_inverse() * card.global_transform
			box = box.merge(to_prop * card.get_rect())
	return box.intersection(area)


## A lying body's box (local px) from its ground point to its head socket.
static func lying_box(feet: Vector2, head: Vector2) -> Rect2:
	var pad: float = HALF_W_M * Ink.PX_PER_M + Ink.LINE_PX
	return Rect2(feet, Vector2.ZERO).expand(head).grow(pad)

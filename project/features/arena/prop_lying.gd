class_name PropLying
extends RefCounted
## A corpse behind one of the arena's tall props (d9 seams item 1). In the city block at tilt70
## (seed 5, tick 900, 32 px/m) two dead cops lying just north of the kerb barrier drew their heads
## over its top: PropOcclusion took every body as standing (a feet-to-head box rising up the
## screen), and a body fallen south reaches down the screen instead, onto the barrier. A dead rig's
## box is the line from its ground point to its head as drawn, grown by half a body's width, so
## PropOcclusion redraws the prop over the part inside its drawn area (no silhouette: the dead).
## (The n8 notes blamed the crowd atlas: hiding the dead rigs at tick 880 emptied the frame.)

## false: a corpse is boxed as standing again (n8's look; for a before/after).
const ON: bool = true
## Half a lying body's width (m) round its ground-to-head line, the shoulders and a held weapon.
const HALF_W_M: float = 0.45


## The part of `rig`'s screen box inside a prop's drawn `area` (po's local px): a standing body's
## feet-to-head box (PropOcclusion.body_patch), a dead one's lying box.
static func patch(po: Node2D, rig: CutRig, feet: Vector2, head: Vector2, area: Rect2) -> Rect2:
	if not ON or not rig.dead or rig.head == null:
		return PropOcclusion.body_patch(feet, head, area)
	return lying_box(feet, po.to_local(rig.head.global_position)).intersection(area)


## A lying body's box (local px) from its ground point to its drawn head.
static func lying_box(feet: Vector2, head: Vector2) -> Rect2:
	var pad: float = HALF_W_M * Ink.PX_PER_M + Ink.LINE_PX
	return Rect2(feet, Vector2.ZERO).expand(head).grow(pad)

class_name RigDepthBox
extends RefCounted
## n15 combat (city film t642-654: a cop 1.75 m north of Rivet drew over his head): the overlap
## box RigDepthSort gives one rig. Rivet's drawn figure is x1.5 (the owner's visual-only size), so
## his box is RIVET_W_K wider, and every box is at least as tall as the rig's drawn card: a body's
## head reaches up over what stands behind it as far as it is drawn, not as far as a 1.8 m man.

const RIVET_W_K: float = 1.5


## Half the box width (global px) for `rig`; `w` = the plain body box width.
static func half(rig: CutRig, w: float) -> float:
	var rivet: bool = rig.head_card != null and rig.head_card.has_meta(RivetFrames.ON)
	return w * 0.5 * (RIVET_W_K if rivet else 1.0)


## The box height (global px) for `rig`; `h` = the plain body box height.
static func tall(rig: CutRig, h: float) -> float:
	return maxf(h, card_tall(rig))


## How far (global px) a rig's drawn card reaches above its foot; 0 with no visible card.
static func card_tall(rig: CutRig) -> float:
	var c: Sprite2D = rig.head_card
	if c == null or not c.is_visible_in_tree() or c.texture == null:
		return 0.0
	var r: Rect2 = c.get_global_transform() * c.get_rect()
	return maxf(rig.global_position.y - r.position.y, 0.0)

class_name GibCardCut
extends RefCounted
## n15 combat (n11 REPORT: "the rocket gib flies as one tumbling body at combo"): under a card
## view a victim is one drawn card and its rig parts are hidden, so GibCut's copy of the visible
## sprites put the whole figure in one group and the other five flew empty. A card is cut instead
## into six regions of its own frame (SignatureKill.PIECE_IDS 0-5): the head band, the torso, the
## torso band's outer strips as the arms, the lower band's halves as the legs; each piece sits
## where it was drawn, so the blast's first frame is still the figure. Render only, no RNG.
## `--gib-card=whole` = the before (the card in one group).

## Band edges as shares of the card cell's height (the figure fills the cell, feet on its floor).
const HEAD_V: float = 0.3
const LEG_V: float = 0.62
## Each arm strip's share of the cell width (the figure's middle is its torso).
const ARM_U: float = 0.3
## Per piece 0-5 (SignatureKill.PIECE_IDS order): u0, v0, u1, v1 in the frame's own shares
## (unflipped), CUT_STRIDE values each.
const CUTS: PackedFloat32Array = [
	0.0,
	0.0,
	1.0,
	HEAD_V,
	ARM_U,
	HEAD_V,
	1.0 - ARM_U,
	LEG_V,
	0.0,
	HEAD_V,
	ARM_U,
	LEG_V,
	1.0 - ARM_U,
	HEAD_V,
	1.0,
	LEG_V,
	0.0,
	LEG_V,
	0.5,
	1.0,
	0.5,
	LEG_V,
	1.0,
	1.0,
]
const CUT_STRIDE: int = 4

static var _whole: int = -1


## True when `spr` is `rig`'s drawn whole-figure card standing in for its hidden parts.
static func cuts(rig: CutRig, spr: Sprite2D) -> bool:
	if _whole < 0:
		_whole = 1 if ArenaArgs.parse().text("--gib-card") == "whole" else 0
	if _whole == 1 or spr != rig.head_card or rig.sides.is_empty():
		return false
	var thigh: Sprite2D = rig.sides[0].thigh
	return thigh == null or not thigh.is_visible_in_tree()


## When `spr` is the card (cuts): its six region copies into `groups` (by piece), each at its
## own centre from `xf` (the card's, in the rig parent's px, origin relative to the rig); true.
static func placed(rig: CutRig, groups: Array[Node2D], spr: Sprite2D, xf: Transform2D) -> bool:
	if not cuts(rig, spr):
		return false
	for kp: Array in split(spr, xf):
		var piece: Sprite2D = kp[1]
		piece.z_index = GibCut._z(spr, rig)
		groups[kp[0]].add_child(piece)
	return true


## A group's centre for GibCut: its parts' mean origin (`sum` / `count`), else (card pieces
## only) its first piece's position.
static func centre(group: Node2D, sum: Vector2, count: int) -> Vector2:
	if count > 0:
		return sum / float(count)
	var first: Node2D = group.get_child(0) as Node2D if group.get_child_count() > 0 else null
	return first.position if first != null else Vector2.ZERO


## The card's six region copies: [piece index, Sprite2D], each transform set from `xf` to the
## region's own centre.
static func split(spr: Sprite2D, xf: Transform2D) -> Array:
	var cell: Vector2 = _cell(spr)
	var base: Vector2 = _frame_origin(spr, cell)
	var tl: Vector2 = spr.offset - (cell * 0.5 if spr.centered else Vector2.ZERO)
	var out: Array = []
	for k: int in CUTS.size() / CUT_STRIDE:
		var c: PackedFloat32Array = CUTS.slice(k * CUT_STRIDE, (k + 1) * CUT_STRIDE)
		var at: Vector2 = Vector2(c[0], c[1]) * cell
		var size: Vector2 = (Vector2(c[2], c[3]) - Vector2(c[0], c[1])) * cell
		var px: float = cell.x - at.x - size.x if spr.flip_h else at.x
		var piece: Sprite2D = GibCut._copy(spr)
		piece.hframes = 1
		piece.vframes = 1
		piece.frame = 0
		piece.region_enabled = true
		piece.region_rect = Rect2(base + at, size)
		piece.centered = true
		piece.offset = Vector2.ZERO
		piece.transform = xf * Transform2D(0.0, tl + Vector2(px, at.y) + size * 0.5)
		out.append([k, piece])
	return out


static func _cell(spr: Sprite2D) -> Vector2:
	var area: Vector2 = spr.region_rect.size if spr.region_enabled else spr.texture.get_size()
	return area / Vector2(maxi(1, spr.hframes), maxi(1, spr.vframes))


static func _frame_origin(spr: Sprite2D, cell: Vector2) -> Vector2:
	var start: Vector2 = spr.region_rect.position if spr.region_enabled else Vector2.ZERO
	var h: int = maxi(1, spr.hframes)
	return start + Vector2(spr.frame % h, spr.frame / h) * cell

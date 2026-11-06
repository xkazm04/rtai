class_name RigHeadCard
extends RefCounted
## View lab (docs/view-lab/PLAN.md): the upright facing card. Under a tilted --view whose row has
## `cards` (data/tables/view.json), a rig with a card strip (CARDS, by art_dir) draws its head and
## collar as one upright card drawn for the raised camera instead of the top-down head disc: the
## face reads. 5 facings drawn (front, front three-quarter, side, back three-quarter, back, all
## turned to screen right), the left 3 mirrored; picked by the head's look octant on screen.
## The card stands upright (no rotation) and undoes the camera's ground squash, so its art keeps
## its drawn aspect; it anchors on the collar ring. Rotation stays free for the rest of the rig.
## Render only. Straight down (or a row without cards) nothing here runs: bit-identical.

## art_dir -> [strip, anchor y (fraction of the card height from the top where the anchor sits),
## width over the anchor part's width, bust (the card covers the chest too: the torso hides),
## raw (the strip is pre-printed by tools/art/cut_facings.py --snap: gold would print vermilion)].
## Rivet anchors on his collar ring, King's bust on his torso.
const CARDS: Dictionary[String, Array] = {
	"rivet": ["res://features/characters/art/view/rivet_head_card.png", 0.86, 1.0, false, true],
	"king": ["res://features/characters/art/view/king_bust_card.png", 0.80, 2.4, true, true],
}
const FRAMES: int = 5
## Card frame and mirror per screen octant of the look (0 = screen right, +1 = 45 deg clockwise,
## toward the camera; the camera sits south, so octant 2 is the face).
const OCT_FRAME: PackedInt32Array = [2, 1, 0, 1, 2, 3, 4, 3]
const OCT_FLIP: PackedByteArray = [0, 0, 0, 1, 1, 1, 0, 0]
static var _tex: Dictionary[String, Texture2D] = {}


## Each pose step under a tilt (CutRig.drive): build the card once, then face and place it.
static func step(rig: CutRig) -> void:
	if rig.head_card == null:
		if not ViewMode.shared().cards or not CARDS.has(rig.plan.art_dir):
			return
		_build(rig)
	_place(rig)


static func frame_of(look: float) -> Vector2i:
	var o: int = posmod(roundi(look / (PI * 0.25)), 8)
	return Vector2i(OCT_FRAME[o], OCT_FLIP[o])


static func _build(rig: CutRig) -> void:
	var row: Array = CARDS[rig.plan.art_dir]
	var path: String = row[0]
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	var card: Sprite2D = Sprite2D.new()
	card.name = &"head_card"
	card.texture = _tex[path]
	card.hframes = FRAMES
	card.centered = false
	var cell: Vector2 = Vector2(card.texture.get_width() / float(FRAMES), card.texture.get_height())
	var anchor_y: float = row[1]
	card.offset = Vector2(-cell.x * 0.5, -cell.y * anchor_y)
	if row[4] != true:
		card.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, false, 0)
	card.z_index = rig.plan.head_z
	rig.head.add_child(card)
	rig.head_card = card
	_hide(rig.head, rig.head_spr)
	if row[3] == true:
		_hide(rig.torso, rig.torso_spr)
	if rig.collar_spr != null:
		rig.collar_spr.visible = false


## Hides a body part and its readability halo (a HALO sibling under the same node).
static func _hide(node: Node2D, spr: Sprite2D) -> void:
	spr.visible = false
	for c: Node in node.get_children():
		if c.name == RigBuild.HALO and c is CanvasItem:
			(c as CanvasItem).visible = false


static func _place(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	var src: Sprite2D = _anchor(rig)
	var at: Vector2 = src.global_position
	var k: float = CARDS[rig.plan.art_dir][2]
	var w_world: float = src.texture.get_width() * absf(src.global_scale.x) * k
	var f: Vector2i = frame_of(rig.head.global_rotation)
	card.frame = f.x
	card.flip_h = f.y == 1
	var s: float = w_world / (card.texture.get_width() / float(FRAMES))
	card.global_rotation = 0.0
	card.global_scale = Vector2(s, s / ViewMode.shared().ground_k())
	card.global_position = at


## The part the card stands on and spans: the collar ring, else the torso (a bust card).
static func _anchor(rig: CutRig) -> Sprite2D:
	return rig.collar_spr if rig.collar_spr != null else rig.torso_spr

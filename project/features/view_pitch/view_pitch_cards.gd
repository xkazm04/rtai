class_name ViewPitchCards
extends RefCounted
## Lane d8-view70: the facing cards drawn from a view row's `art` folder (p70). Until RigHeadCard
## resolves a row's `art` itself (REQUEST to lane chars, JOURNAL), each live card (RigHeadCard's
## `head_card`, built from the base 55 strip) gets an overlay child drawing the folder's strip:
## same frame and mirror, the same height in the card's pixels (so a wider 70 bust stays as tall
## as the 55 one; RigHeadCard sizes a card by its cell width), anchored at the base card's anchor
## fraction, and the parent's material (the hit flash). `mix` cross-fades the two: 0 = the base
## card only, 1 = the folder's only (the card's own texture drawn invisible through self_modulate).
## Render only; straight down no card is ever built, so nothing here runs.

const OVERLAY: StringName = &"pitch_art"
## Per card file: the overlay's scale over the base card's height (1 = equally tall).
const SCALE: Dictionary[String, float] = {"king_bust_card.png": 1.0, "rivet_head_card.png": 1.0}

static var _tex: Dictionary[String, Texture2D] = {}


## Every card under `root` drawn from the folder `folder` mixed in by `mix` (0..1).
static func apply(root: Node, folder: String, mix: float) -> void:
	if root == null:
		return
	for n: Node in root.find_children("head_card", "Sprite2D", true, false):
		dress(n as Sprite2D, folder, mix)


## One card: its overlay (built once; none when the folder has no such strip) faced as the card.
static func dress(card: Sprite2D, folder: String, mix: float) -> void:
	var o: Sprite2D = card.get_node_or_null(NodePath(String(OVERLAY))) as Sprite2D
	if o == null:
		var tex: Texture2D = _strip(card.texture, folder)
		if tex == null:
			return
		o = _build(card, tex)
	o.frame = card.frame
	o.flip_h = card.flip_h
	o.modulate.a = mix
	o.visible = mix > 0.0
	card.self_modulate.a = 1.0 - mix


static func _build(card: Sprite2D, tex: Texture2D) -> Sprite2D:
	var o: Sprite2D = Sprite2D.new()
	o.name = OVERLAY
	o.texture = tex
	o.hframes = RigHeadCard.FRAMES
	o.centered = false
	o.use_parent_material = true
	var frac: float = -card.offset.y / maxf(card.texture.get_height(), 1.0)
	var s: float = SCALE.get(card.texture.resource_path.get_file(), 1.0)
	s *= card.texture.get_height() / float(tex.get_height())
	o.scale = Vector2(s, s)
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	o.offset = Vector2(-cell.x * 0.5, -cell.y * frac)
	card.add_child(o)
	return o


## The folder's strip for the base card texture `base`, or null (no folder, no such strip).
static func _strip(base: Texture2D, folder: String) -> Texture2D:
	if base == null or folder.is_empty():
		return null
	var path: String = ViewPitch.card_path(base.resource_path, folder)
	if path == base.resource_path:
		return null
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	return _tex[path]

class_name ViewPitchCards
extends RefCounted
## Lane d8-view70: the combined view's card cross-fade. RigHeadCard builds every card from the
## art folder ViewMode.art names (rows_of: p70 above the swap pitch, p55 below); inside the fade
## window each live card (`head_card`) gets an overlay child drawing the OTHER folder's strip of
## the same card row: same frame and mirror, anchored on the same point (the card's origin, the
## collar or torso), sized by that row's own width as RigHeadCard would draw it, and the
## parent's material (the hit flash). `other_a` is the overlay's alpha: the card itself draws at
## 1 - other_a (self_modulate), so the two cross-fade. The other folder is picked per card from
## the art it was built under, so a card not yet rebuilt after a swap still fades right. Render
## only; straight down no card is ever built, so nothing here runs.

const OVERLAY: StringName = &"pitch_art"
## GhostCard's sprite (Tonnage): one strip per folder, the same width and anchor in every folder.
const GHOST: String = "ghost_card"

static var _tex: Dictionary[String, Texture2D] = {}


## Every card under `root` at the row's `mix` (ViewPitch.mix_at: 1 = all `art`, 0 = boss_art).
static func apply(root: Node, pitch: ViewPitch, mix: float) -> void:
	if root == null:
		return
	var cards: Array[Node] = root.find_children("head_card", "Sprite2D", true, false)
	cards.append_array(root.find_children(GHOST, "Sprite2D", true, false))
	for n: Node in cards:
		var card: Sprite2D = n as Sprite2D
		var built: String = art_of(card)
		var other: String = pitch.boss_art if built == pitch.art else pitch.art
		dress(card, other, mix if other == pitch.art else 1.0 - mix)


## One card: its overlay (built once per card and folder; none when the folder draws this card
## from the same strip) faced as the card.
static func dress(card: Sprite2D, other: String, other_a: float) -> void:
	var o: Sprite2D = card.get_node_or_null(NodePath(String(OVERLAY))) as Sprite2D
	if o != null and str(o.get_meta(&"art", "")) != other:
		o.free()
		o = null
	if o == null and other_a > 0.0:
		o = _build(card, other)
	if o == null:
		card.self_modulate.a = 1.0
		return
	o.frame = card.frame
	o.flip_h = card.flip_h
	o.modulate.a = other_a
	o.visible = other_a > 0.0
	card.self_modulate.a = 1.0 - other_a


## The art folder a card was built under: RigHeadCard's meta, else its strip's folder (GhostCard).
static func art_of(card: Sprite2D) -> String:
	if card.has_meta(&"art"):
		return str(card.get_meta(&"art"))
	if card.texture == null:
		return ""
	return card.texture.resource_path.get_base_dir().get_file()


## The card row (RigHeadCard.rows_of) drawing `path` under the folder `art`, or "".
static func key_of(path: String, art: String) -> String:
	var rows: Dictionary[String, Array] = RigHeadCard.rows_of(art)
	for key: String in rows:
		if str(rows[key][0]) == path:
			return key
	return ""


static func _build(card: Sprite2D, other: String) -> Sprite2D:
	if card.texture == null:
		return null
	if card.name == GHOST:
		return _build_ghost(card, other)
	var art: String = str(card.get_meta(&"art", ViewMode.shared().art))
	var key: String = key_of(card.texture.resource_path, art)
	var rows: Dictionary[String, Array] = RigHeadCard.rows_of(other)
	if key.is_empty() or not rows.has(key) or str(rows[key][0]) == card.texture.resource_path:
		return null
	var mine: Array = RigHeadCard.rows_of(art)[key]
	var row: Array = rows[key]
	var path: String = row[0]
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	var tex: Texture2D = _tex[path]
	var o: Sprite2D = _sprite(tex, other)
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	var mine_w: float = card.texture.get_width() / float(RigHeadCard.FRAMES)
	# RigHeadCard scales a card to (width k x anchor width) / cell width: the ratio of the two.
	var k: float = row[2]
	var k_mine: float = mine[2]
	var anchor: float = row[1]
	var s: float = (k / cell.x) / (k_mine / mine_w)
	o.scale = Vector2(s, s)
	o.offset = Vector2(-cell.x * 0.5, -cell.y * anchor)
	card.add_child(o)
	return o


## A ghost card's overlay: the other folder's strip of the same name, as wide and anchored alike.
static func _build_ghost(card: Sprite2D, other: String) -> Sprite2D:
	var mine: String = card.texture.resource_path
	var root: String = mine.get_base_dir().get_base_dir()
	var path: String = root.path_join(other).path_join(mine.get_file())
	if other.is_empty() or path == mine or not ResourceLoader.exists(path):
		return null
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	var tex: Texture2D = _tex[path]
	var o: Sprite2D = _sprite(tex, other)
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	var mine_w: float = card.texture.get_width() / float(RigHeadCard.FRAMES)
	var anchor: float = -card.offset.y / float(card.texture.get_height())
	o.scale = Vector2.ONE * (mine_w / cell.x)
	o.offset = Vector2(-cell.x * 0.5, -cell.y * anchor)
	card.add_child(o)
	return o


static func _sprite(tex: Texture2D, art: String) -> Sprite2D:
	var o: Sprite2D = Sprite2D.new()
	o.name = OVERLAY
	o.texture = tex
	o.hframes = RigHeadCard.FRAMES
	o.centered = false
	o.use_parent_material = true
	o.set_meta(&"art", art)
	return o

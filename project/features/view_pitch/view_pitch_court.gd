class_name ViewPitchCourt
extends RefCounted
## Lane d8-view70: the King's court strips (bosses' KingArt, art/p<pitch>/) under the combined
## view. KingArt dresses a card once, by the LIVE pitch rounded; under combo the cards are rebuilt
## at the swap pitch (62.5), where no court strip exists, so the boss fight at 55 would draw the
## shared strip. Here a folder ("p55") stands for its pitch: rows_of is RigHeadCard.rows_of with
## each court strip of that pitch in its card row (KingArt's anchor, the shared width times the
## court's width factor), and a card built under a court folder takes the court strip as
## KingArt._swap would. Render only; used by ViewPitchCards on combo rows and on rows drawing a
## strip that wears its own megaphone (OWN_HORN: then the rig's horn part hides, as KingArt does
## under a court strip, so the King at 70 shows one bell, not two).

## Card strips that draw the King's megaphone themselves (cut from the 70 sheet with the bell).
const OWN_HORN: Array[String] = ["res://features/characters/art/view/p70/king_bust_card.png"]


## The pitch a card folder was cut for ("p55" -> 55; 90 for none: no court strip).
static func pitch_of(art: String) -> float:
	if art.length() < 2 or not art.begins_with("p") or not art.substr(1).is_valid_int():
		return 90.0
	return float(art.substr(1))


## RigHeadCard.rows_of(art) with the court's strips for that folder's pitch in their rows.
static func rows_of(art: String) -> Dictionary[String, Array]:
	var rows: Dictionary[String, Array] = RigHeadCard.rows_of(art).duplicate()
	for key: String in KingArt.STRIPS:
		var row: Array = court_row(key, art)
		if not row.is_empty():
			rows[key] = row
	return rows


## [strip, anchor y, width over the anchor, bust, raw] of the court's card `key` under `art`, or [].
static func court_row(key: String, art: String) -> Array:
	var path: String = KingArt.strip_path(key, pitch_of(art))
	var base: Array = RigHeadCard.rows_of(art).get(key, [])
	if path.is_empty() or base.is_empty():
		return []
	var court: Array = KingArt.STRIPS[key]
	var base_k: float = base[2]
	var court_k: float = court[2]
	var anchor: float = court[1]
	return [path, anchor, base_k * court_k, base[3], base[4]]


## A card built under a court folder that still draws the shared strip takes the court strip,
## anchor and width (KingArt multiplies the card by its META each step); this frame's scale too.
static func dress(card: Sprite2D) -> void:
	if card.texture == null or card.name == ViewPitchCards.GHOST:
		return
	if OWN_HORN.has(card.texture.resource_path):
		_hide_horn(card)
	var art: String = str(card.get_meta(&"art", ""))
	for key: String in KingArt.STRIPS:
		var row: Array = court_row(key, art)
		if row.is_empty() or str(row[0]) == card.texture.resource_path:
			continue
		var base: Array = RigHeadCard.rows_of(art).get(key, [])
		if str(base[0]) != card.texture.resource_path:
			continue
		var width_k: float = KingArt.STRIPS[key][2]
		_swap(card, row, width_k)
		return


static func _swap(card: Sprite2D, row: Array, width_k: float) -> void:
	var tex: Texture2D = load(str(row[0])) as Texture2D
	var old_cell_w: float = card.texture.get_width() / float(RigHeadCard.FRAMES)
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	card.texture = tex
	var anchor: float = row[1]
	card.offset = Vector2(-cell.x * 0.5, -cell.y * anchor)
	var was: float = card.get_meta(KingArt.META, 1.0)
	card.scale *= old_cell_w / cell.x * width_k / was
	card.set_meta(KingArt.META, width_k)
	_hide_horn(card)


## A row whose art folder holds an OWN_HORN strip (p70): its cards need dressing even unblended.
static func dresses(art: String) -> bool:
	for path: String in OWN_HORN:
		if path.get_base_dir().get_file() == art:
			return true
	return false


static func _hide_horn(card: Sprite2D) -> void:
	var rig: Node = card.get_parent()
	while rig != null and not rig is CutRig:
		rig = rig.get_parent()
	if rig == null:
		return
	var horn: Node = rig.find_child(KingArt.HORN, true, false)
	if horn is CanvasItem and (horn as CanvasItem).visible:
		(horn as CanvasItem).visible = false

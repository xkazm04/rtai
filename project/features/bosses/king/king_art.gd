class_name KingArt
extends RefCounted
## d8 bosses: the King's court card art per view row (render only). A facing card is drawn for one
## camera pitch, so the court's strips live in art/p<pitch>/ (p55 for `tilt` today; a p70 strip sits
## beside it), picked by the active view row's pitch. After RigHeadCard builds a rig's card (the
## shared strip of features/characters/art/view/), the court's own strip for this pitch replaces its
## texture, anchor and width; a pitch with no strip keeps the shared card. Straight down (`top`) no
## card is built, so nothing here runs: the 90-degree game is untouched.

const DIR: String = "res://features/bosses/king/art/p%d/%s.png"
## The King's limb parts in the boss palette for a pitch (tools/art/king_parts_pitch.py: today's
## part boxes, so the pivots hold), drawn raw; a part with no file here keeps today's print.
const PARTS_DIR: String = "res://features/bosses/king/art/p%d/%s/%s.png"
## art_dir -> its part folder under art/p<pitch>/ (the King's limbs, the gang's bodies).
const PART_SETS: Dictionary[String, String] = {"king": "parts", "gang": "gang_parts"}
const COURT_ROOT: String = "res://features/bosses/king/art/"
## art_dir -> [strip name, anchor y (fraction of the cell height from the top), width over the
## shared card's width]. 5 facings as RigHeadCard.FRAMES (front .. back, turned right). The King's
## 1.5: the 55 sheet's bust is the boss's bulk (1.0 drew it a head narrower than his press arms);
## the gang 1.25 (1.0 drew the helmet narrower than the bodyguard's shoulders at 48 px/m).
const STRIPS: Dictionary[String, Array] = {
	"king": ["king_bust_card", 0.80, 2.0],  # owner d8: bigger than 1.5 (n8 picked 2.0 over 1.75)
	"gang": ["gang_head_card", 0.84, 1.25],
}
const META: StringName = &"court_card"
## The pitch a card was dressed for, and the shared strip it wore before (texture, offset): a live
## pitch change (view70's combined view eases 70 -> 55 into a boss fight) re-dresses the card.
const META_PITCH: StringName = &"court_pitch"
const META_SHARED: StringName = &"court_shared"
## d8 A/B: true = under a court strip the King's bust card wears his cape (its front facings show
## the cape's edges, its back facings the whole cape) and KingCape's drawn fan stands down; false =
## the drawn fan stays behind him (flat on the ground under the tilt: the it18 read).
const CARD_CAPE: bool = true
## The rig's shoulder megaphone part (KingRigs): the court card draws its own, so the part hides.
const HORN: StringName = &"horn"

static var _tex: Dictionary[String, Texture2D] = {}
static var _exists: Dictionary[String, bool] = {}
## A part texture's path -> the court's part for this view's pitch (null: none, keep the print).
static var _parts: Dictionary[String, Texture2D] = {}


## KingCape stands down: the King's court strip for this view wears the cape (CARD_CAPE).
static func card_wears_cape() -> bool:
	return CARD_CAPE and not strip_path("king", ViewMode.shared().art_pitch()).is_empty()


## The strip a rig's card draws at a pitch ("" = none: the shared card stays).
static func strip_path(art_dir: String, pitch_deg: float) -> String:
	if not STRIPS.has(art_dir) or pitch_deg >= 90.0:
		return ""
	var path: String = DIR % [roundi(pitch_deg), STRIPS[art_dir][0]]
	if not _exists.has(path):  # asked every frame by KingAccents: one lookup per strip
		_exists[path] = ResourceLoader.exists(path)
	return path if _exists[path] else ""


## After each drive step: dress a freshly built card (or one whose pitch moved) once, then rescale
## it by the strip's width.
static func dress(rig: CutRig) -> void:
	_dress_parts(rig)
	var card: Sprite2D = rig.head_card
	if card == null:
		return
	var pitch: int = roundi(ViewMode.shared().art_pitch())
	if not card.has_meta(META) or card.get_meta(META_PITCH) != pitch:
		if not card.has_meta(META_SHARED):
			card.set_meta(META_SHARED, [card.texture, card.offset])
		var fit: Vector2 = _swap(card, rig)
		card.scale *= fit.x  # this step was placed by the old strip's cell width
		card.set_meta(META, fit.y)
		card.set_meta(META_PITCH, pitch)
	var k: float = card.get_meta(META)
	if k != 1.0:
		card.scale *= k


## Swaps the card's strip; returns (the shared over the new cell width, for the step already
## placed; the strip's width factor from then on). ONE = untouched (no strip for this pitch).
static func _swap(card: Sprite2D, rig: CutRig) -> Vector2:
	var art_dir: String = rig.plan.art_dir
	var path: String = strip_path(art_dir, ViewMode.shared().art_pitch())
	var old_cell_w: float = card.texture.get_width() / float(RigHeadCard.FRAMES)
	var horn: Node = rig.find_child(HORN, true, false)
	if horn is CanvasItem:
		(horn as CanvasItem).visible = path.is_empty()
	if path.is_empty():  # no strip at this pitch: the shared card again (a no-op if never swapped)
		var shared: Array = card.get_meta(META_SHARED)
		card.texture = shared[0]
		card.offset = shared[1]
		return Vector2(old_cell_w / (card.texture.get_width() / float(RigHeadCard.FRAMES)), 1.0)
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	var tex: Texture2D = _tex[path]
	var row: Array = STRIPS[art_dir]
	var cell: Vector2 = Vector2(tex.get_width() / float(RigHeadCard.FRAMES), tex.get_height())
	card.texture = tex
	var anchor_y: float = row[1]
	card.offset = Vector2(-cell.x * 0.5, -cell.y * anchor_y)
	var width_k: float = row[2]  # RigHeadCard scales by the cell width: the drawn width holds
	return Vector2(old_cell_w / cell.x, width_k)


## The court's limbs: each step (the rig swaps end-on and toe-off textures as it moves), a part with
## a court texture for this pitch takes it, raw (no print material) unless the hit flash is lit.
static func _dress_parts(rig: CutRig) -> void:
	var set_dir: String = PART_SETS.get(rig.plan.art_dir, "")
	if set_dir.is_empty() or ViewMode.shared().art_pitch() >= 90.0:
		return
	var raw: bool = not rig.is_tinted()
	for spr: Sprite2D in rig.sprites:
		if spr.texture == null:
			continue
		var path: String = spr.texture.resource_path
		if not path.begins_with(COURT_ROOT):
			var court: Texture2D = _court_part(set_dir, path)
			if court == null:
				continue
			spr.texture = court
		if raw and spr.material != null:
			spr.material = null


## The court's part `name` for this view's pitch (null: none, or straight down).
static func part(name: String) -> Texture2D:
	if ViewMode.shared().art_pitch() >= 90.0:
		return null
	return _court_part(PART_SETS["king"], PartLibrary.ART_ROOT + "king/" + name + ".png")


static func _court_part(set_dir: String, path: String) -> Texture2D:
	var pitch: int = roundi(ViewMode.shared().art_pitch())  # a live pitch (view70's combo) re-asks
	var key: String = "%d:%s:%s" % [pitch, set_dir, path]
	if not _parts.has(key):
		var p: String = PARTS_DIR % [pitch, set_dir, path.get_file().get_basename()]
		_parts[key] = load(p) as Texture2D if ResourceLoader.exists(p) else null
	return _parts[key]

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

## art_dir -> [strip, anchor y (card height fraction from the top), width over the anchor part's,
## bust (covers the chest: the torso hides), raw (pre-printed: cut_facings.py --snap)].
const CARDS: Dictionary[String, Array] = {
	"rivet": ["res://features/characters/art/view/rivet_head_card.png", 0.86, 1.0, false, true],
	"king": ["res://features/characters/art/view/king_bust_card.png", 0.80, 2.4, true, true],
	"gang": ["res://features/characters/art/view/gang_head_card.png", 0.84, 1.4, false, true],
	"cop/head_cap":
	["res://features/characters/art/view/cop_head_card.png", 0.86, 1.15, false, false],
	"cop/head_helmet":
	["res://features/characters/art/view/cop_riot_card.png", 0.86, 1.2, false, false],
}
## Per view art (view.json `art`: "p55" cut from the 55-degree sheets, "p70" the 70): a file of the
## same name under ART_DIR/<art>/ swaps the strip; SET_CARDS[<art>] rows replace whole rows (an
## empty path keeps the strip, changes the rest). p55: Rivet's bust (rivet_bust.py), Dent's tan bust
## (ghost_card_tone.py; teal kept as dent_bust_card_teal.png), the street heads (street_head.py).
const ART_DIR: String = "res://features/characters/art/view/"
const SET_CARDS: Dictionary[String, Dictionary] = RigCardSets.SETS
const FRAMES: int = 5
## Card frame and mirror per screen octant of the look (0 = screen right, +1 = 45 deg clockwise,
## toward the camera; the camera sits south, so octant 2 is the face).
const OCT_FRAME: PackedInt32Array = [2, 1, 0, 1, 2, 3, 4, 3]
const OCT_FLIP: PackedByteArray = [0, 0, 0, 1, 1, 1, 0, 0]
static var _tex: Dictionary[String, Texture2D] = {}
static var _merged: Dictionary[String, Array] = {}
static var _merged_art: String = "-"


## Each pose step under a tilt (CutRig.drive): build the card once, then face and place it. A
## card built under other art (ViewMode.art changed live, the combined view) is rebuilt.
static func step(rig: CutRig) -> void:
	if rig.head_card != null and str(rig.head_card.get_meta(&"art", "")) != ViewMode.shared().art:
		drop(rig)
	if rig.head_card == null:
		if not ViewMode.shared().cards or _key(rig).is_empty():
			return
		_build(rig)
	_place(rig)


## The hit flash (CutRig.set_tint): a raw card takes the tinted part material while lit, then
## draws raw again; a printed card swaps between the plain and the tinted part material.
static func on_tint(rig: CutRig, on: bool) -> void:
	if rig.head_card == null:
		return
	var raw: bool = rows()[_key(rig)][4] == true
	var mat: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.PART, on, 0)
	rig.head_card.material = null if raw and not on else mat


## A variant swap (CutRig.apply_variant) or an art change drops the card; renamed first, so a card
## rebuilt this frame keeps the name `head_card`. The top-down parts draw until the next step.
static func drop(rig: CutRig) -> void:
	if rig.head_card == null:
		return
	rig.head_card.name = &"head_card_dropped"
	rig.head_card.queue_free()
	rig.head_card = null
	_hide(rig.head, rig.head_spr, true)
	_hide(rig.torso, rig.torso_spr, true)
	if rig.collar_spr != null:
		rig.collar_spr.visible = true


static func _key(rig: CutRig) -> String:
	var v: RigVariant = rig.variant
	return key_of(rig.plan, v.head if v != null and v.head != "" else rig.plan.head_part)


## The card row a head draws: "art_dir/head" (a head variant, e.g. the patrol cop's cap), else
## the art_dir (every head of the set), else "" (no card).
static func key_of(plan: BodyPlan, head: String) -> String:
	var all: Dictionary[String, Array] = rows()
	var k: String = "%s/%s" % [plan.art_dir, head]
	if all.has(k):
		return k
	return plan.art_dir if all.has(plan.art_dir) else ""


## The card rows this run's view draws now: CARDS under its art (rows_of).
static func rows() -> Dictionary[String, Array]:
	var want: String = ViewMode.shared().art
	if want != _merged_art:
		_merged = rows_of(want)
		_merged_art = want
	return _merged


## CARDS with each strip found under ART_DIR/<art>/ swapped in, then RigCardSets.all()[art]'s rows.
static func rows_of(art: String) -> Dictionary[String, Array]:
	if art == "":
		return CARDS
	var out: Dictionary[String, Array] = {}
	for key: String in CARDS:
		var row: Array = CARDS[key].duplicate()
		var alt: String = ART_DIR.path_join(art).path_join(str(row[0]).get_file())
		if ResourceLoader.exists(alt):
			row[0] = alt
		out[key] = row
	var sets: Dictionary[String, Dictionary] = RigCardSets.all()
	for key: String in sets.get(art, {}):
		var set_row: Array = sets[art][key]
		var row: Array = set_row.duplicate()
		if str(row[0]) == "" and out.has(key):
			row[0] = out[key][0]
		out[key] = row
	return out


static func frame_of(look: float) -> Vector2i:
	var o: int = posmod(roundi(look / (PI * 0.25)), 8)
	return Vector2i(OCT_FRAME[o], OCT_FLIP[o])


static func _build(rig: CutRig) -> void:
	var row: Array = rows()[_key(rig)]
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
	if row[4] != true or rig.is_tinted():
		card.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, rig.is_tinted(), 0)
	card.z_index = rig.plan.head_z
	card.set_meta(&"art", ViewMode.shared().art)
	rig.head.add_child(card)
	rig.head_card = card
	_hide(rig.head, rig.head_spr)
	if row[3] == true:
		_hide(rig.torso, rig.torso_spr)
	if rig.collar_spr != null:
		rig.collar_spr.visible = false


## Hides a body part and its readability halo (a HALO sibling under the same node).
static func _hide(node: Node2D, spr: Sprite2D, shown: bool = false) -> void:
	spr.visible = shown
	for c: Node in node.get_children():
		if c.name == RigBuild.HALO and c is CanvasItem:
			(c as CanvasItem).visible = shown


static func _place(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	var src: Sprite2D = _anchor(rig)
	var at: Vector2 = src.global_position
	var k: float = rows()[_key(rig)][2]
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

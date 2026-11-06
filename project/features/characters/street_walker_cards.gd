class_name StreetWalkerCards
extends RefCounted
## Lane n8 street: under a view row with a WALK strip (p70) a pedestrian draws as one whole-figure
## card at its feet (the library's ped_*_70 top row: five facings, the left three mirrored by
## RigHeadCard.frame_of) instead of a head card over top-down parts, which read as a sack on pills
## under the tilt. The parts are hidden, not freed; the card is the person's head card with its
## strip swapped. A gait bob and sway (rig.phase) carry the walk until the library's stride frames
## land (REQUEST to assets, n8 it4). Hit or dead (rig.react, rig.dead) the person drops back to
## the parts and the head card for good, so knock-back, the fall and the corpse draw as before.
## No strip for the view (p55, top) = nothing here runs. ENABLED false = the head cards (before).

const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/"
## view art -> card row (the head the person draws, StreetCrowdCards included) -> strip file.
const STRIPS: Dictionary[String, Dictionary] = {
	"p70":
	{
		"ped/head_hair": "ped_suit_full.png",
		"ped/head_bald": "ped_elder_full.png",
		"ped/head_hat": "ped_hat_full.png",
		"ped/head_hood": "ped_hood_full.png",
		"ped/head_cap": "ped_cap_full.png",
		"ped/head_punk": "ped_punk_full.png",
		"ped/head_shopper": "ped_shopper_full.png",
		"ped/head_jogger": "ped_jogger_full.png",
		"ped/head_worker": "ped_worker_full.png",
	},
}
## The standing figure's height on the ground plane (m), before the person's crowd scale.
const HEIGHT_M: float = 1.7
## The feet's height in the cell (from the top): street_head.py pads 2 px under the shoes.
const FOOT_Y: float = 0.985
## The gait: a lift per step (world px at full walk speed) and a sway (rad) per stride.
const BOB_PX: float = 1.6
const SWAY: float = 0.05
const WALK_SPEED: float = 1.2
const ON: StringName = &"street_walker"
const HID: StringName = &"street_walker_hid"
const WAS: StringName = &"street_walker_was"
static var _tex: Dictionary[String, Texture2D] = {}


## Each pose step under a tilt (StreetView, after RigHeadCard and StreetCrowdCards).
static func step(rig: CutRig) -> void:
	var path: String = strip_of(rig)
	if path.is_empty():
		release(rig)
		return
	var card: Sprite2D = rig.head_card
	if not card.has_meta(ON):
		_build(rig, card, path)
	for c: CanvasItem in rig.body.get_meta(HID):
		c.visible = false
	_place(rig, card)


## The strip a person draws now ("" = none: no card, not a pedestrian, no strip, hit or dead).
static func strip_of(rig: CutRig) -> String:
	if not ENABLED or rig.head_card == null or rig.plan.art_dir != "ped":
		return ""
	if rig.dead or rig.react != null:
		return ""
	var rows: Dictionary = STRIPS.get(ViewMode.shared().art, {})
	var key: String = row_of(rig)
	return DIR + ViewMode.shared().art + "/" + rows[key] if rows.has(key) else ""


## The card row the person's head card draws (StreetCrowdCards' pick, else the look's head).
static func row_of(rig: CutRig) -> String:
	var base: String = RigHeadCard.key_of(rig.plan, rig.variant.head) if rig.variant != null else ""
	return str(rig.head_card.get_meta(&"street_row", base))


## Back to the parts: restores what step hid (each item's own visibility) and drops the
## whole-figure card (the next RigHeadCard step builds the head card again).
static func release(rig: CutRig) -> void:
	if rig.body == null or not rig.body.has_meta(HID):
		return
	var was: Array[bool] = rig.body.get_meta(WAS)
	var hid: Array[CanvasItem] = rig.body.get_meta(HID)
	for i: int in hid.size():
		if is_instance_valid(hid[i]):
			hid[i].visible = was[i]
	rig.body.remove_meta(HID)
	rig.body.remove_meta(WAS)
	if rig.head_card != null and rig.head_card.has_meta(ON):
		RigHeadCard.drop(rig)


static func _build(rig: CutRig, card: Sprite2D, path: String) -> void:
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	card.texture = _tex[path]
	var cell: Vector2 = Vector2(
		card.texture.get_width() / float(RigHeadCard.FRAMES), card.texture.get_height()
	)
	card.offset = Vector2(-cell.x * 0.5, -cell.y * FOOT_Y)
	card.set_meta(ON, true)
	if rig.body.has_meta(HID):
		return
	var hid: Array[CanvasItem] = []
	var was: Array[bool] = []
	for n: Node in rig.find_children("*", "CanvasItem", true, false):
		if n != card and not n.is_ancestor_of(card):
			hid.append(n as CanvasItem)
			was.append((n as CanvasItem).visible)
	rig.body.set_meta(HID, hid)
	rig.body.set_meta(WAS, was)


static func _place(rig: CutRig, card: Sprite2D) -> void:
	var k: float = 1.0 + StreetCrowdCards.SCALE_VAR * StreetCrowdCards.vary(rig.actor_id, 3)
	var s: float = HEIGHT_M * CharacterRigs.PX_PER_M * k / card.texture.get_height()
	var walk: float = clampf(rig.speed_now / WALK_SPEED, 0.0, 1.0)
	var stride: float = sin(TAU * rig.phase)
	card.global_rotation = stride * SWAY * walk
	card.global_scale = Vector2(s, s)
	card.global_position = rig.global_position - Vector2(0.0, absf(stride) * BOB_PX * walk)

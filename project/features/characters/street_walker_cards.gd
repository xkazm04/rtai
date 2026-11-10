class_name StreetWalkerCards
extends RefCounted
## Lane n8 street: under a view row with a WALK strip (p70) a pedestrian draws as one whole-figure
## card at its feet (the library's ped_*_70 rows; the left three facings mirrored by frame_of)
## instead of a head card over top-down parts. The parts are hidden, not freed. WALKS grids (5
## facings x 4 stride frames, street_walk.py) step by rig.phase; a row without one bobs and sways.
## A flinch keeps the figure; a death holds it DEATH_HOLD of the family, then the parts take the
## fall and the corpse (falls()), unless the row has a drawn fall (StreetWalkerFall.FALLS: the
## figure falls and lies as drawn). p55: the 55 top rows with the bob. No strip (top): nothing runs.
## ENABLED false = the head cards (before).
const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/"
## view art -> card row (the head the person draws, StreetCrowdCards included) -> strip file.
const ROWS: Dictionary[String, String] = StreetWalkerRows.ROWS
const STRIPS: Dictionary[String, Dictionary] = StreetWalkerRows.STRIPS
const FRAMES_ON: bool = true
const WALKS: Dictionary[String, Dictionary] = StreetWalkerRows.WALKS
const WALK_FILL: Dictionary[String, float] = StreetWalkerRows.WALK_FILL
const STRIDE_FRAMES: int = 4
## The frame a person stands in (pass: the feet together).
const STAND_FRAME: int = 1
## How far into a death family (0..1) the whole figure holds before the parts take the fall;
## 0 = the parts from the blow (it4).
const DEATH_HOLD: float = 0.3
## The standing figure's height on the ground plane (m), before the person's crowd scale; per view
## art: the 55 drawings are longer-legged with smaller heads, so at 1.7 they read ~0.8 the p70 bulk.
const HEIGHT_M: float = 1.7
const HEIGHT_BY_ART: Dictionary[String, float] = {"p55": 2.0}
## The feet's height in the cell (from the top): street_head.py pads 2 px under the shoes.
const FOOT_Y: float = 0.985
## The gait: a lift per step (world px at full walk speed) and a sway (rad) per stride.
const BOB_PX: float = 1.6
const SWAY: float = 0.05
const WALK_SPEED: float = 1.2
## RigGait's own "moving" floor (px/s): below it the phase stands still.
const MOVING: float = 6.0
const ON: StringName = &"street_walker"
const HID: StringName = &"street_walker_hid"
const WAS: StringName = &"street_walker_was"


## Each pose step under a tilt (StreetView, after RigHeadCard and StreetCrowdCards).
static func step(rig: CutRig) -> void:
	if rig.head_card != null and not rig.head_card.has_meta(StreetStrips.PREF):
		StreetStrips.prefetch_fall(rig, ViewMode.shared().art, row_of(rig))
	var path: String = strip_of(rig)
	if path.is_empty():
		release(rig)
		return
	var card: Sprite2D = rig.head_card
	if str(card.get_meta(ON, "")) != path:
		_build(rig, card, path)
	if not rig.limbs_cold:  # a cold rig posed no part this step: nothing re-showed them
		var hid: Array[CanvasItem] = rig.body.get_meta(HID)
		StreetView.hide_all(hid)
	place(rig, card)


## True while this rig's parts are hidden under its whole-figure card (limbs need no pose).
static func hides_parts(rig: CutRig) -> bool:
	return rig.head_card != null and rig.head_card.has_meta(ON)


## The strip a person draws now ("" = none); a cop: a FALLS grid while down, else StreetCopWalk's.
static func strip_of(rig: CutRig) -> String:
	if not ENABLED or rig.head_card == null:
		return ""
	var ped: bool = rig.plan.art_dir == "ped"
	var hit: String = StreetWalkerHit.grid_of(rig, row_of(rig))
	if not hit.is_empty():
		return DIR + hit
	var on: String = rig.head_card.get_meta(ON, "")
	var stale: bool = on.ends_with("_fall.png") or StreetWalkerHit.is_grid(on)
	if not on.is_empty() and not StreetWalkerFall.down(rig) and not stale:
		if ped or (rig.strike_arm < 0 and rig.throw_t < 0.0 and rig.reload_k < 0.0):
			return on  # a living walker's strip: unchanged until a card or art change drops it
	var art: String = ViewMode.shared().art
	var key: String = row_of(rig)
	if not ped and not StreetWalkerFall.down(rig):
		return StreetCopWalk.strip_of(rig, art, key)
	var grid: String = StreetWalkerFall.grid_of(rig, art, key)
	if not grid.is_empty():
		return DIR + grid
	if not ped or falls(rig):
		return ""
	var walks: Dictionary = WALKS.get(art, {}) if FRAMES_ON else {}
	if walks.has(key):
		return DIR + art + "/" + walks[key]
	var rows: Dictionary = STRIPS.get(art, {})
	return DIR + art + "/" + rows[key] if rows.has(key) else ""


## The stride frame for a gait phase (one cycle = two steps); STAND_FRAME when not moving.
static func stride_frame(phase: float, moving: bool) -> int:
	return posmod(floori(phase * STRIDE_FRAMES), STRIDE_FRAMES) if moving else STAND_FRAME


## True once the person goes to the parts: dead past DEATH_HOLD of the death family (the swap
## lands mid-fall, where the motion hides it), or dead with no family playing. A flinch keeps the
## figure (the head's snap and the hit flash carry it: ReactPose moves the card's parent).
static func falls(rig: CutRig) -> bool:
	var r: HumanReact = rig.react
	if r != null and r.dying:
		return r.progress() >= DEATH_HOLD
	return rig.dead


## The card row the person's head card draws (StreetCrowdCards' pick, else the look's head).
static func row_of(rig: CutRig) -> String:
	if rig.head_card.has_meta(&"street_row"):
		return rig.head_card.get_meta(&"street_row")
	return RigHeadCard.key_of(rig.plan, rig.variant.head) if rig.variant != null else ""


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
	card.texture = StreetStrips.get_tex(path)
	var fall: bool = path.ends_with("_fall.png")
	var walk: bool = path.ends_with("_walk.png")
	card.vframes = StreetFallBetween.rows_of(path) if fall else (STRIDE_FRAMES if walk else 1)
	var cell: Vector2 = Vector2(
		card.texture.get_width() / float(RigHeadCard.FRAMES),
		card.texture.get_height() / float(card.vframes)
	)
	card.offset = Vector2(-cell.x * 0.5, -cell.y * (0.5 if fall else FOOT_Y))
	card.set_meta(ON, path)
	card.remove_meta(StreetWalkerFall.OCT)
	StreetDeadPlan.drop(card)
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


static func place(rig: CutRig, card: Sprite2D) -> void:
	var k: float = 1.0 + StreetCrowdCards.SCALE_VAR * StreetCrowdCards.vary(rig.actor_id, 3)
	if StreetFallBetween.is_fall_card(card):
		StreetWalkerFall.draw(rig, card, k)
		return
	var h: float = HEIGHT_BY_ART.get(ViewMode.shared().art, HEIGHT_M)
	var hit: bool = StreetWalkerHit.is_grid(str(card.get_meta(ON, "")))
	if card.vframes > 1:
		var file: String = card.texture.resource_path.get_file()
		k *= WALK_FILL.get(file, StreetCopWalk.fill_of(card.texture.resource_path))
	elif hit:
		k *= StreetWalkerHit.fill_of(str(card.get_meta(ON, "")))
	var s: float = h * CharacterRigs.PX_PER_M * k * card.vframes / card.texture.get_height()
	var walk: float = clampf(rig.speed_now / WALK_SPEED, 0.0, 1.0)
	if card.vframes > 1:
		var moving: bool = rig.speed_now > MOVING
		card.frame_coords = Vector2i(
			card.frame % RigHeadCard.FRAMES, stride_frame(rig.phase, moving)
		)
		walk = 0.0
	var stride: float = sin(TAU * rig.phase)
	var fall: Vector2 = Vector2(0.0, 1.0) if hit else StreetWalkerFall.pose(rig, card)
	var wound: Vector3 = StreetWalkerHit.shove(rig)
	card.global_rotation = stride * SWAY * walk + fall.x + wound.z
	card.global_scale = Vector2(s, s * fall.y)
	card.global_position = (
		rig.global_position - Vector2(0.0, absf(stride) * BOB_PX * walk) + Vector2(wound.x, wound.y)
	)
	if hit:
		StreetWalkerHit.face(card, rig.react.dir.rotated(rig.facing))

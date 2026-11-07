class_name RivetFrames
extends RefCounted
## Lane d9 rivet: under a view row with card art (p70 in play, p55 in boss fights) Rivet draws as
## one whole-figure drawing at his feet instead of the head card over top-down parts (the parts are
## hidden, not freed; StreetWalkerCards' pattern). Strips (tools/art/rivet_frames.py): BASE (5
## facings, 3 drawn left, walk, sprint, roll, claw strike, hit, death) and one EQ strip per weapon
## (5 facings holding it, fire or swing right, at the camera, at rest), used while it is out. A
## one-handed hold turned left (no drawn left view: a mirror swaps the weapon hand) keeps the base
## left figure + RivetHeldView's held part (logged). The art key's change swaps the strip (the
## combo's hard swap). Straight down nothing runs. ENABLED false = the head card (before).
enum Cell { WALK = 8, SPRINT = 9, ROLL = 10, CLAW = 11, HIT = 12, DEATH = 13 }
enum Eq { FIRE_SIDE = 5, FIRE_CAM = 6, REST = 7 }

const ENABLED: bool = true
const DIR: String = "res://features/characters/art/view/"
const BASE: String = "rivet_frames.png"
const BASE_CELLS: int = 14
const EQ_CELLS: int = 8
## Base cells: screen octant of the look (0 = screen right, +1 = 45 deg toward the camera) -> cell.
const BASE_OCT: PackedInt32Array = [2, 1, 0, 5, 6, 7, 4, 3]
## Equipped: the five right-turned facings; the left octants mirror 1, 2, 3 (two-handed holds).
const EQ_OCT: PackedInt32Array = [2, 1, 0, 1, 2, 3, 4, 3]
const LEFT: PackedByteArray = [0, 0, 0, 1, 1, 1, 0, 0]
## Holds drawn with one hand on the weapon: never mirrored (the owner's hand rule).
const ONE_HAND: Array[StringName] = [
	&"pistol",
	&"machine_pistol",
	&"hand_cannon",
	&"molotov",
	&"electro_baton",
	&"electro_gun",
	&"ray_gun",
	&"homing_shard",
]
## The facings' median figure height in the strips (rivet_frames.json fig_h) and the feet's pad.
const FIG_PX: float = 110.0
const PAD_PX: float = 2.0
## Rivet's standing height on screen (m): ~35 px at 32 px/m (the asset lane's mock).
## p55: the 55 drawings carry a smaller helmet over longer legs (StreetWalkerCards' x1.18 step).
const HEIGHT_M: float = 1.1
const HEIGHT_BY_ART: Dictionary[String, float] = {"p55": 1.3}
## A shot's recoil (RigClips.recoil, 0.4-1.6, decays 6/s) above this draws the fire cell.
const FIRE_RECOIL: float = 0.25
## The gait without drawn stride frames: a lift per step (px at full walk) and a sway (rad).
const BOB_PX: float = 1.4
const SWAY: float = 0.06
const WALK_SPEED: float = 1.2
const MOVING: float = 6.0
const WEAPON: StringName = &"rivet_weapon"
const ON: StringName = &"rivet_frames"
const HID: StringName = &"rivet_frames_hid"
const WAS: StringName = &"rivet_frames_was"
static var _tex: Dictionary[String, Texture2D] = {}
static var _logged: Dictionary[StringName, bool] = {}


## Each pose step under a tilt (CutRig.drive, after StreetView).
static func step(rig: CutRig) -> void:
	if rig.plan.art_dir != "rivet":
		return
	var weapon: StringName = weapon_of(rig)
	var path: String = strip_of(ViewMode.shared().art, weapon) if rig.head_card != null else ""
	if not ENABLED or path.is_empty():
		release(rig)
		return
	var card: Sprite2D = rig.head_card
	if str(card.get_meta(ON, "")) != path:
		_build(rig, card, path)
	var hid: Array[CanvasItem] = rig.body.get_meta(HID)
	StreetView.hide_all(hid)
	place(rig, card)


## The strip under view art `art` for the weapon out ("" = bare claw): the weapon's own strip if
## cut, else the base; "" when the art has no strips (top, or an art key without Rivet frames).
static func strip_of(art: String, weapon: StringName) -> String:
	if art.is_empty():
		return ""
	var base: String = DIR + art + "/" + BASE
	if not ResourceLoader.exists(base):
		return ""
	var eq: String = DIR + art + "/rivet_eq_" + String(weapon) + ".png"
	return eq if weapon != &"" and ResourceLoader.exists(eq) else base


## The weapon out (RivetHeldView publishes the held id while the gun is up), &"" = none.
static func weapon_of(rig: CutRig) -> StringName:
	return StringName(str(rig.get_meta(WEAPON, ""))) if rig.gun_out else &""


## True while the drawn frame carries the weapon (RivetHeldView hides its held part then).
static func owns_weapon(rig: CutRig) -> bool:
	var card: Sprite2D = rig.head_card
	return card != null and card.hframes == EQ_CELLS and str(card.get_meta(ON, "")) != ""


## The cell and mirror for the rig's state: Vector2i(cell, flip).
static func cell_of(rig: CutRig, eq: bool) -> Vector2i:
	var o: int = posmod(roundi(rig.head.global_rotation / (PI * 0.25)), 8)
	var left: int = LEFT[o]
	if rig.dead or (rig.react != null and rig.react.dying):
		return Vector2i(Cell.DEATH, 0)
	if not eq:
		if rig.clips.rolling():
			return Vector2i(Cell.ROLL, 0)
		if rig.clips.active() == RigClips.Clip.PUNCH or rig.clips.strike_t >= 0.0:
			return Vector2i(Cell.CLAW, left)
		if rig.clips.hit_t > 0.0:
			return Vector2i(Cell.HIT, 0)
		return Vector2i(BASE_OCT[o], 0)
	if absf(rig.clips.recoil) > FIRE_RECOIL or rig.clips.strike_t >= 0.0:
		return Vector2i(Eq.FIRE_CAM if o == 2 else Eq.FIRE_SIDE, left)
	if not rig.aiming and rig.speed_now <= MOVING and o in [1, 2, 3]:
		return Vector2i(Eq.REST, 0)
	return Vector2i(EQ_OCT[o], left)


## True when the weapon's frames can not draw this octant (a one-handed hold turned left).
static func falls_back(rig: CutRig, weapon: StringName) -> bool:
	var o: int = posmod(roundi(rig.head.global_rotation / (PI * 0.25)), 8)
	return LEFT[o] == 1 and ONE_HAND.has(weapon)


static func place(rig: CutRig, card: Sprite2D) -> void:
	var weapon: StringName = weapon_of(rig)
	var eq: bool = card.hframes == EQ_CELLS
	if eq and falls_back(rig, weapon):
		_log_fallback(weapon)
		_set_strip(rig, card, strip_of(ViewMode.shared().art, &""))
		eq = false
	var c: Vector2i = cell_of(rig, eq)
	card.frame = c.x
	card.flip_h = c.y == 1
	var h: float = HEIGHT_BY_ART.get(ViewMode.shared().art, HEIGHT_M)
	var s: float = h * CharacterRigs.PX_PER_M / FIG_PX
	var walk: float = clampf(rig.speed_now / WALK_SPEED, 0.0, 1.0)
	walk = walk if c.x != Cell.ROLL and c.x != Cell.DEATH else 0.0
	var stride: float = sin(TAU * rig.phase)
	card.global_rotation = stride * SWAY * walk + _roll_spin(rig, c.x)
	card.global_scale = Vector2(s, s)
	card.global_position = rig.global_position - Vector2(0.0, absf(stride) * BOB_PX * walk)


## The roll ball turns once over the roll, toward the travel side.
static func _roll_spin(rig: CutRig, cell: int) -> float:
	if cell != Cell.ROLL or rig.clips.roll_len <= 0.0:
		return 0.0
	var k: float = 1.0 - rig.clips.roll_t / rig.clips.roll_len
	var side: float = -1.0 if rig.vel_in.x < 0.0 else 1.0
	return TAU * k * side


## Back to the parts: restores what step hid and drops the card (RigHeadCard builds it again).
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
	_set_strip(rig, card, path)
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


static func _set_strip(_rig: CutRig, card: Sprite2D, path: String) -> void:
	if str(card.get_meta(ON, "")) == path:
		return
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D
	card.texture = _tex[path]
	card.hframes = BASE_CELLS if path.ends_with(BASE) else EQ_CELLS
	card.vframes = 1
	var w: float = card.texture.get_width() / float(card.hframes)
	var cell: Vector2 = Vector2(w, card.texture.get_height())
	card.offset = Vector2(-cell.x * 0.5, -(cell.y - PAD_PX))
	card.set_meta(ON, path)


static func _log_fallback(weapon: StringName) -> void:
	if _logged.has(weapon):
		return
	_logged[weapon] = true
	Log.info("rivet", "no drawn left view for %s: base left figure + held part" % weapon)

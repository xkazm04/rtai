class_name RivetFrames
extends RefCounted
## Lane d9 rivet: under a card-art view (p70 play, p55 boss) Rivet is one whole drawn figure, the
## parts hidden. Strips (RivetStrips): BASE (5 facings, 3 left, walk, sprint, roll, claw, hit,
## death), EQ per weapon (5 facings, fire side, fire at camera, rest), LEFT (a one-handed hold's
## 3 drawn left views). The art key's change swaps the strip (the combo's hard swap).
enum Cell { WALK = 8, SPRINT = 9, ROLL = 10, CLAW = 11, HIT = 12, DEATH = 13 }
enum Eq { FIRE_SIDE = 5, FIRE_CAM = 6, REST = 7 }

const ENABLED: bool = true
const BASE_CELLS: int = 14
const EQ_CELLS: int = 8
const LEFT_CELLS: int = 3
## Octant (0 = screen right, +1 = 45 deg toward the camera) -> base cell / equipped cell (mirrored).
const BASE_OCT: PackedInt32Array = [2, 1, 0, 5, 6, 7, 4, 3]
const EQ_OCT: PackedInt32Array = [2, 1, 0, 1, 2, 3, 4, 3]
const LEFT: PackedByteArray = [0, 0, 0, 1, 1, 1, 0, 0]
## The facings' median figure height in the strips (rivet_frames.json fig_h) and the feet's pad.
const FIG_PX: float = 110.0
const PAD_PX: float = 2.0
## Rivet's standing height on screen (m). n9: the owner's +50 % (1.1 -> 1.65 m, ~53 px at
## 32 px/m); p55 in proportion (1.3 -> 1.95: the 55 drawings, a smaller helmet over longer legs).
const HEIGHT_M: float = 1.65
const HEIGHT_BY_ART: Dictionary[String, float] = {"p55": 1.95}
const ROLL_SHADOW: float = 0.45  # the roll ball's cast-shadow height, in standing heights
## The fire cell: a recoil (RigClips.recoil, 0.4-1.6) above FIRE_RECOIL, or a shot left within
## FIRE_TICKS (streams and autos: RivetHeldView publishes it from the trigger's cooldown).
const FIRE_RECOIL: float = 0.25
const FIRE_TICKS: int = 7
## The gait without drawn stride frames: a lift per step (px at full walk) and a sway (rad).
const BOB_PX: float = 1.4
const SWAY: float = 0.06
const WALK_SPEED: float = 1.2
const MOVING: float = 6.0
const WEAPON: StringName = &"rivet_weapon"
const FIRE: StringName = &"rivet_fire"
const ON: StringName = &"rivet_frames"
const HID: StringName = &"rivet_frames_hid"
const WAS: StringName = &"rivet_frames_was"
## The owner's Call 1 (his size): --rivet-height=<m> (CastFlags) scales every art key's height.
static var height_k: float = 1.0
static var _tex: Dictionary[String, Texture2D] = {}


## Each pose step under a tilt (CutRig.drive, after StreetView).
static func step(rig: CutRig) -> void:
	if rig.plan.art_dir != "rivet":
		return
	var weapon: StringName = weapon_of(rig)
	var art: String = ViewMode.shared().art
	var path: String = RivetStrips.strip_of(art, weapon) if rig.head_card != null else ""
	if path != "" and RivetWalk.path_of(rig, art, weapon) != "":
		path = RivetWalk.path_of(rig, art, weapon)
	if path != "" and LEFT[oct_of(rig)] == 1 and RivetStrips.ONE_HAND.has(weapon):
		path = RivetStrips.left_of(art, weapon)
	if not ENABLED or path.is_empty():
		release(rig)
		return
	var card: Sprite2D = rig.head_card
	if str(card.get_meta(ON, "")) != path:
		_build(rig, card, path)
	var hid: Array[CanvasItem] = rig.body.get_meta(HID)
	StreetView.hide_all(hid)
	place(rig, card)


## The weapon out (RivetHeldView publishes the held id while the gun is up), &"" = none.
static func weapon_of(rig: CutRig) -> StringName:
	var down: bool = rig.dead or (rig.react != null and rig.react.dying)
	return StringName(str(rig.get_meta(WEAPON, ""))) if rig.gun_out and not down else &""


## RivetHeldView each frame: the weapon out, whether a shot left within FIRE_TICKS, the muzzle.
static func publish(rig: CutRig, held: StringName, gun: GunHand) -> void:
	rig.set_meta(WEAPON, held)
	var t: Trigger = gun.trigger if gun != null and gun.trigger.spec.id == held else null
	rig.set_meta(FIRE, t != null and t.cooldown > maxi(0, t.spec.interval_ticks - FIRE_TICKS))
	RivetMuzzle.publish(rig)  # the drawn cell's muzzle (the held part is hidden then)


## True while Rivet is one drawn figure: RivetHeldView feeds no magazine part then (no bottle or
## tank has one either); a part beside a drawn figure floats off it (it6: at his helmet on reload).
static func drawn(rig: CutRig) -> bool:
	return rig.head_card != null and rig.head_card.has_meta(ON)


## True while the drawn frame carries the weapon (RivetHeldView hides its held part then).
static func owns_weapon(rig: CutRig) -> bool:
	var card: Sprite2D = rig.head_card
	var bare: bool = card != null and (card.hframes == BASE_CELLS or RivetWalk.is_grid(card))
	return card != null and not bare and card.has_meta(ON)


## The cell and mirror for the rig's state: Vector2i(cell, flip). `walk_ph` >= 0: a walk grid.
static func cell_of(rig: CutRig, cells: int, walk_ph: float = -1.0) -> Vector2i:
	var o: int = oct_of(rig)
	var left: int = LEFT[o]
	if cells == LEFT_CELLS:
		return Vector2i(clampi(o - 3, 0, 2), 0)
	if rig.dead or (rig.react != null and rig.react.dying):
		return Vector2i(Cell.DEATH, 0)
	if walk_ph >= 0.0:
		return Vector2i(RivetWalk.frame_of(o, walk_ph, cells), 0)
	if cells == BASE_CELLS:
		if rig.clips.rolling():
			return Vector2i(Cell.ROLL, 0)
		if rig.clips.active() == RigClips.Clip.PUNCH or rig.clips.strike_t >= 0.0:
			return Vector2i(Cell.CLAW, left)
		if rig.clips.hit_t > 0.0:
			return Vector2i(Cell.HIT, 0)
		return Vector2i(BASE_OCT[o], 0)
	var fired: bool = absf(rig.clips.recoil) > FIRE_RECOIL or rig.get_meta(FIRE, false) == true
	if RivetStrips.draws_fire(rig, weapon_of(rig), o, fired or rig.clips.strike_t >= 0.0):
		return Vector2i(Eq.FIRE_CAM if o == 2 else Eq.FIRE_SIDE, left)
	if not rig.aiming and rig.speed_now <= MOVING and o in [1, 2, 3]:
		return Vector2i(Eq.REST, 0)
	return Vector2i(EQ_OCT[o], left)


## The screen octant of the look (0 = screen right, +1 = 45 deg toward the camera).
static func oct_of(rig: CutRig) -> int:
	return posmod(roundi(rig.head.global_rotation / (PI * 0.25)), 8)


static func place(rig: CutRig, card: Sprite2D) -> void:
	var art: String = ViewMode.shared().art
	var h: float = HEIGHT_BY_ART.get(art, HEIGHT_M) * height_k
	var s: float = h * CharacterRigs.PX_PER_M / FIG_PX
	var drawn_walk: bool = RivetWalk.is_grid(card)
	var ph: float = RivetWalk.phase_of(rig, art, s)
	var c: Vector2i = cell_of(rig, card.hframes, ph if drawn_walk else -1.0)
	card.frame = c.x
	card.flip_h = c.y == 1
	var walk: float = clampf(rig.speed_now / WALK_SPEED, 0.0, 1.0)
	walk = walk if c.x != Cell.ROLL and c.x != Cell.DEATH and not drawn_walk else 0.0
	var stride: float = sin(TAU * rig.phase)
	card.global_rotation = stride * SWAY * walk + _roll_spin(rig, c.x)
	card.global_scale = Vector2(s, s)
	var k: float = ROLL_SHADOW if c.x == Cell.ROLL else RigTilt.hip_h(rig) / rig.plan.hip_z
	rig.set_meta(
		RigCastShadows.CAST_HIP, h * CharacterRigs.PX_PER_M * k / RigCastShadows.BODY_IN_HIPS
	)
	card.global_position = rig.global_position - Vector2(0.0, absf(stride) * BOB_PX * walk)


## The roll ball turns once over the roll, toward the travel side.
static func _roll_spin(rig: CutRig, cell: int) -> float:
	if cell != Cell.ROLL or rig.clips.roll_len <= 0.0:
		return 0.0
	var k: float = 1.0 - rig.clips.roll_t / rig.clips.roll_len
	return TAU * k * (-1.0 if rig.vel_in.x < 0.0 else 1.0)


## Back to the parts: restores what step hid and drops the card (RigHeadCard builds it again).
static func release(rig: CutRig) -> void:
	rig.remove_meta(RigCastShadows.CAST_HIP)
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
	_set_strip(card, path)
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


static func _set_strip(card: Sprite2D, path: String) -> void:
	if str(card.get_meta(ON, "")) == path:
		return
	card.texture = _tex.get_or_add(path, load(path) as Texture2D)
	card.frame = 0  # the walk grid's 32 frames vs a strip's 3-14: never out of range mid-swap
	var left: bool = path.ends_with("_left.png")
	var grid: bool = path.ends_with(RivetWalk.STRIP) or path.ends_with(RivetWalk.STRIP4)
	card.hframes = (
		BASE_CELLS if path.ends_with(RivetStrips.BASE) else (LEFT_CELLS if left else EQ_CELLS)
	)
	card.hframes = (8 if path.ends_with(RivetWalk.STRIP) else 4) if grid else card.hframes
	card.vframes = RivetWalk.ROWS if grid else 1
	var w: float = card.texture.get_width() / float(card.hframes)
	card.offset = Vector2(-w * 0.5, PAD_PX - card.texture.get_height() / float(card.vframes))
	card.set_meta(ON, path)

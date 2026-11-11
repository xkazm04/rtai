class_name RivetThrust
extends RefCounted
## n17 rivet-strike (DEFECTS #5; owner "attach movement with melee"): a lunging hit (a
## melee_weapons.json row with `lunge_ticks`, the katana's 2.5 m thrust) travels its whole lunge
## on the lunge_ticks just before contact, but the figure held one wind-up cell through the dash: a
## whole-figure slide. Where the weapon has a drawn thrust strip (rivet_eq_<weapon>_thrust.png, the
## asset lane's it454 cells: 0 the side, 1 the camera, 2 the drawn left; front foot forward, back
## foot pushing, the blade level at full reach) it is drawn from the lunge's first tick through the
## contact (the active ticks); the recovery takes the strike cell again. Only on the octants whose
## blade strike is drawn (RivetSwipe.blade_drawn): elsewhere the facing and the game arc stand.
## The drawn pose carries its own lean (no RivetLean on it). `--rivet-thrust=off` (CastFlags) =
## before. Render only: the hit is matched to the strike clip by its wind-up and active ticks.
## Past the contact (the recovery and the strike hold) a weapon with a drawn recovery strip
## (RECOVER_FILE, the asset lane's it458 cells in the same order: the blade drawn back level toward
## the guard, both feet planted, no arc) draws it instead of the slash strike cell, whose swing arc
## read wrong after a straight thrust. `--rivet-thrust-recover=off` (CastFlags) = the strike cell.

const FILE: String = "_thrust.png"
const RECOVER_FILE: String = "_thrust_recover.png"
const CELLS: int = 3
const SIDE: int = 0
const CAM: int = 1
const LEFT: int = 2
## The camera cell's boots above the cell bottom (strip px): its blade reaches down the cell
## toward the viewer, below the boots (read at 2x/4x with a 10 px ruler: the planted boot's bottom
## at row 176 of 256 at p70, 124 of 141 at p55; it454's 250/134 were the blade's tip).
const CAM_FEET: Dictionary[String, float] = {"p70": 79.0, "p55": 16.0}
## The recovery's camera cell, read the same way (its blade tip touches the cell floor): p70 both
## boots at row 188 of 256; p55 the front boot 135, the back 114 of 141, seated between them.
const RECOVER_CAM_FEET: Dictionary[String, float] = {"p70": 67.0, "p55": 16.0}

static var enabled: bool = true
static var recover: bool = true
static var _hits: Dictionary[StringName, Array] = {}


## The weapon's thrust strip while `rig`'s strike lunges or makes contact on the equipped strip
## or its drawn left strip (`path`) at a drawn-blade octant, else `path`.
static func path_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	if not enabled or weapon == &"" or not RivetSwipe.blade_drawn(RivetFrames.oct_of(rig)):
		return path
	var eq: String = RivetStrips.DIR + art + "/rivet_eq_" + String(weapon)
	if path != eq + ".png" and path != eq + "_left.png":
		return path
	var file: String = (
		FILE if thrusting(rig, weapon) else (RECOVER_FILE if recovering(rig, weapon) else "")
	)
	return eq + file if file != "" and RivetStrips.has_file(eq + file) else path


## True from the lunge's first tick to the end of the contact (the active ticks).
static func thrusting(rig: CutRig, weapon: StringName) -> bool:
	var t: float = rig.clips.strike_t
	var ph: Vector3 = rig.clips.strike_ph
	var lunge: int = lunge_ticks(weapon, ph)
	if t < 0.0 or lunge <= 0:
		return false
	var half: float = SimClock.TICK_DT * 0.5
	return t >= ph.x - lunge * SimClock.TICK_DT - half and t < ph.x + ph.y - half


## True past a lunging hit's contact while its clip runs (the recovery and the strike hold).
static func recovering(rig: CutRig, weapon: StringName) -> bool:
	var ph: Vector3 = rig.clips.strike_ph
	var t: float = rig.clips.strike_t
	if not recover or t < 0.0 or lunge_ticks(weapon, ph) <= 0:
		return false
	return t >= ph.x + ph.y - SimClock.TICK_DT * 0.5


## The lunge_ticks of `weapon`'s hit whose wind-up and active seconds are `ph`'s, 0 when none.
static func lunge_ticks(weapon: StringName, ph: Vector3) -> int:
	if not _hits.has(weapon):
		_hits[weapon] = (
			MeleeTable.weapon(weapon).hits if MeleeTable.weapon_ids().has(weapon) else []
		)
	var half: float = SimClock.TICK_DT * 0.5
	for h: MeleeHit in _hits[weapon]:
		var w: float = h.windup * SimClock.TICK_DT
		var a: float = h.active * SimClock.TICK_DT
		if h.lunge_ticks > 0 and absf(w - ph.x) < half and absf(a - ph.y) < half:
			return h.lunge_ticks
	return 0


## True when `card` shows a thrust or thrust recovery strip.
static func shows(card: Sprite2D) -> bool:
	var on: String = str(card.get_meta(RivetFrames.ON, "")) if card != null else ""
	return on.ends_with(FILE) or on.ends_with(RECOVER_FILE)


## Poses the thrust cell for the facing (RivetStrike.placed): on his ground point, upright.
static func place(rig: CutRig, card: Sprite2D, s: float, h_px: float) -> void:
	var path: String = str(card.get_meta(RivetFrames.ON))
	var o: int = RivetFrames.oct_of(rig)
	var cell: int = CAM if o == 2 else (LEFT if RivetFrames.LEFT[o] == 1 else SIDE)
	card.hframes = CELLS
	card.vframes = 1
	card.frame = cell
	card.flip_h = false
	var size: Vector2 = card.texture.get_size() / Vector2(CELLS, 1)
	var art: String = path.get_base_dir().get_file()
	var cam: Dictionary[String, float] = (
		RECOVER_CAM_FEET if path.ends_with(RECOVER_FILE) else CAM_FEET
	)
	var foot: float = cam.get(art, 0.0) if cell == CAM else RivetStrips.foot_px(path)
	card.offset = Vector2(-size.x * 0.5, foot - size.y)
	card.global_rotation = 0.0
	card.global_scale = Vector2(s, s) / RivetRes.of(path)
	card.global_position = rig.global_position
	rig.set_meta(RigCastShadows.CAST_HIP, h_px / RigCastShadows.BODY_IN_HIPS)

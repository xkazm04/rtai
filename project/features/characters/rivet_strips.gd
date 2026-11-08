class_name RivetStrips
extends RefCounted
## Lane d9 rivet: which drawn strip Rivet's figure takes (RivetFrames draws it). Strips are cut by
## tools/art/rivet_frames.py from tools/art/rivet_frames.json under DIR/<art key>/: the base, one
## equipped strip per weapon, and a one-handed hold's drawn left views (the owner's hand rule: a
## mirrored facing would swap the weapon hand).

const DIR: String = "res://features/characters/art/view/"
const BASE: String = "rivet_frames.png"

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
## Streams whose drawn flame cell fires only along the side and camera octants (fires_drawn).
## n9: the owner's r-7 B, the drawn flame in every direction (`cone` empty); --rivet-flame=cone
## brings back d9's CONE_D9 (the facing cell + the game jet off those octants).
const CONE_D9: Array[StringName] = [&"flamethrower"]
const CONE_TOL: float = PI / 8.0
## A cone burst that went off its drawn flame (rig meta): it keeps the facing cell until the fire
## latch clears, which outlives the stream by RivetFrames.FIRE_TICKS while the aim swings.
const CONE_OFF: StringName = &"rivet_cone_off"
## Equipped strips per art key whose strike cells draw no swing arc: under them RivetHeldView
## keeps posing the hidden held part so the game's smear (MeleeSmearView) still sweeps the cut.
## The katana, chainsaw and plasma sword sheets draw their own arc (no game smear over it).
const NO_ARC: Dictionary[String, Array] = {"p55": [&"electro_baton"]}
## n9 it5: a stream's drawn DIAGONAL fire cells (tools/art/rivet_flame_diag.py: the library's
## fire_diag cells, the left ones drawn): rivet_eq_<weapon>_diag.png, 4 cells (3/4 toward right,
## 3/4 away right, 3/4 toward left, 3/4 away left) by octant. A toward flame reaches below his
## feet, so the strip's foot line sits DIAG_FOOT_PX above the cell bottom (the tool prints it).
## --rivet-flame=side fires the side cell on the diagonals too (it3's two flames).
const DIAG: String = "_diag.png"
const DIAG_CELLS: int = 4
const DIAG_CELL: PackedInt32Array = [-1, 0, -1, 2, -1, 3, -1, 1]
const DIAG_FOOT_PX: Dictionary[String, float] = {"p70": 35.0, "p55": 15.0}
static var cone: Array[StringName] = []
static var diag: bool = true
static var _logged: Dictionary[StringName, bool] = {}


## The strip under view art `art` for the weapon out ("" = bare claw): the weapon's own strip if
## cut, else the base; "" when the art has no strips (top, or an art key without Rivet frames).
static func strip_of(art: String, weapon: StringName) -> String:
	var base: String = DIR + art + "/" + BASE
	if art.is_empty() or not ResourceLoader.exists(base):
		return ""
	var eq: String = DIR + art + "/rivet_eq_" + String(weapon) + ".png"
	return eq if weapon != &"" and ResourceLoader.exists(eq) else base


## `path`, or the weapon's drawn diagonal fire strip while a shot latches at a diagonal octant.
static func diag_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	if not diag or weapon == &"" or cone.has(weapon) or DIAG_CELL[RivetFrames.oct_of(rig)] < 0:
		return path
	var d: String = DIR + art + "/rivet_eq_" + String(weapon) + DIAG
	return d if fire_latched(rig) and ResourceLoader.exists(d) else path


## A short strip's cell for octant `o`: a drawn left strip (3) or a diagonal fire strip (4).
static func small_cell(o: int, cells: int) -> int:
	return maxi(DIAG_CELL[o], 0) if cells == DIAG_CELLS else clampi(o - 3, 0, 2)


## The cell count of a non-grid strip, and its feet's pad above the cell bottom (px).
static func cells_of(path: String, left: bool) -> int:
	return DIAG_CELLS if path.ends_with(DIAG) else (RivetFrames.LEFT_CELLS if left else 8)


static func foot_px(path: String) -> float:
	var art: String = path.get_base_dir().get_file()
	return DIAG_FOOT_PX.get(art, 0.0) if path.ends_with(DIAG) else RivetFrames.PAD_PX


## A one-handed hold turned left: its drawn left strip, else the base (the fallback, logged once).
static func left_of(art: String, weapon: StringName) -> String:
	var path: String = DIR + art + "/rivet_eq_" + String(weapon) + "_left.png"
	if ResourceLoader.exists(path):
		return path
	if not _logged.has(weapon):
		_logged[weapon] = true
		Log.info("rivet", "no drawn left view for %s at %s: base left + held part" % [weapon, art])
	return DIR + art + "/" + BASE


## True while the drawn figure carries the weapon and draws its whole read: RivetHeldView shows
## nothing then. A strip in NO_ARC keeps the hidden held part posing for the smear.
static func hides_held(rig: CutRig) -> bool:
	if not RivetFrames.owns_weapon(rig):
		return false
	var no_arc: Array = NO_ARC.get(ViewMode.shared().art, [])
	return not no_arc.has(RivetFrames.weapon_of(rig))


## True while a shot or a strike latches the fire cell (the recoil, the FIRE latch, a strike).
static func fire_latched(rig: CutRig) -> bool:
	var fired: bool = absf(rig.clips.recoil) > RivetFrames.FIRE_RECOIL
	return fired or rig.get_meta(RivetFrames.FIRE, false) == true or rig.clips.strike_t >= 0.0


## Whether the rig's equipped strip draws its fire cell this frame (`firing`: a shot or a strike
## is up); a cone burst that went off its drawn flame stays on the facing cell to its end.
static func draws_fire(rig: CutRig, weapon: StringName, o: int, firing: bool) -> bool:
	var was_off: bool = rig.get_meta(CONE_OFF, false) == true
	var off: bool = firing and (was_off or not fires_drawn(weapon, o, aim_of(rig)))
	rig.set_meta(CONE_OFF, off)
	return firing and not off


## The cone (the flamer) fires its drawn flame along the side and camera octants while the aim
## (NAN = the head's) is within CONE_TOL of it; else the facing cell fires (not two flames).
static func fires_drawn(weapon: StringName, o: int, aim: float = NAN) -> bool:
	if not cone.has(weapon):
		return true
	var off: float = 0.0 if is_nan(aim) else absf(angle_difference(aim, o * PI * 0.25))
	return o in [0, 2, 4] and off <= CONE_TOL


## The aim's screen angle while aiming, else NAN.
static func aim_of(rig: CutRig) -> float:
	var to: Vector2 = rig.aim_at - rig.global_position
	return to.angle() if rig.aiming and to.length() > 1.0 else NAN

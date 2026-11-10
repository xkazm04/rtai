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
## n10: one-handed melee holds. A drawn left strip has only its three facings, no strike cell, so
## under it the smear has to keep running from the hidden held part or a left swing draws nothing.
const LEFT_NO_SWING: Array[StringName] = [&"electro_baton"]
## n10: a strip whose weapon hangs below his feet is cut with its feet this far above the cell
## bottom (tools/art/rivet_frames.py body_band prints it), keyed "<art key>/<file>".
const FOOT_PX: Dictionary[String, float] = {"p70/rivet_eq_electro_baton_left.png": 35.0}
## n9 it5: a stream's drawn DIAGONAL fire cells (tools/art/rivet_flame_diag.py: the library's
## fire_diag cells, the left ones drawn): rivet_eq_<weapon>_diag.png, 4 cells (3/4 toward right,
## 3/4 away right, 3/4 toward left, 3/4 away left) by octant. A toward flame reaches below his
## feet, so the strip's foot line sits DIAG_FOOT_PX above the cell bottom (the tool prints it).
## --rivet-flame=side fires the side cell on the diagonals too (it3's two flames).
const DIAG: String = "_diag.png"
const DIAG_CELLS: int = 4
const DIAG_CELL: PackedInt32Array = [-1, 0, -1, 2, -1, 3, -1, 1]
const DIAG_FOOT_PX: Dictionary[String, float] = {"p70": 35.0, "p55": 15.0}
## n9 it10: the drawn flame's screen angle (deg, y down) in the fire cell each octant shows
## (side 0 / 180, camera 90, the diagonal cells as drawn: measured by the yellow's long axis). A
## burst whose aim is over FLAME_TOL off it keeps the facing cell and the game jet alone (one
## flame): straight up there is no drawn flame (the side cell drew it sideways under an up jet).
## --rivet-flame=all draws the fire cell at any aim (it9).
const FLAME_DEG: Dictionary[String, PackedFloat32Array] = {
	"p70/flamethrower": [0.0, 40.0, 90.0, 140.0, 180.0, -151.0, 0.0, -26.0],
	"p55/flamethrower": [0.0, 35.0, 90.0, 144.0, 180.0, -159.0, 0.0, -20.0],
}
const FLAME_TOL: float = PI / 6.0
## n9 it12: a gun's fire cell draws its gun along the side (0 / 180) or the camera (90); a shot
## aimed over GUN_TOL off it keeps the facing cell (fired up the screen, the side cell drew the gun
## and its flash sideways under an up tracer). --rivet-flame=all = any aim (it11).
const GUN_TOL: float = PI / 4.0
## n10: a burst already drawing its fire cell keeps it within this extra angle: an aim on the
## tolerance's edge (a 45 deg shot) lost the cell to one tick of float noise for the whole latch.
const FIRE_HOLD: float = PI / 30.0
const DREW: StringName = &"rivet_fire_drew"
static var flame_all: bool = false
static var cone: Array[StringName] = []
static var diag: bool = true
static var _logged: Dictionary[StringName, bool] = {}
static var _exists: Dictionary[String, bool] = {}


## ResourceLoader.exists once per path: Rivet's pose step asks it several times a frame for shipped
## files that cannot change while the game runs, and each ask is a file probe (n10 perf).
static func has_file(path: String) -> bool:
	if not _exists.has(path):
		_exists[path] = ResourceLoader.exists(path)
	return _exists[path]


## The strip under view art `art` for the weapon out ("" = bare claw): the weapon's own strip if
## cut, else the base; "" when the art has no strips (top, or an art key without Rivet frames).
static func strip_of(art: String, weapon: StringName) -> String:
	var base: String = DIR + art + "/" + BASE
	if art.is_empty() or not has_file(base):
		return ""
	var eq: String = DIR + art + "/rivet_eq_" + String(weapon) + ".png"
	return eq if weapon != &"" and has_file(eq) else base


## `path`, or the weapon's drawn diagonal fire strip while a shot latches at a diagonal octant
## and its drawn flame lies along the aim (draws_fire; n9 it10).
static func diag_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	var o: int = RivetFrames.oct_of(rig)
	if not diag or weapon == &"" or cone.has(weapon) or DIAG_CELL[o] < 0:
		return path
	var d: String = DIR + art + "/rivet_eq_" + String(weapon) + DIAG
	if not fire_latched(rig) or not has_file(d):
		return path
	return d if draws_fire(rig, weapon, o, true) else path


## A short strip's cell for octant `o`: a drawn left strip (3) or a diagonal fire strip (4).
static func small_cell(o: int, cells: int) -> int:
	return maxi(DIAG_CELL[o], 0) if cells == DIAG_CELLS else clampi(o - 3, 0, 2)


## The cell count of a non-grid strip, and its feet's pad above the cell bottom (px).
static func cells_of(path: String, left: bool) -> int:
	if path.ends_with(BASE):
		return RivetFrames.BASE_CELLS
	return DIAG_CELLS if path.ends_with(DIAG) else (RivetFrames.LEFT_CELLS if left else 8)


static func foot_px(path: String) -> float:
	var art: String = path.get_base_dir().get_file()
	if path.ends_with(DIAG):
		return DIAG_FOOT_PX.get(art, 0.0)
	var res: float = RivetRes.of(path)
	return FOOT_PX.get(art + "/" + path.get_file(), RivetFrames.PAD_PX / res) * res


## A one-handed hold turned left: its drawn left strip, else the base (the fallback, logged once).
static func left_of(art: String, weapon: StringName) -> String:
	var path: String = DIR + art + "/rivet_eq_" + String(weapon) + "_left.png"
	if has_file(path):
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
	var weapon: StringName = RivetFrames.weapon_of(rig)
	var on: String = str(rig.head_card.get_meta(RivetFrames.ON, ""))
	if LEFT_NO_SWING.has(weapon) and on.ends_with("_left.png"):
		return false
	var no_arc: Array = NO_ARC.get(ViewMode.shared().art, [])
	return not no_arc.has(weapon)


## True while a shot or a strike latches the fire cell (the recoil, the FIRE latch, a strike).
static func fire_latched(rig: CutRig) -> bool:
	var fired: bool = absf(rig.clips.recoil) > RivetFrames.FIRE_RECOIL
	return fired or rig.get_meta(RivetFrames.FIRE, false) == true or rig.clips.strike_t >= 0.0


## Whether the rig's equipped strip draws its fire cell this frame (`firing`: a shot or a strike
## is up); a cone burst that went off its drawn flame stays on the facing cell to its end.
static func draws_fire(rig: CutRig, weapon: StringName, o: int, firing: bool) -> bool:
	var was_off: bool = rig.get_meta(CONE_OFF, false) == true
	var aim: float = NAN if rig.clips.strike_t >= 0.0 else aim_of(rig)
	var drew: bool = rig.get_meta(DREW, false) == true
	var slack: float = FIRE_HOLD if drew else 0.0
	var art: String = ViewMode.shared().art
	var off: bool = firing and (was_off or not fires_drawn(weapon, o, aim, art, slack))
	off = off or (firing and rig.clips.strike_t >= 0.0 and not RivetSwipe.blade_drawn(o))
	rig.set_meta(CONE_OFF, off)
	rig.set_meta(DREW, firing and not off)
	RivetFireCam.step(rig, weapon, o, aim, firing and not off, drew)
	return firing and not off


## The cone (the flamer) fires its drawn flame along the side and camera octants while the aim
## (NAN = the head's) is within CONE_TOL of it; else the facing cell fires (not two flames).
static func fires_drawn(
	weapon: StringName, o: int, aim: float = NAN, art: String = "", slack: float = 0.0
) -> bool:
	if not cone.has(weapon):
		var deg: PackedFloat32Array = FLAME_DEG.get(art + "/" + String(weapon), [])
		if flame_all or is_nan(aim):
			return true
		if deg.is_empty():
			var gun: float = 90.0 if o == 2 else 180.0 * RivetFrames.LEFT[o]
			if RivetFireCam.covers(weapon, o, aim, art, slack):
				return true
			return absf(angle_difference(aim, deg_to_rad(gun))) <= GUN_TOL + slack
		var drawn: float = deg[o] if diag or DIAG_CELL[o] < 0 else 180.0 * RivetFrames.LEFT[o]
		return absf(angle_difference(aim, deg_to_rad(drawn))) <= FLAME_TOL + slack
	var off: float = 0.0 if is_nan(aim) else absf(angle_difference(aim, o * PI * 0.25))
	return o in [0, 2, 4] and off <= CONE_TOL


## The aim's screen angle while aiming, else NAN.
static func aim_of(rig: CutRig) -> float:
	var to: Vector2 = rig.aim_at - rig.global_position
	return to.angle() if rig.aiming and to.length() > 1.0 else NAN

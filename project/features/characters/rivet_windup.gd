class_name RivetWindup
extends RefCounted
## n13 weapon art (item 4): a blade's wind-up cell. The drawn equipped strips have no wind-up, so
## the strike cell (the swing already through, its arc drawn) showed from the first wind-up tick.
## Where a weapon has a wind-up strip (rivet_eq_<weapon>_windup.png, tools/art/blade_windup.py: 0 =
## the side wind-up, 1 = the camera wind-up, drawn facing right), RivetFrames draws it while the
## view's strike clip is inside its wind-up (RigClips.strike_t < strike_ph.x); the active and
## recovery ticks keep the strike cell. View only: the sim's timings are untouched.
## `--rivet-windup=off` (CastFlags) = the strike cell through the wind-up (the before).

const FILE: String = "_windup.png"
const CELLS: int = 2
const SIDE: int = 0
const CAM: int = 1
static var enabled: bool = true


## The wind-up strip while `rig`'s strike winds up on the weapon's equipped strip (`path`; a walk
## grid, a reload or a knock keeps its own) and the weapon has one, else `path`.
static func path_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	if not enabled or weapon == &"" or not winding(rig):
		return path
	var eq: String = RivetStrips.DIR + art + "/rivet_eq_" + String(weapon)
	if path != eq + ".png":
		return path
	var w: String = eq + FILE
	return w if RivetStrips.has_file(w) else path


## True while the view's strike clip is inside its wind-up phase.
static func winding(rig: CutRig) -> bool:
	var t: float = rig.clips.strike_t
	return t >= 0.0 and t < rig.clips.strike_ph.x


## A short strip's cell and mirror for octant `o`: the wind-up strip's camera cell facing the
## camera (where a melee strike draws its camera cell), else its side cell (mirrored on the left);
## any other short strip RivetStrips.small_cell unmirrored.
static func small_of(o: int, cells: int) -> Vector2i:
	if cells != CELLS:
		return Vector2i(RivetStrips.small_cell(o, cells), 0)
	if o == 2:
		return Vector2i(CAM, 0)
	return Vector2i(SIDE, RivetFrames.LEFT[o])

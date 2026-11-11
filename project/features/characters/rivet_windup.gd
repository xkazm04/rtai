class_name RivetWindup
extends RefCounted
## n13 weapon art (item 4): a blade's wind-up cell. The drawn equipped strips have no wind-up, so
## the strike cell (the swing already through, its arc drawn) showed from the first wind-up tick.
## Where a weapon has a wind-up strip (rivet_eq_<weapon>_windup.png: 0 = the side wind-up, 1 = the
## camera wind-up, drawn facing right; the asset lane's drawn cells laid by
## tools/art/rivet_windup_cells.py), RivetFrames draws it while the view's strike clip is inside its
## wind-up (RigClips.strike_t < strike_ph.x); the active and recovery ticks keep the strike cell.
## n14: a one-handed weapon turned left draws its drawn left strip (never mirrored), so its wind-up
## is a second slot: rivet_eq_<weapon>_left_windup.png, one cell (the left side wind-up), swapped
## for the left strip the same way. View only: the sim's timings are untouched.
## `--rivet-windup=off` (CastFlags) = the strike cell through the wind-up (the before).
## n15: past the wind-up (the strike and its recovery, as the equipped strip's strike cell) a left
## strip swaps to the drawn left strike, rivet_eq_<weapon>_left_strike.png, one cell
## (the baton's: it334, laid by rivet_windup_cells.py). `--rivet-left-strike=off` = the left facing
## and the game smear through the swing (the before).

const FILE: String = "_windup.png"
const LEFT_FILE: String = "_left_windup.png"
const LEFT_STRIKE_FILE: String = "_left_strike.png"
const CELLS: int = 2
const LEFT_CELLS: int = 1
const SIDE: int = 0
const CAM: int = 1
## n15: two-handed blades with a drawn left set (it338 strips, it346 wind-ups, it342 strikes):
## turned left they take it as a one-handed hold does (the mirror put the hose arm far). Their
## left strike shows only where the blade's strike is drawn (RivetSwipe.blade_drawn: straight
## left); on the left diagonals the left facing stands under the game's arc.
## --rivet-blade-left=off (CastFlags) = the mirrored right strip (the before).
const BLADE_LEFT: Array[StringName] = [&"katana", &"plasma_sword", &"chainsaw"]
static var enabled: bool = true
static var left_strike: bool = true
static var blade_left: bool = true


## True when `weapon` turned left draws its drawn left strip (never mirrored): a one-handed hold
## (RivetStrips.ONE_HAND) or, under blade_left, a BLADE_LEFT blade.
static func left_drawn(weapon: StringName) -> bool:
	return RivetStrips.ONE_HAND.has(weapon) or (blade_left and BLADE_LEFT.has(weapon))


## The wind-up strip while `rig`'s strike winds up on the weapon's equipped strip or its drawn
## left strip (`path`; a walk grid, a reload or a knock keeps its own) and the weapon has one, else
## `path`.
static func path_or(rig: CutRig, art: String, weapon: StringName, path: String) -> String:
	if not enabled or weapon == &"":
		return path
	var eq: String = RivetStrips.DIR + art + "/rivet_eq_" + String(weapon)
	var w: String = ""
	if not winding(rig):
		if left_strike and path == eq + "_left.png" and struck(rig) and _strikes_left(rig, weapon):
			w = eq + LEFT_STRIKE_FILE
	elif path == eq + ".png":
		w = eq + FILE
	elif path == eq + "_left.png":
		w = eq + LEFT_FILE
	return w if w != "" and RivetStrips.has_file(w) else path


## n15: a blade's drawn left strike only where its strike is drawn (BLADE_LEFT).
static func _strikes_left(rig: CutRig, weapon: StringName) -> bool:
	return not BLADE_LEFT.has(weapon) or RivetSwipe.blade_drawn(RivetFrames.oct_of(rig))


## True while the view's strike clip is inside its wind-up phase.
static func winding(rig: CutRig) -> bool:
	var t: float = rig.clips.strike_t
	return t >= 0.0 and t < rig.clips.strike_ph.x


## True while the view's strike clip is past its wind-up (the strike and its recovery).
static func struck(rig: CutRig) -> bool:
	var t: float = rig.clips.strike_t
	return t >= 0.0 and t >= rig.clips.strike_ph.x


## True for a strip this slot owns (a wind-up strip or the drawn left strike).
static func owns(path: String) -> bool:
	return path.ends_with(FILE) or path.ends_with(LEFT_STRIKE_FILE)


## The cell count of a wind-up or left strike strip at `path` (RivetStrips.cells_of).
static func cells_of(path: String) -> int:
	return LEFT_CELLS if path.ends_with(LEFT_FILE) or path.ends_with(LEFT_STRIKE_FILE) else CELLS


## A short strip's cell and mirror for octant `o`: the wind-up strip's camera cell facing the
## camera (where a melee strike draws its camera cell), else its side cell (mirrored on the left);
## the left wind-up's one cell unmirrored; any other short strip RivetStrips.small_cell unmirrored.
static func small_of(o: int, cells: int) -> Vector2i:
	if cells == LEFT_CELLS:
		return Vector2i(SIDE, 0)
	if cells != CELLS:
		return Vector2i(RivetStrips.small_cell(o, cells), 0)
	if o == 2:
		return Vector2i(CAM, 0)
	return Vector2i(SIDE, RivetFrames.LEFT[o])

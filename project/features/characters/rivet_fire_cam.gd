class_name RivetFireCam
extends RefCounted
## n10 rivet: a shot at 45-67 deg (octant 1) was fired from the 3/4 facing, whose gun is at image
## left with no muzzle point (the five one-handers), so the flash sat about a metre off him. Their
## camera fire cell lies within GUN_TOL of that aim, so it draws instead. View only: writes no sim.

const META: StringName = &"rivet_fire_cam"

## false = the facing cell (the before).
static var on: bool = true


## True while this burst draws the camera fire cell (RivetFrames.cell_of).
static func drawn(rig: CutRig) -> bool:
	return rig.get_meta(META, false) == true


## Whether the camera cell's gun covers `aim` for a burst at octant `o` (RivetStrips.fires_drawn).
static func covers(weapon: StringName, o: int, aim: float, art: String, slack: float) -> bool:
	var off: float = absf(angle_difference(aim, PI * 0.5))
	return off <= RivetStrips.GUN_TOL + slack and applies(weapon, o, art)


## Latches the cell for this tick. `shows`: a fire cell draws at all; `drew`: it drew last tick.
static func step(
	rig: CutRig, weapon: StringName, o: int, aim: float, shows: bool, drew: bool
) -> void:
	var was: bool = drawn(rig)
	var art: String = ViewMode.shared().art
	var use: bool = shows and not is_nan(aim) and applies(weapon, o, art)
	rig.set_meta(META, use and _past_edge(aim, drew, was))


## A one-hander at octant 1 whose facing has no muzzle point and whose camera cell has one.
static func applies(weapon: StringName, o: int, art: String) -> bool:
	if not on or o != 1:
		return false
	var eq: String = RivetStrips.strip_of(art, weapon)
	var cam: Vector2 = RivetMuzzle.point(eq, RivetFrames.Eq.FIRE_CAM)
	return RivetMuzzle.point(eq, 1).x < 0.0 and cam.x >= 0.0


## Past 45 deg the camera cell is the nearer drawn gun; a burst keeps its cell inside FIRE_HOLD.
static func _past_edge(aim: float, drew: bool, was: bool) -> bool:
	var hold: float = (
		0.0 if not drew else (-RivetStrips.FIRE_HOLD if was else RivetStrips.FIRE_HOLD)
	)
	return angle_difference(0.0, aim) > RivetStrips.GUN_TOL + hold

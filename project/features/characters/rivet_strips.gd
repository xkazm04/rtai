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
## Streams drawn as a long flame in the fire cells (fires_drawn).
const CONE: Array[StringName] = [&"flamethrower"]
const CONE_TOL: float = PI / 8.0
## A cone burst that went off its drawn flame (rig meta): it keeps the facing cell until the fire
## latch clears, which outlives the stream by RivetFrames.FIRE_TICKS while the aim swings.
const CONE_OFF: StringName = &"rivet_cone_off"
static var _logged: Dictionary[StringName, bool] = {}


## The strip under view art `art` for the weapon out ("" = bare claw): the weapon's own strip if
## cut, else the base; "" when the art has no strips (top, or an art key without Rivet frames).
static func strip_of(art: String, weapon: StringName) -> String:
	var base: String = DIR + art + "/" + BASE
	if art.is_empty() or not ResourceLoader.exists(base):
		return ""
	var eq: String = DIR + art + "/rivet_eq_" + String(weapon) + ".png"
	return eq if weapon != &"" and ResourceLoader.exists(eq) else base


## A one-handed hold turned left: its drawn left strip, else the base (the fallback, logged once).
static func left_of(art: String, weapon: StringName) -> String:
	var path: String = DIR + art + "/rivet_eq_" + String(weapon) + "_left.png"
	if ResourceLoader.exists(path):
		return path
	if not _logged.has(weapon):
		_logged[weapon] = true
		Log.info("rivet", "no drawn left view for %s at %s: base left + held part" % [weapon, art])
	return DIR + art + "/" + BASE


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
	if not CONE.has(weapon):
		return true
	var off: float = 0.0 if is_nan(aim) else absf(angle_difference(aim, o * PI * 0.25))
	return o in [0, 2, 4] and off <= CONE_TOL


## The aim's screen angle while aiming, else NAN.
static func aim_of(rig: CutRig) -> float:
	var to: Vector2 = rig.aim_at - rig.global_position
	return to.angle() if rig.aiming and to.length() > 1.0 else NAN

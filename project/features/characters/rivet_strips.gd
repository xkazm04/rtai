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

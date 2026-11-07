class_name PadGlyphs
extends RefCounted
## d9-handheld: the pad prompts follow the pad's family (Valve's Deck Verified rule: "on-screen
## glyphs must match the inputs being used"). The prompts are written in the Xbox-style layout
## ("A", "RB", "LT"); a PlayStation or a Nintendo-layout pad gets its own names for the same
## positions. The family is the USB vendor id from Input.get_joy_info (the engine writes it as a
## decimal string), else the pad's name; a Steam Input virtual pad reads as Xbox-style (the
## layout Steam presents). Handheld profiles only (DeviceProfile.is_handheld): the desktop game
## keeps its labels (docs/decisions.md).

const SONY: int = 0x054C
const NINTENDO: int = 0x057E
const RELABEL: Dictionary[StringName, Dictionary] = {
	&"playstation":
	{
		"A": "Cross",
		"B": "Circle",
		"X": "Square",
		"Y": "Triangle",
		"LB": "L1",
		"RB": "R1",
		"LT": "L2",
		"RT": "R2",
		"Back": "Create",
		"Start": "Options",
	},
	&"nintendo":
	{
		"A": "B",
		"B": "A",
		"X": "Y",
		"Y": "X",
		"LB": "L",
		"RB": "R",
		"LT": "ZL",
		"RT": "ZR",
		"Back": "-",
		"Start": "+",
	},
}


## The family of a pad from its get_joy_info dictionary and its name: xbox, playstation, nintendo.
static func family(info: Dictionary, pad_name: String) -> StringName:
	if info.has("steam_input_index"):
		return &"xbox"
	var raw: Variant = info.get("vendor_id", 0)
	var vendor: int = raw if raw is int else str(raw).to_int()
	var lower: String = pad_name.to_lower()
	if (
		vendor == SONY
		or lower.contains("dualsense")
		or lower.contains("ps4")
		or lower.contains("ps5")
	):
		return &"playstation"
	if vendor == NINTENDO or lower.contains("nintendo") or lower.contains("joy-con"):
		return &"nintendo"
	return &"xbox"


## `xbox_label` as a pad of `fam` names it (unchanged for xbox and unknown labels).
static func relabel(xbox_label: String, fam: StringName) -> String:
	var names: Dictionary = RELABEL.get(fam, {})
	return str(names.get(xbox_label, xbox_label))


## The family of the first connected pad under a handheld profile; xbox on the desktop.
static func active_family() -> StringName:
	var pads: Array[int] = Input.get_connected_joypads()
	if pads.is_empty() or not DeviceProfile.shared().is_handheld():
		return &"xbox"
	return family(Input.get_joy_info(pads[0]), Input.get_joy_name(pads[0]))


## `label` as this run's pad names it.
static func label(xbox_label: String) -> String:
	return relabel(xbox_label, active_family())

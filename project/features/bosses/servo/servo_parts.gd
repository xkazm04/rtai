class_name ServoParts
extends RefCounted
## n8: Servo's part textures under the active view (ServoArt.path per part), reloaded when the
## view's art key changes: the combined view hard-swaps 70 -> 55 as the boss engages, and the
## parts follow the key (d8 loaded them once, at the live pitch). Render only.

## The pads' art: pad_hazard (tools/art/servo_pad_rim.py: the sheet's hazard rim) or pad (it13).
const PAD: StringName = &"pad_hazard"
const NAMES: Array[StringName] = [
	&"head",
	&"pad",
	&"pelvis",
	&"torso",
	&"rack",
	&"rack3",
	&"thigh",
	&"shin",
	&"arm",
	PAD,
	&"drone"
]

var tex: Dictionary[StringName, Texture2D] = {}
var _art: String = "?"  # never a view's key: the first sync loads


## Loads the parts when the view's art key changed since the last call; true when it did.
func sync(names: Array[StringName] = NAMES) -> bool:
	if ServoArt.key() == _art:
		return false
	_art = ServoArt.key()
	tex = ServoArt.parts(names)
	return true

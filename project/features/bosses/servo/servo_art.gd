class_name ServoArt
extends RefCounted
## d8 bosses: Servo's part art per view row (render only). Parts drawn for an angled view's pitch
## live in art/p<pitch>/ (p55 for `tilt`, from servo_55.png: ochre enamel, tan steel, copper
## hoses; tools/art/servo_parts_pitch.py cuts them to today's part sizes, so ServoRig's scale
## holds). A part with no file for the pitch, and every part straight down (`top`), loads today's.

const DIR: String = "res://features/bosses/servo/art/p%d/%s.png"


## The texture path ServoRig loads for part `n` under the active view.
static func path(n: StringName) -> String:
	return path_at(n, ViewMode.shared().pitch_deg)


static func path_at(n: StringName, pitch_deg: float) -> String:
	if pitch_deg < 90.0:
		var p: String = DIR % [roundi(pitch_deg), n]
		if ResourceLoader.exists(p):
			return p
	return ServoRig.ART % n

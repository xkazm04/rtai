class_name TakeArgs
extends RefCounted
## n31 foes: value checks for play_take.gd's own flags.


static func valid(flag: String, s: String) -> bool:
	var ok: bool = true
	match flag:
		"--take-wave", "--take-tick":
			ok = s.is_valid_int() and s.to_int() >= int(flag == "--take-wave")
		"--take-s":
			ok = s.is_valid_float() and s.to_float() >= 1.0 and s.to_float() <= 120.0
		"--frames-out":
			ok = s.is_absolute_path()
		"--zoom-ppm":
			ok = s in ["32", "64"]
		"--follow":
			ok = not s.is_empty()
		"--foe-moves":
			ok = s in ["legacy", "split"]
		"--stalk":
			ok = s.is_empty()
	return ok

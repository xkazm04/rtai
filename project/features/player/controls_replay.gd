class_name ControlsReplay
extends RefCounted
## Player input is decoded with the bindings and initial wheel selection used at recording.
## The first replay format omitted both fields and its player always used legacy controls.


static func bind(loop: SimLoop, actions: PlayerActions) -> void:
	var controls: Dictionary = {"mode": "wheel" if actions.wheel else "legacy"}
	if actions.wheel and ControlsMode.start_drawn():
		controls["wheel_start"] = "drawn"
	loop.set_meta(&"record_options", {"controls": controls})


## Apply the tape's options before constructing the replay world. A CLI replay exits afterwards.
## In-process scenarios restore LaunchArgs when their verification finishes.
static func load_for_playback(path: String) -> ReplayLog:
	var log: ReplayLog = ReplayLog.load_file(path)
	if log == null:
		return null
	var header: Dictionary = log.get_meta(&"record_options", {})
	var recorded: Variant = header.get("controls", {})
	if not recorded is Dictionary:
		Log.error("replay", "invalid recorded controls in %s" % path)
		return null
	var controls: Dictionary = recorded
	var mode: String = str(controls.get("mode", "legacy"))
	var start: String = str(controls.get("wheel_start", "hands"))
	if mode not in ["wheel", "legacy"] or start not in ["hands", "drawn"]:
		Log.error("replay", "invalid recorded controls in %s" % path)
		return null
	var args: PackedStringArray = LaunchArgs.unknown()
	for flag: String in LaunchArgs.KNOWN_FLAGS:
		if LaunchArgs.has(flag):
			@warning_ignore("return_value_discarded")
			args.append(flag + "=" + LaunchArgs.value(flag))
	LaunchArgs.parse(args + PackedStringArray(["--controls=" + mode, "--wheel-start=" + start]))
	return log

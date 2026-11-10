class_name CastFlags
extends RefCounted
## d7-calls (2026-11-05): the owner's Rivet picks are the defaults (cast-1 size 0.89, cast-8 plain
## head, cast-9 light tan); these launch flags bring back the old defaults for an A/B in the exe
## (the arena, the city block and quest 1 under --rigs; quest 1's sprite Rivet is a capture):
## --rivet-form=<RivetPlan form id> (wide = the 1.2x n5-cast size), --rivet-visor (the ink visor
## slot), --rivet-tan=<0..1> (1 = the full tan), --gun-grey (look-8: held guns in the old grey
## print, not the tan inks); d9: --rivet-height=<m> (his height before PlayerScale.k; n9 builds
## 1.65, p55 in proportion); n9: --rivet-flame=cone (d9's flamer), =side (no diagonal cells),
## =all (the fire cell at any aim),
## --rivet-walk=4 (d9's 4-frame walk by the gait phase), --rivet-reload=off (no drawn reload),
## n13: --rivet-windup=off (no drawn wind-up cell).
## Read once, before the first plan or material.

static var _read: bool = false


static func apply(args: PackedStringArray = OS.get_cmdline_user_args()) -> void:
	if _read:
		return
	_read = true
	for arg: String in args:
		if arg.begins_with("--rivet-form="):
			RivetPlan.form = StringName(arg.substr(13))
		elif arg == "--rivet-visor":
			PartMaterials.head_lod_fill = PartMaterials.HEAD_VISOR_FILL
		elif arg.begins_with("--rivet-tan="):
			PartMaterials.core_tan = clampf(arg.substr(12).to_float(), 0.0, 1.0)
		elif arg == "--gun-grey":
			PartMaterials.gun_tan = 0.0
		elif arg.begins_with("--rivet-height="):
			var m: float = clampf(arg.substr(15).to_float(), 0.8, 2.5)
			RivetFrames.height_k = m / RivetFrames.HEIGHT_M
		elif arg == "--rivet-flame=cone":
			RivetStrips.cone = RivetStrips.CONE_D9.duplicate()
		elif arg == "--rivet-flame=side":
			RivetStrips.diag = false
		elif arg == "--rivet-flame=all":
			RivetStrips.flame_all = true
		elif (
			arg.begins_with("--rivet-walk=")
			or arg.begins_with("--rivet-swipe")
			or arg.begins_with("--rivet-bob")
		):
			_walk(arg)
		elif arg == "--rivet-knock=off":
			RivetKnock.enabled = false
		elif arg == "--rivet-reload=off":
			RivetReload.enabled = false
		elif arg == "--rivet-windup=off" or arg == "--rivet-left-strike=off":
			_windup(arg)
		elif arg == "--ghost-voice=facing":  # n10: the voice at his facing's own left, on his head
			GhostApparition.clear_figure = false


## n13 --rivet-windup=off: the strike cell through the wind-up (the before); n15
## --rivet-left-strike=off: the left facing + the game smear through a left swing (the before).
static func _windup(arg: String) -> void:
	if arg == "--rivet-windup=off":
		RivetWindup.enabled = false
	else:
		RivetWindup.left_strike = false


## --rivet-walk=<mode>; n11: --rivet-swipe=off (one drawn strike cell), --rivet-bob=drawn (no damp).
static func _walk(arg: String) -> void:
	match arg:
		"--rivet-walk=bob":
			RivetWalk.enabled = false
		"--rivet-walk=4":
			RivetWalk.frames = 4
		"--rivet-walk=walk8":
			RivetWalk.run = false
		"--rivet-walk-armed=off":
			RivetWalk.armed = false
		"--rivet-stride=off":
			RivetStride.enabled = false
		"--rivet-swipe=off":
			RivetSwipe.enabled = false
		"--rivet-bob=drawn":
			RivetBob.enabled = false
		_:
			pass

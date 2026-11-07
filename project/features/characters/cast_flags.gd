class_name CastFlags
extends RefCounted
## d7-calls (2026-11-05): the owner's Rivet picks are the defaults (cast-1 size 0.89, cast-8 plain
## head, cast-9 light tan); these launch flags bring back the old defaults for an A/B in the exe
## (the arena, the city block and quest 1 under --rigs; quest 1's sprite Rivet is a capture):
## --rivet-form=<RivetPlan form id> (wide = the 1.2x n5-cast size), --rivet-visor (the ink visor
## slot), --rivet-tan=<0..1> (1 = the full tan), --gun-grey (look-8: held guns in the old grey
## print, not the tan inks); d9: --rivet-height=<m> (his drawn standing height at play, 1.1 built;
## p55 in proportion). Read once, before the first plan or material.

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
			var m: float = clampf(arg.substr(15).to_float(), 0.8, 2.0)
			RivetFrames.height_k = m / RivetFrames.HEIGHT_M
		elif arg == "--rivet-walk=bob":
			RivetWalk.enabled = false

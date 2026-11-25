extends "res://dev/cast/cast_size_beside.gd"
## Robot thug A's card (row forced on in this dev process only) spawned beside a spawned patrol cop
## and Rivet on the fight street, all standing, front three-quarter, at 64 and 32 px/m, 70 deg.
## Writes build/look/n29-thug/size/ for tools/art/cast_size_measure.py (same shots as size beside).


func _ready() -> void:
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root: String = ProjectSettings.globalize_path("res://")
	_dir = root.path_join("../build/look/n29-thug/size").simplify_path()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_dir)
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	_ppm = PPMS[0]
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	_cop = _arena.squad_ai.spawn_member(_arena, CENTRE, &"patrol_cop")
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(_cop)
	var foes: Dictionary[StringName, Fighter] = {}
	foes[FoeThugCardView.ID] = _arena.squad_ai.spawn_member(_arena, CENTRE, FoeThugCardView.ID)
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(foes[FoeThugCardView.ID])
	for ppm: int in PPMS:
		if not await _pass(ppm, foes):
			_fail("pass %d px/m failed" % ppm)
			return
	var file: FileAccess = FileAccess.open(_dir.path_join("shots.json"), FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	file.store_string(JSON.stringify({"shots": _shots}, "  ", true))
	file.close()
	Log.info("cast", "thug beside saved %d shots to %s" % [_shots.size(), _dir])
	get_tree().quit(0)

extends "res://dev/cast/cast_size_beside.gd"
## Robot thug A's card (the shipped row, no preview enable) spawned beside a spawned patrol cop
## and Rivet on the fight street, all standing, front three-quarter, at 64 and 32 px/m, 70 deg
## (GTAI_CAST_PITCH=55 for 55 deg, writing size55/ instead).
## Writes build/look/n29-thug/size/ for tools/art/cast_size_measure.py (same shots as size beside).


func _ready() -> void:
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root: String = ProjectSettings.globalize_path("res://")
	var pitch: int = 55 if OS.get_environment("GTAI_CAST_PITCH") == "55" else 70
	var sub: String = "size" if pitch == 70 else "size55"
	if _shadow_mode():
		sub = "shadow%d" % pitch
	_dir = root.path_join("../build/look/n30-c01/thug/" + sub).simplify_path()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_dir)
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(float(pitch))
	ViewMode.shared().art = "p%d" % pitch
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


func _shadow_mode() -> bool:
	return OS.get_environment("GTAI_CAST_SHADOW") == "1"


## GTAI_CAST_SHADOW=1: the same-pose toggle. Beside still, then the street's shadow layer AND the
## card's own contact rings hidden (the card draws them as a child behind it), everyone standing.
func _take(stem: String, foe: Fighter) -> void:
	if not _shadow_mode():
		await super._take(stem, foe)
		return
	var tag: String = "%s_%d" % [stem, _ppm]
	_save(tag + ".png")
	_shadow.hide()
	var rings: Array[Node2D] = []
	var rig: CutRig = _host.robots.rig_for(foe.id) if foe != null and _host.robots != null else null
	var card: Node2D = rig.get_meta(FoeThugCardView.CARD) if rig != null else null
	if card != null:
		for child: Node in card.get_children():
			if child is Node2D and (child as Node2D).show_behind_parent:
				rings.append(child)
	for ring: Node2D in rings:
		ring.modulate.a = 0.0
	await _settle(2)
	_save(tag + "_body.png")
	_shots.append({"tag": tag, "rings_hidden": rings.size(), "ppm": _ppm})
	for ring: Node2D in rings:
		ring.modulate.a = 1.0
	_shadow.show()

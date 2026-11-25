extends "res://dev/cast/cast_size_beside.gd"
## n30 c04b: three patrol cops (build jitter min id 710, unjittered id 793, max id 230; Fighter.id
## is forced right after the spawn) in one row with the card foes and Rivet, 64 px/m tilt 70.
## Writes build/look/n30-c04b/: row_64.png, row_64_body.png, row_64_gone_<who>.png, shots.json.

const COP_IDS: Array[int] = [710, 793, 230]
const SPACING: float = 2.4
const FOES: Array[StringName] = [
	&"contractor", &"appliance_warden", &"rocket_trooper", &"robot_gunner", &"robot_thug"
]


func _ready() -> void:
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_dir = (
		ProjectSettings.globalize_path("res://").path_join("../build/look/n30-c04b").simplify_path()
	)
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_dir)
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	_ppm = 64
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	var row: Dictionary[String, Fighter] = {}
	for cop_id: int in COP_IDS:
		var cop: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, &"patrol_cop")
		cop.id = cop_id
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(cop)
		row["cop_%d" % cop_id] = cop
	for key: StringName in FOES:
		var foe: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, key)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(foe)
		row[String(key)] = foe
	row["rivet"] = _arena.rivet
	await _take_row(row)
	var file: FileAccess = FileAccess.open(_dir.path_join("shots.json"), FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	file.store_string(JSON.stringify({"shots": _shots}, "  ", true))
	file.close()
	Log.info("cast", "cop jitter saved %d shots to %s" % [_shots.size(), _dir])
	get_tree().quit(0)


func _take_row(row: Dictionary[String, Fighter]) -> void:
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	var homes: Dictionary[String, Vector2] = {}
	var x: float = -SPACING * (row.size() - 1) / 2.0
	for who: String in row:
		homes[who] = CENTRE + Vector2(x, 0.0)
		x += SPACING
	for other: Fighter in _arena.hostiles:
		other.pos = PARK
	_place(row, homes)
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	await _settle(SETTLE)
	_save("row_64.png")
	_shadow.hide()
	await _settle(2)
	_save("row_64_body.png")
	for who: String in row:
		var point: Vector2 = (
			get_viewport().get_canvas_transform() * (homes[who] * SimConst.PX_PER_M)
		)
		_shots.append(_entry("row_64", who, point, row[who]))
		row[who].pos = PARK + Vector2(0.0, 30.0)
		await _settle(4)
		_save("row_64_gone_%s.png" % who)
		row[who].pos = homes[who]
		await _settle(6)
	_shadow.show()


func _place(row: Dictionary[String, Fighter], homes: Dictionary[String, Vector2]) -> void:
	for who: String in row:
		row[who].pos = homes[who]
		row[who].facing = LOOK.normalized()

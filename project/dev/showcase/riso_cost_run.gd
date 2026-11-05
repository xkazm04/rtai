class_name RisoCostRun
extends D5CostRun
## n5-look: GPU cost of the riso layer (look_d5.gdshader riso_print) on the D5CostRun frame
## (16 full rigs at 64 px/m, vsync off). Tiers: "d4" (the world layer off), "d5" (look_d5
## `world`, riso 0 = the old print), "riso" (look_d5 `world_riso`: the shipped middle ground),
## then d5 and riso again (the repeat shows the noise). Writes <out>/riso-cost.json.

const RISO_TIERS: Array[String] = ["d4", "d5", "riso", "d5b", "risob"]


func shoot() -> int:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var rid: RID = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	_frame_at(COST_ZOOM)
	var data: Dictionary = _params()
	var report: Dictionary = {
		"adapter": RenderingServer.get_video_adapter_name(),
		"frames": FRAMES,
		"ppm": roundi(COST_ZOOM * PX),
		"tiers": {},
	}
	var ok: bool = DirAccess.make_dir_recursive_absolute(out_dir) == OK
	for tier: String in RISO_TIERS:
		var key: String = "world_riso" if tier.begins_with("riso") else "world"
		var u: Dictionary = data.get(key, {})
		for k: String in u:
			var v: Variant = u[k]
			overlay.set_shader_parameter(k, _vec(v) if v is Array else v)
		var dial: float = u.get("riso", 0.0)
		overlay.set_shader_parameter("riso", dial)
		overlay.set_shader_parameter("amount", 0.0 if tier == "d4" else amount_at(COST_ZOOM))
		report["tiers"][tier] = await _measure(rid)
		var img: Image = get_viewport().get_texture().get_image()
		ok = img.save_png(out_dir.path_join("riso-cost-%s.png" % tier)) == OK and ok
	var fh: FileAccess = FileAccess.open(out_dir.path_join("riso-cost.json"), FileAccess.WRITE)
	if fh == null:
		return 1
	ok = fh.store_string(JSON.stringify(report, "  ", true)) and ok
	fh.close()
	printerr(JSON.stringify(report))
	return 0 if ok else 1


func _params() -> Dictionary:
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(PARAMS)) != OK or not json.data is Dictionary:
		return {}
	return json.data

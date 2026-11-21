extends "res://dev/gauntlet/gauntlet.gd"
## Windowed evidence from the live gauntlet. Set GTAI_GAUNTLET_STILLS to the output directory.
## The first offer comes from a cleared fight. Template stills use the same rolling street.

var _out: String


func _ready() -> void:
	_out = OS.get_environment("GTAI_GAUNTLET_STILLS")
	if not _out.is_absolute_path() or DirAccess.make_dir_recursive_absolute(_out) != OK:
		Log.error("gauntlet-stills", "set GTAI_GAUNTLET_STILLS to a writable absolute directory")
		get_tree().quit(2)
		return
	ViewMode.select("tilt70")
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super._ready()
	if session == null or pick_view == null:
		Log.error("gauntlet-stills", "open the windowed human entry")
		get_tree().quit(2)
		return
	set_physics_process(false)
	Log.info(
		"gauntlet-stills", "window at %s, view %s" % [get_window().position, ViewMode.shared().id]
	)
	await get_tree().process_frame
	var walker: GauntletWalker = GauntletWalker.new()
	walker.configure(&"average", &"random", run.seed)
	walker.bind(run, session)
	session.world.loop().set_input(walker)
	while waves.pending.is_empty() and not waves.done and session.tick() < 7200:
		session.step()
	if waves.pending.is_empty() or not await _save("pick_screen_32"):
		Log.error("gauntlet-stills", "failed to capture the first cleared wave")
		get_tree().quit(1)
		return
	# Activate the real UI button, just as a pointer release does.
	(pick_view._cards.get_child(0) as Button).pressed.emit()
	hud.hide()
	var captured: bool = await _segments()
	await _close_capture(captured)


func _close_capture(captured: bool) -> void:
	# Retire rendered rigs and their canvases while the renderer can still drain a frame.
	set_process(false)
	for child: Node in get_children():
		if child != session.world:
			child.queue_free()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var closed: bool = _finish()
	await get_tree().process_frame
	get_tree().quit(0 if captured and closed else 1)


func _segments() -> bool:
	var table: DataTable = DataTable.open(GauntletStreet.TABLE, GauntletStreet.SCHEMA)
	var found: Array[StringName] = []
	var wanted: int = table.array(table.raw, "segments").size()
	var arena: CombatArena = session.stage.arena
	for i: int in 200:
		var block: GauntletSegment = session.street.current()
		if not found.has(block.id):
			var at: Vector2 = Vector2(block.start_x + block.length_m * 0.5, 0)
			arena.rivet.pos = session.stage.walls.push_out(at, arena.rivet.radius_m)
			if not await _save("segment_%s_32" % block.id):
				return false
			found.append(block.id)
			if found.size() == wanted:
				return true
		arena.rivet.pos.x = block.end_x() + 0.1
		session.street.step(session.stage, session.tick())
	Log.error("gauntlet-stills", "captured %d of %d street templates" % [found.size(), wanted])
	return false


func _save(stem: String) -> bool:
	for i: int in 4:
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var shot: Image = get_viewport().get_texture().get_image()
	var path: String = _out.path_join(stem + ".png")
	if shot.get_size() != Vector2i(1920, 1080) or shot.save_png(path) != OK:
		Log.error("gauntlet-stills", "could not save 1920x1080 to %s" % path)
		return false
	var ppm: float = get_viewport().get_canvas_transform().x.length() * SimConst.PX_PER_M
	Log.info("gauntlet-stills", "saved %s at tick %d, %.1f px/m" % [stem, session.tick(), ppm])
	return true

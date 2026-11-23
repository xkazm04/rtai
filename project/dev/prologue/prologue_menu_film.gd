extends Node
## Accelerates the two real worlds between stills; no player profile is written.

var _drive: PrologueMenuDrive = PrologueMenuDrive.new()
var _out: String
var _stills: String


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_out = LaunchArgs.value("--result")
	_stills = ArenaArgs.parse().text("--film-dir")
	if not LaunchArgs.has("--bot") or not _out.is_absolute_path():
		_fail("requires --bot and an absolute --result")
		return
	if _stills != "" and (not _stills.is_absolute_path() or DisplayServer.get_name() == "headless"):
		_fail("--film-dir requires an absolute directory and a window")
		return
	var tree: SceneTree = get_tree()
	if not tree.current_scene is Quest1Game:
		if tree.change_scene_to_file("res://boot/quest1.tscn") != OK:
			_fail("could not load the slice menu")
			return
		await tree.scene_changed
	var game: Quest1Game = tree.current_scene as Quest1Game
	game.save_path = ""
	var issue: String = _drive.press(game)
	if issue == "" and _stills != "":
		issue = await _capture("newgame-prologue-first")
	while issue == "" and _drive.first_line_tick < 0:
		for i: int in 180:
			issue = _drive.step()
			if issue != "" or _drive.first_line_tick >= 0:
				break
		await tree.process_frame
	if issue == "" and _stills != "":
		issue = await _opening_still(game)
	if issue == "":
		issue = _write_result()
	if issue != "":
		_fail(issue)
	else:
		tree.quit()


func _opening_still(game: Quest1Game) -> String:
	var lines: QuestLinePlayer = game.session.system.runner.lines
	while (
		lines.current != null and lines.current.id == _drive.FIRST_LINE and not lines.fully_typed()
	):
		game.session.step()
	if lines.current == null or lines.current.id != _drive.FIRST_LINE:
		return "the first line ended before its full text was visible"
	return await _capture("handover-quest1-first-line")


func _capture(label: String) -> String:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var frame: Image = get_viewport().get_texture().get_image()
	if frame == null or frame.get_size() != Vector2i(1920, 1080):
		return "capture requires a 1920x1080 viewport"
	if DirAccess.make_dir_recursive_absolute(_stills) != OK:
		return "could not create the stills directory"
	var path: String = _stills.path_join(label + ".png")
	return "" if frame.save_png(path) == OK else "could not save " + path


func _write_result() -> String:
	var payload: String = JSON.stringify(_drive.result(), "  ", true)
	if DirAccess.make_dir_recursive_absolute(_out.get_base_dir()) != OK:
		return "could not create the result directory"
	var file: FileAccess = FileAccess.open(_out, FileAccess.WRITE)
	if file == null or not file.store_string(payload + "\n"):
		return "could not write " + _out
	Log.info("newgame", payload)
	return ""


func _fail(reason: String) -> void:
	Log.error("newgame", reason)
	get_tree().quit(1)

extends Node
## The save notice on the real game's screen: quest 1 is played through the bound input to beat 3
## (two autosaves, the two slots), the newest slot is flipped, and the title card's Continue is
## pressed. The loader falls back to the older slot; the HUD shows the one-line notice. Frame
## captured at 32 px/m (on foot). Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/save_notice_frame.tscn
##     -- --out=<dir>

const ROOT: String = "user://save_notice_frame"
const STOP_POINT: String = "as-b3-toner-room"
const TIMEOUT_TICKS: int = 25 * 60 * SimClock.TICK_RATE
const SETTLE_FRAMES: int = 90


func _ready() -> void:
	var out: String = "user://save_notice_frame_out"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	SaveKit.wipe(ROOT)
	Save.use_root(ROOT)
	var game: Quest1Game = (load("res://boot/quest1.tscn") as PackedScene).instantiate()
	game.settings_path = ""
	add_child(game)
	game.card.start_pressed.emit()
	var failure: String = _play(game.session)
	if failure == "":
		var slots: SaveSlots = Save.slots()
		var newest: int = 0 if slots.read(0).seq() > slots.read(1).seq() else 1
		SaveKit.flip(slots.slot_path(newest), 70)
		game.card.continue_pressed.emit()
		for i: int in SETTLE_FRAMES:
			await get_tree().process_frame
		failure = _capture(out, game)
	Save.use_root(Save.DEFAULT_ROOT)
	SaveKit.wipe(ROOT)
	if failure != "":
		Log.error("save_notice_frame", failure)
	get_tree().quit(0 if failure == "" else 1)


func _play(s: Quest1Session) -> String:
	s.world.set_process(false)
	var driver: CollectCallInputDriver = CollectCallInputDriver.new(s.stage, s.system)
	var fired: Array[String] = []
	s.autosave.sink = func(point: String, body: Dictionary, meta: Dictionary) -> void:
		fired.append(point)
		Save.autosave(point, body, meta)
		Save.flush()
	while not fired.has(STOP_POINT) and s.tick() < TIMEOUT_TICKS and not driver.done():
		driver.act()
		s.step()
		s.autosave.poll()
	driver.release()
	return "" if fired.has(STOP_POINT) else "autosaves fired %s" % [fired]


func _capture(out: String, game: Quest1Game) -> String:
	if game.view == null or game.view.notice.text() == "":
		return "no notice on screen after Continue"
	var dir_err: Error = DirAccess.make_dir_recursive_absolute(out)
	var image: Image = get_viewport().get_texture().get_image()
	if dir_err != OK or image.save_png(out.path_join("save-notice-32ppm.png")) != OK:
		return "could not write the frame to %s" % out
	Log.info("save_notice_frame", "notice: %s -> %s" % [game.view.notice.text(), out])
	return ""

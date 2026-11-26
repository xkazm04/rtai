extends Node
## n31 ghost 03 (dev only): stills of Tonnage's drop deploy at named ticks after the press, in
## the gauntlet street at tilt 70 and --ppm (32 or 64), 1920x1080, one sim tick a frame.
## --at=<since press,...> names the stills (beats-<ppm>-p<since>.png in --out).
## --kill adds a one-hit cop 1 m from the drop centre (inside crush_m): his death on film.

const KNOWN_FLAGS: PackedStringArray = ["--ppm", "--out", "--at", "--position", "--kill"]
const RESOLUTION: Vector2i = Vector2i(1920, 1080)
const TAIL_TICKS: int = 4

var input: GhostN31BeatsInput = GhostN31BeatsInput.new()
var bus: EventBus = EventBus.new()
var data: DataStore = DataStore.new()
var session: GauntletSession
var street: GauntletView
var ppm: int
var out_dir: String
var wanted: Array[int] = []


func _ready() -> void:
	set_process(false)
	var args: ArenaArgs = ArenaArgs.parse()
	ppm = args.text("--ppm", "64").to_int()
	out_dir = args.text("--out")
	input.kill = args.has("--kill")
	for part: String in args.text("--at", "0,7,22,27,30,60,110").split(",", false):
		wanted.append(part.to_int())
	if ppm not in [32, 64] or not out_dir.is_absolute_path():
		_fail("use --ppm=32|64 and an absolute --out")
		return
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var win: Window = get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	win.borderless = true
	win.position = Vector2i(0, 1440)
	win.size = RESOLUTION
	ViewMode.select("tilt70")
	process_priority = -1000
	if not _open():
		_fail("could not open the gauntlet stage or rigs")
		return
	set_process(true)


func _open() -> bool:
	var run: GauntletRun = GauntletRun.new()
	run.seed = 24
	session = GauntletSession.open_street(bus, data, run, input)
	if session == null:
		return false
	add_child(session.world)
	session.world.set_process(false)
	var r: Fighter = session.stage.arena.rivet
	r.pos = Vector2(13.0, 0.0)
	input.bind(session.stage)
	session.pilot.ghosts.forms.apply_locks([HaulerStage.GHOST])
	session.pilot.ghosts.transform_unlocked = false
	street = GauntletView.new(session.street)
	street.px_per_m = ppm
	street.focus = input.spot + Vector2(0.0, -0.6)
	street.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(street)
	street.hud_view.hide()
	var rigs: ArenaRigs = ArenaRigs.new()
	add_child(rigs)
	if not rigs.attach(session.stage, street, session.world.context()):
		return false
	if input.kill:  # the brutality station: signature deaths drawn (crush vs the standard death)
		var sig: BrutalityHook = BrutalityHook.new()
		session.stage.hooks.append(sig)
		sig.setup(session.stage, session.world.context())
		sig.attach_view(street)
	street.print_stage.place(street.focus)
	street.print_stage.camera.make_current()
	street.print_stage.camera.force_update_scroll()
	return true


func _process(_delta: float) -> void:
	session.step()
	street.focus = input.spot + Vector2(0.0, -0.6)
	if input.press_tick < 0:
		return
	var since: int = session.stage.tick - input.press_tick
	if input.crush_cop != null and since < 27:  # held 1 m from the drop centre until the dump
		input.crush_cop.pos = session.pilot.ghosts.deploy.spot + Vector2(-1.0, 0.0)
	if since in wanted:
		await RenderingServer.frame_post_draw
		_save(since)
	if since >= wanted.max() + TAIL_TICKS:
		set_process(false)
		_quit.call_deferred()


func _save(since: int) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	var ghost: GhostDeploy = session.pilot.ghosts.deploy
	var file: String = "beats-%d-p%03d.png" % [ppm, since]
	Log.info(
		"beats",
		"%s: tick=%d phase=%d spot=%s" % [file, session.stage.tick, ghost.phase, ghost.spot]
	)
	if image.save_png(out_dir.path_join(file)) != OK:
		_fail("could not write " + file)


func _quit() -> void:
	_close()
	await get_tree().process_frame
	get_tree().quit()


func _fail(message: String) -> void:
	set_process(false)
	Log.error("beats", message)
	get_tree().quit(2)


func _exit_tree() -> void:
	_close()


func _close() -> void:
	if session != null:
		for child: Node in get_children():
			if child != session.world:
				child.free()
		input.stage = null
		session.close()
		session = null
	if is_instance_valid(bus):
		bus.free()
	if is_instance_valid(data):
		data.free()

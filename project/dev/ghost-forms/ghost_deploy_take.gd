extends Node
## Movies and stills share a 60 Hz input source, with an optional slow close-up on release.

const KNOWN_FLAGS: PackedStringArray = [
	"--form", "--ppm", "--out", "--stills", "--position", "--real-speed"
]
const RUN_TICKS: int = 1443
const WIDE_FRAMES: int = 1440
const CLOSE_FRAMES: int = 420
const RESOLUTION: Vector2i = Vector2i(1920, 1080)

var input: GhostDeployFilmInput = GhostDeployFilmInput.new()
var bus: EventBus = EventBus.new()
var data: DataStore = DataStore.new()
var session: GauntletSession
var street: GauntletView
var ppm: int
var out_dir: String
var frame: int = 0
var next_step: int = 1
var last_frame: int
var stills: Array[int] = []
var slow_attack: bool


func _ready() -> void:
	set_process(false)
	var args: ArenaArgs = ArenaArgs.parse()
	input.single = StringName(args.text("--form", "all"))
	slow_attack = input.single != &"all" and not args.has("--real-speed")
	var zoom: String = args.text("--ppm", "32")
	if input.single != &"all" and input.single not in GhostDeployFilmInput.FORMS:
		_fail("unknown --form")
		return
	if zoom not in ["32", "64"]:
		_fail("use --ppm=32 or 64")
		return
	ppm = zoom.to_int()
	last_frame = WIDE_FRAMES if input.single == &"all" else CLOSE_FRAMES
	out_dir = args.text("--out")
	if not _stills(args.text("--stills")):
		_fail("expected an absolute --out and film frame numbers for --stills")
		return
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


func _stills(raw: String) -> bool:
	if out_dir.is_empty():
		return raw.is_empty()
	if not out_dir.is_absolute_path() or DirAccess.make_dir_recursive_absolute(out_dir) != OK:
		return false
	for part: String in raw.split(",", false):
		if not part.is_valid_int() or part.to_int() < 1 or part.to_int() > last_frame:
			return false
		stills.append(part.to_int())
	return true


func _open() -> bool:
	var run: GauntletRun = GauntletRun.new()
	run.seed = 24
	session = GauntletSession.open_street(bus, data, run, input)
	if session == null:
		return false
	add_child(session.world)
	session.world.set_process(false)
	input.bind(session.stage)
	var r: Fighter = session.stage.arena.rivet
	r.pos = Vector2(13.0, 0.0)
	r.weapon = &"pistol"
	session.stage.guns = StageGuns.make(session.world.context().rng.stream(&"gunplay"))
	session.pilot.ghosts.forms.apply_locks(GhostDeployFilmInput.FORMS)
	session.pilot.ghosts.transform_unlocked = false
	street = GauntletView.new(session.street)
	street.px_per_m = ppm
	street.focus = r.pos + Vector2(3.0, -0.7)
	street.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(street)
	street.hud_view.hide()
	var rigs: ArenaRigs = ArenaRigs.new()
	add_child(rigs)
	if not rigs.attach(session.stage, street, session.world.context()):
		return false
	street.style_ghost_meter(rigs.ghost_view.hud)
	street.print_stage.place(street.focus)
	street.print_stage.camera.make_current()
	street.print_stage.camera.force_update_scroll()
	@warning_ignore("return_value_discarded")
	StageAudio.attach(self, session.stage, null, bus, 1)
	return true


func _process(_delta: float) -> void:
	frame += 1
	if frame >= next_step:
		session.step()
		input.observe()
		var ghost: GhostDeploy = session.pilot.ghosts.deploy
		var slow: bool = slow_attack and ghost.phase == GhostDeploy.Phase.ACTIVE
		next_step = frame + (4 if slow else 1)
	var r: Fighter = session.stage.arena.rivet
	street.focus = street.focus.lerp(r.pos + Vector2(2.8, -0.7), 0.12)
	if frame == 5 and not _framed():
		_fail("expected 1920x1080, requested camera scale and 70 degree tilt")
		return
	if frame in stills:
		await RenderingServer.frame_post_draw
		if not _save_still():
			_fail("could not write the requested viewport still")
			return
	if frame == last_frame:
		set_process(false)
		if frame not in stills and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_finish.call_deferred()


func _framed() -> bool:
	var xform: Transform2D = street.fx_view.get_global_transform_with_canvas()
	var scale_x: float = (xform * Ink.px(Vector2.RIGHT) - xform * Vector2.ZERO).x
	return (
		get_viewport().get_visible_rect().size == Vector2(RESOLUTION)
		and is_equal_approx(scale_x, ppm)
		and is_equal_approx(ViewMode.shared().pitch_deg, 70.0)
	)


func _save_still() -> bool:
	var image: Image = get_viewport().get_texture().get_image()
	var ghost: GhostDeploy = session.pilot.ghosts.deploy
	var label: String = String(input.cue)
	if ghost.phase == GhostDeploy.Phase.AIMING:
		label = "aim" if input.single == &"all" else "hold_" + label
	var file: String = "deploy_%s-%d-f%04d.png" % [label, ppm, frame]
	Log.info("deploy-film", "%s: phase=%d spot=%s" % [file, ghost.phase, ghost.spot])
	return image.get_size() == RESOLUTION and image.save_png(out_dir.path_join(file)) == OK


func _finish() -> void:
	var wanted: int = 8 if input.single == &"all" else 1
	var msg: String = (
		"%d releases, %d pistol shots during deployment, %d shots total, %d sim ticks"
		% [input.casts, input.fired_while_active, session.stage.shots_fired, session.stage.tick]
	)
	if (
		input.casts != wanted
		or (input.single == &"all" and input.live_holds != wanted)
		or input.hits_on_marks != wanted
		or input.fired_while_active < 1
		or session.pilot.ghosts.transforms != 0
	):
		_fail(msg)
		return
	Log.info("deploy-film", msg)
	_close()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()


func _fail(message: String) -> void:
	set_process(false)
	Log.error("deploy-film", message)
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

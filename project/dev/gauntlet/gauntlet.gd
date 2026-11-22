extends Node
## Headless and live gauntlet entry. The engine cap allows one simulated hour of street fighting.

const KNOWN_FLAGS: PackedStringArray = [
	"--seed", "--bot", "--pick", "--waves", "--result", "--controls", "--pick-view"
]
const RUN_TICKS: int = 216000
const BOT_PATH: String = "res://features/gauntlet/bot/gauntlet_bot.gd"

@export var camera_ppm: float = 32.0

var run: GauntletRun = GauntletRun.new()
var session: GauntletSession
var pilot: GauntletPilot
var waves: GauntletWaves
var view: GauntletView
var hud: GauntletHud
var pick_view: GauntletPickView
var _result_path: String = ""


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var problem: String = _invalid_arg(args)
	if problem != "":
		Log.error("gauntlet", "invalid argument %s" % problem)
		get_tree().quit(2)
		return
	run.seed = args.text("--seed", "0").to_int()
	run.profile = StringName(args.text("--bot", "human"))
	if args.has("--bot"):
		pilot = _bot()
		if pilot == null:
			Log.error("gauntlet", "cannot instantiate %s as GauntletPilot" % BOT_PATH)
			get_tree().quit(1)
			return
	session = _open_street(args)
	if session == null:
		get_tree().quit(1)
		return
	var picker: GauntletPilot = pilot if pilot != null else GauntletPilot.new()
	picker.configure(run.profile, StringName(args.text("--pick", "random")), run.seed)
	picker.bind(run, session)
	waves = GauntletWaves.attach(session, run, picker, args.text("--waves", "0").to_int())
	_result_path = args.text("--result")
	if DisplayServer.get_name() == "headless":
		_run_headless()
	else:
		_open_view(args.has("--pick-view"))


func _open_street(args: ArenaArgs) -> GauntletSession:
	run.controls = StringName(args.text("--controls", "wheel"))
	return GauntletSession.open_street(Events, Data, run, pilot)


func _run_headless() -> void:
	while not waves.done and session.tick() < RUN_TICKS:
		session.step()
	if not waves.done:
		Log.error("gauntlet", "headless tick cap reached before run ended")
	var written: bool = _finish()
	get_tree().quit(0 if waves.done and written else 1)


func _process(_delta: float) -> void:
	if session != null and waves != null and waves.done:
		get_tree().quit(0 if _finish() else 1)


func _physics_process(_delta: float) -> void:
	if session == null or waves.done:
		return
	if waves.pending.is_empty():
		session.world.loop().frame(SimClock.TICK_DT)
	elif pick_view != null and pilot != null:
		pick_view.advance()


func _open_view(film: bool) -> void:
	if film:
		ViewMode.select("tilt70")
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	add_child(session.world)
	# A human clear can occur on any tick. Check for its modal before each 60 Hz step.
	waves.manual_picks = pilot == null or film
	session.world.set_process(not waves.manual_picks)
	set_physics_process(waves.manual_picks)
	view = GauntletView.new(session.street)
	view.px_per_m = camera_ppm
	view.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(view)
	view.hud_view.visible = false
	hud = GauntletHud.new()
	hud.session = session
	hud.run = run
	hud.waves = waves
	add_child(hud)
	if waves.manual_picks:
		pick_view = GauntletPickView.new()
		pick_view.waves = waves
		pick_view.pilot = pilot
		hud.add_child(pick_view)
		hud.move_child(hud.get_node(^"Status"), -1)
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(session.stage, view, session.world.context())
	if cast.ghost_view != null:
		view.style_ghost_meter(cast.ghost_view.hud)
	session.live.viewport = get_viewport()
	session.live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size * 0.5
	session.live.px_per_m = func() -> float: return view.px_per_m


func _input(event: InputEvent) -> void:
	if session != null and waves != null and waves.pending.is_empty():
		session.live.note_event(event)


func _exit_tree() -> void:
	if session != null and not _finish():
		get_tree().quit(1)


func _finish() -> bool:
	Log.info("gauntlet", "tick %d, segment %d" % [session.tick(), session.street.index])
	run.capped = not waves.done and maxi(session.tick(), Engine.get_process_frames()) >= RUN_TICKS
	var ok: bool = _result_path.is_empty() or _write_result(_result_path)
	if hud != null and is_instance_valid(hud):
		hud.set_process(false)
	session.close()
	session = null
	return ok


func _bot() -> GauntletPilot:
	if not ResourceLoader.exists(BOT_PATH):
		return GauntletWalker.new()
	var script: GDScript = load(BOT_PATH) as GDScript
	if script == null or not script.can_instantiate():
		return null
	var instance: Object = script.new()
	return instance as GauntletPilot


func _invalid_arg(args: ArenaArgs) -> String:
	for flag: String in args.values:
		var s: String = args.text(flag)
		if not KNOWN_FLAGS.has(flag):
			return flag
		var valid: bool = true
		match flag:
			"--pick-view":
				valid = s.is_empty()
			"--seed":
				valid = s.is_valid_int() and s.to_int() >= 0 and s.to_int() <= RngRegistry.SEED_MASK
			"--waves":
				valid = s.is_valid_int() and s.to_int() >= 1
			"--bot":
				valid = s in ["novice", "average", "expert"]
			"--pick":
				valid = s in ["random", "greedy"]
			"--controls":
				valid = s in ["legacy", "wheel"]
			"--result":
				valid = s.is_absolute_path()
		if not valid:
			return "%s=%s" % [flag, s]
	return ""


func _write_result(path: String) -> bool:
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE) if dir_error == OK else null
	if file == null or not file.store_string(JSON.stringify(run.to_result(), "  ", true) + "\n"):
		Log.error("gauntlet", "cannot write result to %s" % path)
		return false
	file.close()
	return true

extends Node
## One take for comparison stills and the film. The same input goes through StagePilot in
## both modes. The shots start after the full turn, so none of the held stills has a flash.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--view", "--movie"]
const SIZE: Vector2i = Vector2i(640, 360)
const END: int = 12 * SimClock.TICK_RATE
const RAISE: int = 60
const TURN: int = 120
const OCTANT_TICKS: int = 30
const LOWER: int = 420
const VOLLEY: int = 510
const ROUND_GAP: int = 15

var dock: GuardFilmSet = GuardFilmSet.new()
var tick: int = 0
var broken_at: int = -1
var directory: String
var movie: bool
var ppm: int
var capturing: bool = false
var tape: StreamPeerBuffer = StreamPeerBuffer.new()
var cast: ArenaRigs = ArenaRigs.new()
var view: CollectCallView = CollectCallView.new()


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	directory = args.text("--out")
	ppm = int(args.number("--ppm", 32))
	movie = args.has("--movie")
	if not directory.is_absolute_path() or DirAccess.make_dir_recursive_absolute(directory) != OK:
		_fail("Expected a writable absolute --out directory")
		return
	LaunchArgs.parse(["--controls=wheel"])
	ViewMode.select(args.text("--view", "tilt70"))
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = SIZE
	dock.build("pose")
	view.stage_view = ArenaFloorView.new()
	view.px_per_m = ppm
	view.focus = GuardFilmSet.START + Vector2.UP * 1.15
	view.bind(dock.stage, CollectCallWorld.new(dock.stage), null)
	add_child(view)
	view.hud_view.hide()
	add_child(cast)
	if not cast.attach(dock.stage, view, dock.ctx):
		_fail("Arena rig layer missing")
		return
	cast.ghost_view.hud.hide()
	if not movie:
		for item: Node in view.print_stage.actor_layer().get_children():
			if item is PlayerGuardView:
				(item as CanvasItem).self_modulate.a = 0.0
	process_priority = -1000


func _process(_delta: float) -> void:
	if capturing:
		return
	capturing = true
	tick += 1
	var spin: float = clampf(float(tick - TURN) / (8 * OCTANT_TICKS), 0.0, 1.0)
	var aim: Vector2 = Vector2.from_angle(PI * 0.25 + TAU * spin)
	var input: TickInput = TickInput.new(PlayerCommand.pack_aim(aim, dock.actions))
	if (tick >= RAISE and tick < LOWER) or (tick >= 480 and broken_at == -1):
		input.buttons |= 1 << dock.actions.bit(&"guard")
	var guard: PlayerGuard = dock.stage.pilot.guard
	var rounds: int = ceili(guard.tuning.meter_max / guard.tuning.drain_per_round)
	if tick >= VOLLEY and tick < VOLLEY + rounds * ROUND_GAP and (tick - VOLLEY) % ROUND_GAP == 0:
		_incoming(aim)
	dock.stage.step(tick, input)
	dock.stage.write_state(tape)
	if guard.broken() and broken_at == -1:
		broken_at = tick
	var still: String = _still_name()
	if not still.is_empty() or movie:
		await RenderingServer.frame_post_draw
		if not _capture(still):
			_fail("Could not save frame at tick %d" % tick)
			return
	capturing = false
	if tick >= END:
		set_process(false)
		if guard.breaks != 1 or guard.deflects != rounds:
			_fail("Expected one break after %d deflected rounds" % rounds)
			return
		Log.info(
			"guard_pose_film",
			"break %d, stage tape %s" % [broken_at, tape.data_array.hex_encode().sha256_text()]
		)
		get_tree().quit()


func _incoming(aim: Vector2) -> void:
	var shooter: Fighter = Fighter.make(
		Fighter.Kind.GUARD, 101, dock.stage.arena.rivet.pos + aim * 6.0, 1.0
	)
	var shot: Shot = Shot.fire(shooter, -aim, dock.stage.arena.tuning.weapon(&"pistol"))
	dock.stage.arena.shots.append(shot)


func _still_name() -> String:
	if tick >= TURN and tick < TURN + 8 * OCTANT_TICKS and (tick - TURN) % OCTANT_TICKS == 0:
		var octant: int = (1 + floori(float(tick - TURN) / OCTANT_TICKS)) % 8
		return "oct_%d" % octant
	if tick in [RAISE - 1, RAISE, RAISE + 3, RAISE + 6]:
		return "raise_%d" % (tick - RAISE + 1)
	if broken_at >= 0 and tick == broken_at + 32:
		return "stagger"
	return ""


func _capture(still: String) -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.get_size() != SIZE:
		return false
	if not still.is_empty() and img.save_png(directory.path_join(still + ".png")) != OK:
		return false
	return not movie or img.save_png(directory.path_join("t%04d.png" % tick)) == OK


func _fail(reason: String) -> void:
	set_process(false)
	Log.error("guard_pose_film", reason)
	get_tree().quit(1)

extends Node
## n31 ghost 21 (dev only, a copy of g17's Dent probe): stills of Kerf's drop deploy at named
## ticks after the press, in the gauntlet street at tilt 70 and --ppm (32 or 64), 1920x1080, one
## sim tick a frame. --at=<since press,...> names the stills (kerf-beats-<ppm>-p<since>.png in
## --out; the cut lands on since 12, so 8 = the wind-up C-4 and 14 = the cut C+2); a base still
## (p-01) is the street the tick before the press. Each still logs the origin, the spot, the
## locked target and the drawn body in screen px.

const KNOWN_FLAGS: PackedStringArray = ["--ppm", "--out", "--at", "--position"]
const RESOLUTION: Vector2i = Vector2i(1920, 1080)
const TAIL_TICKS: int = 4

var input: GhostN31KerfBeatsInput = GhostN31KerfBeatsInput.new()
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
	for part: String in args.text("--at", "8,14").split(",", false):
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
	session.pilot.ghosts.forms.apply_locks([KerfStage.GHOST])
	session.pilot.ghosts.transform_unlocked = false
	street = GauntletView.new(session.street)
	street.px_per_m = ppm
	street.focus = _focus()
	street.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(street)
	street.hud_view.hide()
	var rigs: ArenaRigs = ArenaRigs.new()
	add_child(rigs)
	if not rigs.attach(session.stage, street, session.world.context()):
		return false
	street.print_stage.place(street.focus)
	street.print_stage.camera.make_current()
	street.print_stage.camera.force_update_scroll()
	return true


func _process(_delta: float) -> void:
	session.step()
	street.focus = _focus()
	if input.press_tick < 0:
		if session.stage.tick == GhostN31KerfBeatsInput.PRESS_TICK - 1:
			await RenderingServer.frame_post_draw
			_save(-1)
		return
	var since: int = session.stage.tick - input.press_tick
	if since in wanted:
		await RenderingServer.frame_post_draw
		_save(since)
	if since >= wanted.max() + TAIL_TICKS:
		set_process(false)
		_quit.call_deferred()


## Midway between Rivet and the aim point, a little up the screen.
func _focus() -> Vector2:
	return session.stage.arena.rivet.pos.lerp(input.spot, 0.5) + Vector2(0.0, -0.6)


func _save(since: int) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	var ghost: GhostDeploy = session.pilot.ghosts.deploy
	var file: String = "kerf-beats-%d-p%03d.png" % [ppm, since]
	var view: GhostDeployView = get_tree().root.find_child("GhostDeployView", true, false)
	var px: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	if view != null:
		var xf: Transform2D = view.get_global_transform_with_canvas()
		px = [
			xf * (ghost.origin * SimConst.PX_PER_M),
			xf * (ghost.spot * SimConst.PX_PER_M),
			xf * view._body.position,
			xf * (input.target.pos * SimConst.PX_PER_M)
		]
	Log.info(
		"beats",
		(
			"%s: tick=%d phase=%d origin=%s spot=%s screen origin=%s spot=%s body=%s target=%s"
			% [
				file,
				session.stage.tick,
				ghost.phase,
				ghost.origin,
				ghost.spot,
				px[0],
				px[1],
				px[2],
				px[3]
			]
		)
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

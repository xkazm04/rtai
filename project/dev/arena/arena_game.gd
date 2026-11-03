class_name ArenaGame
extends Node
## The dev arena's scene (dev/arena/arena.tscn): ArenaSession under the player's hands, drawn
## by quest 1's CollectCallView (print pass, D5 look, blood) with ArenaFloorView as its floor.
## Args (after --): --ppm=<32|48|64|128> the zoom, --bot=range|course|pit plays that station's
## scripted player, --shot=<png> saves one frame after --shot-tick=<tick> and quits,
## --telemetry=<json> writes the session's telemetry on exit, --arena=city the city proving block,
## --clean hides the dev HUD (clips of the game only).

const TUNE_TICK: int = 300

var session: ArenaSession = null
var view: CollectCallView = null
var px_per_m: float = 32.0
var hud: ArenaHud = ArenaHud.new()
var panel: ArenaPanel = ArenaPanel.new()
var tuning: ArenaTuning = null
var _shot: String = ""
var _shot_tick: int = 600
var _telemetry: String = ""
var _taken: bool = false
var _tune: String = ""
var _zoom_i: int = 0
var _area_i: int = 0
var _characters: CityCharacters = null


func _ready() -> void:
	RenderingServer.set_default_clear_color(Ink.CREAM)
	var args: ArenaArgs = ArenaArgs.parse()
	px_per_m = args.number("--ppm", px_per_m)
	_shot = args.text("--shot")
	_shot_tick = int(args.number("--shot-tick", 600.0))
	_telemetry = args.text("--telemetry")
	_tune = args.text("--tune")
	_open(args)
	_add_view()
	view.hud_view.visible = false
	@warning_ignore("return_value_discarded")
	ArenaKeys.install()
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud")
	add_child(layer)
	hud.session = session
	hud.px_per_m = px_per_m
	layer.add_child(hud)
	hud.visible = not args.has("--clean")  # a clip of the game only (the owner's sample)
	tuning = ArenaTuning.new(session.actions, session.stage.arena.tuning)
	tuning.hooks = session.stage.hooks
	panel.tick_now = session.tick
	panel.build(session.stations, tuning)
	panel.position = Vector2(8.0, 200.0)
	panel.visible = args.has("--panel")
	layer.add_child(panel)
	session.live.viewport = get_viewport()
	session.live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size / 2.0


## The session (the dev arena, or the city proving block with --arena=city) and the bot.
func _open(args: ArenaArgs) -> void:
	var on_city: bool = args.text("--arena") == "city"
	session = ArenaSession.open(Events, Data, ArenaSession.MASTER_SEED, null, on_city)
	if args.text("--bot") == "range":
		session.world.loop().set_input(ArenaRangeBot.new(session.stage, session.actions))
	elif args.text("--bot") == "course":
		session.world.loop().set_input(ArenaCourseBot.new(session.stage))
	elif args.text("--bot") == "pit":
		session.world.loop().set_input(ArenaPitBot.new(session.stage, session.actions))
	add_child(session.world)


## Quest 1's view on the arena's floor; on the city its CityView and baked characters as well.
func _add_view() -> void:
	view = CollectCallView.new()
	view.px_per_m = px_per_m
	view.stage_view = ArenaFloorView.new()
	if session.city != null:
		view.city = session.city
		view.city_view = CityView.new()
		view.city_view.clock = session.world.context().clock
	view.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(view)
	for hook: ArenaHook in session.stage.hooks:
		hook.attach_view(view)
	if session.city != null:
		_characters = CityCharacters.new(session.city, view.city_view, session.world.context())
		_characters.rivet_on_foot = false
		_characters.bake()


func _process(_delta: float) -> void:
	if _tune != "" and session.tick() >= TUNE_TICK:
		var ok: bool = panel.set_live(_tune.get_slice(":", 0), _tune.get_slice(":", 1).to_float())
		hud.note = "tuned %s live (%s)" % [_tune, ok]
		_tune = ""
	if _shot != "" and not _taken and session.tick() >= _shot_tick:
		_taken = true
		_save_shot.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"arena_panel"):
		panel.visible = not panel.visible
	elif event.is_action_pressed(&"arena_zoom"):
		_zoom_i = (_zoom_i + 1) % session.plan.zoom_ppm.size()
		set_zoom(session.plan.zoom_ppm[_zoom_i])
	elif event.is_action_pressed(&"arena_teleport"):
		_area_i = (_area_i + 1) % session.plan.areas.size()
		teleport(session.plan.areas[_area_i])
	elif event.is_action_pressed(&"arena_save_telemetry"):
		var path: String = _telemetry if _telemetry != "" else "user://arena/telemetry.json"
		hud.note = "telemetry -> %s (%s)" % [path, session.write_telemetry(path)]


func set_zoom(ppm: float) -> void:
	px_per_m = ppm
	hud.px_per_m = ppm
	if view.print_stage != null:
		view.print_stage.zoom = ppm / SimConst.PX_PER_M


## Dev teleport (outside the input tape: a live run that teleports does not replay; logged).
func teleport(area: ArenaPlan.Area) -> void:
	session.stage.arena.rivet.pos = area.rect.get_center()
	session.pilot.mover.stop()
	hud.note = "teleported to %s (this run no longer replays)" % area.name
	Log.info("arena", "teleport to %s at tick %d" % [area.id, session.tick()])


func _save_shot() -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_shot.get_base_dir())
	var err: Error = img.save_png(_shot)
	Log.info("arena", "frame %s at tick %d (%s)" % [_shot, session.tick(), error_string(err)])
	_quit()


func _quit() -> void:
	if _telemetry != "":
		@warning_ignore("return_value_discarded")
		session.write_telemetry(_telemetry)
	get_tree().quit(0)


## Window closed, or the engine's --quit-after ended a clip capture: the telemetry is written.
func _notification(what: int) -> void:
	var leaving: bool = what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE
	if leaving and _telemetry != "" and session != null:
		@warning_ignore("return_value_discarded")
		session.write_telemetry(_telemetry)

class_name ArenaGame
extends Node
## The dev arena's scene (dev/arena/arena.tscn): ArenaSession under the player's hands, drawn
## by quest 1's CollectCallView (print pass, D5 look, blood) with ArenaFloorView as its floor.
## Args (after --): --ppm=<32|48|64|128> the zoom, --bot=range plays the range's scripted
## player, --shot=<png> saves one frame after --shot-tick=<tick> and quits, --telemetry=<json>
## writes the session's telemetry on exit.

var session: ArenaSession = null
var view: CollectCallView = null
var px_per_m: float = 32.0
var _shot: String = ""
var _shot_tick: int = 600
var _telemetry: String = ""
var _taken: bool = false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Ink.CREAM)
	var args: ArenaArgs = ArenaArgs.parse()
	px_per_m = args.number("--ppm", px_per_m)
	_shot = args.text("--shot")
	_shot_tick = int(args.number("--shot-tick", 600.0))
	_telemetry = args.text("--telemetry")
	session = ArenaSession.open(Events, Data)
	if args.text("--bot") == "range":
		session.world.loop().set_input(ArenaRangeBot.new(session.stage, session.actions))
	add_child(session.world)
	view = CollectCallView.new()
	view.px_per_m = px_per_m
	var floor_view: ArenaFloorView = ArenaFloorView.new()
	view.stage_view = floor_view
	view.bind(session.stage, CollectCallWorld.new(session.stage), null)
	add_child(view)
	session.live.viewport = get_viewport()
	session.live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size / 2.0


func _process(_delta: float) -> void:
	if _shot != "" and not _taken and session.tick() >= _shot_tick:
		_taken = true
		_save_shot.call_deferred()


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


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and _telemetry != "" and session != null:
		@warning_ignore("return_value_discarded")
		session.write_telemetry(_telemetry)

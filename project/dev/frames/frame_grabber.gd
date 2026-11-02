extends Node
## Plays quest 1 with CollectCallBot exactly as the scenario does (same seed, same ticks), draws
## it with CollectCallView, and saves one PNG per FrameShot after RenderingServer.frame_post_draw
## (TST-08), fast-forwarding the sim between shots. Quits 0 when every shot is saved.

const MAX_TICKS_PER_FRAME: int = 900

var out_dir: String = ""
var _play: CollectCallPlay
var _view: CollectCallView
var _shots: Array[FrameShot] = []
var _next: int = 0
var _busy: bool = false
var _saved: Array[String] = []


func _ready() -> void:
	RenderingServer.set_default_clear_color(Ink.CREAM)
	_play = CollectCallPlay.begin()
	_view = CollectCallView.new()
	_view.bind(_play.stage, _play.port, _play.system)
	add_child(_view)
	_shots = FrameShot.collect_call(_play)


func _process(_delta: float) -> void:
	if _busy:
		return
	for _i: int in MAX_TICKS_PER_FRAME:
		if _next >= _shots.size():
			_finish(0)
			return
		if _shots[_next].ready.call():
			_grab(_shots[_next])
			return
		if not _play.running():
			Log.error("frames", "the play ended before %s" % _shots[_next].name)
			_finish(1)
			return
		_play.tick_once()


func _grab(shot: FrameShot) -> void:
	_busy = true
	_view.focus = shot.focus.call()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var path: String = out_dir.path_join("%s.png" % shot.name)
	var err: Error = image.save_png(path)
	Log.info("frames", "%s at tick %d -> %s (%d)" % [shot.name, _play.ticks, path, err])
	_saved.append("%s tick %d" % [shot.name, _play.ticks])
	_next += 1
	_busy = false


func _finish(code: int) -> void:
	set_process(false)
	Log.info("frames", "saved %d of %d: %s" % [_saved.size(), _shots.size(), _saved])
	_play.release()
	get_tree().quit(code)

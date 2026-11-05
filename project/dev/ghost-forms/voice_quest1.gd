extends Node
## ghost-forms (dev): quest 1 played by CollectCallBot exactly as the scenario does, drawn by
## CollectCallView, with a GhostApparition bound to the play's own event bus, so the quest's real
## whisper beats (b1: Rivet a moment in the dumpster, Kilohm's line, the tazer hit) cue the voice.
## The bot has no StagePilot, so the apparition is stepped here at Rivet's spot (Rivet in base,
## the first ghost selected: what GhostFormView does in the game). From each of the first VOICES
## whispers it saves a PNG every EVERY ticks for SHOTS shots, then quits 0.

const SHOTS: int = 12
const EVERY: int = 10
const VOICES: int = 2
const FAST: int = 900

var out_dir: String = ""
var _play: CollectCallPlay
var _view: CollectCallView
var _app: GhostApparition = GhostApparition.new()
var _shot: int = -1
var _voices: int = 0
var _saved: Array[String] = []


func _ready() -> void:
	RenderingServer.set_default_clear_color(Ink.CREAM)
	_play = CollectCallPlay.begin()
	_view = CollectCallView.new()
	_view.bind(_play.stage, _play.port, _play.system)
	add_child(_view)
	if _view.blood != null:
		_view.blood.max_steps = FAST
	if _view.print_stage != null:
		_app.z_index = RenderLayers.z(&"actors") + GhostFormView.Z_OVER_RIGS
		_view.print_stage.actor_layer().add_child(_app)
	else:
		_app.scale = Vector2.ONE * Ink.PX_PER_M / SimConst.PX_PER_M
		_view.add_child(_app)
	var pt: PowerTable = PowerTable.load_default()
	_app.bind(
		GhostForms.new(GhostFormTable.load_default(), SoulPowers.new(pt)), _play.stage.events()
	)


func _process(_delta: float) -> void:
	var n: int = FAST if _shot < 0 else EVERY
	for _i: int in n:
		if not _play.running():
			_finish(1 if _saved.is_empty() else 0)
			return
		var was: bool = _app.speaking()
		_play.tick_once()
		_step_app()
		if _shot < 0 and _app.speaking() and not was:
			_shot = 0
			Log.info("frames", "voice %d at tick %d (%s)" % [_voices, _play.ticks, _app.id])
			break
	if _shot >= 0:
		_grab()


func _step_app() -> void:
	var r: Fighter = _play.stage.arena.rivet
	_app.step(r.pos * SimConst.PX_PER_M, r.facing.angle(), 1, _play.ticks)


func _grab() -> void:
	set_process(false)
	_view.focus = _play.stage.arena.rivet.pos
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path: String = out_dir.path_join("voice%d_%02d.png" % [_voices, _shot])
	var err: Error = get_viewport().get_texture().get_image().save_png(path)
	_saved.append("%s tick %d (%d)" % [path.get_file(), _play.ticks, err])
	_shot += 1
	if _shot >= SHOTS:
		_shot = -1
		_voices += 1
		if _voices >= VOICES:
			_finish(0)
			return
	set_process(true)


func _finish(code: int) -> void:
	set_process(false)
	Log.info("frames", "voice frames: %s" % [_saved])
	_play.release()
	get_tree().quit(code)

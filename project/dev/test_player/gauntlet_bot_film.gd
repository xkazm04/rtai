extends "res://dev/gauntlet/gauntlet.gd"
## The offer pauses the simulation. Hide its last combat caption until the next tick.

var _previous: Array = []
@onready var _label: Label = $Caption/Act


func _ready() -> void:
	($Caption as CanvasLayer).layer = RenderLayers.canvas(&"hud") + 1
	(_label.get_theme_stylebox(&"normal") as StyleBoxFlat).bg_color = Ink.CREAM
	_label.add_theme_color_override(&"font_color", HudArt.INK)
	super._ready()
	if session != null:
		@warning_ignore("return_value_discarded")
		get_tree().process_frame.connect(_caption, CONNECT_DEFERRED)


func _run_headless() -> void:
	# Headless play has no rendered frames. Observe each step before the usual writer closes it.
	while not waves.done and session.tick() < RUN_TICKS:
		session.step()
		_caption()
	super._run_headless()


func _caption() -> void:
	var bot: GauntletTestPlayer = pilot as GauntletTestPlayer
	if bot == null or session == null:
		return
	var guard: PlayerGuard = session.pilot.guard
	var deflects: int = guard.deflects if guard != null else 0
	var action: StringName = bot.act()
	var mark: Array = [
		run.wave, action, bot.cover_threat(), deflects, int(not waves.pending.is_empty())
	]
	if mark != _previous:
		_previous = mark
		_label.text = tr(action)
		_label.visible = waves.pending.is_empty()
		var prefix: String = "tick=%d frame=%d " % [session.stage.tick, Engine.get_frames_drawn()]
		Log.info("bot-film", prefix + "wave=%d act=%s threat=%s deflects=%d pick=%d" % mark)

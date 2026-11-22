extends GauntletHud
## The production health label and meter read the live arena. Only the wave rows are hidden.


func _init(stage: ArenaStage) -> void:
	session = GauntletSession.new()
	session.stage = stage
	session.pilot = stage.pilot
	run = GauntletRun.new()
	waves = GauntletWaves.new()
	waves._run = run


func _ready() -> void:
	super._ready()
	_wave.hide()
	_time.hide()
	guard_meter.self_modulate = Color.TRANSPARENT
	var panel: ColorRect = get_node(^"Status") as ColorRect
	panel.position = Vector2(52, 110)
	panel.size = Vector2(369, 67)
	_health.position = Vector2(21, 0)
	_health.add_theme_font_size_override(&"font_size", 24)
	_hp.position = Vector2(22, 41)
	_hp.size = Vector2(325, 12)


func _exit_tree() -> void:
	session.world.free()

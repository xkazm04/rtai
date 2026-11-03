class_name Quest1Game
extends Node
## The slice's main scene (boot/quest1.tscn): a title card (start, quit), then quest 1
## (collect-call) under the player's hands: Quest1Session (the World, the stage, the quest, the
## bound input) drawn by CollectCallView at gameplay zoom, the pause card on the pause action,
## and the end card once Rivet is paid. Text goes through QuestText (tr() with an English
## fallback, LOC-01). Headless (tests) it builds no view; start() is the Start button's action.

signal started

var session: Quest1Session = null
var view: CollectCallView = null
var card: Quest1Card = Quest1Card.new()
var paused: bool = false
## The on-foot camera: 32 px/m (the AGENTS camera table).
var px_per_m: float = 32.0
## Where the beat checkpoints go ("" turns saving off, e.g. a test that must not touch user://).
var save_path: String = Checkpoint.DEFAULT_PATH
## The player's settings file ("" = defaults, never saved: tests).
var settings_path: String = PlayerSettings.PATH
var settings: PlayerSettings = PlayerSettings.new()
var _ended: bool = false


func _enter_tree() -> void:
	boot()


## Builds the title card once (a headless SceneTree script calls it before any frame runs).
func boot() -> void:
	if card.get_parent() != null:
		return
	RenderingServer.set_default_clear_color(Ink.CREAM)
	if settings_path != "":
		settings = PlayerSettings.load_or_default(settings_path)
	settings.reduced_motion = settings.reduced_motion or LaunchArgs.has("--reduced-motion")
	add_child(card)
	@warning_ignore("return_value_discarded")
	card.start_pressed.connect(start)
	@warning_ignore("return_value_discarded")
	card.continue_pressed.connect(func() -> void: restart(Checkpoint.load_file(save_path)))
	@warning_ignore("return_value_discarded")
	card.resume_pressed.connect(func() -> void: set_paused(false))
	@warning_ignore("return_value_discarded")
	card.quit_pressed.connect(func() -> void: get_tree().quit(0))
	card.show_title(save_path != "" and Checkpoint.load_file(save_path) != null)
	if LaunchArgs.has("--replay"):
		_replay.call_deferred(LaunchArgs.value("--replay"))


## Start (cp null) or Continue (the last beat checkpoint): opens the contract for the player.
func start(cp: Checkpoint = null) -> void:
	if session != null:
		set_paused(false)
		return
	session = Quest1Session.resume(Events, Data, cp) if cp != null else null
	if session == null:
		session = Quest1Session.open(Events, Data)
	if session == null:
		get_tree().quit(1)
		return
	settings.apply()
	if LaunchArgs.has("--record"):
		session.world.loop().start_recording()
	add_child(session.world)
	if DisplayServer.get_name() != "headless":
		view = CollectCallView.new()
		view.px_per_m = px_per_m
		view.objective_view = ObjectiveView.new()
		view.fx_view.reduced_motion = settings.reduced_motion
		if session.city != null:
			view.city = session.city
			view.city_view = CityView.new()
			view.city_view.clock = session.world.context().clock
		view.bind(session.stage, session.port, session.system)
		add_child(view)
		session.live.viewport = get_viewport()
		session.live.origin_px = func() -> Vector2:
			return get_viewport().get_visible_rect().size / 2.0
	card.hide_all()
	started.emit()
	Log.info("quest1", "started: Rivet is the player's (seed %d)" % Quest1Session.MASTER_SEED)


func _input(event: InputEvent) -> void:
	if session != null:
		session.live.note_event(event)


func _unhandled_input(event: InputEvent) -> void:
	if session != null and not _ended and event.is_action_pressed(&"pause"):
		set_paused(not paused)


func _process(_delta: float) -> void:
	if session == null or _ended:
		return
	var cp: Checkpoint = session.poll_checkpoint()
	if cp != null and save_path != "":
		Log.info("save", "checkpoint %s at tick %d (%d)" % [cp.beat, cp.tick, cp.save(save_path)])
	if session.paid() and not session.system.runner.lines.busy():
		_end()
	elif session.failed():
		_ended = true
		session.live.enabled = false
		Log.info("quest1", "contract failed at %s" % session.beat_id())
		card.show_failed(save_path != "" and Checkpoint.load_file(save_path) != null)


func set_paused(on: bool) -> void:
	paused = on
	session.world.set_process(not on)
	session.live.enabled = not on
	if on:
		card.show_pause(_settings_panel())
	else:
		card.hide_all()


## Drops the running session (if any) and starts again: from `cp`, or fresh when null.
func restart(cp: Checkpoint) -> void:
	if session != null:
		session.world.queue_free()
		session = null
	if view != null:
		view.queue_free()
		view = null
	_ended = false
	paused = false
	start(cp)


func _end() -> void:
	_ended = true
	session.live.enabled = false
	var cash: int = session.stage.wallet.cash - session.cash_before
	Log.info("quest1", "paid +%d at tick %d" % [cash, session.tick()])
	card.show_paid(cash)
	if save_path != "":
		Checkpoint.erase(save_path)


## `-- --replay=<file>` (SIM-05): re-runs a recorded slice log on a fresh session and quits
## 0 identical, 1 diverged, 2 unreadable. `-- --record=<file>` is saved by the World on exit.
func _replay(path: String) -> void:
	var log: ReplayLog = ReplayLog.load_file(path)
	var again: Quest1Session = Quest1Session.open(Events, Data, log.master_seed) if log else null
	if again == null:
		get_tree().quit(2)
		return
	var divergence: String = again.world.verify_replay(log)
	Log.info("replay", divergence if divergence != "" else "identical")
	again.world.free()
	get_tree().quit(0 if divergence == "" else 1)


func _settings_panel() -> Quest1SettingsPanel:
	var panel: Quest1SettingsPanel = Quest1SettingsPanel.new(settings)
	@warning_ignore("return_value_discarded")
	panel.changed.connect(
		func() -> void: view.fx_view.reduced_motion = settings.reduced_motion if view else false
	)
	return panel

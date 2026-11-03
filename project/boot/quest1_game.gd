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
var _ended: bool = false


func _enter_tree() -> void:
	boot()


## Builds the title card once (a headless SceneTree script calls it before any frame runs).
func boot() -> void:
	if card.get_parent() != null:
		return
	RenderingServer.set_default_clear_color(Ink.CREAM)
	add_child(card)
	@warning_ignore("return_value_discarded")
	card.start_pressed.connect(start)
	@warning_ignore("return_value_discarded")
	card.resume_pressed.connect(func() -> void: set_paused(false))
	@warning_ignore("return_value_discarded")
	card.quit_pressed.connect(func() -> void: get_tree().quit(0))
	card.show_title()


## The Start button: opens the contract and hands Rivet to the player.
func start() -> void:
	if session != null:
		set_paused(false)
		return
	session = Quest1Session.open(Events, Data)
	if session == null:
		get_tree().quit(1)
		return
	if LaunchArgs.has("--record"):
		session.world.loop().start_recording()
	add_child(session.world)
	if DisplayServer.get_name() != "headless":
		view = CollectCallView.new()
		view.bind(session.stage, session.port, session.system)
		add_child(view)
		session.live.viewport = get_viewport()
		session.live.origin_px = func() -> Vector2:
			return get_viewport().get_visible_rect().size / 2.0
	card.hide_all()
	started.emit()
	Log.info("quest1", "started: Rivet is the player's (seed %d)" % Quest1Session.MASTER_SEED)


func _unhandled_input(event: InputEvent) -> void:
	if session != null and not _ended and event.is_action_pressed(&"pause"):
		set_paused(not paused)


func _process(_delta: float) -> void:
	if session == null or _ended:
		return
	if session.paid() and not session.system.runner.lines.busy():
		_end()


func set_paused(on: bool) -> void:
	paused = on
	session.world.set_process(not on)
	session.live.enabled = not on
	if on:
		card.show_pause()
	else:
		card.hide_all()


func _end() -> void:
	_ended = true
	session.live.enabled = false
	var cash: int = session.stage.wallet.cash - session.cash_before
	Log.info("quest1", "paid +%d at tick %d" % [cash, session.tick()])
	card.show_paid(cash)

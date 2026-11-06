class_name Quest1Game
extends Node
## The slice's main scene (boot/quest1.tscn): a title card (start, quit), then quest 1
## (collect-call) under the player's hands: Quest1Session (the World, the stage, the quest, the
## bound input) drawn by CollectCallView at gameplay zoom, the pause card on the pause action,
## and the end card once Rivet is paid. Text goes through QuestText (tr() with an English
## fallback, LOC-01). Headless (tests) it builds no view; start() is the Start button's action.

signal started

const QUIT_POINT: String = "quit"
## n8-view: under a view that draws the standing cards the quest's cast is the rig cast (_dev_rigs).
const RIGS_UNDER_CARDS: bool = true

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
## Quest 1's sound (features/audio): the service, the Events hooks, the shot feed, the voice player.
var _audio: StageAudio = null
## The city's crowd atlas and near rigs (quest 1 on the city; Rivet is the quest's cast).
var _characters: CityCharacters = null
## The ghost forms and voices on the sprite cast (null under --rigs).
var _story: StoryForms = null


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
	Quest1Session.ghost_locks = not LaunchArgs.has("--ghosts-free")  # ghost-powers-5's old default
	Quest1Session.table_guns = LaunchArgs.value("--quest-guns") != "off"  # n7-ranged's before
	Quest1Session.blade = Quest1Game.blade_of(LaunchArgs.value("--quest-blade"))  # n7-melee
	add_child(card)
	@warning_ignore("return_value_discarded")
	card.start_pressed.connect(start)
	@warning_ignore("return_value_discarded")
	card.continue_pressed.connect(_continue)
	@warning_ignore("return_value_discarded")
	card.resume_pressed.connect(func() -> void: set_paused(false))
	@warning_ignore("return_value_discarded")
	card.quit_pressed.connect(func() -> void: get_tree().quit(0))
	card.show_title(_can_continue())
	if LaunchArgs.has("--replay"):
		_replay.call_deferred(LaunchArgs.value("--replay"))


## Start (cp null) or Continue (the last beat checkpoint): opens the contract for the player.
func start(cp: Checkpoint = null) -> void:
	if session != null:
		set_paused(false)
		return
	var opened: Quest1Session = Quest1Session.resume(Events, Data, cp) if cp != null else null
	_begin(opened if opened != null else Quest1Session.open(Events, Data))


## Continue / Retry: the newest valid autosave slot (the other when one is damaged), else a
## fresh start with the engine's one-line notice (SAV-08). Re-simulation happens in `accept`.
func _continue() -> void:
	var out: SaveLoader.Outcome = Save.load_latest(Quest1Autosave.accept(Events, Data))
	var resumed: Quest1Session = out.value if out.status == SaveLoader.Status.LOADED else null
	if session != null:
		session.world.queue_free()
		session = null
	if view != null:
		view.queue_free()
		view = null
	_ended = false
	paused = false
	_begin(resumed if resumed != null else Quest1Session.open(Events, Data))


## True when Continue has a game to offer: a slot exists and the newest save is not the quest end.
func _can_continue() -> bool:
	if save_path == "" or not Save.has_continue():
		return false
	return Save.read_meta().get("point", "") != AutosavePoints.QUEST_END


func _begin(opened: Quest1Session) -> void:
	session = opened
	if session == null:
		get_tree().quit(1)
		return
	settings.apply()
	if save_path != "":
		session.autosave.sink = Save.autosave
	if LaunchArgs.has("--record"):
		session.world.loop().start_recording()
	add_child(session.world)
	if DisplayServer.get_name() != "headless":
		view = CollectCallView.new()
		view.px_per_m = px_per_m
		view.objective_view = ObjectiveView.new()
		var live: LiveInput = session.live
		view.objective_view.pad_prompts = func() -> bool: return live.pad_last
		view.fx_view.reduced_motion = settings.reduced_motion
		if session.city != null:
			view.city = session.city
			view.city_view = CityView.new()
			view.city_view.clock = session.world.context().clock
		view.bind(session.stage, session.port, session.system)
		add_child(view)
		if session.city != null:
			_characters = CityCharacters.new(session.city, view.city_view, session.world.context())
			_characters.rivet_on_foot = false
			_characters.bake()
		_casts()
		_audio = StageAudio.attach(
			self, session.stage, session.system, Events, Quest1Session.MASTER_SEED
		)
		_bind_live()
	if view != null:
		view.notice.show(Save.take_notice())
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
	session.autosave.poll()
	if session.paid() and not session.system.runner.lines.busy():
		_end()
	elif session.failed():
		_ended = true
		session.live.enabled = false
		Log.info("quest1", "contract failed at %s" % session.beat_id())
		card.show_failed(_can_continue())


## Quit (SAV-08): a game in progress writes its state as the "quit" autosave and waits for the write
## before the window closes. A finished or failed run has its own saves (quest end, last beat).
func save_on_quit() -> bool:
	if session == null or _ended or session.failed():
		return false
	var wrote: bool = session.autosave.save_now(QUIT_POINT)
	Save.flush()
	return wrote


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		@warning_ignore("return_value_discarded")
		save_on_quit()


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
	if _audio != null:
		_audio.queue_free()
		_audio = null
	_ended = false
	paused = false
	start(cp)


func _end() -> void:
	_ended = true
	session.live.enabled = false
	var cash: int = session.stage.wallet.cash - session.cash_before
	Log.info("quest1", "paid +%d at tick %d" % [cash, session.tick()])
	card.show_paid(cash)


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


## Quest 1's fighters on the cast rigs (ArenaRigs: Rivet's held weapon, swings, reloads) when
## the view draws the standing cards (n8-view: under combo / tilt70 the sprite cast lay flat on
## the tilted ground), or on `-- --rigs` in a debug build (rivet-arsenal). Otherwise (`top`,
## today's ship) the sprite cast stays, and the ghost forms and voices show through StoryForms
## (the rig cast brings its own GhostFormView). RIGS_UNDER_CARDS false = the sprite cast always.
func _dev_rigs() -> void:
	var dev: bool = LaunchArgs.has("--rigs") and OS.is_debug_build()
	if not dev and not (RIGS_UNDER_CARDS and ViewMode.shared().cards):
		_story = StoryForms.attach(self, view, session.stage, settings.reduced_motion)
		return
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	var ok: bool = cast.attach(session.stage, view, session.world.context())
	Log.info("quest1", "cast rigs: %s" % ok)


## The cast (_dev_rigs), then the ghosts' attack views over either cast (lane ghost-powers,
## GhostAttackViews: quest 1 runs every ghost's attack through StagePilot, so it draws them too).
func _casts() -> void:
	_dev_rigs()
	@warning_ignore("return_value_discarded")
	GhostAttackViews.attach_quest(view, session.stage, settings.reduced_motion)
	if _story != null:  # n7-melee: the sprite cast draws the carried blade (rigs: RivetHeldView)
		@warning_ignore("return_value_discarded")
		CastBladeView.attach(view, session.stage)


## The live input's screen frame: Rivet at the centre, and the view's px/m so a thrown aim lands
## where the cursor is in metres (n7-ranged, quest 1's table guns).
func _bind_live() -> void:
	session.live.viewport = get_viewport()
	session.live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size / 2.0
	session.live.px_per_m = func() -> float: return view.px_per_m


## n7-melee: `--quest-blade` -> the carried blade (absent or off: none, Rivet's own claws, the
## owner's 2026-11-06 call; else the id, e.g. katana).
static func blade_of(flag: String) -> StringName:
	return &"" if flag == "" or flag == "off" else StringName(flag)

extends Node
## The shipped Quest 1 title and session, with two cuts across travel/dialogue. The original
## quest pad plays every intervening tick. Only the opening attacks and wheel inputs differ.

const KNOWN_FLAGS: PackedStringArray = ["--ppm", "--view", "--controls"]
const FIXED_FPS: int = 60
const START: int = 240
const BRASS: int = 720
const DOCK: int = 1030
const SEEK_LIMIT: int = 30000
const QUEST_SCENE: PackedScene = preload("res://boot/quest1.tscn")

var game: Quest1Game
var session: Quest1Session
var driver: CollectCallInputDriver
var frame: int = -1
var pickup_frame: int = -1
var shots_at_pickup: int = 0


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	game = QUEST_SCENE.instantiate() as Quest1Game
	game.px_per_m = ArenaArgs.parse().number("--ppm", 32.0)
	game.save_path = ""
	game.settings_path = ""
	add_child(game)
	process_priority = -1000


func _process(_delta: float) -> void:
	frame += 1
	if frame < START:
		return
	if frame == START:
		game.card.start_button.pressed.emit()
		session = game.session
		session.world.set_process(false)
		session.live.viewport = null
		driver = CollectCallInputDriver.new(session.stage, session.system)
	if frame < BRASS:
		_opening()
	elif session.pilot.wheel == null:
		_note("end of legacy opening")
		get_tree().quit()
	elif frame < DOCK:
		_grant()
	else:
		_dock()


func _opening() -> void:
	var age: int = frame - START
	var aim: Vector2 = Vector2(1, 0.6).normalized()
	OpeningFilmPad.sticks(Vector2.ZERO, aim)
	OpeningFilmPad.button(&"fire", float(age >= 110 and age < 155))
	OpeningFilmPad.button(&"melee", float(age in [205, 277]))
	if age >= 330:
		driver.act()
		# Walk to the first objective. The cut covers the time spent hidden in the dumpster.
		Input.action_release(&"interact")
	session.step()
	if age in [0, 155, 290]:
		_note("opening")


func _grant() -> void:
	var age: int = frame - BRASS
	if age == 0:
		if not _seek(false):
			return
		_note("Brass gave Gloria")
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2(1, 0.5).normalized())
	if age in [95, 187]:
		OpeningFilmPad.scroll(session.live)
	OpeningFilmPad.button(&"fire", float(age == 238))
	session.step()
	if age in [95, 187, 239]:
		_note("after input")


func _dock() -> void:
	if frame == DOCK:
		if not _seek(true):
			return
		# Arrive at the first dropped rifle on hands, via the real mouse-wheel binding.
		OpeningFilmPad.scroll(session.live)
	if pickup_frame < 0:
		_walk_to_rifle()
		session.step()
		if frame == DOCK:
			_note("scrolled to hands before approaching the drop")
		if session.stage.arena.rifles_grabbed > 0:
			pickup_frame = frame
			shots_at_pickup = session.stage.shots_fired
			_note("first floor rifle collected")
			driver.release()
		elif frame > DOCK + 600:
			_fail("The pad did not reach the first dropped rifle within the shot")
		return
	_after_pickup(frame - pickup_frame)


func _walk_to_rifle() -> void:
	var arena: CombatArena = session.stage.arena
	if arena.rifle_drops.is_empty():
		_fail("The dropped rifle disappeared before Rivet reached it")
		return
	var to: Vector2 = arena.rifle_drops[0] - arena.rivet.pos
	OpeningFilmPad.sticks(to.normalized(), to.normalized())
	OpeningFilmPad.button(&"interact", float(to.length() < StageActions.RIFLE_REACH_M))


func _after_pickup(age: int) -> void:
	var aim: Vector2 = Vector2.RIGHT
	for hostile: Fighter in session.stage.arena.hostiles:
		if hostile.alive() and hostile.exposed:
			aim = session.stage.arena.rivet.pos.direction_to(hostile.pos)
			break
	OpeningFilmPad.sticks(Vector2.ZERO, aim)
	OpeningFilmPad.button(&"interact", 0)
	if age in [95, 170, 245]:
		OpeningFilmPad.scroll(session.live)
	OpeningFilmPad.button(&"fire", float(age in [290, 305, 320, 335, 350]))
	session.step()
	if age in [1, 95, 170, 245, 351]:
		_note("after pickup")
	if age == 360:
		if session.stage.shots_fired <= shots_at_pickup or session.pilot.melee_swings < 1:
			_fail("Missing opening claw or post-selection shot")
		else:
			get_tree().quit()


func _seek(floor_rifle: bool) -> bool:
	var from: int = session.tick()
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.ZERO)
	OpeningFilmPad.button(&"fire", 0)
	while session.tick() < SEEK_LIMIT:
		driver.act()
		if floor_rifle and Input.is_action_pressed(&"fire") and session.tick() % 3 == 1:
			Input.action_release(&"fire")
		session.step()
		if floor_rifle and not session.stage.arena.rifle_drops.is_empty():
			break
		if not floor_rifle and session.stage.last_line == "brass-gloria":
			break
	driver.release()
	if session.tick() >= SEEK_LIMIT:
		_fail("Quest pad did not reach the next shot")
		return false
	if game.view != null:
		@warning_ignore("return_value_discarded")
		game.view.fill_street()
	_note("cut from sim tick %d" % from)
	return true


func _note(beat: String) -> void:
	var stage: CollectCallStage = session.stage
	var wheel: RivetWheel = session.pilot.wheel
	var slot: String = String(wheel.selected()) if wheel != null else "legacy"
	Log.info(
		"quest_opening",
		(
			"frame %d sim %d %s, slot %s, weapon '%s', shots %d, swings %d"
			% [
				frame,
				stage.tick,
				beat,
				slot,
				stage.arena.rivet.weapon,
				stage.shots_fired,
				stage.pilot.melee_swings
			]
		)
	)


func _fail(reason: String) -> void:
	set_process(false)
	Log.error("quest_opening", reason)
	get_tree().quit(1)

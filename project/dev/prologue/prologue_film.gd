extends Node
## Godot's movie writer records from the first draw. Seek the real pilot before that
## draw, then advance one sim tick per movie frame, including the full end-card hold.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--clip", "--result", "--seed", "--view"]
const FIXED_FPS: int = 60
const NEEDS_WINDOW: bool = true
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const SIZE: Vector2i = Vector2i(1920, 1080)
const LEAD: int = 3 * SimClock.TICK_RATE
const TAIL: int = 12 * SimClock.TICK_RATE
const LIMIT: int = 300 * SimClock.TICK_RATE

var _game: PrologueGame
var _last_tick: int = -1


func _ready() -> void:
	set_process(false)
	if not LaunchArgs.has("--bot") or LaunchArgs.value("--bot") == "skipper":
		_fail("use --bot for the unskipped pilot")
		return
	if DisplayServer.get_name() == "headless" or get_window().size != SIZE:
		_fail("use a window and --resolution 1920x1080")
		return
	if ProjectSettings.get_setting("display/window/size/viewport_width") != SIZE.x:
		_fail("use capture/film.ps1 to set the AVI viewport and MJPEG quality before startup")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("tilt70")
	var first_tick: int = 0
	if LaunchArgs.has("--clip"):
		var clip: String = LaunchArgs.value("--clip")
		if clip not in ["first_kill", "guard_lesson", "pistol_pickup", "mulroney_order"]:
			_fail("unknown --clip=%s" % clip)
			return
		var moment: int = _locate(clip)
		if moment < 0:
			_fail("pilot did not reach %s within %d ticks" % [clip, LIMIT])
			return
		first_tick = maxi(0, moment - LEAD)
		_last_tick = moment + TAIL
		Log.info(
			"prologue-film", "%s at %d, filming %d..%d" % [clip, moment, first_tick, _last_tick]
		)
	_game = ENTRY.instantiate() as PrologueGame
	add_child(_game)
	if _game.world == null:
		return
	_game.world.set_process(false)
	while _game.world.context().clock.tick() < first_tick:
		_game.world.loop().step()
	process_priority = -100
	set_process(true)


func _locate(clip: String) -> int:
	var probe: PrologueGame = ENTRY.instantiate() as PrologueGame
	probe.with_view = false
	add_child(probe)
	probe.result_path = ""
	var moment: int = -1
	if probe.world != null:
		while probe.world.context().clock.tick() < LIMIT and probe.encounter.street.end_tick < 0:
			probe.world.loop().step()
			if _at_event(probe.encounter, clip):
				moment = probe.stage.tick
				break
	probe.free()
	return moment


func _at_event(encounter: PrologueEncounter, clip: String) -> bool:
	match clip:
		"first_kill":
			return encounter.dale_died >= 0
		"guard_lesson":
			return encounter.prompts.active("guard")
		"pistol_pickup":
			return encounter.battle.pistol.picked_tick >= 0
		"mulroney_order":
			# The first ranged flank follows the pickup. Its tell and punish fit in one clip.
			return (
				encounter.battle.ranged
				and encounter.battle.orders.back()["line"] == "b2_l01_mulroney_line_up"
			)
	return false


func _process(_dt: float) -> void:
	_game.world.loop().step()
	if _game.stage.tick == _last_tick:
		get_tree().quit()
	elif _game.stage.tick >= LIMIT:
		_fail("pilot timed out before the end card")


func _fail(message: String) -> void:
	Log.error("prologue-film", message)
	get_tree().quit(2)

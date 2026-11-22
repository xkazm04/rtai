extends ArenaGame
## The regular arena and pistol loadout, with a live-input route to its five-metre dummy.

const KNOWN_FLAGS: PackedStringArray = ["--ppm", "--view", "--clean", "--loadout"]
const FIXED_FPS: int = 60
const DRAW: int = 580
const HOLSTER: int = 864
const END: int = 970

var dummy: ArenaTargets.Target
var hits_with_hands: int = 0


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	for target: ArenaTargets.Target in session.stage.targets.targets:
		if target.spawn.id == "static_05m":
			dummy = target
			break
	if dummy == null or session.pilot.wheel == null:
		_fail("Expected the range dummy and the default wheel")


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	var to: Vector2 = dummy.home - session.stage.arena.rivet.pos
	var move: Vector2 = Vector2.ZERO
	if tick >= 45 and tick < 450 and to.length() > 1.1:
		move = to.normalized()
	elif tick >= 450 and tick < DRAW and to.length() < 4.5:
		move = -to.normalized()
	OpeningFilmPad.sticks(move, to.normalized())
	var primary: bool = (tick >= 270 and tick < 380) or (tick in [620, 655, 700, 745, 790, 825])
	OpeningFilmPad.button(&"fire", float(primary))
	OpeningFilmPad.button(&"melee", float(tick == 422))
	if tick in [DRAW, HOLSTER]:
		OpeningFilmPad.scroll(session.live)
	session.step()
	_check(tick)


func _check(tick: int) -> void:
	var wheel: RivetWheel = session.pilot.wheel
	if tick in [0, DRAW, HOLSTER]:
		Log.info(
			"arena_opening",
			"sim %d selected %s, order %s" % [tick, wheel.selected(), wheel.order()]
		)
		var expected: StringName = &"pistol" if tick == DRAW else RivetWheel.HANDS
		if wheel.selected() != expected:
			_fail("Unexpected slot at tick %d" % tick)
	if tick == DRAW:
		hits_with_hands = session.pilot.melee.landed
	if tick == END:
		var shots: int = session.stage.shots_fired
		Log.info("arena_opening", "claw hits %d, pistol shots %d" % [hits_with_hands, shots])
		if hits_with_hands < 2 or shots < 2:
			_fail("The range take needs at least two claw hits and two pistol shots")
		else:
			get_tree().quit()


func _fail(reason: String) -> void:
	set_process(false)
	Log.error("arena_opening", reason)
	get_tree().quit(1)

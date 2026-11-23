class_name PressureTake
extends RefCounted
## One fresh street per take. All movement and attacks go through the live stage.
## The rifle demonstration cues single aimed rounds so each defensive contact is visible.

const TAKES: Array[String] = ["guard", "blade", "stand", "circle", "dash", "rockets"]
const WAVE: int = 6
const RIFLE: StringName = &"assault-rifle"

var session: GauntletSession
var arena: GauntletCombat
var take: String
var tick: int = 0
var length: int
var mark: Vector2
var rifles: PressureRifles = PressureRifles.new()
var contacts: int = 0
var paired_ticks: int = 0
var first_pair: int = 0
var first_dash: int = 0
var _dash_read: int = BotProfile.shipped(&"average").dash_read_ticks
var _launch: int = -1000
var _last_rocket: Shot
var _wave: GauntletLiveWave


func open(id: String, seed_value: int) -> bool:
	take = id
	var run: GauntletRun = GauntletRun.new()
	run.seed = seed_value
	run.controls = &"wheel"
	run.profile = &"average"
	session = GauntletSession.open_street(Events, Data, run)
	if session == null:
		return false
	arena = session.stage.arena as GauntletCombat
	arena.wave_live = true
	# Use an open crossing for a clear sightline and a common fixed camera.
	while session.street.current().id != &"crosswalk" and session.street.index < 100:
		arena.rivet.pos.x = session.street.current().end_x() + 0.1
		session.street.step(session.stage, 0)
	mark = Vector2(session.street.current().start_x + 12.0, 0)
	arena.rivet.pos = mark
	session.pilot.carry = RivetWheel.carry_for(arena)
	@warning_ignore("return_value_discarded")
	arena.struck.connect(_hit)
	match take:
		"guard", "blade":
			length = 600
			rifles.place(session, mark, take == "blade")
		"rockets":
			_rockets()
		_:
			return _fight(run)
	return true


func _rockets() -> void:
	length = 960
	@warning_ignore("return_value_discarded")
	session.pilot.carry.add(&"rocket_launcher")
	arena.rivet.pos = mark + Vector2(-4, -1)
	var at: Vector2 = mark + Vector2(12, 1)
	var foe: Fighter = arena.squad_ai.spawn_member(arena, at, &"rocket_trooper")
	foe.pos = at


func _fight(run: GauntletRun) -> bool:
	length = 420
	var crew: Array[StringName] = GauntletComposer.shipped(session.world.context().rng).compose(
		WAVE
	)
	if not crew.has(&"rocket_trooper") or not crew.has(&"patrol_cop"):
		return false
	@warning_ignore("return_value_discarded")
	session.pilot.carry.add(&"pistol")
	run.wave = WAVE - 1
	arena.rivet.pos = mark + Vector2(2, 0)
	session.street.hold_block(arena)
	_wave = GauntletLiveWave.new(crew, session.street.max_alive)
	@warning_ignore("return_value_discarded")
	_wave.spawn(session.stage, session.street.current(), session.street.max_alive, 0, run)
	arena.wave_live = true
	return true


func advance() -> void:
	tick += 1
	if not arena.rivet.alive():
		return
	var input: TickInput = TickInput.new()
	var aim: Vector2 = Vector2.RIGHT
	match take:
		"guard", "blade":
			rifles.drive(input, tick)
		"rockets":
			aim = _rocket_input(input)
		_:
			aim = _fight_input(input)
	input.buttons |= PlayerCommand.pack_aim(aim, session.actions, 16.0)
	session.stage.step(tick, input)
	if first_dash == 0 and session.pilot.motion.dashes > 0:
		first_dash = tick
	var own: bool = false
	var hostile: bool = false
	for shot: Shot in arena.shots:
		if shot is FoeRocketFlight.Round:
			hostile = true
			if not shot.has_meta(&"pressure_launch"):
				shot.set_meta(&"pressure_launch", tick)
				_launch = tick
				_last_rocket = shot
		elif shot.from_rivet and shot.weapon == &"rocket_launcher":
			own = true
	if own and hostile:
		paired_ticks += 1
		if first_pair == 0:
			first_pair = tick


func _rocket_input(input: TickInput) -> Vector2:
	if tick == 2:
		_press(input, &"weapon_next")
	if tick == _launch + 3:
		_press(input, &"fire")
	if tick == _launch + 22:
		_press(input, &"dash")
		input.move_y = TickInput.AXIS_MAX if arena.rivet.pos.y < 0 else -TickInput.AXIS_MAX
	# Cross the hostile lane at an angle so the comparison can run for several volleys.
	return Vector2(1, -0.40 if arena.rivet.pos.y < 0 else 0.40).normalized()


func _fight_input(input: TickInput) -> Vector2:
	if tick == 2:
		_press(input, &"weapon_next")
	if tick % 59 == 29:
		_press(input, &"fire")
	var offset: Vector2 = arena.rivet.pos - mark
	var move: Vector2 = Vector2.ZERO
	if take != "stand":
		var radial: Vector2 = offset.normalized()
		move = (radial.orthogonal() + radial * (3.0 - offset.length())).normalized() * 0.7
	if take == "dash" and tick == _launch + _dash_read and _last_rocket != null:
		var side: Vector2 = _last_rocket.vel.normalized().orthogonal()
		if side.dot(move) < 0:
			side = -side
		move = side
		_press(input, &"dash")
	input.move_x = roundi(move.x * TickInput.AXIS_MAX)
	input.move_y = roundi(move.y * TickInput.AXIS_MAX)
	for foe: Fighter in _wave.members:
		if foe.alive():
			return arena.rivet.pos.direction_to(foe.pos)
	return Vector2.RIGHT


func _press(input: TickInput, action: StringName) -> void:
	input.buttons |= 1 << session.actions.bit(action)


func _hit(fighter: Fighter, _dir: Vector2, _lethal: bool, weapon: StringName) -> void:
	if fighter == arena.rivet and weapon == RIFLE:
		contacts += 1


func summary() -> Dictionary:
	return {
		"take": take,
		"tick": tick,
		"hp": arena.rivet.hp,
		"hits": contacts,
		"passed": rifles.passed,
		"returned": rifles.returned,
		"shooter_hits": arena.kills,
		"dashes": session.pilot.motion.dashes,
		"paired_ticks": paired_ticks,
		"first_pair": first_pair,
		"first_dash": first_dash,
		"last_launch": _launch,
		"shots": session.stage.shots_fired,
	}

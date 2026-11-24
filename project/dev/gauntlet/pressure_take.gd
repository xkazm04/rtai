class_name PressureTake
extends RefCounted
## One fresh street per take. All movement and attacks go through the live stage.
## The rifle demonstration cues single aimed rounds so each defensive contact is visible.

const TAKES: Array[String] = [
	"guard",
	"blade",
	"stand",
	"circle",
	"dash",
	"rockets",
	"pair_circle",
	"pair_dash",
	"guard6",
	"blade6"
]
const PAIR_TICKS: int = 1500
const NEAR_TICKS: int = 2380
const WAVE: int = 6
const RIFLE: StringName = &"assault-rifle"

var session: GauntletSession
var arena: GauntletCombat
var take: String
var tick: int = 0
var length: int
var mark: Vector2
var rifles: PressureRifles = PressureRifles.new()
var pair: PressurePair = PressurePair.new()
var contacts: int = 0
var rockets: PressureLaunches = PressureLaunches.new()
var first_dash: int = 0
var _dash_read: int = BotProfile.shipped(&"average").dash_read_ticks
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
		"guard6", "blade6":
			length = NEAR_TICKS
			rifles.near(take == "blade6")
			rifles.place(session, mark, take == "blade6", true)
		"pair_circle", "pair_dash":
			length = PAIR_TICKS
			PressureStreet.widen(session, PressurePair.RADIUS_M)
			pair.place(session, mark + Vector2(4, 0), take == "pair_dash")
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
		if take.begins_with("pair"):
			pair.observe(tick)
		return
	var input: TickInput = TickInput.new()
	var aim: Vector2 = Vector2.RIGHT
	match take:
		"guard", "blade", "guard6", "blade6":
			rifles.drive(input, tick)
		"pair_circle", "pair_dash":
			aim = pair.drive(input, tick)
		"rockets":
			aim = _rocket_input(input)
		_:
			aim = _fight_input(input)
	input.buttons |= PlayerCommand.pack_aim(aim, session.actions, 16.0)
	session.stage.step(tick, input)
	rifles.observe(tick)
	if take.begins_with("pair"):
		pair.observe(tick)
		return
	if first_dash == 0 and session.pilot.motion.dashes > 0:
		first_dash = tick
	rockets.observe(arena, tick)


func _rocket_input(input: TickInput) -> Vector2:
	if tick == 2:
		_press(input, &"weapon_next")
	if tick == rockets.launch + 3:
		_press(input, &"fire")
	if tick == rockets.launch + 22:
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
	if take == "dash" and tick == rockets.launch + _dash_read and rockets.last != null:
		var side: Vector2 = rockets.last.vel.normalized().orthogonal()
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
	var row: Dictionary = {
		"take": take,
		"tick": tick,
		"hp": arena.rivet.hp,
		"hits": contacts,
		"shooter_hits": arena.kills,
		"dashes": session.pilot.motion.dashes,
		"first_dash": first_dash,
		"paired_ticks": rockets.paired_ticks,
		"first_pair": rockets.first_pair,
		"last_launch": rockets.launch,
		"shots": session.stage.shots_fired,
	}
	row.merge(rifles.summary())
	row.merge(pair.summary())
	return row

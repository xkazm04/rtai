extends ArenaGame
## A fixed-step take on the arena range. Only the analogue sticks bypass the installed keys.

const KNOWN_FLAGS: PackedStringArray = [
	"--view", "--ppm", "--clean", "--shot", "--shot-tick", "--car-doors"
]
const FIXED_FPS: int = 60
const FORMS: Array[StringName] = [&"dent", &"kerf", &"ohm", &"tonnage"]
const PARK: Vector2 = Vector2(29, -21.7)
const MARKS: Array[Vector2] = [Vector2(31, -8), Vector2(24, -9), Vector2(14, -11), Vector2(27, -13)]
const SIGHTS: Array[Vector2] = [Vector2(20, -15), Vector2(10, -15), Vector2(20, -10)]
const CLAW: int = 260
const FIRST_RELEASE: int = 394

var _caps: KeysFilmCaps = KeysFilmCaps.new()
var _rivet: Fighter
var _dummy: ArenaTargets.Target
var _car: VehicleBody
var _deploy: GhostDeploy
var _releases: Array[int] = []
var _enter: int
var _leave: int
var _landed: Array[StringName] = []
var _driving: bool = false
var _entered: bool = false
var _exited: bool = false


func _ready() -> void:
	if Engine.get_write_movie_path() != "":
		var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		if Vector2i(width, height) != Vector2i(1920, 1080):
			_fail("Movie Maker needs a 1920x1080 project viewport")
			return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	session.world.set_process(false)
	session.live.viewport = null
	process_priority = -1000
	_rivet = session.stage.arena.rivet
	_rivet.pos = Vector2(4, -6.6)
	for target: ArenaTargets.Target in session.stage.targets.targets:
		if target.spawn.id == "static_35m":
			_dummy = target
	if _dummy == null or session.stage.vehicles == null:
		_fail("range dummy and arena cars required")
		return
	var lot: RangeLot = RangeLot.new()
	lot.rivet = _rivet
	session.stage.vehicles.world = lot
	_car = session.stage.vehicles.spawn_parked(&"sedan", PARK, Vector2.LEFT, 3)
	_deploy = session.pilot.ghosts.deploy
	var release: int = FIRST_RELEASE
	for id: StringName in FORMS:
		_releases.append(release)
		release += _deploy.strike.attacks.deploy[id].cooldown_ticks
	_enter = _releases.back() + 150
	_leave = _enter + 244
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud") + 10
	add_child(layer)
	layer.add_child(_caps)
	_caps.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caps.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	_sticks(tick)
	_keys(tick)
	var before: GhostDeploy.Phase = _deploy.phase
	session.step()
	_caps.advance(tick)
	_observe(tick, before)
	super(0.0)  # ArenaGame's optional post-draw still.


func _sticks(tick: int) -> void:
	var aim: Vector2 = _rivet.pos.direction_to(_dummy.home)
	var move: Vector2 = Vector2.ZERO
	if tick < CLAW:
		var goal: Vector2 = Vector2(31, -6.8) if tick < 185 else _dummy.home
		if tick >= 15 and _rivet.pos.distance_to(goal) > 1.0:
			move = _rivet.pos.direction_to(goal)
	elif tick >= CLAW + 25 and tick < _releases.back():
		var beat: int = 0
		while beat < FORMS.size() - 1 and tick > _releases[beat] + 66:
			beat += 1
		var mark: Vector2 = MARKS[beat]
		var sight: Vector2 = _dummy.home if beat == 0 else SIGHTS[beat - 1]
		if beat > 0:
			var start: int = _releases[beat - 1] + 115
			var phase: float = clampf(float(tick - start) / (_releases[beat] - start), 0.0, 1.0)
			mark += Vector2(sin(TAU * phase) * 2.5, sin(PI * phase))
			sight.y += sin(TAU * phase) * 2.8
		move = (mark - _rivet.pos).limit_length(0.65)
		aim = _rivet.pos.direction_to(sight)
	elif tick >= _releases.back() + 52 and tick < _enter:
		var door: Vector2 = VehicleDoorPath.driver_door(_car, session.stage.vehicles.doors.radius)
		move = (door + Vector2.DOWN * 0.7 - _rivet.pos).limit_length(0.8)
		aim = _rivet.pos.direction_to(_car.pos)
	elif tick >= _enter + 25 and tick < _leave - 8:
		# Ease off and brake before the second tap so the ordinary door walk plays.
		move = Vector2.UP * 0.62 if tick < _leave - 55 else Vector2.DOWN
		if tick >= _leave - 55 and _car.speed() < 0.6:
			move = Vector2.ZERO
	OpeningFilmPad.sticks(move, aim)


func _keys(tick: int) -> void:
	_interval(tick, &"sprint", 66, 186)
	_interval(tick, &"dash", 200, 206)
	_interval(tick, &"melee", CLAW, CLAW + 6)
	for i: int in FORMS.size():
		var start: int = CLAW + 55 if i == 0 else _releases[i - 1] + 115
		_interval(tick, GhostNumberKeys.ACTIONS[i], start, _releases[i])
	_interval(tick, &"car", _enter, _enter + 6)
	_interval(tick, &"car", _leave, _leave + 6)


func _interval(tick: int, action: StringName, down: int, up: int) -> void:
	if tick != down and tick != up:
		return
	var word: String = tr(action)
	var slot: int = GhostNumberKeys.ACTIONS.find(action)
	if slot >= 0:
		word = cast.ghost_view.hud.names[FORMS[slot]]
	elif action == &"melee":
		var prompt: String = QuestText.new().resolve(
			&"PROLOGUE__CLAW", ProloguePrompts.COPY["claw"]
		)
		word = prompt.replace("[melee]", "").strip_edges()
	if not _caps.send(action, tick == down, tick, word):
		_fail("missing installed key for %s at tick %d" % [action, tick])


func _observe(tick: int, before: GhostDeploy.Phase) -> void:
	if _deploy.phase == GhostDeploy.Phase.ACTIVE and before != GhostDeploy.Phase.ACTIVE:
		_landed.append(_deploy.form)
		Log.info("keys_film", "tick %d | deployed %s" % [tick, _deploy.form])
	if tick in _releases:
		var id: StringName = FORMS[_releases.find(tick)]
		if _deploy.phase != GhostDeploy.Phase.ACTIVE or _deploy.form != id:
			_fail("tick %d | missing deploy %s | refusal %s" % [tick, id, _deploy.last_refusal])
	if tick == 100 or tick == 200 or tick == CLAW + 22:
		var motion: PlayerMotion = session.pilot.motion
		var state: Array = [tick, motion.sprinting, motion.dashes, _dummy.hits, _rivet.pos]
		Log.info("keys_film", "tick %d | sprint %s | dashes %d | dummy hits %d | %s" % state)
		if (tick == 100 and not motion.sprinting) or (tick == 200 and motion.dashes != 1):
			_fail("movement cue missed at tick %d" % tick)
		if tick == CLAW + 22 and (_dummy.hits == 0 or session.pilot.melee.landed == 0):
			_fail("claw missed at tick %d" % tick)
	_seat(tick)
	if tick == _leave + 35:
		if _landed != FORMS or not _entered or not _exited or _car.pos.distance_to(PARK) < 4.0:
			_fail("incomplete take: %s, entered %s, exited %s" % [_landed, _entered, _exited])
		else:
			Log.info("keys_film", "complete | car travelled %.2f m" % _car.pos.distance_to(PARK))
			get_tree().quit()


func _seat(tick: int) -> void:
	var seated: bool = session.stage.vehicles.driving == _car
	if seated != _driving:
		if seated:
			_entered = true
		else:
			_exited = true
		Log.info("keys_film", "tick %d | car %s" % [tick, "entered" if seated else "left"])
	_driving = seated
	var rig: CutRig = cast.rigs.rig_for(_rivet.id)
	if rig != null:
		rig.modulate.a = 0.0 if seated and session.stage.vehicles.doors.car == null else 1.0


func _fail(reason: String) -> void:
	Log.error("keys_film", reason)
	set_process(false)
	get_tree().quit(1)


class RangeLot:
	extends VehicleWorld
	## The stock arena keeps the driver offstage. Supply the actual foot and follow the seat.
	var rivet: Fighter

	func player_pos() -> Vector2:
		return rivet.pos

	func set_focus(at: Vector2, _in_car: bool) -> void:
		rivet.pos = at

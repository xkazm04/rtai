extends Node
## Capture the real 32 px/m viewport on the exact sim tick of each patrol or squad event.

const KNOWN_FLAGS: PackedStringArray = [
	"--bot", "--film-dir", "--prologue-stills", "--seed", "--view"
]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60

var _game: PrologueGame
var _out: String
var _target: String
var _captured: Dictionary[String, bool] = {}
var _saving: bool = false


func _ready() -> void:
	_game = $Prologue as PrologueGame
	_out = ArenaArgs.parse().text("--film-dir")
	_target = LaunchArgs.value("--prologue-stills")
	if _target not in ["", "patrol", "squad", "street"]:
		Log.error("prologue-film", "--prologue-stills expects patrol, squad or street")
		get_tree().quit(2)
		return
	if (
		DisplayServer.get_name() == "headless"
		or not LaunchArgs.has("--bot")
		or not _out.is_absolute_path()
		or DirAccess.make_dir_recursive_absolute(_out) != OK
	):
		Log.error("prologue-film", "a windowed --bot and absolute --film-dir are required")
		get_tree().quit(2)
		return
	_game.world.set_process(false)
	process_priority = -100


func _process(_dt: float) -> void:
	if _saving:
		return
	var battle: PrologueBattle = _game.encounter.battle
	var warmup: bool = _target == "squad" and not battle.ranged
	warmup = warmup or (_target == "street" and battle.died_tick < 0)
	var steps: int = 20 if warmup else 1
	for i: int in steps:
		_game.world.loop().step()
		var tick: int = _game.stage.tick
		var shot: String = _event(battle, tick)
		if shot != "" and not _captured.has(shot):
			_saving = true
			_capture.call_deferred(shot, tick)
			return
		if (_target != "street" and battle.died_tick >= 0) or tick >= 12000:
			Log.error(
				"prologue-film", "missing frame at tick %d, captured %s" % [tick, _captured.keys()]
			)
			get_tree().quit(1)
			return


func _event(battle: PrologueBattle, tick: int) -> String:
	if _target == "street":
		return _street_event(tick) if battle.died_tick >= 0 else ""
	if _target != "squad":
		if tick == 300:
			return "yard"
		return "dale-first-kill" if tick == _game.encounter.dale_died else ""
	return _squad_event(battle, tick)


func _squad_event(battle: PrologueBattle, tick: int) -> String:
	var floor_guns: Array[WeaponPickups.Item] = _game.stage.pilot.carry.ground.items
	if not _captured.has("pistol-marked") and not floor_guns.is_empty():
		if _game.stage.arena.rivet.pos.distance_to(floor_guns[0].pos) <= 4.5:
			return "pistol-marked"
	if battle.pistol.picked_tick >= 0 and battle.due_tick - tick == 30:
		return "mulroney-order"
	if battle.ranged and battle.formation.boss.hurt_tick == tick and tick < battle.exposed_until:
		return "mulroney-hit"
	return ""


func _street_event(tick: int) -> String:
	var street: PrologueStreet = _game.encounter.street
	var at: Vector2 = _game.stage.arena.rivet.pos
	var gate: Vector2 = (_game.stage.plan as PrologueYard).gate
	if not _captured.has("gate-exit") and at.y >= gate.y + 0.18 and at.y <= gate.y + 0.9:
		return "gate-exit"
	match street.phase:
		PrologueStreet.Phase.PHONE:
			if (
				_game.stage.router.ringing(street.phone)
				and at.distance_to(_game.stage.layout.phones[street.phone]) < 4.5
			):
				return "payphone-ringing"
		PrologueStreet.Phase.CALL:
			var line_tick: int = _game.lines.events.back()["tick"]
			if _game.lines.current == "b3_l05_fax_talent" and tick - line_tick >= 18:
				return "payphone-call"
		PrologueStreet.Phase.REQUEST:
			return "channel-request"
		PrologueStreet.Phase.END:
			return "end-card"
	return ""


func _capture(shot: String, tick: int) -> void:
	await RenderingServer.frame_post_draw
	var path: String = _out.path_join("%s-t%04d.png" % [shot, tick])
	var frame: Image = get_viewport().get_texture().get_image()
	if _game.stage.tick != tick or frame == null or frame.is_empty() or frame.save_png(path) != OK:
		Log.error("prologue-film", "could not capture tick %d to %s" % [tick, path])
		get_tree().quit(1)
		return
	Log.info("prologue-film", "tick %d, %s px, %s" % [tick, frame.get_size(), path])
	_captured[shot] = true
	_saving = false
	var wanted: int = 5 if _target == "street" else (3 if _target == "squad" else 2)
	if _captured.size() == wanted:
		get_tree().quit()

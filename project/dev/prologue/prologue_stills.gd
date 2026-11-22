extends Node
## Capture the real 32 px/m viewport on the exact sim tick of each patrol or squad event.

const KNOWN_FLAGS: PackedStringArray = [
	"--bot", "--film-dir", "--prologue-stills", "--seed", "--view"
]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60

var _game: PrologueGame
var _out: String
var _squad: bool
var _captured: Dictionary[String, bool] = {}
var _saving: bool = false


func _ready() -> void:
	_game = $Prologue as PrologueGame
	_out = ArenaArgs.parse().text("--film-dir")
	var target: String = LaunchArgs.value("--prologue-stills")
	if target not in ["", "patrol", "squad"]:
		Log.error("prologue-film", "--prologue-stills expects patrol or squad")
		get_tree().quit(2)
		return
	_squad = target == "squad"
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
	# Skip rendering the patrol warm-up when filming only the second squad.
	var steps: int = 20 if _squad and not battle.ranged else 1
	for i: int in steps:
		_game.world.loop().step()
		var tick: int = _game.stage.tick
		var shot: String = _event(battle, tick)
		if shot != "" and not _captured.has(shot):
			_saving = true
			_capture.call_deferred(shot, tick)
			return
		if battle.died_tick >= 0 or tick >= 12000:
			Log.error(
				"prologue-film", "missing frame at tick %d, captured %s" % [tick, _captured.keys()]
			)
			get_tree().quit(1)
			return


func _event(battle: PrologueBattle, tick: int) -> String:
	if not _squad:
		if tick == 300:
			return "yard"
		return "dale-first-kill" if tick == _game.encounter.dale_died else ""
	var floor_guns: Array[WeaponPickups.Item] = _game.stage.pilot.carry.ground.items
	if not _captured.has("pistol-marked") and not floor_guns.is_empty():
		if _game.stage.arena.rivet.pos.distance_to(floor_guns[0].pos) <= 4.5:
			return "pistol-marked"
	if battle.ranged and battle.due_tick - tick == 30:
		return "mulroney-order"
	if battle.ranged and battle.formation.boss.hurt_tick == tick and tick < battle.exposed_until:
		return "mulroney-hit"
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
	if _captured.size() == (3 if _squad else 2):
		get_tree().quit()

extends Node
## Capture the real 32 px/m viewport on the exact sim tick of each patrol or squad event.

const KNOWN_FLAGS: PackedStringArray = [
	"--bot", "--film-dir", "--prologue-stills", "--seed", "--view"
]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
## Matched views from the unskipped opening, before the first combat input.
const PATROL_FRAMES: Dictionary[int, String] = {
	300: "yard", 648: "warden-patrol", 1186: "dale-megaphone"
}

var _out: String = ArenaArgs.parse().text("--film-dir")
var _target: String = LaunchArgs.value("--prologue-stills")
var _captured: Dictionary[String, bool] = {}
@onready var _game: PrologueGame = $Prologue as PrologueGame


func _ready() -> void:
	if _target not in ["", "patrol", "lessons", "squad", "street"]:
		Log.error("prologue-film", "--prologue-stills expects patrol, lessons, squad or street")
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
	var battle: PrologueBattle = _game.encounter.battle
	var warmup: bool = _target == "squad" and not battle.ranged
	warmup = warmup or (_target == "street" and battle.died_tick < 0)
	warmup = warmup or (_target == "lessons" and _game.encounter.dale_died < 0)
	var steps: int = 20 if warmup else 1
	for i: int in steps:
		_game.world.loop().step()
		var tick: int = _game.stage.tick
		var shot: String = _event(battle, tick)
		if shot != "" and not _captured.has(shot):
			set_process(false)
			_capture.call_deferred(shot, tick)
			return
		if (_target != "street" and battle.died_tick >= 0) or tick >= 300 * SimClock.TICK_RATE:
			Log.error("prologue-film", "missing still at %d, saved %s" % [tick, _captured.keys()])
			get_tree().quit(1)
			return


func _event(battle: PrologueBattle, tick: int) -> String:
	if _target == "lessons":
		for id: String in ProloguePrompts.HAND_ORDER:
			if _game.encounter.prompts.active(id):
				return "lesson-" + id
		return ""
	if _target == "street":
		return _street_event(tick) if battle.died_tick >= 0 else ""
	if _target != "squad":
		if tick == _game.encounter.dale_died:
			return "dale-first-kill"
		return PATROL_FRAMES.get(tick, "") if _game.encounter.patrol.dale.alive() else ""
	return _squad_event(battle, tick)


func _squad_event(battle: PrologueBattle, tick: int) -> String:
	var floor_guns: Array[WeaponPickups.Item] = _game.stage.pilot.carry.ground.items
	if not _captured.has("pistol-marked") and not floor_guns.is_empty():
		if _game.stage.arena.rivet.pos.distance_to(floor_guns[0].pos) <= 4.5:
			return "pistol-marked"
	if battle.pistol.picked_tick >= 0 and battle.due_tick - tick == 30:
		var order: String = battle.orders.back()["line"]
		return "mulroney-order" if order == "b2_l05_mulroney_shoot" else "mulroney-flank"
	if battle.ranged and battle.formation.boss.hurt_tick == tick and tick < battle.exposed_until:
		return "mulroney-hit"
	if (
		_game.encounter.prompts.active("fire")
		and _game.stage.pilot.wheel.selected() == battle.pistol.id
	):
		return "pistol-lesson"
	return ""


func _street_event(tick: int) -> String:
	var street: PrologueStreet = _game.encounter.street
	var at: Vector2 = _game.stage.arena.rivet.pos
	var gate: Vector2 = (_game.stage.plan as PrologueYard).gate
	if not _captured.has("gate-exit") and at.y >= gate.y + 0.18 and at.y <= gate.y + 0.9:
		return "gate-exit"
	match street.phase:
		PrologueStreet.Phase.PHONE:
			var phone: Vector2 = _game.stage.layout.phones[street.phone]
			if _game.stage.router.ringing(street.phone) and at.distance_to(phone) < 4.5:
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
	var name_png: String = (
		"%s.png" % shot if _target == "lessons" else "%s-t%04d.png" % [shot, tick]
	)
	var path: String = _out.path_join(name_png)
	var frame: Image = get_viewport().get_texture().get_image()
	if _game.stage.tick != tick or frame == null or frame.is_empty() or frame.save_png(path) != OK:
		Log.error("prologue-film", "could not capture tick %d to %s" % [tick, path])
		get_tree().quit(1)
		return
	Log.info("prologue-film", "tick %d, %s px, %s" % [tick, frame.get_size(), path])
	_captured[shot] = true
	set_process(true)
	var wanted: int = 5 if _target in ["street", "squad"] else 4
	if _target == "lessons":
		wanted = ProloguePrompts.HAND_ORDER.size()
	if _captured.size() == wanted:
		get_tree().quit()

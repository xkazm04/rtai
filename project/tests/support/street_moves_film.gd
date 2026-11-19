extends Node
## Replay the scenario's actual words under the quest view. Sample after draw and verify
## the two positions on every tick, including the fast-forward on either side of the clip.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--ticks", "--view"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60

var _out: String
var _ppm: int
var _first: int
var _last: int
var _s: Quest1Session
var _game: Quest1Game
var _reference: StreetMovesTrace
var _running: bool


func _ready() -> void:
	if not _options():
		_fail("requires --out=<dir>, --view=tilt70, --ppm=32|64, --ticks=first-last")
		return
	var tape: StreetMovesTape = StreetMovesTape.new()
	_reference = StreetMovesTrace.record(tape)
	if _reference.failure != "":
		_fail(_reference.failure)
		return
	_game = Quest1Game.new()
	_game.settings_path = ""
	_game.save_path = ""
	_game.px_per_m = _ppm
	add_child(_game)
	_s = Quest1Session.open(Events, Data, StreetMovesTape.SEED)
	if _s == null:
		_fail("could not open quest 1")
		return
	tape.bind(_s)
	while _s.tick() < _first - 90:
		if not _step():
			return
	_game._begin(_s)
	_game.set_process(false)
	_s.world.set_process(false)
	_game.view.objective_view.hide()
	_game.view.hud_view.hide()
	_game.view.city_view.rig = null
	_game.view.city_view.zoom = float(_ppm) / SimConst.PX_PER_M
	_running = true


func _options() -> bool:
	var values: Dictionary[String, String] = {}
	for arg: String in LaunchArgs.unknown():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			return false
		values[flag] = arg.substr(flag.length() + 1)
	_ppm = str(values.get("--ppm", "")).to_int()
	_out = values.get("--out", "")
	var ticks: PackedStringArray = str(values.get("--ticks", "")).split("-")
	if ticks.size() != 2 or not ticks[0].is_valid_int() or not ticks[1].is_valid_int():
		return false
	_first = ticks[0].to_int()
	_last = ticks[1].to_int()
	return (
		ViewMode.shared().id == &"tilt70"
		and _ppm in [32, 64]
		and not _out.is_empty()
		and DirAccess.make_dir_recursive_absolute(_out) == OK
		and _first >= 0
		and _last >= _first
		and _last < StreetMovesTape.TICKS
	)


func _process(_delta: float) -> void:
	if not _running:
		return
	var tick: int = _s.tick()
	if tick > _last:
		_finish()
		return
	if not _step() or tick < _first or (tick - _first) % 2 != 0:
		return
	_running = false
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.save_png(_out.path_join("street_%05d.png" % tick)) != OK:
		_fail("failed to save tick %d" % tick)
		return
	_running = true


func _step() -> bool:
	var tick: int = _s.tick()
	_s.step()
	if (
		_reference.feet[tick] != _s.stage.arena.rivet.pos
		or _reference.city_feet[tick] != _s.city.target
	):
		_fail("rendered run diverged at tick %d" % tick)
		return false
	var v: PlayerVault = _s.pilot.motion.vault
	if v.frame == 0 or (tick == _first and _first == _last):
		Log.info(
			"street-film",
			(
				"tick %d %s frame %d at %s"
				% [tick, v.hit.kind if v.hit else "", v.frame, _s.stage.arena.rivet.pos]
			)
		)
	return true


func _finish() -> void:
	_running = false
	while _s.tick() < StreetMovesTape.TICKS:
		if not _step():
			return
	var digest: String = _s.world.loop().state_hash()
	if digest != _reference.digest:
		_fail("rendered final digest diverged: " + digest)
		return
	Log.info(
		"street-film", "verified ticks %d-%d at %d px/m, digest %s" % [_first, _last, _ppm, digest]
	)
	_s.live.cursor_px = Callable()
	_s.autosave = null
	_s.stage.watch(null)
	_game.queue_free()
	_s = null
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()


func _fail(reason: String) -> void:
	_running = false
	Log.error("street-film", reason)
	get_tree().quit(1)

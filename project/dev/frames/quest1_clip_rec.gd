extends Node
## Records the slice (boot/quest1.tscn) in a real window: the title card, the Start press, then
## quest 1 driven only through input events (CollectCallInputDriver, a scripted pad: never the
## bot's direct calls), one tick per sim step, a PNG every `every` ticks inside the clip windows
## (the opening seconds and the Dock 9 fight), plus a few stills. Dev-only, never shipped.

## [first beat, ticks to keep] per clip window; the opening is counted from the Start press.
const WINDOWS: Array[Array] = [["b1-dumpster", 720], ["b4-dock", 1200]]
const TIMEOUT_TICKS: int = 25 * 60 * SimClock.TICK_RATE

var out_dir: String = ""
var px_per_m: float = 32.0
var every: int = 2
## Stills mode: only these ticks (even) are saved, as still_<tick>_<ppm>.png; no clip.
var stills: Array[int] = []
var _game: Quest1Game
var _driver: CollectCallInputDriver = null
var _frame: int = 0
var _kept: Dictionary[String, int] = {}


func _ready() -> void:
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	_game = scene.instantiate() as Quest1Game
	_game.px_per_m = px_per_m
	_game.save_path = ""
	_game.settings_path = ""
	add_child(_game)
	await _settle()
	await _save("title")
	_game.card.start_button.pressed.emit()
	_game.session.world.set_process(false)
	_game.session.live.viewport = null
	_driver = CollectCallInputDriver.new(_game.session.stage, _game.session.system)
	await _settle()
	_run()


func _run() -> void:
	var s: Quest1Session = _game.session
	var last: String = ""
	while not _driver.done() and s.tick() < TIMEOUT_TICKS:
		for i: int in every:
			_driver.act()
			s.step()
		var beat: String = s.beat_id()
		if not stills.is_empty():
			if stills.has(s.tick()):
				await _save("still_%d_%d" % [s.tick(), px_per_m])
				if s.tick() == stills[0]:
					_game.set_paused(true)
					await _settle()
					await _save("pause_%d" % px_per_m)
					_game.set_paused(false)
					_game.session.world.set_process(false)
			if s.tick() > stills.max():
				break
			continue
		if _keep(beat):
			await _save("clip_%05d" % _frame)
			_frame += 1
		elif beat != last:
			await _save("beat_%s" % beat)
		last = beat
	_driver.release()
	await _settle()
	await _save("paid")
	Log.info("clip", "saved %d clip frames at %d px/m, tick %d" % [_frame, px_per_m, s.tick()])
	if get_tree().has_method(&"finish"):
		get_tree().call(&"finish")
	else:
		get_tree().quit(0)


func _keep(beat: String) -> bool:
	for w: Array in WINDOWS:
		if w[0] == beat:
			var n: int = _kept.get(beat, 0)
			var limit: int = w[1]
			if n < limit:
				_kept[beat] = n + every
				return true
	return false


func _settle() -> void:
	for i: int in 3:
		await get_tree().process_frame


func _save(name_stem: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var err: Error = image.save_png(out_dir.path_join("%s.png" % name_stem))
	if err != OK:
		Log.error("clip", "cannot save %s (%d)" % [name_stem, err])

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
## Where the game writes its beat checkpoints ("" = none); with press_continue the run presses
## Continue on the title and saves continue_f1 .. continue_f6 (the first frames after it).
var save_path: String = ""
var press_continue: bool = false
## rivet-arsenal: the camera leans toward the cop Rivet fights (dev/rivet_arsenal/quest_fight_cam).
var fight_cam: bool = false
## rivet-arsenal: clip only the ticks [x, y] (Vector2i.ZERO = the WINDOWS); the sim runs through
## the rest with no frame drawn, so a Dock 9 close-up does not wait on the opening's frames.
var tick_window: Vector2i = Vector2i.ZERO
## n7-melee: the pad's blade window (CollectCallInputDriver.blade_ticks; ZERO = never).
var blade_ticks: Vector2i = Vector2i.ZERO
var _game: Quest1Game
var _driver: CollectCallInputDriver = null
var _frame: int = 0
var _kept: Dictionary[String, int] = {}


func _ready() -> void:
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	_game = scene.instantiate() as Quest1Game
	_game.px_per_m = px_per_m
	_game.save_path = save_path
	_game.settings_path = ""
	add_child(_game)
	await _settle()
	await _save("title")
	if press_continue:
		await _continue_frames()
		return
	_game.card.start_button.pressed.emit()
	_game.session.world.set_process(false)
	_game.session.live.viewport = null
	_driver = CollectCallInputDriver.new(_game.session.stage, _game.session.system)
	_driver.blade_ticks = blade_ticks
	await _settle()
	_run()


func _run() -> void:
	var s: Quest1Session = _game.session
	var last: String = ""
	while not _driver.done() and s.tick() < TIMEOUT_TICKS:
		for i: int in every:
			_driver.act()
			s.step()
		_attach_fight_cam()
		var beat: String = s.beat_id()
		if not stills.is_empty():
			if stills.has(s.tick()):
				await _still(s.tick())
			if s.tick() > stills.max():
				break
			continue
		if tick_window != Vector2i.ZERO:
			if s.tick() > tick_window.y:
				break
			await _in_window(s.tick())
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


## --cam=fight: once the city view exists (it is built after the Start press).
func _attach_fight_cam() -> void:
	if not fight_cam or _game.view == null or _game.view.city_view == null:
		return
	fight_cam = false
	var cam: Node = (load("res://dev/rivet_arsenal/quest_fight_cam.gd") as GDScript).new()
	cam.set("session", _game.session)
	cam.set("city_view", _game.view.city_view)
	add_child(cam)
	move_child(cam, 0)  # before the CityView in tree order, both at process_priority 1
	Log.info("clip", "fight cam on the city view at tick %d" % _game.session.tick())


func _continue_frames() -> void:
	_game.card.continue_pressed.emit()
	_game.session.world.set_process(false)
	await _save("continue_f1")
	for i: int in 5:  # one tick per frame, as the game steps; every frame kept (the warm-up spans 3)
		_game.session.step()
		await get_tree().process_frame
		await _save("continue_f%d" % (i + 2))
	Log.info(
		"clip", "continue at tick %d, beat %s" % [_game.session.tick(), _game.session.beat_id()]
	)
	if get_tree().has_method(&"finish"):
		get_tree().call(&"finish")
	else:
		get_tree().quit(0)


func _still(tick: int) -> void:
	await _warm()
	await _save("still_%d_%d" % [tick, px_per_m])
	if tick == stills[0]:
		_game.set_paused(true)
		await _settle()
		await _save("pause_%d" % px_per_m)
		_game.set_paused(false)
		_game.session.world.set_process(false)


## --ticks: a clip frame only inside the window.
func _in_window(tick: int) -> void:
	if tick >= tick_window.x:
		await _save("clip_%05d" % _frame)
		_frame += 1


func _keep(beat: String) -> bool:
	for w: Array in WINDOWS:
		if w[0] == beat:
			var n: int = _kept.get(beat, 0)
			var limit: int = w[1]
			if n < limit:
				_kept[beat] = n + every
				return true
	return false


## A still jumps the sim thousands of ticks with no frame drawn, so the city view has not streamed
## the chunks around Rivet yet: fill the street the way a Continue does, then let the crowd settle.
func _warm() -> void:
	if _game.view != null and _game.view.city_view != null:
		@warning_ignore("return_value_discarded")
		_game.view.fill_street()
	await _settle()


func _settle() -> void:
	for i: int in 3:
		await get_tree().process_frame


func _save(name_stem: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var err: Error = image.save_png(out_dir.path_join("%s.png" % name_stem))
	if err != OK:
		Log.error("clip", "cannot save %s (%d)" % [name_stem, err])

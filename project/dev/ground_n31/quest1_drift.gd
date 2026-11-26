extends Node
## n31-16: quest 1's city under the project stretch as played: Start pressed, the scripted pad
## (CollectCallInputDriver) walking Rivet, one sim tick per frame. Per drawn frame it logs the
## canvas origin, the window stretch and the CityView's world_px to <--result>/ticks.jsonl, the
## row format tools/ground/drift/drift.py --pan reads. --clip=<last tick> ends it (default 900).

const KNOWN_FLAGS: PackedStringArray = ["--clip", "--result"]
const NEEDS_WINDOW: bool = true
const LIMIT: int = 900
const QUEST: String = "res://boot/quest1.tscn"

var _game: Quest1Game
var _log: FileAccess


func _ready() -> void:
	var out: String = LaunchArgs.value("--result")
	if out.is_empty():
		Log.error("quest1-drift", "use --result=<abs dir>")
		get_tree().quit(2)
		return
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out)
	_log = FileAccess.open(out.path_join("ticks.jsonl"), FileAccess.WRITE)
	_game = (load(QUEST) as PackedScene).instantiate() as Quest1Game
	_game.settings_path = ""
	_game.save_path = ""
	add_child(_game)
	_run()


func _run() -> void:
	var limit: int = LaunchArgs.value("--clip").to_int() if LaunchArgs.has("--clip") else LIMIT
	for i: int in 3:
		await get_tree().process_frame
	_game.card.start_button.pressed.emit()
	_game.session.world.set_process(false)
	_game.session.live.viewport = null
	var session: Quest1Session = _game.session
	var driver: CollectCallInputDriver = CollectCallInputDriver.new(session.stage, session.system)
	for i: int in 3:
		await get_tree().process_frame
	while _game.session.tick() < limit and not driver.done():
		driver.act()
		_game.session.step()
		await RenderingServer.frame_post_draw
		_write()
	driver.release()
	_log.close()
	get_tree().quit(0)


func _write() -> void:
	var city: CityView = _game.view.city_view if _game.view != null else null
	if city == null:
		return
	var t: Transform2D = get_viewport().get_final_transform()
	var o: Vector2 = get_viewport().get_canvas_transform() * Vector2.ZERO
	var row: Dictionary = {
		"tick": _game.session.tick(),
		"pass": "",
		"canvas_origin": [o.x, o.y],
		"stretch": [t.get_scale().x, t.get_scale().y, t.origin.x, t.origin.y],
		"world_px": [city.world_px.x, city.world_px.y],
		"part_world_px": [PartMaterials.world_px.x, PartMaterials.world_px.y],
	}
	@warning_ignore("return_value_discarded")
	_log.store_line(JSON.stringify(row))

extends Node
## n31-07: the print lock against the camera in another view, log only. Runs the gauntlet
## (the default; it refuses an unknown --clip) on its own --bot under the project stretch, as
## played, and logs per drawn frame the canvas origin, the window stretch and the first
## `world_px` it finds (PrintStage or CityView) to <--result>/ticks.jsonl for drift.py --pan.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--clip", "--pick-view", "--result", "--seed"]
const NEEDS_WINDOW: bool = true
const SCENES: Dictionary = {"gauntlet": "res://dev/gauntlet/gauntlet.tscn"}
const FRAMES: int = 900

var _log: FileAccess
var _stage: Node = null


func _ready() -> void:
	var out: String = LaunchArgs.value("--result")
	var clip: String = LaunchArgs.value("--clip") if LaunchArgs.has("--clip") else "gauntlet"
	if out.is_empty() or not SCENES.has(clip):
		Log.error("drift-log-probe", "use --clip=gauntlet and --result=<abs dir>")
		get_tree().quit(2)
		return
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out)
	_log = FileAccess.open(out.path_join("ticks.jsonl"), FileAccess.WRITE)
	var path: String = SCENES[clip]
	add_child((load(path) as PackedScene).instantiate())
	_run()


func _run() -> void:
	for frame: int in FRAMES:
		await RenderingServer.frame_post_draw
		if _stage == null:
			_stage = _find(self)
		if _stage == null:
			continue
		var t: Transform2D = get_viewport().get_final_transform()
		var o: Vector2 = get_viewport().get_canvas_transform() * Vector2.ZERO
		var w: Vector2 = _world_px()
		var row: Dictionary = {
			"tick": frame,
			"pass": "",
			"canvas_origin": [o.x, o.y],
			"stretch": [t.get_scale().x, t.get_scale().y, t.origin.x, t.origin.y],
			"world_px": [w.x, w.y],
		}
		@warning_ignore("return_value_discarded")
		_log.store_line(JSON.stringify(row))
	_log.close()
	get_tree().quit(0)


func _world_px() -> Vector2:
	if _stage is PrintStage:
		return (_stage as PrintStage).world_px
	return (_stage as CityView).world_px


func _find(node: Node) -> Node:
	if node is PrintStage or node is CityView:
		return node
	for child: Node in node.get_children():
		var hit: Node = _find(child)
		if hit != null:
			return hit
	return null

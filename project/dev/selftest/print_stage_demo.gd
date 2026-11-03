extends Node
## PrintStage evidenced on a view that is not the city: flat placeholder shapes in quest 1's style
## (a concrete dock floor, crates, a fire barrel, cream people, one vermilion threat) drawn as the
## view would, with one PrintStage node added. Captures look off / d4 at 32 and 48 px/m and auto at
## 64 px/m: print-stage-<look>-<ppm>.png.
##   godot --path project res://dev/selftest/print_stage_demo.tscn -- --out=<dir>

const CASES: Array = [[&"off", 1.0], [&"d4", 1.0], [&"off", 1.5], [&"d4", 1.5], [&"auto", 2.0]]
const FOCUS: Vector2 = Vector2(12.0, 8.0)
const CREAM: Color = Color("#F2E8D5")
const INK: Color = Color("#17131B")
const VERM: Color = Color("#E8502A")

var _out: String = "user://print_stage_demo"
var _stage: PrintStage = PrintStage.new()


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--out="):
			get_tree().quit(2)
			return
		_out = arg.substr(6)
	add_child(_stage)
	var floor: Node2D = Node2D.new()
	floor.z_index = RenderLayers.z(&"ground")
	@warning_ignore("return_value_discarded")
	floor.draw.connect(_draw_floor.bind(floor))
	_stage.add_child(floor)
	var props: Node2D = Node2D.new()
	props.z_index = RenderLayers.z(&"props")
	@warning_ignore("return_value_discarded")
	props.draw.connect(_draw_props.bind(props))
	_stage.add_child(props)
	var people: Node2D = Node2D.new()
	people.z_index = RenderLayers.z(&"actors")
	people.material = _stage.item_material()
	@warning_ignore("return_value_discarded")
	people.draw.connect(_draw_people.bind(people))
	_stage.actor_layer().add_child(people)
	for c: Array in CASES:
		var look: StringName = c[0]
		var z: float = c[1]
		_stage.look_id = look
		_stage.zoom = z
		for i: int in 4:
			_stage.place(FOCUS)
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var ppm: int = roundi(z * SimConst.PX_PER_M)
		var file: String = "print-stage-%s-%dppm.png" % [look, ppm]
		@warning_ignore("return_value_discarded")
		get_viewport().get_texture().get_image().save_png(_out.path_join(file))
	get_tree().quit(0)


func _m(v: Vector2) -> Vector2:
	return v * SimConst.PX_PER_M


func _draw_floor(ci: Node2D) -> void:
	ci.draw_rect(Rect2(_m(Vector2(-10, -10)), _m(Vector2(44, 36))), Color("#8A8580"))
	ci.draw_rect(Rect2(_m(Vector2(-10, 14)), _m(Vector2(44, 12))), Color("#3A3436"))
	for x: int in range(-10, 34, 4):
		ci.draw_line(_m(Vector2(x, -10)), _m(Vector2(x, 14)), Color("#6E6964"), 2.0)


func _draw_props(ci: Node2D) -> void:
	for at: Vector2 in [Vector2(4, 3), Vector2(5.5, 3), Vector2(4, 4.5), Vector2(19, 11)]:
		ci.draw_rect(Rect2(_m(at), _m(Vector2(1.4, 1.4))), CREAM)
		ci.draw_rect(Rect2(_m(at), _m(Vector2(1.4, 1.4))), INK, false, 3.0)
		ci.draw_line(_m(at), _m(at + Vector2(1.4, 1.4)), INK, 2.0)
	ci.draw_circle(_m(Vector2(15, 4)), 0.45 * SimConst.PX_PER_M, INK)
	ci.draw_circle(_m(Vector2(15, 4)), 0.3 * SimConst.PX_PER_M, VERM)


func _draw_people(ci: Node2D) -> void:
	for at: Vector2 in [Vector2(9, 7), Vector2(10.5, 9), Vector2(13, 6.5), Vector2(8, 10)]:
		ci.draw_circle(_m(at), 0.42 * SimConst.PX_PER_M, INK)
		ci.draw_circle(_m(at), 0.34 * SimConst.PX_PER_M, CREAM)
	ci.draw_circle(_m(Vector2(16, 9)), 0.42 * SimConst.PX_PER_M, INK)
	ci.draw_circle(_m(Vector2(16, 9)), 0.34 * SimConst.PX_PER_M, VERM)

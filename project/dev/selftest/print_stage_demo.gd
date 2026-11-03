extends Node
## PrintStage evidenced on a view that is not the city: flat placeholder shapes in quest 1's style
## (a concrete dock floor, crates, a fire barrel, cream people, one vermilion threat) drawn as the
## view would, with one PrintStage node added. Captures look off / d4 at 32 and 48 px/m and auto at
## 64 px/m: print-stage-<look>-<ppm>.png; then FX and the night grade (_fx_case).
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
	await _cases()
	await _fx_case()
	get_tree().quit(0)


## The look cases (off / d4 at 32 and 48 px/m, auto at 64).
func _cases() -> void:
	for c: Array in CASES:
		var look: StringName = c[0]
		var z: float = c[1]
		_stage.look_id = look
		_stage.zoom = z
		for i: int in 4:
			_stage.place(FOCUS)
			await get_tree().process_frame
		await _save("print-stage-%s-%dppm.png" % [look, roundi(z * SimConst.PX_PER_M)])


## The FX and light paths through the stage: an explosion at the barrel, the electroshock crackle
## on a person, a muzzle at the threat (8 ticks on a SimClock the demo steps), then the night grade
## with a fire light at the barrel. print-stage-fx-48ppm.png, print-stage-night-48ppm.png.
func _fx_case() -> void:
	var clock: SimClock = SimClock.new()
	_stage.clock = clock
	_stage.look_id = &"d4"
	_stage.zoom = 1.5
	@warning_ignore("return_value_discarded")
	_stage.fx.spawn(&"explosion", _m(Vector2(15, 4)), 0.0, 0)
	@warning_ignore("return_value_discarded")
	_stage.fx.spawn(&"crackle", _m(Vector2(10.5, 9)), 0.0, 0)
	for i: int in 8:
		if i == 6:
			@warning_ignore("return_value_discarded")
			_stage.fx.spawn(&"muzzle", _m(Vector2(15.5, 9)), PI, clock.tick())
		clock.complete_tick()
		_stage.place(FOCUS)
		await get_tree().process_frame
	await _save("print-stage-fx-48ppm.png")
	_stage.lights.set_grade(&"night")
	@warning_ignore("return_value_discarded")
	_stage.lights.add(&"fire", _m(Vector2(15, 4)), 0.0, clock.tick())
	for i: int in 30:
		clock.complete_tick()
		_stage.place(FOCUS)
		await get_tree().process_frame
	await _save("print-stage-night-48ppm.png")


func _save(file: String) -> void:
	await RenderingServer.frame_post_draw
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_out.path_join(file))


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

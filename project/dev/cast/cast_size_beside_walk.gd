extends "res://dev/cast/cast_size_beside.gd"
## Movie Maker take of the size check: every enabled card foe, three spawned patrol cops (each with
## its own crowd build jitter) and Rivet in one row, all walking a small rectangle at once, 32 px/m
## tilt 70. Labels give each figure's nominal px height (50 px at 32 x actor_scale; card foes are
## matched to the unjittered cop, 100.6 px at 64 = 50 at 32). GTAI_CAST_TICKS sets the length.

const WALK_MPS: float = 1.4
const SPACING: float = 4.3
## One lap of the rectangle: down, right, up, left (world directions), ticks per leg.
const LAP: Array[Vector2] = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
const LEG_TICKS: Array[int] = [180, 90, 180, 90]
const COPS: int = 3

var _figures: Array[Fighter] = []
var _names: Array[String] = []
var _labels: Array[Label] = []
var _homes: Array[Vector2] = []


func _ready() -> void:
	_ppm = 32
	var ticks: int = OS.get_environment("GTAI_CAST_TICKS").to_int()
	if ticks <= 0 or get_window().size != Vector2i(1920, 1080):
		_fail("set GTAI_CAST_TICKS at 1920x1080")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	_cast()
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	await _settle(SETTLE)
	var zoom: float = get_viewport().get_canvas_transform().x.length()
	if not is_equal_approx(zoom * SimConst.PX_PER_M, _ppm):
		_fail("zoom is not 32 px/m")
		return
	for tick: int in ticks:
		_step_walk(tick)
		await _settle(1)
		_place_labels()
	Log.info("cast", "size walk done, %d figures, %d ticks" % [_figures.size(), ticks])
	get_tree().quit(0)


func _cast() -> void:
	var ids: Array[StringName] = _card_foes()
	var foes: Array[StringName] = ids.duplicate()
	for i: int in COPS:
		foes.append(&"patrol_cop")
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 120
	_scene.add_child(layer)
	for node: Node in _scene.find_children("*", "Control", true, false):
		(node as Control).hide()
	for id: StringName in foes:
		var fighter: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, id)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(fighter)
		fighter.hp = 999.0
		fighter.max_hp = fighter.hp
		_add(fighter, String(id), layer)
	_arena.rivet.hp = 999.0
	_arena.rivet.max_hp = _arena.rivet.hp
	_add(_arena.rivet, "rivet", layer)
	for other: Fighter in _arena.hostiles:
		if not _figures.has(other):
			other.pos = PARK
	for i: int in _figures.size():
		_homes.append(CENTRE + Vector2((i - 0.5 * (_figures.size() - 1)) * SPACING, -1.0))
	Log.info("cast", "size walk: %s" % [_names])


func _add(fighter: Fighter, who: String, layer: CanvasLayer) -> void:
	var is_cop: bool = fighter.archetype == &"patrol_cop"
	var scale: float = StreetCrowdCards.body_scale(fighter.id)
	var short: String = who.replace("robot_", "").replace("appliance_", "").replace("sergeant_", "")
	if who == "shield_robot":
		short = "door carrier"
	var text: String = short
	if is_cop:
		text = "patrol cop\n%.0f px (x%.2f)" % [50.0 * scale, scale]
	elif who != "rivet":
		text = "%s\n%.0f px" % [short, 50.0 * scale]
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	layer.add_child(label)
	_figures.append(fighter)
	_names.append(text)
	_labels.append(label)


func _step_walk(tick: int) -> void:
	var lap: int = 0
	for n: int in LEG_TICKS:
		lap += n
	var at: int = tick % lap
	var offset: Vector2 = Vector2.ZERO
	var dir: Vector2 = LAP[0]
	var step: float = WALK_MPS * SimClock.TICK_DT
	for i: int in LAP.size():
		var span: int = mini(at, LEG_TICKS[i])
		offset += LAP[i] * step * span
		if at < LEG_TICKS[i]:
			dir = LAP[i]
			break
		at -= LEG_TICKS[i]
	for i: int in _figures.size():
		_figures[i].pos = _homes[i] + offset
		_figures[i].facing = dir


func _place_labels() -> void:
	var xf: Transform2D = get_viewport().get_canvas_transform()
	for i: int in _figures.size():
		var foot: Vector2 = xf * (_figures[i].pos * SimConst.PX_PER_M)
		_labels[i].position = foot + Vector2(-_labels[i].size.x * 0.5, 14.0)

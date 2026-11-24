extends "res://dev/cast/cast_lineup.gd"
## One foe walking right across a metre grid with its sole dots drawn per rendered frame.
## GTAI_CAST_PPM 32|64, GTAI_CAST_SUBJECT, GTAI_CAST_SPEED (m/s), GTAI_CAST_TICKS,
## GTAI_CAST_SOLES (json from tools/art/cast_foe_film_soles.py), GTAI_CAST_STILL (optional png).

var _soles: Dictionary
var _overlay: CastFootOverlay


class Grid:
	extends Node2D
	const ORIGIN: Vector2 = Vector2(12, -100)

	func _draw() -> void:
		var step: float = SimConst.PX_PER_M
		for i: int in range(-40, 41):
			var x: float = (ORIGIN.x + i) * step
			draw_line(
				Vector2(x, (ORIGIN.y - 12.0) * step),
				Vector2(x, (ORIGIN.y + 12.0) * step),
				Color(0, 0, 0, 0.18),
				1.0
			)
		for j: int in range(-12, 13):
			var y: float = (ORIGIN.y + j) * step
			draw_line(
				Vector2((ORIGIN.x - 40.0) * step, y),
				Vector2((ORIGIN.x + 40.0) * step, y),
				Color(0, 0, 0, 0.18),
				1.0
			)


func _ready() -> void:
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	_pitch = 70
	var subject: StringName = StringName(OS.get_environment("GTAI_CAST_SUBJECT"))
	var speed: float = OS.get_environment("GTAI_CAST_SPEED").to_float()
	var ticks: int = OS.get_environment("GTAI_CAST_TICKS").to_int()
	if (
		_ppm not in [32, 64]
		or speed <= 0.0
		or ticks <= 0
		or get_window().size != Vector2i(1920, 1080)
	):
		_fail("set GTAI_CAST_PPM, SUBJECT, SPEED, TICKS at 1920x1080")
		return
	_soles = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("GTAI_CAST_SOLES")))
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(float(_pitch))
	ViewMode.shared().art = "p%d" % _pitch
	var host: ArenaRigs = _open_wave()
	if host == null:
		_fail("could not open wave cast")
		return
	_dress()
	await _walk(host, subject, speed, ticks)
	var still: String = OS.get_environment("GTAI_CAST_STILL")
	if not still.is_empty():
		var image: Image = get_viewport().get_texture().get_image()
		if image.save_png(still) != OK:
			_fail("cannot save %s" % still)
			return
	get_tree().quit()


func _dress() -> void:
	var layer: CanvasLayer = _view.print_stage.actor_layer()
	var grid: Grid = Grid.new()
	grid.z_index = -4000
	layer.add_child(grid)
	var top: CanvasLayer = CanvasLayer.new()
	top.layer = 120
	_overlay = CastFootOverlay.new()
	top.add_child(_overlay)
	_scene.add_child(top)
	for node: Node in _scene.find_children("*", "Control", true, false):
		(node as Control).hide()


func _advance() -> void:
	_clock.complete_tick()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _walk(host: ArenaRigs, subject: StringName, speed: float, ticks: int) -> void:
	var foe: Fighter = _arena.squad_ai.spawn_member(_arena, MARK, subject)
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(foe)
	for other: Fighter in _arena.hostiles:
		if other != foe:
			other.pos = PARK
	_arena.rivet.pos = MARK + Vector2(-0.45 * ticks * speed * SimClock.TICK_DT, 3.0)
	var start: Vector2 = MARK + Vector2.LEFT * 0.5 * ticks * speed * SimClock.TICK_DT
	foe.pos = start
	foe.facing = Vector2.RIGHT
	for tick: int in 24:
		await _advance()
	for tick: int in ticks:
		foe.pos = start + Vector2.RIGHT * ((tick + 1) * speed * SimClock.TICK_DT)
		await _advance()
		_mark(CastFeetFrame.sample(host, foe))


func _mark(frame: Dictionary) -> void:
	if not frame.has("card"):
		return
	var card: Dictionary = frame.card
	var path: String = card.path
	var table: Dictionary = _soles.get(path.get_file(), {})
	var rows: Array = table.get(str(_pitch), [])
	var row: int = card.row
	var col: int = card.col
	if col != 2 or row >= rows.size() or rows[row] == null:
		return
	var uv: Array = rows[row]
	var xf: Array = card.xf
	var f: PackedFloat64Array = PackedFloat64Array(xf)
	var u: float = uv[0]
	var v: float = uv[1]
	var at: Vector2 = Vector2(f[0] + u * f[2] + v * f[4], f[1] + u * f[3] + v * f[5])
	_overlay.add(row * 2 / rows.size(), at)

class_name CursorSweepRec
extends Node2D
## n11 hero (dev): logs each tick's drawn octant against the scripted cursor (`<out>.tsv`), and
## pastes crops into `<out>.png`, one row per leg (the cursor drawn in). View only.

const CROP: int = 300
const COLS: int = 12
const LIFT_PX: float = 60.0
const HEADER: String = "tick	leg	in	cur	gnd	oct	deg	err	frame	flip	strip	sim"
var _game: ArenaGame
var _bot: CursorSweepBot
var _out: String
var _sheet: Image
var _lines: PackedStringArray = PackedStringArray()
var _last: int = -1
var _pending: int = 0
var _mark: Node2D
var _worst: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _sum: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _n: Array[int] = [0, 0, 0, 0]


func _init(game: ArenaGame, bot: CursorSweepBot, out: String) -> void:
	_game = game
	_bot = bot
	_out = out
	process_priority = 40


func _ready() -> void:
	_sheet = Image.create_empty(CROP * COLS, CROP * 4, false, Image.FORMAT_RGBA8)
	@warning_ignore("return_value_discarded")
	_lines.append(HEADER)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_mark = CursorMark.new()
	layer.add_child(_mark)


func _process(_delta: float) -> void:
	var tick: int = _game.session.tick()
	if tick == _last:
		return
	_last = tick
	_mark.position = _bot.cursor
	var rig: CutRig = _game.cast.rigs.rig_for(_game.session.stage.arena.rivet.id)
	if rig == null or rig.head_card == null or _bot.leg == CursorSweepBot.Leg.DONE:
		if _bot.leg == CursorSweepBot.Leg.DONE and _pending == 0:
			_finish()
		return
	_row(rig, tick)
	var step: int = CursorSweepBot.LEG_TICKS / COLS
	var melee: bool = _bot.leg == CursorSweepBot.Leg.MELEE
	var every: int = CursorSweepBot.MELEE_EVERY if melee else step
	if _bot.in_leg % every == (27 if melee else 0):
		_pending += 1
		_grab.call_deferred(rig, Vector2i(_bot.in_leg / every, int(_bot.leg)))


func _row(rig: CutRig, tick: int) -> void:
	var at: Vector2 = rig.get_global_transform_with_canvas().origin
	var d: Vector2 = _bot.cursor - at
	var ppm: float = _game.px_per_m
	var g: Vector2 = ViewMode.shared().ground_of(d - LiveInput.aim_lift_px(ppm))
	var o: int = RivetFrames.oct_of(rig)
	var drawn: float = o * 45.0
	var err: float = absf(rad_to_deg(angle_difference(deg_to_rad(drawn), g.angle())))
	var i: int = int(_bot.leg)
	_worst[i] = maxf(_worst[i], err)
	_sum[i] += err
	_n[i] += 1
	var card: Sprite2D = rig.head_card
	var row: Array = [
		tick,
		i,
		_bot.in_leg,
		"%.1f" % rad_to_deg(d.angle()),
		"%.1f" % rad_to_deg(g.angle()),
		o,
		drawn,
		"%.1f" % err,
		card.frame,
		int(card.flip_h),
		str(card.get_meta(RivetFrames.ON, "")).get_file().get_basename(),
		"%.1f" % rad_to_deg(_game.session.stage.arena.rivet.facing.angle()),
	]
	@warning_ignore("return_value_discarded")
	_lines.append("\t".join(row.map(func(v: Variant) -> String: return str(v))))


func _grab(rig: CutRig, cell: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	var k: Vector2 = Vector2(img.get_size()) / get_viewport().get_visible_rect().size
	var at: Vector2 = rig.get_global_transform_with_canvas().origin * k
	var c: Vector2i = Vector2i(at - Vector2(0.0, LIFT_PX))
	_sheet.blit_rect(img, Rect2i(c - Vector2i.ONE * (CROP >> 1), Vector2i.ONE * CROP), cell * CROP)
	_pending -= 1


func _finish() -> void:
	set_process(false)
	@warning_ignore("return_value_discarded")
	_sheet.save_png(_out + ".png")
	var f: FileAccess = FileAccess.open(_out + ".tsv", FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	f.store_string("\n".join(_lines) + "\n")
	f.close()
	for i: int in 4:
		var mean: float = _sum[i] / maxi(_n[i], 1)
		Log.info("hero", "leg %d: mean err %.1f, worst %.1f deg" % [i, mean, _worst[i]])
	get_tree().quit(0)


class CursorMark:
	extends Node2D

	func _draw() -> void:
		draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.1, 0.5))
		draw_circle(Vector2.ZERO, 3.0, Color.WHITE)

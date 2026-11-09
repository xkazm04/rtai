class_name RivetTourRec
extends Node2D
## n10 rivet (dev): logs Rivet's drawn state every tick to `<out>.tsv` and pastes crops of him into
## one contact sheet `<out>.png`, one row per aim octant, one column per sampled state. View only.

const CROP: int = 180
const LIFT_PX: float = 45.0
const HEADER: PackedStringArray = [
	"tick",
	"phase",
	"oct_i",
	"in",
	"oct",
	"weapon",
	"strip",
	"frame",
	"flip",
	"speed",
	"aim",
	"gun",
	"reload",
	"fire",
	"fresh",
	"aimdeg",
	"held",
	"hold",
	"roll",
]
## [phase, tick inside the phase] for each column.
const COLUMNS: Array[Vector2i] = [
	Vector2i(RivetTourBot.Phase.WALK, 18),
	Vector2i(RivetTourBot.Phase.RUN, 18),
	Vector2i(RivetTourBot.Phase.STAND, 8),
	Vector2i(RivetTourBot.Phase.FIRE, 2),
	Vector2i(RivetTourBot.Phase.FIRE, 12),
	Vector2i(RivetTourBot.Phase.FIRE, 24),
	Vector2i(RivetTourBot.Phase.RELOAD, 6),
	Vector2i(RivetTourBot.Phase.RELOAD, 30),
	Vector2i(RivetTourBot.Phase.RELOAD, 60),
]

var _game: ArenaGame = null
var _bot: RivetTourBot = null
var _out: String = ""
var _sheet: Image = null
var _lines: PackedStringArray = PackedStringArray()
var _last_tick: int = -1
var _pending: int = 0
var _columns: Array[Vector2i] = COLUMNS


func _init(game: ArenaGame, bot: RivetTourBot, out: String) -> void:
	_game = game
	_bot = bot
	_out = out
	process_priority = 30
	var own: Array[Vector2i] = bot.columns()
	_columns = own if not own.is_empty() else COLUMNS


func _ready() -> void:
	var w: int = CROP * _columns.size()
	_sheet = Image.create_empty(w, CROP * RivetTourBot.OCTS, false, Image.FORMAT_RGBA8)
	_add_line("\t".join(HEADER))


func _process(_delta: float) -> void:
	var tick: int = _game.session.tick()
	if tick == _last_tick:
		return
	_last_tick = tick
	var rig: CutRig = _game.cast.rigs.rig_for(_game.session.stage.arena.rivet.id)
	if rig == null or rig.head_card == null:
		return
	_log_row(rig, tick)
	if _bot.phase == RivetTourBot.Phase.DONE and _pending == 0:
		_finish()
		return
	for c: int in _columns.size():
		if _columns[c] == Vector2i(_bot.phase, _bot.in_phase):
			_pending += 1
			_grab.call_deferred(rig, Vector2i(c, _bot.oct_i))


func _log_row(rig: CutRig, tick: int) -> void:
	var card: Sprite2D = rig.head_card
	var row: Array = [
		tick,
		_bot.phase,
		_bot.oct_i,
		_bot.in_phase,
		RivetFrames.oct_of(rig),
		RivetFrames.weapon_of(rig),
		str(card.get_meta(RivetFrames.ON, "")).get_file().get_basename(),
		card.frame,
		int(card.flip_h),
		"%.0f" % rig.speed_now,
		int(rig.aiming),
		int(rig.gun_out),
		"%.2f" % rig.reload_k,
		int(RivetStrips.fire_latched(rig)),
		int(HeldMuzzle.fresh()),
		"%.1f" % rad_to_deg(RivetStrips.aim_of(rig)),
		_game.session.stage.pilot.hold.held,
		_game.session.stage.pilot.hold.state,
		int(rig.clips.rolling()),
	]
	_add_line("\t".join(row.map(func(v: Variant) -> String: return str(v))))


func _add_line(line: String) -> void:
	@warning_ignore("return_value_discarded")
	_lines.append(line)


func _grab(rig: CutRig, cell: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	var k: Vector2 = Vector2(img.get_size()) / get_viewport().get_visible_rect().size
	var at: Vector2 = rig.get_global_transform_with_canvas().origin * k
	var c: Vector2i = Vector2i(at - Vector2(0.0, LIFT_PX))
	var r: Rect2i = Rect2i(c - Vector2i.ONE * (CROP >> 1), Vector2i.ONE * CROP)
	_sheet.blit_rect(img, r, cell * CROP)
	_pending -= 1


func _finish() -> void:
	set_process(false)
	@warning_ignore("return_value_discarded")
	_sheet.save_png(_out + ".png")
	var f: FileAccess = FileAccess.open(_out + ".tsv", FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	f.store_string("\n".join(_lines) + "\n")
	f.close()
	Log.info("rivet", "tour done: %s (%d rows)" % [_out, _lines.size() - 1])
	get_tree().quit(0)

class_name StrideFilm
extends ArenaGame
## n11 hero (dev scene `dev/rivet_motion/stride_film.tscn`): one gait filmed tick by tick on a
## ground line (legs: walk right, walk toward, sprint right, sprint toward; FRAMES ticks each, the
## cursor ahead), crops centred on the rig's point so a planted foot sits on one row.
## `-- --rigs --ppm=64 --start=pad --film-out=<abs prefix>`: `<out>.png` + `<out>_<leg>_<f>.png`.

const FRAMES: int = 16
const LEG_TICKS: int = 130
const FILM_FROM: int = 50
const CROP_PX: int = 260
const FEET_PX: int = 215
const EVERY: Array[int] = [4, 4, 2, 2]
const DIRS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.RIGHT, Vector2.DOWN]
## `--film-diag`: legs turned 45 deg up the screen (3/4 rows); `--film-turn=<deg>` (n15) any turn
## (135 the left diagonals, 180 the left profile and away). `--film-attack`: a melee press every
## ATTACK_EVERY ticks; `--film-fire` the fire press too (Dent's seize); `--film-hurt`: a hit every
## HURT_EVERY, `--film-blow=<deg>` (n15) along that screen angle. n15 it14: `--film-every=<ticks>`
## for the sprint legs (default 2), `--film-leg=<n>` the first leg (2: sprint while a form lasts).
const ATTACK_EVERY: int = 24
const HURT_EVERY: int = 32

var _out: String = ""
var _bot: Bot
var _sheet: Image
var _last: int = -1
var _pending: int = 0
var _hurt: bool = false
var _blow: Vector2 = Vector2.ZERO
var _crop: int = CROP_PX
var _feet: int = FEET_PX
var _every: int = 0


func _ready() -> void:
	super._ready()
	var args: ArenaArgs = ArenaArgs.parse()
	_out = args.text("--film-out")
	_bot = Bot.new(session.live, session.actions, get_viewport())
	_bot.attack = args.has("--film-attack")
	_bot.turn = deg_to_rad(args.number("--film-turn", -45.0 if args.has("--film-diag") else 0.0))
	_bot.fire = args.has("--film-fire")
	_hurt = args.has("--film-hurt")
	if args.has("--film-blow"):
		_blow = Vector2.from_angle(deg_to_rad(args.number("--film-blow", 0.0)))
	_crop = maxi(CROP_PX, args.number("--film-crop", CROP_PX) as int)
	_feet = _crop * FEET_PX / CROP_PX
	_every = args.number("--film-every", 0.0) as int
	_bot.leg = args.number("--film-leg", 0.0) as int
	var form: StringName = StringName(args.text("--film-form"))
	if form != &"":
		var order: Array[StringName] = session.stage.pilot.ghosts.forms.table.order
		_bot.form_presses(maxi(0, order.find(form)))
	session.world.loop().set_input(_bot)
	_sheet = Image.create_empty(_crop * FRAMES, _crop * DIRS.size(), false, Image.FORMAT_RGBA8)
	add_child(Rec.new(self))


func on_frame() -> void:
	var tick: int = session.tick()
	if tick == _last:
		return
	_last = tick
	if _bot.leg >= DIRS.size():
		if _pending == 0:
			_finish()
		return
	if _hurt and tick % HURT_EVERY == 0:
		session.stage.arena.rivet.hurt_tick = tick
		session.stage.arena.rivet.hurt_dir = _blow
	var f: int = _bot.in_leg - FILM_FROM
	var e: int = _every if _every > 0 and _bot.leg >= 2 else EVERY[_bot.leg]
	if f >= 0 and f < FRAMES * e and f % e == 0:
		_pending += 1
		_grab.call_deferred(Vector2i(f / e, _bot.leg))


func _grab(cell: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	var rig: CutRig = cast.rigs.rig_for(session.stage.arena.rivet.id)
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	var k: Vector2 = Vector2(img.get_size()) / get_viewport().get_visible_rect().size
	var feet: Vector2 = rig.get_global_transform_with_canvas().origin * k
	var at: Vector2i = Vector2i(feet) - Vector2i(_crop >> 1, _feet)
	var crop: Image = Image.create_empty(_crop, _crop, false, Image.FORMAT_RGBA8)
	crop.blit_rect(img, Rect2i(at, Vector2i.ONE * _crop), Vector2i.ZERO)
	# the ground line: the row of his feet
	var row: int = _feet
	for x: int in 12:
		crop.set_pixel(x, row, Color(1.0, 0.1, 0.5))
		crop.set_pixel(_crop - 1 - x, row, Color(1.0, 0.1, 0.5))
	_sheet.blit_rect(crop, Rect2i(Vector2i.ZERO, Vector2i.ONE * _crop), cell * _crop)
	@warning_ignore("return_value_discarded")
	crop.save_png("%s_%d_%02d.png" % [_out, cell.y, cell.x])
	_pending -= 1


func _finish() -> void:
	@warning_ignore("return_value_discarded")
	_sheet.save_png(_out + ".png")
	get_tree().quit(0)


class Bot:
	extends InputSource

	var leg: int = 0
	var in_leg: int = 0
	var attack: bool = false
	var fire: bool = false
	var turn: float = 0.0
	var _presses: Array[Vector2i] = []
	var _at: int = 0
	var _wait: int = 0
	var _live: LiveInput
	var _actions: PlayerActions
	var _vp: Viewport
	var _cursor: Vector2 = Vector2.ZERO

	func _init(live: LiveInput, actions: PlayerActions, vp: Viewport) -> void:
		_live = live
		_actions = actions
		_vp = vp
		_live.cursor_px = func() -> Vector2: return _cursor

	## Selects form `gears` steps along the order and transforms: gearbox presses, then hauler.
	func form_presses(gears: int) -> void:
		for g: int in gears:
			_presses.append(Vector2i(40 + g * 3, 0))
		_presses.append(Vector2i(40 + gears * 3, 1))
		_wait = 40 + gears * 3 + 150

	func sample(tick: int) -> TickInput:
		_at += 1
		for p: Vector2i in _presses:
			if p.x == _at:
				var act: StringName = &"power_hauler" if p.y == 1 else &"power_gearbox"
				return TickInput.new(1 << _actions.bit(act), 0, 0)
		if _at < _wait or leg >= StrideFilm.DIRS.size():
			return TickInput.new(_live.sample(tick).buttons, 0, 0)
		var dir: Vector2 = StrideFilm.DIRS[leg].rotated(turn)
		_cursor = _vp.get_visible_rect().size / 2.0 + dir * 280.0
		var input: TickInput = _live.sample(tick)
		var buttons: int = input.buttons
		if attack and in_leg % StrideFilm.ATTACK_EVERY == 0:
			buttons |= 1 << _actions.bit(&"melee")
		if fire and in_leg % StrideFilm.ATTACK_EVERY == 0:
			buttons |= 1 << _actions.bit(&"fire")
		if leg >= 2:
			buttons |= 1 << _actions.bit(&"sprint")
		var m: Vector2 = dir * TickInput.AXIS_MAX
		in_leg += 1
		if in_leg >= StrideFilm.LEG_TICKS:
			in_leg = 0
			leg += 1
		return TickInput.new(buttons, roundi(m.x), roundi(m.y))


## The frame hook (an own node: the arena's _process stays the arena's).
class Rec:
	extends Node

	var _game: StrideFilm

	func _init(game: StrideFilm) -> void:
		_game = game
		process_priority = 40

	func _process(_frame: float) -> void:
		_game.on_frame()

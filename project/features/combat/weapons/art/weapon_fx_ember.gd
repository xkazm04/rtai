class_name WeaponFxEmber
extends RefCounted
## n5-look (r2_w4): loose embers shed from the flamethrower's jet. Each round trails a few small
## hot flecks in an ink ring off the cone's sides, drifting wider as the round flies and blinking
## in 6-tick steps (the crackle). Each fleck's side, offset and size come from a hash of the
## round's origin and the fleck's index, so a round draws the same embers every run. Drawn on the
## colour canvas while it is attached (the flecks keep their orange through the print). Render
## only: reads the shot, writes nothing. Rules: data/tables/flame_embers.json;
## `--flame-embers=off` = the before.

const TABLE: String = "res://data/tables/flame_embers.json"
const SCHEMA: String = "gtai.flame-embers/1"
const BLINK_TICKS: int = 6
## How far a streak may turn off the jet's heading (rad, either way): parallel streaks read as rain.
const TILT: float = 0.45

static var enabled: bool = not OS.get_cmdline_user_args().has("--flame-embers=off")
static var _rules: WeaponFxEmber = null

var count: int = 0
var size_px: Vector2 = Vector2.ZERO
var edge_px: float = 0.0
var width_px: float = 0.0
var spread_m: Vector2 = Vector2.ZERO
var lag_m: Vector2 = Vector2.ZERO
var blink: float = 0.0
var hot: Color = Color.YELLOW
var rim: Color = Color.ORANGE


static func rules() -> WeaponFxEmber:
	if _rules == null:
		_rules = WeaponFxEmber.new()
		var t: DataTable = DataTable.open(TABLE, SCHEMA)
		_rules.count = t.integer(t.raw, "count")
		_rules.size_px = t.vec(t.raw, "size_px")
		_rules.edge_px = t.num(t.raw, "edge_px")
		_rules.width_px = t.num(t.raw, "width_px")
		_rules.spread_m = t.vec(t.raw, "spread_m")
		_rules.lag_m = t.vec(t.raw, "lag_m")
		_rules.blink = t.num(t.raw, "blink")
		_rules.hot = Color(t.text(t.raw, "hot"))
		_rules.rim = Color(t.text(t.raw, "rim"))
		if not t.ok():
			Log.error("flame_embers", str(t.errors()))
	return _rules


## The embers of jet round `s` heading `dir`, `went` m out of its `range_m` at `tick`.
static func draw(ci: CanvasItem, s: Shot, dir: Vector2, went: float, tick: int) -> void:
	var r: WeaponFxEmber = rules()
	if not enabled or r.count <= 0 or went < WeaponFxArt.CLEAR_M:
		return
	var k: float = clampf(went / maxf(s.spec.range_m, 0.1), 0.0, 1.0)
	var key: float = s.origin.x * 1.37 + s.origin.y * 0.71 + float(s.shooter_id) * 0.13
	var side: Vector2 = dir.orthogonal()
	for i: int in r.count:
		var step: int = tick / BLINK_TICKS + i * 7
		if WeaponFxDebris.hash01(key + float(step), i + 300) < r.blink:
			continue
		var flip: float = 1.0 if i % 2 == 0 else -1.0
		var off: float = lerpf(r.spread_m.x, r.spread_m.y, WeaponFxDebris.hash01(key, i + 320))
		var lag: float = lerpf(r.lag_m.x, r.lag_m.y, WeaponFxDebris.hash01(key, i + 340))
		var at: Vector2 = s.pos - dir * minf(lag, went) + side * flip * off * (0.4 + k)
		var len_px: float = lerpf(r.size_px.x, r.size_px.y, WeaponFxDebris.hash01(key, i + 360))
		var tilt: float = (WeaponFxDebris.hash01(key, i + 380) - 0.5) * TILT * 2.0
		_fleck(ci, Ink.px(at), dir.rotated(tilt) * len_px, 1.0 - 0.4 * k)


## One streak from `at` back along `run` (view px): ink under on the item print, then the rim
## and a short hot head in colour.
static func _fleck(ci: CanvasItem, at: Vector2, run: Vector2, a: float) -> void:
	var r: WeaponFxEmber = rules()
	ci.draw_line(at + run * 0.1, at - run, Color(Ink.INK, a), r.width_px + 2.0 * r.edge_px, true)
	_line(ci, at, at - run, Color(r.rim, a), r.width_px)
	_line(ci, at, at - run * 0.4, Color(r.hot, a), r.width_px * 0.6)


static func _line(ci: CanvasItem, from: Vector2, to: Vector2, c: Color, w: float) -> void:
	if WeaponFxArt.colour != null:
		WeaponFxArt.colour.line(from, to, c, w)
	else:
		ci.draw_line(from, to, c, w, true)

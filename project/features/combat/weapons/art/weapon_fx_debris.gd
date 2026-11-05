class_name WeaponFxDebris
extends RefCounted
## n5-look (r2_w4): the rocket blast flings grey concrete slabs in a bold ink edge and small ink
## specks out past its fireball, eased out and fading over `ticks`. Each slab's direction, size,
## corners and spin come from a hash of the blast's position and the slab's index, so a blast
## draws the same debris every frame and in every run. Render only: reads the blast, writes
## nothing. Rules: data/tables/blast_debris.json; `--blast-debris=off` = the before.

const TABLE: String = "res://data/tables/blast_debris.json"
const SCHEMA: String = "gtai.blast-debris/1"

static var enabled: bool = not OS.get_cmdline_user_args().has("--blast-debris=off")
static var _rules: WeaponFxDebris = null

var chunks: int = 0
var chunk_m: Vector2 = Vector2.ZERO
## chunk_big slabs (spread round the blast) take the top quarter of chunk_m, the rest its lower 60 %
## (0 = uniform).
var chunk_big: int = 0
var fly_k: Vector2 = Vector2.ZERO
var fill: Color = Color.GRAY
var edge_px: float = 0.0
var specks: int = 0
var speck_px: float = 0.0
var ticks: int = 1


static func rules() -> WeaponFxDebris:
	if _rules == null:
		_rules = WeaponFxDebris.new()
		var t: DataTable = DataTable.open(TABLE, SCHEMA)
		_rules.chunks = t.integer(t.raw, "chunks")
		_rules.chunk_m = t.vec(t.raw, "chunk_m")
		if t.raw.has("chunk_big"):
			_rules.chunk_big = t.integer(t.raw, "chunk_big")
		_rules.fly_k = t.vec(t.raw, "fly_k")
		_rules.fill = Color(t.text(t.raw, "fill"))
		_rules.edge_px = t.num(t.raw, "edge_px")
		_rules.specks = t.integer(t.raw, "specks")
		_rules.speck_px = t.num(t.raw, "speck_px")
		_rules.ticks = maxi(t.integer(t.raw, "ticks"), 1)
		if not t.ok():
			Log.error("blast_debris", str(t.errors()))
	return _rules


## A value in [0, 1) from the blast key and a slab index (a sine hash; render only).
static func hash01(key: float, i: int) -> float:
	var v: float = sin(key * 12.9898 + float(i) * 78.233) * 43758.5453
	return v - floorf(v)


## Where slab or speck `i` of a blast of radius `r_m` sits `k` (0..1) into its flight (m).
static func fly(r_m: float, k: float, h: float) -> float:
	var r: WeaponFxDebris = rules()
	var ease: float = 1.0 - (1.0 - k) * (1.0 - k)
	return r_m * lerpf(r.fly_k.x, r.fly_k.y * (0.75 + 0.25 * h), ease)


## Draws blast `b` (x, y, radius m) `age` ticks old: the slabs, then the specks over them.
static func draw(ci: CanvasItem, b: Vector3, age: int) -> void:
	var r: WeaponFxDebris = rules()
	if not enabled or age >= r.ticks or r.chunks <= 0:
		return
	var k: float = float(age) / float(r.ticks)
	var fade: float = clampf((1.0 - k) / 0.3, 0.0, 1.0)
	var key: float = b.x * 1.37 + b.y * 0.71
	var c: Vector2 = Vector2(b.x, b.y)
	for i: int in r.chunks:
		var h: float = hash01(key, i)
		var dir: Vector2 = Vector2.from_angle(TAU * (float(i) + 0.6 * h) / float(r.chunks))
		var size: float = lerpf(r.chunk_m.x, r.chunk_m.y, _size_k(r, i, hash01(key, i + 40)))
		_slab(ci, c + dir * fly(b.z, k, h), size, h * TAU + k * (3.0 + 4.0 * h), key + i, fade)
	var ink: Color = Color(Ink.INK, fade)
	for j: int in r.specks:
		var h: float = hash01(key, j + 80)
		var dir: Vector2 = Vector2.from_angle(TAU * h)
		var at: Vector2 = c + dir * fly(b.z, k, hash01(key, j + 120)) * 1.1
		ci.draw_circle(Ink.px(at), r.speck_px * (0.6 + 0.8 * hash01(key, j + 160)), ink)


## One slab: a lopsided quad of `size` m turned `spin`, flat grey in an ink edge.
static func _slab(
	ci: CanvasItem, at: Vector2, size: float, spin: float, key: float, fade: float
) -> void:
	var r: WeaponFxDebris = rules()
	var pts: Array[Vector2] = []
	for q: int in 4:
		var a: float = spin + TAU * float(q) / 4.0 + 0.5 * (hash01(key, q + 200) - 0.5)
		var reach: float = size * (0.42 + 0.3 * hash01(key, q + 240))
		pts.append(Ink.px(at + Vector2.from_angle(a) * reach))
	ci.draw_colored_polygon(PackedVector2Array(pts), Color(r.fill, fade))
	pts.append(pts[0])
	ci.draw_polyline(PackedVector2Array(pts), Color(Ink.INK, fade), r.edge_px, true)


## Where slab i sits in chunk_m (0..1) for its hash h: every (chunks / chunk_big)-th slab is a big
## one (spread round the blast: slab i flies at angle i / chunks), the rest small.
static func _size_k(r: WeaponFxDebris, i: int, h: float) -> float:
	if r.chunk_big <= 0:
		return h
	var step: int = maxi(r.chunks / r.chunk_big, 1)
	var big: bool = i % step == 0 and i / step < r.chunk_big
	return lerpf(0.75, 1.0, h) if big else h * 0.6

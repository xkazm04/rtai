class_name AlleyDecor
extends Node2D
## n5-look: the alley's ground and overhead dressing in quest 1's ink, from
## data/tables/alley_decor.json and the station's props. The ground instance (the world print,
## over the floor view's dock slab) lays wet cracked asphalt, the city's crack, oil, puddle and
## drain decals, the dumpsters turned along the walls, bag piles and trash cans, and the
## chain-link mesh over the north end's thin wall. The overhead instance (roof_occluders, above
## the cast) draws the city's fire-escape art: 3 m+ up, always over a 1.8 m fighter, so one order
## holds in every pose (registry depth-ordered-layered-art). Reads data only, never the sim.

const CARD: Color = Color("#B8976C")
const BAG_DARK: Color = Color("#2E2833")
const BAG_PALE: Color = Color("#C9BCA4")
const MESH_STEP_M: float = 0.16
const ART: String = "res://features/city/art/"
const CRACKS: Texture2D = preload(ART + "decals/cracks.png")
const OIL: Texture2D = preload(ART + "decals/oil_stain.png")
const PUDDLE: Texture2D = preload(ART + "decals/puddle.png")
const DUMPSTER: Texture2D = preload(ART + "props/dumpster.png")
const CAN: Texture2D = preload(ART + "props/trash_can.png")
const ESCAPE: Texture2D = preload(ART + "props/fire_escape.png")

var _rows: Dictionary = {}
var _base: Vector2 = Vector2.ZERO
var _overhead: bool = false
var _floor: Rect2 = Rect2()
var _props: Array[ArenaStation.Prop] = []


func _init(rows: Dictionary, base: Vector2, overhead: bool) -> void:
	_rows = rows
	_base = base
	_overhead = overhead


## A fill from alley_decor.json "tones" (fallback when the key is absent or "").
static func tone(rows: Dictionary, key: String, fallback: Color) -> Color:
	var t: Dictionary = rows.get("tones", {})
	var v: String = str(t.get(key, ""))
	return Color(v) if v != "" else fallback


## The ground pass's extra inputs: the alley area (asphalt) and the station's cover props.
func set_ground(floor_m: Rect2, props: Array[ArenaStation.Prop]) -> void:
	_floor = Rect2(Ink.px(floor_m.position), floor_m.size * Ink.PX_PER_M)
	_props = props


static func rect_px(v: Variant, base: Vector2) -> Rect2:
	var raw: Array = v if v is Array else [0, 0, 0, 0]
	var a: PackedFloat32Array = PackedFloat32Array(raw)
	return Rect2(Ink.px(base + Vector2(a[0], a[1])), Vector2(a[2], a[3]) * Ink.PX_PER_M)


func _draw() -> void:
	if _overhead:
		for e: Variant in _rows.get("escapes", []):
			_turned(ESCAPE, rect_px(e, _base))
		return
	draw_rect(_floor, tone(_rows, "asphalt", Color("#6F6964")), true)
	var tones: Dictionary = _rows.get("tones", {})
	var stain_a: float = tones.get("stain_a", 0.8)
	_decals("stains", OIL, Color(1, 1, 1, stain_a))
	_decals("cracks", CRACKS, Color(1, 1, 1, 0.75))
	var pool: Color = tone(_rows, "puddle", Color.TRANSPARENT)
	if pool.a == 0.0:
		_decals("puddles", PUDDLE, Color(0.86, 0.9, 1.0, 0.95))
	for v: Variant in _rows.get("puddles", []) if pool.a > 0.0 else []:
		AlleyProps.puddle(self, rect_px(v, _base), pool)
	for v: Variant in _rows.get("litter", []):
		AlleyProps.litter(self, v, _base)
	for g: Variant in _rows.get("drains", []):
		_drain(rect_px(g, _base))
	for p: ArenaStation.Prop in _props:
		var r: Rect2 = Rect2(Ink.px(_base + p.at - p.size * 0.5), p.size * Ink.PX_PER_M)
		if p.kind == "cover_high":
			_turned(DUMPSTER, r, tone(_rows, "dumpster", Color.WHITE))
		elif p.kind == "cover_low":
			_bags(r)
	for v: Variant in _rows.get("bags", []):
		_bags(rect_px(v, _base))
	_decals("cans", CAN, Color.WHITE)
	for f: Variant in _rows.get("fences", []):
		_fence(rect_px(f, _base))


func _decals(key: String, tex: Texture2D, tint: Color) -> void:
	for v: Variant in _rows.get(key, []):
		draw_texture_rect(tex, rect_px(v, _base), false, tint)


## Landscape art (nose to +x) laid along a tall rect: turned a quarter so it fills the rect.
func _turned(tex: Texture2D, r: Rect2, tint: Color = Color.WHITE) -> void:
	if r.size.x >= r.size.y:
		draw_texture_rect(tex, r, false, tint)
		return
	draw_set_transform(r.get_center(), PI * 0.5)
	var l: Rect2 = Rect2(-r.size.y * 0.5, -r.size.x * 0.5, r.size.y, r.size.x)
	draw_texture_rect(tex, l, false, tint)
	draw_set_transform(Vector2.ZERO)


## A trash-bag pile: lumpy bags, dark and pale, each with a tied knot catching a highlight.
func _bags(r: Rect2) -> void:
	var c: Vector2 = r.get_center()
	var s: float = minf(r.size.x, r.size.y) * 0.5
	var offs: Array[Vector2] = [Vector2(-0.35, -0.3), Vector2(0.4, -0.15), Vector2(-0.1, 0.38)]
	if maxf(r.size.x, r.size.y) > minf(r.size.x, r.size.y) * 1.4:  # a long pile: two more bags
		var tall: bool = r.size.y > r.size.x
		offs.append(Vector2(0.2, 0.95) if tall else Vector2(0.95, 0.2))
		offs.append(Vector2(-0.3, -0.95) if tall else Vector2(-0.95, -0.3))
	for i: int in offs.size():
		var rad: float = s * (0.66 if i % 2 == 0 else 0.56)
		AlleyProps.sack(
			self, c + offs[i] * s, rad, BAG_DARK if i % 3 != 1 else BAG_PALE, 1.3 + i * 2.1
		)


## A chain-link run: a fine diamond mesh between two rails, posts every 1.5 m (drawn along x;
## a north-south run is turned a quarter).
func _fence(r: Rect2) -> void:
	var len: float = maxf(r.size.x, r.size.y)
	var w: float = minf(r.size.x, r.size.y)
	draw_set_transform(r.get_center(), 0.0 if r.size.x >= r.size.y else PI * 0.5)
	var l: Rect2 = Rect2(-len * 0.5, -w * 0.5, len, w)
	var step: float = MESH_STEP_M * Ink.PX_PER_M
	var x: float = l.position.x
	while x < l.end.x:
		draw_line(Vector2(x, l.position.y), Vector2(x + w, l.end.y), Ink.INK, 1.0)
		draw_line(Vector2(x + w, l.position.y), Vector2(x, l.end.y), Ink.INK, 1.0)
		x += step
	draw_line(l.position, Vector2(l.end.x, l.position.y), Ink.INK, 2.0)
	draw_line(Vector2(l.position.x, l.end.y), l.end, Ink.INK, 2.0)
	var post: float = l.position.x
	while post <= l.end.x + 0.5:
		draw_circle(Vector2(post, 0.0), 0.11 * Ink.PX_PER_M, Ink.INK)
		post += 1.5 * Ink.PX_PER_M
	draw_set_transform(Vector2.ZERO)


## A drain grate: an ink slot box with cream bars (the city decal carries a rust orange).
func _drain(r: Rect2) -> void:
	draw_rect(r, Ink.INK, true)
	var n: int = 6
	for i: int in range(1, n):
		var x: float = r.position.x + r.size.x * i / n
		draw_line(Vector2(x, r.position.y + 3.0), Vector2(x, r.end.y - 3.0), Color("#8E867C"), 2.0)
	draw_rect(r, Color("#8E867C"), false, 2.0)

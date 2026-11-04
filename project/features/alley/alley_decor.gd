class_name AlleyDecor
extends Node2D
## n5-look: the alley's ground and overhead dressing in quest 1's ink, from
## data/tables/alley_decor.json and the station's props. The ground instance (the world print,
## over the floor view's dock slab) lays wet cracked asphalt, the city's crack, oil, puddle and
## drain decals, the dumpsters turned along the walls, bag piles and trash cans, and the
## chain-link mesh over the north end's thin wall. The overhead instance (roof_occluders, above
## the cast) draws the city's fire-escape art: 3 m+ up, always over a 1.8 m fighter, so one order
## holds in every pose (registry depth-ordered-layered-art). Reads data only, never the sim.

const ASPHALT: Color = Color("#857C71")
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
	draw_rect(_floor, ASPHALT, true)
	_decals("stains", OIL, Color(1, 1, 1, 0.8))
	_decals("cracks", CRACKS, Color(1, 1, 1, 0.75))
	_decals("puddles", PUDDLE, Color(0.86, 0.9, 1.0, 0.95))
	for g: Variant in _rows.get("drains", []):
		_drain(rect_px(g, _base))
	for p: ArenaStation.Prop in _props:
		var r: Rect2 = Rect2(Ink.px(_base + p.at - p.size * 0.5), p.size * Ink.PX_PER_M)
		if p.kind == "cover_high":
			_turned(DUMPSTER, r)
		elif p.kind == "cover_low":
			_bags(r)
	_decals("cans", CAN, Color.WHITE)
	for f: Variant in _rows.get("fences", []):
		_fence(rect_px(f, _base))


func _decals(key: String, tex: Texture2D, tint: Color) -> void:
	for v: Variant in _rows.get(key, []):
		draw_texture_rect(tex, rect_px(v, _base), false, tint)


## Landscape art (nose to +x) laid along a tall rect: turned a quarter so it fills the rect.
func _turned(tex: Texture2D, r: Rect2) -> void:
	if r.size.x >= r.size.y:
		draw_texture_rect(tex, r, false)
		return
	draw_set_transform(r.get_center(), PI * 0.5)
	draw_texture_rect(tex, Rect2(-r.size.y * 0.5, -r.size.x * 0.5, r.size.y, r.size.x), false)
	draw_set_transform(Vector2.ZERO)


## A trash-bag pile: lumpy bags, dark and pale, each with a tied knot catching a highlight.
func _bags(r: Rect2) -> void:
	var c: Vector2 = r.get_center()
	var s: float = minf(r.size.x, r.size.y) * 0.5
	var offs: Array[Vector2] = [Vector2(-0.35, -0.3), Vector2(0.4, -0.15), Vector2(-0.1, 0.38)]
	if r.size.y > r.size.x * 1.4:
		offs.append(Vector2(0.2, 0.95))
		offs.append(Vector2(-0.3, -0.95))
	for i: int in offs.size():
		var at: Vector2 = c + offs[i] * s
		var rad: float = s * (0.62 if i % 2 == 0 else 0.52)
		draw_circle(at + Vector2(3.0, 3.0), rad, Color(Ink.INK, 0.4))
		draw_circle(at, rad, BAG_DARK if i % 3 != 1 else BAG_PALE)
		draw_arc(at, rad, 0.0, TAU, 18, Ink.INK, 2.0)
		draw_arc(at, rad * 0.62, PI * 1.1, PI * 1.5, 6, Color(Ink.CREAM, 0.55), 2.0)
		draw_circle(at + Vector2(rad * 0.15, -rad * 0.2), rad * 0.16, Ink.INK)
		draw_circle(at + Vector2(rad * 0.12, -rad * 0.24), rad * 0.07, Ink.CREAM)


## A chain-link run: a fine diamond mesh between two rails, posts every 1.5 m.
func _fence(r: Rect2) -> void:
	var step: float = MESH_STEP_M * Ink.PX_PER_M
	var x: float = r.position.x
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y), Vector2(x + r.size.y, r.end.y), Ink.INK, 1.0)
		draw_line(Vector2(x + r.size.y, r.position.y), Vector2(x, r.end.y), Ink.INK, 1.0)
		x += step
	draw_line(r.position, Vector2(r.end.x, r.position.y), Ink.INK, 2.0)
	draw_line(Vector2(r.position.x, r.end.y), r.end, Ink.INK, 2.0)
	var post: float = r.position.x
	while post <= r.end.x + 0.5:
		draw_circle(Vector2(post, r.get_center().y), 0.11 * Ink.PX_PER_M, Ink.INK)
		post += 1.5 * Ink.PX_PER_M


## A drain grate: an ink slot box with cream bars (the city decal carries a rust orange).
func _drain(r: Rect2) -> void:
	draw_rect(r, Ink.INK, true)
	var n: int = 6
	for i: int in range(1, n):
		var x: float = r.position.x + r.size.x * i / n
		draw_line(Vector2(x, r.position.y + 3.0), Vector2(x, r.end.y - 3.0), Color("#8E867C"), 2.0)
	draw_rect(r, Color("#8E867C"), false, 2.0)

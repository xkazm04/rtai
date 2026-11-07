class_name FacadeStrips
extends RefCounted
## The facade styles' wall strips (n8 city; city_facades.json `styles`): a south face tiled bay by
## bay from a style's strip across a footprint's width, inked at its two sides and its ground line.
## Split out of ChunkLift, which keeps the order and the lift. Render only.

## The face's ink edges (left, right, ground line), px at zoom 1.
const INK_W: float = 2.0
const INK: Color = Color(0.09, 0.075, 0.106, 1.0)

var _strips: Array[Texture2D] = []
var _bays: Array[int] = []
var _bay_px: Array[float] = []


## Adds a style: its strip (null = no face), its bay cells, a bay's width on the ground in m.
func add(strip: Texture2D, bays: int, bay_m: float) -> void:
	_strips.append(strip)
	_bays.append(bays)
	_bay_px.append(bay_m * SimConst.PX_PER_M)


func has_strip(s: int) -> bool:
	return _strips[s] != null


## Draws style s's face over the ground rect `ext` (px) centred on `at`, `lift` px tall.
func draw(item: RID, s: int, ext: Vector2, at: Vector2, lift: float) -> void:
	var base: float = at.y + ext.y * 0.5
	var x0: float = at.x - ext.x * 0.5
	var n: int = maxi(1, roundi(ext.x / _bay_px[s]))
	var w: float = ext.x / n
	var strip: Texture2D = _strips[s]
	var cell: Vector2 = Vector2(strip.get_width() / float(_bays[s]), strip.get_height())
	RenderingServer.canvas_item_add_set_transform(item, Transform2D.IDENTITY)
	for i: int in n:
		var pick: int = bay_pick(at, i, n, _bays[s])
		var src: Rect2 = Rect2(Vector2(cell.x * pick, 0.0), cell)
		var dst: Rect2 = Rect2(x0 + w * i, base - lift, w, lift)
		RenderingServer.canvas_item_add_texture_rect_region(item, dst, strip.get_rid(), src)
	var top: float = base - lift
	RenderingServer.canvas_item_add_rect(item, Rect2(x0, top, INK_W, lift), INK)
	RenderingServer.canvas_item_add_rect(item, Rect2(x0 + ext.x - INK_W, top, INK_W, lift), INK)
	RenderingServer.canvas_item_add_rect(item, Rect2(x0, base - INK_W, ext.x, INK_W), INK)


## A bay's strip cell by a stable place hash (no sim RNG): doors on some middle bays.
static func bay_pick(at: Vector2, i: int, n: int, cells: int) -> int:
	var h: int = absi(roundi(at.x * 0.37 + at.y * 0.61)) % 7
	if cells < 2 or i != (n >> 1) or h < 3:
		return 0
	return 1 + h % (cells - 1)

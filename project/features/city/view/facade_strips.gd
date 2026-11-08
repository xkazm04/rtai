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
## a style's whole-storey wall (null = the single stretched strip)
var _storeys: Array[FacadeStoreys] = []


## Adds a style from its `styles` row for this art key: the strip (null = no face), and the
## whole-storey wall where the row has one (`storeys`, by art key), with its own bay width.
func add_style(row: Dictionary, art: String, fallback: Dictionary) -> void:
	var bay_m: float = row["bay_m"]
	var bays: int = row["bays"]
	var storeys: FacadeStoreys = null
	var by_art: Dictionary = row.get("storeys", {})
	if by_art.has(art):
		var rows: Dictionary = by_art[art]
		bay_m = rows["bay_m"]
		var upper_h: float = rows["upper_h"]
		var ground_h: float = rows["ground_h"]
		var sheet: Texture2D = load(str(rows["art"]))
		storeys = FacadeStoreys.new(sheet, bays, upper_h, ground_h)
	_strips.append(PropCards.art_texture(str(row["art"]), art, fallback))
	_bays.append(bays)
	_bay_px.append(bay_m * SimConst.PX_PER_M)
	_storeys.append(storeys)


func has_strip(s: int) -> bool:
	return _strips[s] != null or _storeys[s] != null


## Draws style s's face over the ground rect `ext` (px) centred on `at`, `lift` px tall.
func draw(item: RID, s: int, ext: Vector2, at: Vector2, lift: float) -> void:
	var base: float = at.y + ext.y * 0.5
	var x0: float = at.x - ext.x * 0.5
	var n: int = maxi(1, roundi(ext.x / _bay_px[s]))
	var w: float = ext.x / n
	RenderingServer.canvas_item_add_set_transform(item, Transform2D.IDENTITY)
	for i: int in n:
		var pick: int = bay_pick(at, i, n, _bays[s])
		if _storeys[s] != null:
			var upper: int = absi(roundi(at.x * 0.73 + at.y * 0.19)) + i
			var wall: Rect2 = Rect2(x0 + w * i, base - lift, w, lift)
			_storeys[s].draw_bay(item, wall, Vector2i(pick, upper % _bays[s]))
		else:
			_strip_bay(item, s, pick, Rect2(x0 + w * i, base - lift, w, lift))
	var top: float = base - lift
	RenderingServer.canvas_item_add_rect(item, Rect2(x0, top, INK_W, lift), INK)
	RenderingServer.canvas_item_add_rect(item, Rect2(x0 + ext.x - INK_W, top, INK_W, lift), INK)
	RenderingServer.canvas_item_add_rect(item, Rect2(x0, base - INK_W, ext.x, INK_W), INK)


func _strip_bay(item: RID, s: int, pick: int, dst: Rect2) -> void:
	var strip: Texture2D = _strips[s]
	var cell: Vector2 = Vector2(strip.get_width() / float(_bays[s]), strip.get_height())
	var src: Rect2 = Rect2(Vector2(cell.x * pick, 0.0), cell)
	RenderingServer.canvas_item_add_texture_rect_region(item, dst, strip.get_rid(), src)


## A bay's strip cell by a stable place hash (no sim RNG): doors on some middle bays.
static func bay_pick(at: Vector2, i: int, n: int, cells: int) -> int:
	var h: int = absi(roundi(at.x * 0.37 + at.y * 0.61)) % 7
	if cells < 2 or i != (n >> 1) or h < 3:
		return 0
	return 1 + h % (cells - 1)

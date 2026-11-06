class_name ChunkLift
extends RefCounted
## The city's buildings under an angled view (night n8, lane city; data/tables/city_facades.json):
## each roof is lifted up the screen by its building's height (ViewMode.lift_px) and its south face
## is drawn under it, from the ground line to the roof, tiled bay by bay from its style's wall strip
## (keyed by the view row's art, p55 / p70). Buildings draw facade then roof, south edges last, so
## a building in front covers the one behind it. null under a flat view: `top` is untouched.
## Render only: reads the chunk's draw list and the view, never the sim.

const TABLE: String = "res://data/tables/city_facades.json"
## The face's ink edges (left, right, ground line), px at zoom 1.
const INK_W: float = 2.0
const INK: Color = Color(0.09, 0.075, 0.106, 1.0)
## Frames a live pitch (combo) must hold before the chunks redraw at it.
const SETTLE_FRAMES: int = 12

var height_m: PackedFloat32Array = PackedFloat32Array()
var style_of: PackedInt32Array = PackedInt32Array()
var drawn_pitch: float = 0.0
## The table's `occlude`: CityOcclusion redraws a building over a body behind it.
var occlude: bool = true
var _tex: CityTextures
var _is_building: Array[bool] = []
var _strips: Array[Texture2D] = []
var _bays: PackedInt32Array = PackedInt32Array()
var _bay_px: PackedFloat32Array = PackedFloat32Array()
var _order: PackedInt32Array = PackedInt32Array()
var _rev: int = -1
var _rev_frames: int = 0


## The lift for this run's view, or null when the view is flat (or a perspective top_lift).
static func make(tex: CityTextures, is_building: Array[bool]) -> ChunkLift:
	var view: ViewMode = ViewMode.shared()
	if view.is_flat() or view.eye_h_m > 0.0:
		return null
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		Log.warn("city", "%s unreadable: buildings stay flat" % TABLE)
		return null
	var lift: ChunkLift = ChunkLift.new()
	var d: Dictionary = parser.data
	lift._setup(d, tex, is_building, view.art)
	return lift


func _setup(d: Dictionary, tex: CityTextures, is_building: Array[bool], art: String) -> void:
	_tex = tex
	_is_building = is_building
	drawn_pitch = ViewMode.shared().pitch_deg
	var names: Array[String] = []
	var styles: Dictionary = d["styles"]
	for style: String in styles:
		var row: Dictionary = styles[style]
		names.append(style)
		var fallback: Dictionary = d["art_fallback"]
		_strips.append(_strip(str(row["art"]), art, fallback))
		var bays: int = row["bays"]
		var bay_m: float = row["bay_m"]
		@warning_ignore("return_value_discarded")
		_bays.append(bays)
		@warning_ignore("return_value_discarded")
		_bay_px.append(bay_m * SimConst.PX_PER_M)
	occlude = d.get("occlude", true)
	var k: float = d["height_k"]
	var dflt: Dictionary = d["default"]
	var by_name: Dictionary = d["by_name"]
	for i: int in tex.names.size():
		var row: Dictionary = by_name.get(tex.names[i], dflt)
		var h: float = row["height_m"]
		@warning_ignore("return_value_discarded")
		height_m.append(h * k)
		@warning_ignore("return_value_discarded")
		style_of.append(maxi(0, names.find(str(row["style"]))))


static func _strip(path: String, art: String, fallback: Dictionary) -> Texture2D:
	var want: String = art if art != "" else str(fallback.get("", "p55"))
	for key: String in [want, str(fallback.get(want, want))]:
		var p: String = path.replace("<art>", key)
		if ResourceLoader.exists(p):
			return load(p)
	Log.warn("city", "no facade strip for %s at art %s" % [path, art])
	return null


## True once a live pitch (the combined view's ease) has moved and held for SETTLE_FRAMES; it
## takes the new pitch as drawn, so the caller redraws every chunk once.
func stale() -> bool:
	if ViewMode.revision != _rev:
		_rev = ViewMode.revision
		_rev_frames = 0
		return false
	_rev_frames += 1
	if _rev_frames < SETTLE_FRAMES or ViewMode.shared().pitch_deg == drawn_pitch:
		return false
	drawn_pitch = ViewMode.shared().pitch_deg
	return true


## The chunk's `k`-th command in draw order (the order is set when k is 0).
func nth(k: int, chunk: CityChunk) -> int:
	if k == 0:
		order(chunk)
	return _order[k]


## Sets the chunk's command order: everything else as listed, then the buildings' roofs by south
## edge (then west to east), so the painter draws a front building over the one behind it.
func order(chunk: CityChunk) -> void:
	var out: PackedInt32Array = PackedInt32Array()
	var roofs: Array[Vector3] = []
	for k: int in chunk.command_count():
		var t: int = chunk.tex[k]
		var o: int = k * CityChunk.XF_STRIDE
		if _is_building[t] and chunk.xf[o + 3] <= 0.5:
			var south: float = chunk.xf[o + 1] + extent(t, chunk.xf[o + 2]).y * 0.5
			roofs.append(Vector3(south, chunk.xf[o], k))
		else:
			@warning_ignore("return_value_discarded")
			out.append(k)
	roofs.sort()
	for r: Vector3 in roofs:
		@warning_ignore("return_value_discarded")
		out.append(int(r.z))
	_order = out


## The footprint's size on the ground in px (a quarter turn swaps it).
func extent(t: int, rot: float) -> Vector2:
	var sz: Vector2 = _tex.size_px[t]
	return Vector2(sz.y, sz.x) if absf(sin(rot)) > 0.5 else sz


func is_building_tex(t: int) -> bool:
	return _is_building[t]


## The roof's lift (world px) for texture t.
func lift_of(t: int) -> Vector2:
	return ViewMode.shared().lift_px(height_m[t])


## Draws building t's south face into `item` (ground line to the lifted roof); `at` is the roof's
## ground centre in px. Returns where the caller draws the roof (lifted by the height).
func face(item: RID, t: int, rot: float, at: Vector2) -> Vector2:
	var lift: float = -lift_of(t).y
	var s: int = style_of[t]
	if lift < 1.0 or _strips[s] == null:
		return at + lift_of(t)
	var ext: Vector2 = extent(t, rot)
	var base: float = at.y + ext.y * 0.5
	var x0: float = at.x - ext.x * 0.5
	var n: int = maxi(1, roundi(ext.x / _bay_px[s]))
	var w: float = ext.x / n
	var strip: Texture2D = _strips[s]
	var cell: Vector2 = Vector2(strip.get_width() / float(_bays[s]), strip.get_height())
	RenderingServer.canvas_item_add_set_transform(item, Transform2D.IDENTITY)
	for i: int in n:
		var pick: int = _bay_pick(at, i, n, _bays[s])
		var src: Rect2 = Rect2(Vector2(cell.x * pick, 0.0), cell)
		var dst: Rect2 = Rect2(x0 + w * i, base - lift, w, lift)
		RenderingServer.canvas_item_add_texture_rect_region(item, dst, strip.get_rid(), src)
	var box: Rect2 = Rect2(x0, base - lift, ext.x, lift)
	RenderingServer.canvas_item_add_rect(item, Rect2(box.position, Vector2(INK_W, lift)), INK)
	RenderingServer.canvas_item_add_rect(
		item, Rect2(box.end.x - INK_W, box.position.y, INK_W, lift), INK
	)
	RenderingServer.canvas_item_add_rect(item, Rect2(x0, base - INK_W, ext.x, INK_W), INK)
	return at + lift_of(t)


## A bay's strip cell: a stable hash of the building's place (view only, no sim RNG); the doors
## (cells 1+) sit on the ground floor of every other building's middle bay, plain walls elsewhere.
static func _bay_pick(at: Vector2, i: int, n: int, cells: int) -> int:
	var h: int = absi(roundi(at.x * 0.37 + at.y * 0.61)) % 7
	if cells < 2 or i != (n >> 1) or h < 3:
		return 0
	return 1 + h % (cells - 1)

class_name ChunkLift
extends RefCounted
## The city under a tilt (n8 city; city_facades.json): roofs lifted by height over south faces tiled
## from a style's wall strip (by the view's art, p55 / p70), street props standing as PropCards; all
## by south edge, nearer over farther. null under a flat view (`top` untouched). Render only.

const TABLE: String = "res://data/tables/city_facades.json"
## The face's ink edges (left, right, ground line), px at zoom 1.
const INK_W: float = 2.0
const INK: Color = Color(0.09, 0.075, 0.106, 1.0)
## Frames a live pitch (combo) must hold before the chunks redraw at it.
const SETTLE_FRAMES: int = 12

var height_m: PackedFloat32Array = PackedFloat32Array()
var style_of: PackedInt32Array = PackedInt32Array()
var drawn_pitch: float = 0.0
var occlude: bool = true
## the street props drawn standing (PropCards), ordered with the roofs
var cards: PropCards = null
var _tex: CityTextures
var _is_building: Array[bool] = []
var _strips: Array[Texture2D] = []
var _bays: Array[int] = []
var _bay_px: Array[float] = []
var _order: PackedInt32Array = PackedInt32Array()
var _rev: int = -1
## Kerb-parked cars VehicleParked draws as cards (n8 vehicles), handed over by chunk key on order.
var _carded: bool = false
var _parked: PackedVector4Array = PackedVector4Array()
var _order_of: CityChunk = null
var _rev_frames: int = 0


## The lift for this run's view, null when flat (or a perspective top_lift).
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
	_carded = d.get("parked_cards", false) and VehicleParked.carded()
	VehicleParked.clear()  # a new city view: no cars of an old one
	var names: Array[String] = []
	var styles: Dictionary = d["styles"]
	for style: String in styles:
		var row: Dictionary = styles[style]
		names.append(style)
		var fallback: Dictionary = d["art_fallback"]
		_strips.append(PropCards.art_texture(str(row["art"]), art, fallback))
		var bays: int = row["bays"]
		var bay_m: float = row["bay_m"]
		_bays.append(bays)
		_bay_px.append(bay_m * SimConst.PX_PER_M)
	occlude = d.get("occlude", true)
	var props: Dictionary = d.get("props", {})
	var fb: Dictionary = d["art_fallback"]
	cards = PropCards.make(props, tex.names, art, fb)
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


## The chunk's `k`-th command in draw order (the order is set once per chunk).
func nth(k: int, chunk: CityChunk) -> int:
	if _order_of != chunk:
		order(chunk)
	return _order[k]


## How many commands the chunk draws (its parked cards are not drawn here).
func count(chunk: CityChunk) -> int:
	if _order_of != chunk:
		order(chunk)
	return _order.size()


## The chunk's order: flat commands as listed, then roofs and prop cards by south edge.
func order(chunk: CityChunk) -> void:
	var out: PackedInt32Array = PackedInt32Array()
	var roofs: Array[Vector3] = []
	_parked = PackedVector4Array()
	_order_of = chunk
	for k: int in chunk.command_count():
		var t: int = chunk.tex[k]
		var o: int = k * CityChunk.XF_STRIDE
		if _carded and chunk.xf[o + 3] <= 0.5 and VehicleParked.row(t) >= 0:
			@warning_ignore("return_value_discarded")
			_parked.append(Vector4(chunk.xf[o], chunk.xf[o + 1], chunk.xf[o + 2], t))
		elif stands(t) and chunk.xf[o + 3] <= 0.5:
			var south: float = chunk.xf[o + 1] + extent(t, chunk.xf[o + 2]).y * 0.5
			roofs.append(Vector3(south, chunk.xf[o], k))
		else:
			@warning_ignore("return_value_discarded")
			out.append(k)
	if _carded:
		VehicleParked.park(chunk.key(), _parked)
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


## True for a building (face + lifted roof) or a standing prop card: drawn by draw(), not flat.
func stands(t: int) -> bool:
	return _is_building[t] or cards.has(t)


## Draws standing t at ground centre `at` px: a prop card on its south edge, or face + roof.
func draw(item: RID, t: int, rot: float, at: Vector2) -> void:
	if cards.has(t):
		cards.draw(item, t, rot, at + Vector2(0.0, extent(t, rot).y * 0.5))
		return
	var r: Rect2 = Rect2(-_tex.size_px[t] * 0.5, _tex.size_px[t])
	RenderingServer.canvas_item_add_set_transform(item, Transform2D(rot, face(item, t, rot, at)))
	RenderingServer.canvas_item_add_texture_rect(item, r, _tex.rids[t])


## The roof's lift (world px) for texture t.
func lift_of(t: int) -> Vector2:
	return ViewMode.shared().lift_px(height_m[t])


## Draws building t's south face (ground to roof) at ground centre `at`; returns the roof's place.
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


## A bay's strip cell by a stable place hash (no sim RNG): doors on some middle bays.
static func _bay_pick(at: Vector2, i: int, n: int, cells: int) -> int:
	var h: int = absi(roundi(at.x * 0.37 + at.y * 0.61)) % 7
	if cells < 2 or i != (n >> 1) or h < 3:
		return 0
	return 1 + h % (cells - 1)

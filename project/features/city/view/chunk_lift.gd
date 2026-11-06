class_name ChunkLift
extends RefCounted
## The city under a tilt (n8 city; city_facades.json): roofs lifted by height over south faces tiled
## from a style's wall strip (by the view's art, p55 / p70), street props standing as PropCards; all
## by south edge, nearer over farther. null under a flat view (`top` untouched). Render only.

const TABLE: String = "res://data/tables/city_facades.json"
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
var _faces: FacadeStrips = FacadeStrips.new()
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
		var bays: int = row["bays"]
		var bay_m: float = row["bay_m"]
		_faces.add(PropCards.art_texture(str(row["art"]), art, fallback), bays, bay_m)
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
	var hand: bool = _carded and VehicleParked.live  # drawn(): carded at setup, live per chunk
	for k: int in chunk.command_count():
		var t: int = chunk.tex[k]
		var o: int = k * CityChunk.XF_STRIDE
		if hand and chunk.xf[o + 3] <= 0.5 and VehicleParked.row(t) >= 0:
			@warning_ignore("return_value_discarded")
			_parked.append(Vector4(chunk.xf[o], chunk.xf[o + 1], chunk.xf[o + 2], t))
		elif stands(t) and chunk.xf[o + 3] <= 0.5:
			var at: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1]) * SimConst.PX_PER_M
			var ext: Vector2 = extent(t, chunk.xf[o + 2])
			var south: float = at.y + ext.y * 0.5  # px (was metres + px: the size outweighed y)
			if cards.has(t):
				south = cards.foot_at(t, chunk.xf[o + 2], at, ext).y
			roofs.append(Vector3(south, chunk.xf[o], k))
		else:
			@warning_ignore("return_value_discarded")
			out.append(k)
	if hand:
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
		cards.draw(item, t, rot, cards.foot_at(t, rot, at, extent(t, rot)))
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
	if lift >= 1.0 and _faces.has_strip(s):
		_faces.draw(item, s, extent(t, rot), at, lift)
	return at + lift_of(t)

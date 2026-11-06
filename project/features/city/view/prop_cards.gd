class_name PropCards
extends RefCounted
## The city's street props standing up under an angled view (night n8, lane city): a prop named in
## city_facades.json `props` draws as a card from its five-facing strip (keyed by the view row's
## art, p55 / p70; cut by tools/art/city_prop_cut.py from the library's prop sheets) instead of
## its flat top-down art. The facing comes from the command's turn (front, three-quarter, side,
## three-quarter away, back; the other side mirrored); the card's foot sits on the footprint's
## south edge and it rises by the art's aspect over the squashed ground. ChunkLift orders the
## cards with the roofs by south edge. Render only.

const FACINGS: int = 5
const TABLE: String = "res://data/tables/city_facades.json"

## The by-name set for drawers outside the streamed city (the arena's cover, quest 1's stage).
static var _named: PropCards = null
static var _named_art: String = "-"

var _strip: Dictionary[int, Texture2D] = {}
var _cell_w_px: Dictionary[int, float] = {}
var _turn: Dictionary[int, float] = {}
## optional per row: the card's foot in the flat art's frame (px from its centre; a lamp's post
## base at one end of its arm) and `mirror` (the strip's side view faces the other way)
var _foot: Dictionary[int, Vector2] = {}
var _mirror: Dictionary[int, bool] = {}
var _names: Array[String] = []


## props: the table's `props` rows by city_textures name; names: the texture names by id.
static func make(
	props: Dictionary, names: Array[String], art: String, fallback: Dictionary
) -> PropCards:
	var out: PropCards = PropCards.new()
	out._names = names
	for t: int in names.size():
		if not props.has(names[t]):
			continue
		var row: Dictionary = props[names[t]]
		var tex: Texture2D = art_texture(str(row["art"]), art, fallback)
		if tex == null:
			continue
		var w_m: float = row["cell_w_m"]
		var turns: float = row.get("turn", 0.0)
		out._strip[t] = tex
		out._cell_w_px[t] = w_m * SimConst.PX_PER_M
		out._turn[t] = turns * PI * 0.5
		if row.has("foot_m"):
			var f: Array = row["foot_m"]
			var fx: float = f[0]
			var fy: float = f[1]
			out._foot[t] = Vector2(fx, fy) * SimConst.PX_PER_M
		if row.get("mirror", false):
			out._mirror[t] = true
	return out


## The table's props by name for this run's view (its art key), built once per art; null under a
## flat view or a perspective top_lift (those keep their own prop drawing).
static func named() -> PropCards:
	var view: ViewMode = ViewMode.shared()
	if view.is_flat() or view.eye_h_m > 0.0:
		return null
	if _named_art != view.art:
		var parser: JSON = JSON.new()
		if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK:
			return null
		var d: Dictionary = parser.data
		var props: Dictionary = d.get("props", {})
		var names: Array[String] = []
		names.assign(props.keys())
		var fb: Dictionary = d["art_fallback"]
		_named = make(props, names, view.art, fb)
		_named_art = view.art
	return _named


## Draws the card of the prop called `name` facing the camera on `ci` (from its _draw), its foot at
## `foot` px, at `px_per_m`; false (nothing drawn) when the table has no such card. Leaves the
## canvas transform at identity.
func draw_named(ci: CanvasItem, name: String, foot: Vector2, px_per_m: float) -> bool:
	var t: int = _names.find(name)
	if t < 0 or not _strip.has(t):
		return false
	var item: RID = ci.get_canvas_item()
	draw(item, t, 0.0, foot, _cell_w_px[t] * px_per_m / SimConst.PX_PER_M)
	RenderingServer.canvas_item_add_set_transform(item, Transform2D.IDENTITY)
	return true


## The art at `path` with `<art>` set to the view's art key, else its fallback key's; null if none.
static func art_texture(path: String, art: String, fallback: Dictionary) -> Texture2D:
	var want: String = art if art != "" else str(fallback.get("", "p55"))
	for key: String in [want, str(fallback.get(want, want))]:
		var p: String = path.replace("<art>", key)
		if ResourceLoader.exists(p):
			return load(p)
	Log.warn("city", "no art for %s at %s" % [path, art])
	return null


func has(t: int) -> bool:
	return _strip.has(t)


func size() -> int:
	return _strip.size()


## The draw bands by texture with the standing props moved to the roofs band (4).
func bands(band_of: PackedByteArray) -> PackedByteArray:
	var out: PackedByteArray = band_of.duplicate()
	for t: int in _strip:
		out[t] = 4
	return out


## The strip cell for a command's turn and whether it is mirrored (the art's front faces south at
## turn 0, plus the row's `turn` quarter turns).
func facing(t: int, rot: float) -> Vector2i:
	var ang: float = wrapf(rot + _turn[t], -PI, PI)
	var idx: int = clampi(roundi(absf(ang) / (PI * 0.25)), 0, FACINGS - 1)
	var flip: bool = ang < -0.01 and idx > 0 and idx < FACINGS - 1
	return Vector2i(idx, 1 if flip != (idx > 0 and idx < FACINGS - 1 and _mirror.has(t)) else 0)


## The card's foot in world px for a command at ground centre `at` with footprint `ext` px: the
## row's `foot_m` turned with the command, else the footprint's south-edge centre.
func foot_at(t: int, rot: float, at: Vector2, ext: Vector2) -> Vector2:
	if _foot.has(t):
		return at + _foot[t].rotated(rot)
	return at + Vector2(0.0, ext.y * 0.5)


## Draws prop t's card into `item`; `foot` is the footprint's south-edge centre in world px; `w`
## the cell's width in px (default: the table's, at the city's scale).
func draw(item: RID, t: int, rot: float, foot: Vector2, w: float = -1.0) -> void:
	var strip: Texture2D = _strip[t]
	var cell: Vector2 = Vector2(strip.get_width() / float(FACINGS), strip.get_height())
	w = _cell_w_px[t] if w < 0.0 else w
	var h: float = w * cell.y / cell.x / ViewMode.shared().ground_k()
	var f: Vector2i = facing(t, rot)
	var src: Rect2 = Rect2(Vector2(cell.x * f.x, 0.0), cell)
	var dst: Rect2 = Rect2(-w * 0.5, -h, w, h)
	# a mirrored facing flips the basis (a negative rect size shifts the card instead of flipping)
	var xf: Transform2D = Transform2D(Vector2(-1.0 if f.y == 1 else 1.0, 0.0), Vector2.DOWN, foot)
	RenderingServer.canvas_item_add_set_transform(item, xf)
	RenderingServer.canvas_item_add_texture_rect_region(item, dst, strip.get_rid(), src)

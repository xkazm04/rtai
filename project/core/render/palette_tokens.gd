class_name PaletteTokens
extends RefCounted
## The colour doctrine as data (data/tables/palette.json, gtai.palette/1): the base tokens (ink,
## paper, charcoal, wash, steel), the two accent inks with their allowed uses and render layers,
## and the classifier gates. count_accents() measures how many pixels of a frame print as an
## accent, so stray vermilion in the world is a number. Render / dev only.

const TABLE: String = "res://data/tables/palette.json"
const SCHEMA: String = "gtai.palette/1"

static var _shared: PaletteTokens = null

var tokens: Dictionary[StringName, Color] = {}
## accent id -> the render layer ids it may appear on.
var accent_layers: Dictionary[StringName, PackedStringArray] = {}
var accent_uses: Dictionary[StringName, PackedStringArray] = {}
var verm_gate: float = 0.31
var teal_gate: float = 0.26


static func shared() -> PaletteTokens:
	if _shared == null:
		_shared = PaletteTokens.from_json(FileAccess.get_file_as_string(TABLE))
	return _shared


static func from_json(text: String) -> PaletteTokens:
	var out: PaletteTokens = PaletteTokens.new()
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return out
	var d: Dictionary = parser.data
	if d.get("schema", "") != SCHEMA:
		return out
	var gates: Dictionary = d["gates"]
	out.verm_gate = gates["verm_gate"]
	out.teal_gate = gates["teal_gate"]
	for row: Dictionary in d["tokens"]:
		var tid: String = row["id"]
		var hex: String = row["hex"]
		out.tokens[StringName(tid)] = Color.html(hex)
	for row: Dictionary in d["accents"]:
		var aid: String = row["id"]
		var layers: Array = row["layers"]
		var uses: Array = row["uses"]
		out.accent_layers[StringName(aid)] = PackedStringArray(layers)
		out.accent_uses[StringName(aid)] = PackedStringArray(uses)
	return out


func color(id: StringName) -> Color:
	return tokens.get(id, Color.MAGENTA)


## True when the doctrine allows `accent` on render layer `layer`.
func allowed(accent: StringName, layer: StringName) -> bool:
	return accent_layers.has(accent) and accent_layers[accent].has(String(layer))


## 1 = vermilion, 2 = teal, 0 = a base tone (the look_d4 plate gates).
func classify(c: Color) -> int:
	if c.r - maxf(c.g, c.b) >= verm_gate:
		return 1
	if minf(c.g, c.b) - c.r >= teal_gate:
		return 2
	return 0


## Accent pixels in `img`, sampling every `stride`-th pixel in x and y and scaling back up:
## Vector2i(vermilion, teal).
func count_accents(img: Image, stride: int = 1) -> Vector2i:
	var rgb: Image = img.duplicate() as Image
	rgb.convert(Image.FORMAT_RGB8)
	var data: PackedByteArray = rgb.get_data()
	var w: int = rgb.get_width()
	var vg: int = roundi(verm_gate * 255.0)
	var tg: int = roundi(teal_gate * 255.0)
	var verm: int = 0
	var teal: int = 0
	for y: int in range(0, rgb.get_height(), stride):
		var row: int = y * w * 3
		for x: int in range(0, w, stride):
			var i: int = row + x * 3
			var r: int = data[i]
			var g: int = data[i + 1]
			var b: int = data[i + 2]
			if r - maxi(g, b) >= vg:
				verm += 1
			elif mini(g, b) - r >= tg:
				teal += 1
	return Vector2i(verm, teal) * stride * stride

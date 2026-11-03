class_name PaletteTokens
extends RefCounted
## The colour doctrine as data (data/tables/palette.json, gtai.palette/1): the base tokens (ink,
## paper, charcoal, wash, steel), the accent inks (blood, cop blue, vermilion, teal) with their
## allowed uses and render layers, and the classifier gates. count_inks() measures how many pixels
## of a frame print as each accent, so stray vermilion in the world is a number. Render / dev only.

const TABLE: String = "res://data/tables/palette.json"
const SCHEMA: String = "gtai.palette/1"

static var _shared: PaletteTokens = null

var tokens: Dictionary[StringName, Color] = {}
## accent id -> the render layer ids it may appear on.
var accent_layers: Dictionary[StringName, PackedStringArray] = {}
var accent_uses: Dictionary[StringName, PackedStringArray] = {}
var verm_gate: float = 0.31
var teal_gate: float = 0.26
## blood: r >= blood_r and max(g, b) / r < blood_gr (look_noir blood_mask's centres)
var blood_r: float = 0.30
var blood_gr: float = 0.18
## cop blue: b - max(r, g) >= blue_gate
var blue_gate: float = 0.08


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
	out.blood_r = gates["blood_r"]
	out.blood_gr = gates["blood_gr"]
	out.blue_gate = gates["blue_gate"]
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


## 1 = vermilion, 2 = teal, 3 = blood, 4 = cop blue, 0 = a base tone. Blood is tested first:
## deep arterial red also passes the vermilion gate (look_noir blood_mask, the same split).
func classify(c: Color) -> int:
	if c.r >= blood_r and maxf(c.g, c.b) < blood_gr * c.r:
		return 3
	if c.r - maxf(c.g, c.b) >= verm_gate:
		return 1
	if minf(c.g, c.b) - c.r >= teal_gate:
		return 2
	if c.b - maxf(c.r, c.g) >= blue_gate:
		return 4
	return 0


## Accent pixels in `img`, sampling every `stride`-th pixel in x and y and scaling back up:
## Vector2i(vermilion, teal) (blood is not vermilion).
func count_accents(img: Image, stride: int = 1) -> Vector2i:
	var n: PackedInt32Array = count_inks(img, stride)
	return Vector2i(n[1], n[2])


## Pixels per classify() class in `img` (index 0 base .. 4 cop blue), every `stride`-th pixel in
## x and y, scaled back up.
func count_inks(img: Image, stride: int = 1) -> PackedInt32Array:
	var rgb: Image = img.duplicate() as Image
	rgb.convert(Image.FORMAT_RGB8)
	var data: PackedByteArray = rgb.get_data()
	var w: int = rgb.get_width()
	var out: PackedInt32Array = [0, 0, 0, 0, 0]
	var vg: int = roundi(verm_gate * 255.0)
	var tg: int = roundi(teal_gate * 255.0)
	var bg: int = roundi(blue_gate * 255.0)
	var br: int = roundi(blood_r * 255.0)
	for y: int in range(0, rgb.get_height(), stride):
		var row: int = y * w * 3
		for x: int in range(0, w, stride):
			var i: int = row + x * 3
			var r: int = data[i]
			var gb: int = maxi(data[i + 1], data[i + 2])
			if r >= br and gb < blood_gr * r:
				out[3] += 1
			elif r - gb >= vg:
				out[1] += 1
			elif mini(data[i + 1], data[i + 2]) - r >= tg:
				out[2] += 1
			elif data[i + 2] - maxi(r, data[i + 1]) >= bg:
				out[4] += 1
			else:
				out[0] += 1
	for k: int in 5:
		out[k] *= stride * stride
	return out

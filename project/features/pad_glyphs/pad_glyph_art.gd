class_name PadGlyphArt
extends RefCounted
## n9-handheld: the drawn ink pad glyphs (the asset lane's `ui_pad_glyphs_v1`, 128 px cells in one
## atlas) in place of the bracketed pad names in a prompt ("[A]", "[RT]", "[Cross]",
## "[L-stick]"), on the handheld rows only (DeviceProfile.is_handheld): the desktop keeps its text.
## A prompt is split into runs of text and glyphs; draw_line() draws them with a CanvasItem and
## bbcode() writes them for a RichTextLabel. A label with no cell stays bracketed text.

const ATLAS_PNG: String = "res://features/pad_glyphs/ui_pad_glyphs_v1.png"
const ATLAS_JSON: String = "res://features/pad_glyphs/ui_pad_glyphs_v1.json"
## A glyph's height against the text's font size (a 24 px line draws 34 px glyphs).
const GLYPH_K: float = 1.4
## The prompt's pad label (PadGlyphs.label: Xbox, PlayStation or Nintendo names) -> its cell.
const CELL: Dictionary[String, String] = {
	"A": "face_a",
	"B": "face_b",
	"X": "face_x",
	"Y": "face_y",
	"Cross": "face_cross",
	"Circle": "face_circle",
	"Square": "face_square",
	"Triangle": "face_triangle",
	"LB": "lb",
	"RB": "rb",
	"LT": "lt",
	"RT": "rt",
	"L1": "l1",
	"R1": "r1",
	"L2": "l2",
	"R2": "r2",
	"L": "l",
	"R": "r",
	"ZL": "zl",
	"ZR": "zr",
	"Back": "select",
	"Create": "select",
	"-": "select",
	"Start": "start",
	"Options": "start",
	"+": "start",
	"L3": "stick_l3",
	"R3": "stick_r3",
	"L-stick": "move_stick_l",
	"R-stick": "aim_stick_r",
}

static var _cells: Dictionary = {}
static var _tex: Texture2D = null


## True when this run draws the glyphs (a handheld row): the desktop keeps the bracketed text.
static func active() -> bool:
	return DeviceProfile.shared().is_handheld()


## The atlas region of a pad label ("A", "RT", "L-stick"); an empty Rect2 when it has none.
static func region(pad_label: String) -> Rect2:
	if not CELL.has(pad_label):
		return Rect2()
	if _cells.is_empty():
		var parser: JSON = JSON.new()
		if parser.parse(FileAccess.get_file_as_string(ATLAS_JSON)) == OK:
			var d: Dictionary = parser.data
			_cells = d.get("cells", {})
	var r: Array = _cells.get(CELL[pad_label], [])
	if r.size() != 4:
		return Rect2()
	var x: float = r[0]
	var y: float = r[1]
	var w: float = r[2]
	var h: float = r[3]
	return Rect2(x, y, w, h)


static func texture() -> Texture2D:
	if _tex == null:
		_tex = load(ATLAS_PNG)
	return _tex


## `text` as runs: a String is words, a Rect2 is a glyph's atlas region ("[A]" -> the A cell).
static func runs(text: String) -> Array:
	var out: Array = []
	var rest: String = text
	while true:
		var open: int = rest.find("[")
		var close: int = rest.find("]", open + 1) if open >= 0 else -1
		if open < 0 or close < 0:
			break
		var cell: Rect2 = region(rest.substr(open + 1, close - open - 1))
		if cell.has_area():
			if open > 0:
				out.append(rest.substr(0, open))
			out.append(cell)
		else:
			out.append(rest.substr(0, close + 1))
		rest = rest.substr(close + 1)
	if rest != "":
		out.append(rest)
	return out


## The drawn width and height of `text` at `font_size` in the fallback font (glyphs included).
static func line_size(text: String, font_size: int) -> Vector2:
	var font: Font = ThemeDB.fallback_font
	var w: float = 0.0
	var g: float = float(font_size) * GLYPH_K
	for run: Variant in runs(text):
		if run is Rect2:
			w += g
		else:
			w += font.get_string_size(str(run), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	return Vector2(w, maxf(g, font.get_height(font_size)))


## Draws `text` on `ci` from baseline `at` (the theme's fallback font), each glyph centred on the
## text's x-height.
static func draw_line(ci: CanvasItem, at: Vector2, text: String, size: int, ink: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var g: float = float(size) * GLYPH_K
	var x: float = at.x
	for run: Variant in runs(text):
		if run is Rect2:
			var top: float = at.y - float(size) * 0.36 - g * 0.5
			var cell: Rect2 = run
			ci.draw_texture_rect_region(texture(), Rect2(x, top, g, g), cell)
			x += g
		else:
			ci.draw_string(
				font, Vector2(x, at.y), str(run), HORIZONTAL_ALIGNMENT_LEFT, -1, size, ink
			)
			x += font.get_string_size(str(run), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


## `text` as BBCode for a RichTextLabel: glyphs as atlas-region images `px` tall, words escaped.
static func bbcode(text: String, px: int) -> String:
	var out: String = ""
	for run: Variant in runs(text):
		if run is Rect2:
			var r: Rect2 = run
			out += (
				"[img region=%d,%d,%d,%d width=%d height=%d]%s[/img]"
				% [r.position.x, r.position.y, r.size.x, r.size.y, px, px, ATLAS_PNG]
			)
		else:
			out += str(run).replace("[", "[lb]")
	return out

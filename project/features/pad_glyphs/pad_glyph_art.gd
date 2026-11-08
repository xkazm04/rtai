class_name PadGlyphArt
extends RefCounted
## n9-handheld: the drawn ink pad glyphs (the asset lane's `ui_pad_glyphs_v1`, 128 px cells in one
## atlas) in place of the bracketed pad names in a prompt ("[A]", "[RT]", "[Cross]",
## "[L-stick]"), on the handheld rows only (DeviceProfile.is_handheld): the desktop keeps its text.
## The keyboard twin (`ui_kb_glyphs_v1`: "[E]", "[LMB]", "[W A S D]") draws on a `glyphs: kb` row
## (a desktop study row); GlyphCells holds both sets' atlases and label maps.
## A prompt is split into runs of text and glyphs; draw_line() draws them with a CanvasItem and
## bbcode() writes them for a RichTextLabel. A label with no cell stays bracketed text.

## A glyph's height against the text's font size (a 24 px line draws 34 px glyphs).
const GLYPH_K: float = 1.4
## A wide glyph (a shoulder bar, Start) may draw this many glyph heights wide, so it reads as tall
## as it can; the atlas json holds each cell's trimmed ink box, not the 128 px cell.
const WIDE_K: float = 1.5
## The keyboard set's cap: its space bar is ~2.7 heights wide, Shift / Ctrl / Tab ~1.75.
const KB_WIDE_K: float = 2.4
## The air either side of a glyph, in glyph heights (the trimmed boxes touch their ink).
const SIDE_K: float = 0.08
## Godot's JoyButton numbers -> the Xbox-layout names the prompts use (ObjectiveHint.PAD_BUTTONS'
## twin: features cannot name boot).
const PAD_BUTTONS: Dictionary[int, String] = {
	0: "A", 1: "B", 2: "X", 3: "Y", 4: "Back", 6: "Start", 7: "L3", 8: "R3", 9: "LB", 10: "RB"
}

## Kept for callers and tests: the pad set's label -> cell map.
const CELL: Dictionary[String, String] = GlyphCells.PAD_CELL

static var _cells: Dictionary[StringName, Dictionary] = {}
static var _tex: Dictionary[StringName, Texture2D] = {}


## True when this run draws the glyphs (a handheld row, or a row with glyphs: kb): the shipped
## desktop keeps the bracketed text.
static func active() -> bool:
	return glyph_set() != &""


## This run's glyph set: pad on a handheld row, kb on a `glyphs: kb` row, else none (&"").
static func glyph_set() -> StringName:
	var p: DeviceProfile = DeviceProfile.shared()
	if p.is_handheld():
		return GlyphCells.PAD
	return GlyphCells.KB if p.glyphs == GlyphCells.KB else &""


## "[LB]" for `action`'s first bound pad button (relabelled for the pad's family), else `fallback`.
## With the keyboard set the key itself is drawn: "[Q]".
static func action_hint(action: StringName, fallback: String) -> String:
	if glyph_set() == GlyphCells.KB:
		return "[%s]" % fallback
	if not InputMap.has_action(action):
		return fallback
	for ev: InputEvent in InputMap.action_get_events(action):
		var b: InputEventJoypadButton = ev as InputEventJoypadButton
		if b != null and PAD_BUTTONS.has(b.button_index):
			return "[%s]" % PadGlyphs.label(PAD_BUTTONS[b.button_index])
	return fallback


## The atlas region of a label ("A", "RT", "L-stick"; "E", "LMB", "W A S D" in the kb set) in
## this run's set (or `glyph_set`); an empty Rect2 when it has none.
static func region(label: String, glyph_set_id: StringName = &"") -> Rect2:
	var gs: StringName = glyph_set_id if glyph_set_id != &"" else _set_or_pad()
	var map: Dictionary[String, String] = GlyphCells.cell_map(gs)
	if not map.has(label):
		return Rect2()
	if not _cells.has(gs):
		_cells[gs] = {}
		var parser: JSON = JSON.new()
		if parser.parse(FileAccess.get_file_as_string(GlyphCells.ATLAS_JSON[gs])) == OK:
			var d: Dictionary = parser.data
			_cells[gs] = d.get("cells", {})
	var cells: Dictionary = _cells[gs]
	var r: Array = cells.get(map[label], [])
	if r.size() != 4:
		return Rect2()
	var x: float = r[0]
	var y: float = r[1]
	var w: float = r[2]
	var h: float = r[3]
	return Rect2(x, y, w, h)


static func texture() -> Texture2D:
	var gs: StringName = _set_or_pad()
	if not _tex.has(gs):
		_tex[gs] = load(GlyphCells.ATLAS_PNG[gs])
	return _tex[gs]


## This run's set; the pad set when none is active (the tests and the probes read it bare).
static func _set_or_pad() -> StringName:
	var gs: StringName = glyph_set()
	return gs if gs != &"" else GlyphCells.PAD


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


## The drawn size of a glyph whose ink box is `cell`, for a glyph height `g`: as tall as `g`, at
## most WIDE_K x `g` wide (KB_WIDE_K in the keyboard set), its aspect kept.
static func fit(cell: Rect2, g: float) -> Vector2:
	var wide: float = KB_WIDE_K if glyph_set() == GlyphCells.KB else WIDE_K
	var s: float = minf(g / maxf(cell.size.y, 1.0), wide * g / maxf(cell.size.x, 1.0))
	return cell.size * s


## The drawn width and height of `text` at `font_size` in the fallback font (glyphs included).
static func line_size(text: String, font_size: int) -> Vector2:
	var font: Font = ThemeDB.fallback_font
	var w: float = 0.0
	var g: float = float(font_size) * GLYPH_K
	for run: Variant in runs(text):
		if run is Rect2:
			var cell: Rect2 = run
			w += fit(cell, g).x + 2.0 * SIDE_K * g
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
			var cell: Rect2 = run
			var sz: Vector2 = fit(cell, g)
			var top: float = at.y - float(size) * 0.36 - sz.y * 0.5
			ci.draw_texture_rect_region(texture(), Rect2(Vector2(x + SIDE_K * g, top), sz), cell)
			x += sz.x + 2.0 * SIDE_K * g
		else:
			ci.draw_string(
				font, Vector2(x, at.y), str(run), HORIZONTAL_ALIGNMENT_LEFT, -1, size, ink
			)
			x += font.get_string_size(str(run), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


## `text` as BBCode for a RichTextLabel: glyphs as atlas-region images `px` tall, words escaped.
static func bbcode(text: String, px: int) -> String:
	var out: String = ""
	var png: String = GlyphCells.ATLAS_PNG[_set_or_pad()]
	for run: Variant in runs(text):
		if run is Rect2:
			var r: Rect2 = run
			var sz: Vector2 = fit(r, float(px))
			out += (
				"[img region=%d,%d,%d,%d width=%d height=%d]%s[/img]"
				% [r.position.x, r.position.y, r.size.x, r.size.y, sz.x, sz.y, png]
			)
		else:
			out += str(run).replace("[", "[lb]")
	return out

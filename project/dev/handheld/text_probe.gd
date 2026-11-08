class_name TextProbe
extends RefCounted
## handheld lane (n9): the runtime text-legibility probe for Valve's Deck Verified rule ("the
## smallest on-screen font character should never fall below 9 pixels in height at 1280x800",
## 12 px recommended). Walks a live tree and, for every visible Control that shows text (Label,
## Button, RichTextLabel, LineEdit), reads its font and size, scales the size to the window's
## pixels (the canvas transform x the viewport's stretch) and measures the glyph ink heights of
## "H" (cap) and "x" (x-height) from the TextServer at that size. The strict reading checks the
## x-height against 9 px; the cap height is reported beside it. Custom draw_string sites are not
## Controls: `size_row()` measures one font size the same way, for the reviewed table in the LEDGER.
## Read only. Dev code: never shipped (dev/ is not in release exports).

const FLOOR_PX: float = 9.0
const RECOMMEND_PX: float = 12.0
## The Steam Deck's panel: 1280x800 on a 7-inch diagonal (~215.6 ppi).
const DECK_MM_PER_PX: float = 25.4 / 215.6


## One row per visible text Control under `root`, smallest x-height first. `stretch` is the
## base-to-window factor; below 0 it is read from the viewport (a headless window is no panel).
static func probe(root: Node, stretch: float = -1.0) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_walk(root, rows, stretch)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.x_px < b.x_px)
	return rows


## The ink heights of "H" and "x" for `font` at `size` window px, and the Deck's mm.
static func size_row(font: Font, size: float) -> Dictionary:
	var px: int = maxi(1, roundi(size))
	var cap: float = glyph_height(font, px, "H")
	var xh: float = glyph_height(font, px, "x")
	return {
		"font_px": px,
		"cap_px": cap,
		"x_px": xh,
		"x_mm": snappedf(xh * DECK_MM_PER_PX, 0.01),
		"verdict": verdict(xh),
	}


static func verdict(x_px: float) -> String:
	if x_px < FLOOR_PX:
		return "below_9"
	return "ok" if x_px >= RECOMMEND_PX else "above_9"


## The glyph's ink height in px from the TextServer's cache (0 when the font has no such glyph).
static func glyph_height(font: Font, size: int, ch: String) -> float:
	var rids: Array[RID] = font.get_rids()
	var ts: TextServer = TextServerManager.get_primary_interface()
	for rid: RID in rids:
		var g: int = ts.font_get_glyph_index(rid, size, ch.unicode_at(0), 0)
		if g == 0:
			continue
		var cache: Vector2i = Vector2i(size, 0)
		ts.font_render_glyph(rid, cache, g)
		var idx: int = ts.font_get_glyph_texture_idx(rid, cache, g)
		if idx < 0:
			return 0.0
		var page: Image = ts.font_get_texture_image(rid, cache, idx)
		return _ink_rows(page, Rect2i(ts.font_get_glyph_uv_rect(rid, cache, g)))
	return 0.0


## Rows of `rect` in the glyph cache page with any ink (alpha above a quarter): the glyph's height.
static func _ink_rows(page: Image, rect: Rect2i) -> float:
	var img: Image = page.duplicate() as Image
	if img.is_compressed():
		if img.decompress() != OK:
			return 0.0
	img.convert(Image.FORMAT_RGBA8)
	var first: int = -1
	var last: int = -1
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if img.get_pixel(x, y).a > 0.25:
				first = y if first < 0 else first
				last = y
				break
	return 0.0 if first < 0 else float(last - first + 1)


static func _walk(node: Node, rows: Array[Dictionary], stretch: float) -> void:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	if node is Control:
		var row: Dictionary = _row(node as Control, stretch)
		if not row.is_empty():
			rows.append(row)
	for child: Node in node.get_children():
		_walk(child, rows, stretch)


static func _row(c: Control, stretch: float) -> Dictionary:
	var text: String = _text(c)
	if text.strip_edges().is_empty():
		return {}
	var key: StringName = &"normal_font" if c is RichTextLabel else &"font"
	var size_key: StringName = &"normal_font_size" if c is RichTextLabel else &"font_size"
	var font: Font = c.get_theme_font(key)
	var authored: int = c.get_theme_font_size(size_key)
	var k: float = c.get_global_transform_with_canvas().get_scale().y
	k *= stretch if stretch >= 0.0 else c.get_viewport().get_final_transform().get_scale().y
	var row: Dictionary = size_row(font, authored * k)
	row["path"] = str(c.get_path())
	row["class"] = c.get_class()
	row["text"] = text.left(40)
	row["authored_px"] = authored
	row["scale"] = snappedf(k, 0.001)
	return row


static func _text(c: Control) -> String:
	if c is RichTextLabel:
		return (c as RichTextLabel).get_parsed_text()
	if c is Label:
		return (c as Label).text
	if c is Button:
		return (c as Button).text
	if c is LineEdit:
		return (c as LineEdit).text
	return ""

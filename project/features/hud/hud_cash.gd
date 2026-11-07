class_name HudCash
extends RefCounted
## n8-hud: the cash frame as wide as its sum (FIT), right-aligned over the ammo ticket. The frame's
## banknote end and its torn right end (END_SRC source px) are kept at the drawn 420 px scale and
## the plain paper between is cut; between MIN_W and W. FIT false = the fixed 420 px frame.

const FIT: bool = true
const W: float = 420.0
const MIN_W: float = 260.0
const PAD: float = 44.0
const END_SRC: float = 120.0
## The sum's left edge in the frame (screen px), right of the banknote.
const TEXT_X: float = 112.0


## The frame's width for `sum` in the numeral strip at 32 px and, when unarmed, `label` at 22 px.
static func width(art: HudArt, sum: String, label: String) -> float:
	if not FIT:
		return W
	var words: float = digits_w(art, sum, 32.0)
	if label != "":
		var font: Font = ThemeDB.fallback_font
		words = maxf(words, font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x)
	return clampf(TEXT_X + words + PAD, MIN_W, W)


## The cash frame into `box` on `ci`: the art's left up to the seam, then its last END_SRC px.
static func frame(ci: CanvasItem, art: HudArt, box: Rect2) -> void:
	var t: Texture2D = art.texture(&"cash_frame")
	var src: Vector2 = Vector2(t.get_size())
	var k: float = W / src.x
	var end_w: float = minf(END_SRC * k, box.size.x)
	var left: Rect2 = Rect2(box.position, Vector2(box.size.x - end_w, box.size.y))
	ci.draw_texture_rect_region(t, left, Rect2(0.0, 0.0, left.size.x / k, src.y))
	var right: Rect2 = Rect2(left.end.x, box.position.y, end_w, box.size.y)
	ci.draw_texture_rect_region(t, right, Rect2(src.x - end_w / k, 0.0, end_w / k, src.y))


## The advance of `value` in the numeral strip at `size` (what ink_digits draws).
static func digits_w(art: HudArt, value: String, size: float) -> float:
	var s: float = size * 0.92 / art.cap_px
	var x: float = 0.0
	for ch: String in value:
		var k: int = art.glyphs.find(ch)
		x += (art.space_px if k < 0 or k >= art.advance_px.size() else art.advance_px[k]) * s
	return x


## The hand-inked numeral strip on `ci` on the baseline `at`, cap height 0.92 of `size` (the
## condensed caps need more height than the sans to carry the same weight). Unknown characters
## advance a space. n8-hud: moved here from HudView (the corners draw it on their own nodes).
static func ink_digits(
	ci: CanvasItem, art: HudArt, at: Vector2, value: String, size: float
) -> void:
	var s: float = size * 0.92 / art.cap_px
	var strip: Texture2D = art.texture(art.digits_art)
	var cell: Vector2 = art.cell_px
	var x: float = at.x
	for ch: String in value:
		var k: int = art.glyphs.find(ch)
		if k < 0 or k >= art.advance_px.size():
			x += art.space_px * s
			continue
		var adv: float = art.advance_px[k]
		var src: Rect2 = Rect2(Vector2(k * cell.x, 0.0), cell)
		var pos: Vector2 = Vector2(x - (cell.x - adv) * 0.5 * s, at.y - art.baseline_px * s)
		ci.draw_texture_rect_region(strip, Rect2(pos, cell * s), src)
		x += adv * s

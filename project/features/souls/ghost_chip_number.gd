class_name GhostChipNumber
extends RefCounted
## The key number on a deploy-strip chip (GhostFormHud): large digit, paper on an ink plate that
## sits on the avatar's lower-left rim, so it reads on any ground. The label is the live key name.

const PAPER: Color = Color("e9dcc3")
const INK: Color = Color("17131b")
const PLATE: Color = Color(INK, 0.92)
const PAD: float = 3.0
const OUTLINE_PX: int = 4
## How far the strip's background plate is grown past the card (GhostFormHud._draw).
const STRIP_GROW: float = 6.0


## The plate rect for `label` centred on `at` (a square at least, wider for a long key name).
static func plate(font: Font, at: Vector2, label: String, size: int) -> Rect2:
	var w: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var h: float = font.get_height(size)
	var box: Vector2 = Vector2(maxf(w, h * 0.62) + PAD * 2.0, h * 0.62 + PAD * 2.0)
	return Rect2(at - box * 0.5, box)


## Where slot `slot`'s number plate is centred: the avatar's lower-left rim, pushed right just
## enough that the plate's left edge stays inside the strip's plate and off the screen edge.
static func anchor(l: GhostFormLayout, view_h: float, slot: int, label: String) -> Vector2:
	var c: Vector2 = l.chip_center(view_h, slot)
	var at: Vector2 = c + Vector2(-1.2, 1.15) * l.chip_r
	var rect: Rect2 = plate(ThemeDB.fallback_font, at, label, l.number_size)
	at.x += maxf(0.0, l.number_min_x() - rect.position.x)
	return at


static func draw(canvas: CanvasItem, at: Vector2, label: String, size: int) -> void:
	if label == "":
		return
	var font: Font = ThemeDB.fallback_font
	var rect: Rect2 = plate(font, at, label, size)
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = PLATE
	box.border_color = PAPER
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	canvas.draw_style_box(box, rect)
	var w: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var base: Vector2 = Vector2(
		at.x - w * 0.5, at.y + (font.get_ascent(size) - font.get_descent(size)) * 0.5
	)
	canvas.draw_string_outline(
		font, base, label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, OUTLINE_PX, INK
	)
	canvas.draw_string(font, base, label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, PAPER)

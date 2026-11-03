class_name HudOverlay
extends CanvasLayer
## Dev-only HUD layout over the city frame (night lane d4-production evidence): the D4 HUD frames
## from features/hud/art placed in-engine at a UI scale, with sample numbers in the README text
## areas, drawn from the hand-inked numeral strip hud_digits.png (README). Not the game HUD (no HUD
## feature exists yet); digits only, no UI words.

const ART: String = "res://features/hud/art/"
const MARGIN: float = 16.0
## wanted_frame socket centres (frame px, README), y = 72.5; pips draw 64 frame px wide.
const SOCKETS: Array[float] = [137.5, 235.5, 334.0, 432.0, 530.5]
const SOCKET_Y: float = 72.5
const PIP_PX: float = 64.0
## The plated frames (ink rim + drop shadow) carry 7 frame px of rim before the README coordinates.
const PLATE: Vector2 = Vector2(7.0, 7.0)
const STARS: int = 2
## hud_digits.png: one row of DIGIT_CELL cells in DIGIT_GLYPHS order, cap height DIGIT_CAP strip px
## centred in the cell; advances in strip px (digits tabular).
const DIGIT_GLYPHS: String = "0123456789$/x+-:"
const DIGIT_CELL: Vector2 = Vector2(112.0, 160.0)
const DIGIT_CAP: float = 120.0
const DIGIT_ADVANCE: Dictionary[String, float] = {
	"$": 70.0, "/": 58.0, "x": 74.0, "+": 66.0, "-": 62.0, ":": 36.0, " ": 30.0, "1": 70.0
}
const DIGIT_TABULAR: float = 70.0

var ui_scale: float = 0.5


func build(scale_ui: float) -> void:
	ui_scale = scale_ui
	for child: Node in get_children():
		child.queue_free()
	var view: Vector2 = Vector2(get_viewport().get_visible_rect().size)
	_frame("cash_frame", Vector2(MARGIN, MARGIN))
	_digits("12480", Vector2(MARGIN, MARGIN) + (PLATE + Vector2(190.0, 30.0)) * ui_scale, 88)
	var wanted: Vector2 = _size("wanted_frame")
	var w_pos: Vector2 = Vector2(view.x - MARGIN - wanted.x, MARGIN)
	_frame("wanted_frame", w_pos)
	for i: int in SOCKETS.size():
		var pip: String = "wanted_pip_full" if i < STARS else "wanted_pip_empty"
		var c: Vector2 = w_pos + (PLATE + Vector2(SOCKETS[i], SOCKET_Y)) * ui_scale
		var tex: Texture2D = load(ART + pip + ".png") as Texture2D
		var s: float = PIP_PX / float(tex.get_width()) * ui_scale
		_rect(tex, c - Vector2(tex.get_size()) * s * 0.5, s)
	var ammo: Vector2 = _size("ammo_ticket")
	var a_pos: Vector2 = Vector2(MARGIN, view.y - MARGIN - ammo.y)
	_frame("ammo_ticket", a_pos)
	_digits("17 / 90", a_pos + (PLATE + Vector2(160.0, 90.0)) * ui_scale, 110)
	var card: Vector2 = _size("soul_card_active")
	var c_pos: Vector2 = view - Vector2(MARGIN, MARGIN) - card
	_frame("soul_card_active", c_pos)
	_portrait("soul_gearbox", c_pos, "soul_card_active")
	var i_pos: Vector2 = view - Vector2(MARGIN * 1.5 + card.x, MARGIN) - _size("soul_card")
	_frame("soul_card", i_pos)
	_portrait("soul_sentry_idle", i_pos, "soul_card")


## A soul portrait (220 x 350 at 2x) centred across the card, 40 card px from its top (HUD README).
func _portrait(name: String, card_pos: Vector2, card: String) -> void:
	var tex: Texture2D = load(ART + name + ".png") as Texture2D
	var off: Vector2 = Vector2((_size(card).x / ui_scale - tex.get_width()) * 0.5, 40.0)
	_rect(tex, card_pos + off * ui_scale, ui_scale)


func _size(name: String) -> Vector2:
	var tex: Texture2D = load(ART + name + ".png") as Texture2D
	return Vector2(tex.get_size()) * ui_scale


func _frame(name: String, pos: Vector2) -> void:
	_rect(load(ART + name + ".png") as Texture2D, pos, ui_scale)


func _rect(tex: Texture2D, pos: Vector2, s: float) -> void:
	var r: TextureRect = TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.position = pos
	r.size = Vector2(tex.get_size()) * s
	add_child(r)


## Draws `value` from the numeral strip in the box a Label of font size px_2x * ui_scale would
## take at `pos`: cap top at 0.12 of the size, cap height 0.92 of it (the condensed caps need
## more height than the sans to carry the same weight).
func _digits(value: String, pos: Vector2, px_2x: int) -> void:
	var strip: Texture2D = load(ART + "hud_digits.png") as Texture2D
	var size: float = px_2x * ui_scale
	var s: float = size * 0.92 / DIGIT_CAP
	var top: float = pos.y + size * 0.12 - (DIGIT_CELL.y - DIGIT_CAP) * 0.5 * s
	var x: float = pos.x
	for ch: String in value:
		var adv: float = DIGIT_ADVANCE.get(ch, DIGIT_TABULAR)
		var k: int = DIGIT_GLYPHS.find(ch)
		if k >= 0:
			var glyph: AtlasTexture = AtlasTexture.new()
			glyph.atlas = strip
			glyph.region = Rect2(Vector2(k * DIGIT_CELL.x, 0.0), DIGIT_CELL)
			var r: TextureRect = TextureRect.new()
			r.texture = glyph
			r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			r.position = Vector2(x - (DIGIT_CELL.x - adv) * 0.5 * s, top)
			r.size = DIGIT_CELL * s
			add_child(r)
		x += adv * s

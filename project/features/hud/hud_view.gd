class_name HudView
extends Node2D
## The game's HUD in screen space (under a CanvasLayer), drawn from a HudState the caller fills
## each frame: the beat panel with heat as police pips (cop blue), the cash frame, the weapon on
## the ammo ticket, and the subtitle box. Art comes by id from data/tables/hud_art.json (HudArt);
## numbers are drawn from the hand-inked numeral strip. Soul cards are not drawn while the soul
## trail is descoped (owner verdict 3, 2026-11-03). Reads its state, never writes it.

const TEXT_SIZE: int = 30
const NAME_SIZE: int = 26
const MARGIN: float = 36.0
const INK: Color = Color("17131b")

var state: HudState = HudState.new()
var art: HudArt = null


func _ready() -> void:
	if art == null:
		art = HudArt.new()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if art == null:
		return
	var screen: Vector2 = get_viewport_rect().size
	if state.head != "":
		_top_left()
	_top_right(screen)
	if state.notice != "":
		_notice(screen)
	if state.speaker != "":
		_subtitle(screen, state.speaker, state.words)


## The top of the subtitle box's paper (its tape strip included), in screen px: what a camera
## keeps the player's body above while a line is up.
static func subtitle_top(screen_h: float) -> float:
	return screen_h - MARGIN - 236.0 - 28.0


func _top_left() -> void:
	_panel(Rect2(MARGIN, MARGIN, 640, 96))
	_say(Vector2(MARGIN + 18, MARGIN + 38), state.head, 30)
	_say(Vector2(MARGIN + 18, MARGIN + 80), state.heat_label, 24)
	for i: int in state.heat_max:
		var pip: Rect2 = Rect2(MARGIN + 110 + i * 46, MARGIN + 52, 38, 38)
		var id: StringName = &"wanted_pip_police" if i < state.heat else &"wanted_pip_empty"
		draw_texture_rect(art.texture(id), pip, false)


## The one-line notice: centred just above the subtitle box, clear of the objective prompt.
func _notice(screen: Vector2) -> void:
	var box: Rect2 = Rect2(screen.x * 0.5 - 450.0, screen.y - MARGIN - 236.0 - 84.0, 900, 52)
	_panel(box)
	_say(box.position + Vector2(18, 38), state.notice, 24)


func _top_right(screen: Vector2) -> void:
	var box: Rect2 = Rect2(screen.x - MARGIN - 420, MARGIN - 8, 420, 104)
	draw_texture_rect(art.texture(&"cash_frame"), box, false)
	_ink_digits(box.position + Vector2(112, 50), "$%s" % thousands(state.cash), 32.0)
	if state.weapon == "":
		_say(box.position + Vector2(112, 76), state.unarmed_label, 22)
	else:
		_ammo_ticket(Rect2(screen.x - MARGIN - 260, MARGIN + 104, 260, 124))


## The ammo ticket: the bullet stub left of x 120 (authored px), text from x 135; a count only when
## the weapon has a magazine.
func _ammo_ticket(r: Rect2) -> void:
	draw_texture_rect(art.texture(&"ammo_ticket"), r, false)
	var k: float = r.size.x / art.size_px(&"ammo_ticket").x
	var at: Vector2 = r.position + Vector2(140.0 * k, r.size.y * 0.5)
	_say(at, state.weapon.to_upper(), 20)
	if state.ammo >= 0:
		_ink_digits(at + Vector2(0.0, 40.0), "x%d" % state.ammo, 30.0)


func _subtitle(screen: Vector2, who: String, words: String) -> void:
	var box: Rect2 = Rect2(MARGIN * 4, screen.y - MARGIN - 236, screen.x - MARGIN * 8, 236)
	_panel(box)
	_say(box.position + Vector2(24, 58), who.to_upper(), NAME_SIZE)
	var font: Font = ThemeDB.fallback_font
	var at: Vector2 = box.position + Vector2(24, 100)
	draw_multiline_string(font, at, words, 0, box.size.x - 48, TEXT_SIZE, 4, INK)


func _panel(r: Rect2) -> void:
	# 18 px of extra paper on top: the tape strip sits above the first line of text
	var t: Texture2D = art.texture(art.memo_art)
	_nine(t, r.grow_individual(10.0, 28.0, 10.0, 10.0), art.memo_margin_px, art.memo_scale)


## A 9-slice draw of `t` into `r`: corners kept at `scale`, edges and centre stretched.
func _nine(t: Texture2D, r: Rect2, m: float, scale: float) -> void:
	var ts: Vector2 = Vector2(t.get_size())
	m = minf(m, minf(ts.x, ts.y) * 0.5)
	var sx: PackedFloat32Array = [0.0, m, ts.x - m, ts.x]
	var sy: PackedFloat32Array = [0.0, m, ts.y - m, ts.y]
	var d: float = m * scale
	var dx: PackedFloat32Array = [r.position.x, r.position.x + d, r.end.x - d, r.end.x]
	var dy: PackedFloat32Array = [r.position.y, r.position.y + d, r.end.y - d, r.end.y]
	for j: int in 3:
		for i: int in 3:
			var src: Rect2 = Rect2(sx[i], sy[j], sx[i + 1] - sx[i], sy[j + 1] - sy[j])
			var dst: Rect2 = Rect2(dx[i], dy[j], dx[i + 1] - dx[i], dy[j + 1] - dy[j])
			draw_texture_rect_region(t, dst, src)


func _say(at: Vector2, words: String, size: int) -> void:
	draw_string(ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, size, INK)


## The hand-inked numeral strip on the baseline `at`, cap height 0.92 of `size` (the condensed caps
## need more height than the sans to carry the same weight). Unknown characters advance a space.
func _ink_digits(at: Vector2, value: String, size: float) -> void:
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
		draw_texture_rect_region(strip, Rect2(pos, cell * s), src)
		x += adv * s


## 1500 -> "1,500" (the sign is dropped: the HUD shows cash, never debt).
static func thousands(n: int) -> String:
	var digits: String = str(absi(n))
	var out: String = ""
	for i: int in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += ","
		out += digits[i]
	return out

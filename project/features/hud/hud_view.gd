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
## n8-hud: the weapon icon's box width left of the ammo ticket (screen px at 1080p).
const ICON_W: float = 190.0
## n8-hud: the narrowest notice paper (its tape strip needs the width) and the ticket's name size.
const NOTICE_MIN_W: float = 240.0
const WEAPON_SIZE: int = 24
## n8-hud: the beat panel as wide as its words and its heat pips (BEAT_FIT), at most BEAT_MAX_W;
## false = the fixed 640 px strip. BEAT_PAD: the paper right of the longer of the two.
const BEAT_FIT: bool = true
const BEAT_MAX_W: float = 640.0
const BEAT_PAD: float = 40.0
## n8-hud: the weapon icon's ink drop shadow (screen px at 1080p, its alpha): the bare icon on the
## field reads as a HUD piece lifted off the street, not a floor pickup. ZERO = no shadow.
const ICON_SHADOW: Vector2 = Vector2(5.0, 6.0)
const ICON_SHADOW_A: float = 0.5

var state: HudState = HudState.new()
var art: HudArt = null
## n8-hud: the subtitle box with the speaker's face (its own node: the enter/exit animation).
var dialogue: HudDialogue = HudDialogue.new()
## n8-hud: the top corners as their own canvas items (HudSee turns a covered one see-through).
var _left: HudCorner = HudCorner.new()
var _right: HudCorner = HudCorner.new()


func _ready() -> void:
	if art == null:
		art = HudArt.new()
	dialogue.state = state
	dialogue.art = art
	_left.paint = _top_left
	_right.paint = _top_right
	add_child(_left)
	add_child(_right)
	add_child(dialogue)


## One TICK_DT per drawn frame (a render-only ease, like HudDialogue): never the raw delta.
func _process(_delta: float) -> void:
	_left.fade(state.clear_px, SimClock.TICK_DT)
	_right.fade(state.clear_px, SimClock.TICK_DT)
	queue_redraw()


func _draw() -> void:
	if art == null:
		return
	var screen: Vector2 = get_viewport_rect().size
	if state.notice != "":
		_notice(screen)


## The top of the subtitle box's paper (its tape strip included), in screen px: what a camera
## keeps the player's body above while a line is up.
static func subtitle_top(screen_h: float) -> float:
	return screen_h - MARGIN - 236.0 - 28.0


func _top_left(ci: CanvasItem) -> void:
	_left.rect = Rect2()
	if art == null or state.head == "":
		return
	var beat: Rect2 = Rect2(MARGIN, MARGIN, beat_width(state.head, state.heat_max), 96)
	_panel(ci, beat)
	_left.rect = paper_of(beat)
	_say(ci, Vector2(MARGIN + 18, MARGIN + 38), state.head, 30)
	_say(ci, Vector2(MARGIN + 18, MARGIN + 80), state.heat_label, 24)
	for i: int in state.heat_max:
		var pip: Rect2 = Rect2(MARGIN + 110 + i * 46, MARGIN + 52, 38, 38)
		var id: StringName = &"wanted_pip_police" if i < state.heat else &"wanted_pip_empty"
		ci.draw_texture_rect(art.texture(id), pip, false)


## The beat panel's width: the head's words at 30 px or the heat row (label + pips), whichever
## is longer, plus BEAT_PAD; never wider than BEAT_MAX_W (the fixed strip when not BEAT_FIT).
static func beat_width(head: String, heat_max: int) -> float:
	if not BEAT_FIT:
		return BEAT_MAX_W
	var words: float = (
		ThemeDB.fallback_font.get_string_size(head, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
	)
	var pips: float = 110.0 + maxf(heat_max - 1, 0) * 46.0 + 38.0
	return minf(maxf(18.0 + words, pips) + BEAT_PAD, BEAT_MAX_W)


## The one-line notice: centred just above the subtitle box, clear of the objective prompt; n8-hud:
## as wide as its words (a short "Saved." no longer spans a 900 px strip), at most 900 px.
func _notice(screen: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	var w: float = font.get_string_size(state.notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x + 36.0
	w = clampf(w, NOTICE_MIN_W, 900.0)
	var box: Rect2 = Rect2(screen.x * 0.5 - w * 0.5, screen.y - MARGIN - 236.0 - 84.0, w, 52)
	_panel(self, box)
	_say(self, box.position + Vector2(18, 38), state.notice, 24)


func _top_right(ci: CanvasItem) -> void:
	_right.rect = Rect2()
	if art == null:
		return
	var screen: Vector2 = get_viewport_rect().size
	var sum: String = "$%s" % thousands(state.cash)
	var label: String = state.unarmed_label if state.weapon == "" else ""
	var w: float = HudCash.width(art, sum, label)
	var box: Rect2 = Rect2(screen.x - MARGIN - w, MARGIN - 8, w, 104)
	HudCash.frame(ci, art, box)
	_right.rect = box
	HudCash.ink_digits(ci, art, box.position + Vector2(112, 50), sum, 32.0)
	if state.weapon == "":
		_say(ci, box.position + Vector2(112, 76), state.unarmed_label, 22)
	else:
		var tw: float = HudTicket.width(
			art, HudTicket.words_w(art, state, WEAPON_SIZE), state.weapon_icon
		)
		var ticket: Rect2 = Rect2(screen.x - MARGIN - tw, MARGIN + 104, tw, HudTicket.H)
		_right.rect = box.merge(ticket)
		_ammo_ticket(ci, ticket)


## The ammo ticket: the bullet stub left of x 120 (authored px), text from x 135; a count only when
## the weapon has a magazine. n8-hud: the weapon's icon on the ticket's paper (HudTicket).
func _ammo_ticket(ci: CanvasItem, r: Rect2) -> void:
	HudTicket.frame(ci, art, r)
	var at: Vector2 = r.position + Vector2(HudTicket.text_x(art), r.size.y * 0.5)
	_say(ci, at, state.weapon.to_upper(), WEAPON_SIZE)
	if state.weapon_icon != null and HudTicket.ON_TICKET:
		_icon(ci, state.weapon_icon, HudTicket.icon_rect(r, state.weapon_icon))
	elif state.weapon_icon != null:
		var box: Rect2 = Rect2(r.position.x - ICON_W, r.position.y + 14.0, ICON_W - 8.0, 96.0)
		_icon(ci, state.weapon_icon, box)
	if state.ammo >= 0:
		HudCash.ink_digits(ci, art, at + Vector2(0.0, 40.0), "x%d" % state.ammo, 30.0)


## n8-hud: the weapon's icon left of the ticket, fitted into `box` (aspect kept, right-aligned).
func _icon(ci: CanvasItem, t: Texture2D, box: Rect2) -> void:
	var k: float = minf(box.size.x / t.get_width(), box.size.y / t.get_height())
	var sz: Vector2 = Vector2(t.get_width(), t.get_height()) * k
	var at: Vector2 = Vector2(box.end.x - sz.x, box.position.y + (box.size.y - sz.y) * 0.5)
	if ICON_SHADOW != Vector2.ZERO:
		ci.draw_texture_rect(t, Rect2(at + ICON_SHADOW, sz), false, Color(INK, ICON_SHADOW_A))
	ci.draw_texture_rect(t, Rect2(at, sz), false)


func _panel(ci: CanvasItem, r: Rect2) -> void:
	var t: Texture2D = art.texture(art.memo_art)
	nine(ci, t, paper_of(r), art.memo_margin_px, art.memo_scale)


## The memo paper round the words' rect `r`: 18 px of extra paper on top (the tape strip sits
## above the first line of text).
static func paper_of(r: Rect2) -> Rect2:
	return r.grow_individual(10.0, 28.0, 10.0, 10.0)


## A 9-slice draw of `t` into `r` on `ci`: corners kept at `scale`, edges and centre stretched.
static func nine(
	ci: CanvasItem, t: Texture2D, r: Rect2, m: float, scale: float, tint: Color = Color.WHITE
) -> void:
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
			ci.draw_texture_rect_region(t, dst, src, tint)


func _say(ci: CanvasItem, at: Vector2, words: String, size: int) -> void:
	ci.draw_string(ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, size, INK)


## 1500 -> "1,500" (the sign is dropped: the HUD shows cash, never debt).
static func thousands(n: int) -> String:
	var digits: String = str(absi(n))
	var out: String = ""
	for i: int in digits.length():
		if i > 0 and (digits.length() - i) % 3 == 0:
			out += ","
		out += digits[i]
	return out

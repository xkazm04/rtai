class_name BossTaunt
extends Control
## n8-hud: a boss's taunt as a short paper strip hanging under the boss bar, its tail pointing at
## the crest (the boss's face is already there), instead of the full dialogue box: in a fight the
## box covers the lower third of the field and the ghost-form card. Words only, ink on the box's
## torn memo paper (HudArt's 9-slice, its tape below the bar), at most MAX_LINES lines; it fades
## in and out and never waits on play. Render only: the caller sets
## `words` (already translated; empty = none). No boss line system exists yet: the dev shot
## (dev/showcase/boss_taunt.gd) fills it; the box form stays one value away (FORM).

## The taunt's form: &"strip" (under the boss bar) or &"box" (the quest dialogue box with a face).
const FORM: StringName = &"strip"
const ENTER_S: float = 0.18
const EXIT_S: float = 0.22
## The strip's gap under the bar, its padding, the tail's height (screen px at 1080p).
const GAP: float = 34.0
const PAD: Vector2 = Vector2(16.0, 10.0)
const TAIL_H: float = 32.0
const MAX_LINES: int = 2
## The words' sizes, largest first: the first that fits MAX_LINES is drawn.
const FIT_SIZES: Array[int] = [22, 20, 18]

## The words on the strip; empty fades it out.
var words: String = ""
## The memo paper (HudArt's 9-slice memo frame, the dialogue box's paper); null = flat cream.
var art: HudArt = null
var _shown: String = ""
var _alpha: float = 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if art == null:
		art = HudArt.new()


func _process(_delta: float) -> void:
	step(SimClock.TICK_DT)
	size = get_viewport_rect().size
	queue_redraw()


## Advances the fade by `dt` seconds (one TICK_DT per drawn frame, like BossBar's trail).
func step(dt: float) -> void:
	if words != "":
		if words != _shown:
			_alpha = 0.0 if _shown == "" else _alpha
		_shown = words
		_alpha = minf(_alpha + dt / ENTER_S, 1.0)
	else:
		_alpha = maxf(_alpha - dt / EXIT_S, 0.0)
		if _alpha <= 0.0:
			_shown = ""


func alpha() -> float:
	return _alpha


## The strip's paper rect for a screen of `screen` px: under the bar, as wide as the bar, as tall
## as `lines` lines of `font_size` words.
static func strip_rect(screen: Vector2, lines: int, font_size: int) -> Rect2:
	var w: float = screen.x * BossBar.WIDTH_K
	var top: float = BossBar.TOP + BossBar.BAR_H + GAP
	var h: float = PAD.y * 2.0 + lines * font_size * 1.3
	return Rect2(Vector2((screen.x - w) * 0.5, top), Vector2(w, h))


## The largest of FIT_SIZES whose wrapped words fit MAX_LINES in `width`, and its line count.
static func fit(font: Font, text: String, width: float) -> Vector2i:
	for s: int in FIT_SIZES:
		var n: int = roundi(
			font.get_multiline_string_size(text, 0, width, s).y / font.get_height(s)
		)
		if n <= MAX_LINES:
			return Vector2i(s, maxi(n, 1))
	return Vector2i(FIT_SIZES[-1], MAX_LINES)


func _draw() -> void:
	if _shown == "" or _alpha <= 0.0:
		return
	var font: Font = ThemeDB.fallback_font
	var w: float = size.x * BossBar.WIDTH_K - PAD.x * 2.0
	var f: Vector2i = fit(font, _shown, w)
	var r: Rect2 = strip_rect(size, f.y, f.x)
	var ink: Color = Color(Ink.INK, _alpha)
	var x: float = r.position.x
	var tail: PackedVector2Array = [
		Vector2(x + 10.0, r.position.y + 2.0),
		Vector2(x + 34.0, r.position.y + 2.0),
		Vector2(x - 6.0, r.position.y - TAIL_H),
	]
	draw_colored_polygon(tail, ink)
	var memo: Texture2D = art.texture(art.memo_art) if art != null else null
	if memo != null:
		var paper: Rect2 = r.grow_individual(14.0, 16.0, 14.0, 16.0)
		HudView.nine(self, memo, paper, art.memo_margin_px, art.memo_scale, Color(1, 1, 1, _alpha))
	else:
		draw_rect(r.grow(3.0), ink)
		draw_rect(r, Color(Ink.CREAM, _alpha))
	var tail_in: PackedVector2Array = [tail[0] + Vector2(4, 0), tail[1] - Vector2(4, 0), tail[2]]
	draw_colored_polygon(tail_in, Color(Ink.CREAM, _alpha))
	var at: Vector2 = r.position + Vector2(PAD.x, PAD.y + font.get_ascent(f.x))
	draw_multiline_string(font, at, _shown, 0, w, f.x, MAX_LINES, ink)

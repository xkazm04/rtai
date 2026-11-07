class_name HudDialogue
extends Node2D
## n8-hud: the subtitle box with a face. The speaker's bust (or the payphone of a voice-only
## caller) stands in the box's left end, the name and words to its right. The face rises in when
## a new speaker starts (ENTER_S) and the box fades out when the lines end (EXIT_S); play never
## waits on either (render only, reads the HudState the HUD's caller fills).

const ENTER_S: float = 0.18
const EXIT_S: float = 0.22
## The bust's height and the device's, in screen px at 1080p (the box is 236 tall + its tape).
const FACE_H: float = 252.0
const DEVICE_H: float = 214.0
const RISE_PX: float = 36.0
## The box's left and right inset (screen px): its paper (10 px wider than the box) clears the
## ghost-form card folded beside it while a line is up (GhostFormHud.compact: 36 + 108 + 4 rim =
## 148 px), with a gap. The old inset (MARGIN * 4 = 144) laid the paper over the card's edge.
const SIDE_X: float = 166.0
const BOX_H: float = 236.0
## n8-hud it9: the box fits its line: as tall as the words at their fitting size need, from
## BOX_MIN_H up to BOX_H, so a one-line bark leaves the field open and the bust stands out over
## the paper's top edge. FIT_BOX = false is the fixed BOX_H box of it1-it8, one value away.
const FIT_BOX: bool = true
const BOX_MIN_H: float = 150.0
## The words' top inset (under the name) and their bottom pad, in box px.
const WORDS_TOP: float = 96.0
const WORDS_PAD: float = 20.0
## The height eases between lines at this rate (the whole range in one ENTER_S).
const HEIGHT_RATE: float = (BOX_H - BOX_MIN_H) / ENTER_S
## The words' sizes, largest first: the first whose whole line fits the box is drawn.
const FIT_SIZES: Array[int] = [30, 27, 24, 22, 20]

var state: HudState = null
var art: HudArt = null
var _who: String = ""
var _words: String = ""
var _full: String = ""
var _face: Texture2D = null
var _device: bool = false
var _key: String = ""
var _in_s: float = ENTER_S
var _out_s: float = EXIT_S
var _h: float = BOX_H
var _target_h: float = BOX_H
var _snap: bool = true


func _process(_delta: float) -> void:
	step(SimClock.TICK_DT)
	queue_redraw()


## Advances the enter/exit clocks by `dt` seconds against the state. _process steps one TICK_DT per
## drawn frame (a render-only ease, like BossBar's trail): never the sim, never the raw delta.
func step(dt: float) -> void:
	if state == null:
		return
	if state.speaker != "":
		if state.portrait_key != _key or _out_s >= EXIT_S:
			_in_s = 0.0
		_snap = _snap or _out_s >= EXIT_S
		_key = state.portrait_key
		_who = state.speaker
		_words = state.words
		_full = state.full_words if state.full_words != "" else state.words
		_face = state.portrait
		_device = state.portrait_device
		_out_s = 0.0
		_in_s = minf(_in_s + dt, ENTER_S)
		_h = move_toward(_h, _target_h, dt * HEIGHT_RATE)
	else:
		_out_s = minf(_out_s + dt, EXIT_S)
		if _out_s >= EXIT_S:
			_key = ""


func showing() -> bool:
	return _who != "" and _out_s < EXIT_S


func _draw() -> void:
	if art == null or not showing():
		return
	var screen: Vector2 = get_viewport_rect().size
	var font: Font = ThemeDB.fallback_font
	var text_x: float = _text_x()
	var w: float = screen.x - SIDE_X * 2.0 - text_x - 24.0
	var size: int = fit_size(font, _full, w, BOX_H - WORDS_TOP)
	_target_h = fit_height(font, _full, w, size)
	if _snap:
		_h = _target_h
		_snap = false
	var box: Rect2 = box_of(screen, _h)
	var a: float = 1.0 - _out_s / EXIT_S
	var ink: Color = Color(HudView.INK, a)
	var paper: Rect2 = box.grow_individual(10.0, 28.0, 10.0, 10.0)
	var memo: Texture2D = art.texture(art.memo_art)
	HudView.nine(self, memo, paper, art.memo_margin_px, art.memo_scale, Color(1, 1, 1, a))
	if _face != null:
		_draw_face(box, a)
	var at: Vector2 = box.position + Vector2(text_x, 58)
	draw_string(font, at, _who.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, HudView.NAME_SIZE, ink)
	at = box.position + Vector2(text_x, 92 + size * 0.3)
	draw_multiline_string(font, at, _words, HORIZONTAL_ALIGNMENT_LEFT, w, size, -1, ink)


## The subtitle box (its paper is 10 px wider each side and 28 px taller for the tape strip).
static func box_of(screen: Vector2, height: float = BOX_H) -> Rect2:
	var y: float = screen.y - HudView.MARGIN - height
	return Rect2(SIDE_X, y, screen.x - SIDE_X * 2.0, height)


## The box height `words` wrapped to `width` at `size` need (BOX_H when FIT_BOX is off).
static func fit_height(font: Font, words: String, width: float, size: int) -> float:
	if not FIT_BOX:
		return BOX_H
	var h: float = font.get_multiline_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, width, size).y
	return clampf(WORDS_TOP + h + WORDS_PAD, BOX_MIN_H, BOX_H)


## The largest of FIT_SIZES at which `words` wrapped to `width` is at most `room` px tall.
static func fit_size(font: Font, words: String, width: float, room: float) -> int:
	for size: int in FIT_SIZES:
		var h: float = (
			font.get_multiline_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, width, size).y
		)
		if h <= room:
			return size
	return FIT_SIZES[FIT_SIZES.size() - 1]


## The words' left inset in the box: right of the face (or device) when there is one.
func _text_x() -> float:
	if _face == null:
		return 24.0
	return _face_inset() + _face_size().x + 20.0


func _face_inset() -> float:
	return 34.0 if _device else 6.0


func _face_size() -> Vector2:
	var h: float = DEVICE_H if _device else FACE_H
	return Vector2(_face.get_width(), _face.get_height()) * (h / float(_face.get_height()))


## Draws the face standing on the box's floor at its left end (over the paper's top edge when
## the box is shorter than the face).
func _draw_face(box: Rect2, a: float) -> void:
	var sz: Vector2 = _face_size()
	var t: float = clampf(_in_s / ENTER_S, 0.0, 1.0)
	var ease_t: float = 1.0 - (1.0 - t) * (1.0 - t)
	var x: float = box.position.x + _face_inset()
	var y: float = box.end.y - 4.0 - sz.y + RISE_PX * (1.0 - ease_t)
	draw_texture_rect(_face, Rect2(Vector2(x, y), sz), false, Color(1, 1, 1, a * ease_t))

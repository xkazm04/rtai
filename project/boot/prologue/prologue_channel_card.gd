class_name PrologueChannelCard
extends Node2D
## Screen-space readout of the street encounter. The short radio burst and the end
## slate use the simulation clock, including when a still holds a single tick.

const PAPER: Color = Color("#eee4c9")
const INK: Color = Color("#211e25")
const RULE: Color = Color("#a59d89")
const VEIL: Color = Color("#19161ddc")

var street: PrologueStreet
var lines: PrologueLines
var pad: bool
var tick: int


func _draw() -> void:
	var screen: Vector2 = get_viewport_rect().size
	match street.phase:
		PrologueStreet.Phase.REQUEST, PrologueStreet.Phase.RING:
			_request(screen)
		PrologueStreet.Phase.END:
			_end_card(screen)


func _request(screen: Vector2) -> void:
	var box: Rect2 = Rect2(36.0, 46.0, minf(396.0, screen.x - 72.0), 150.0)
	draw_rect(Rect2(box.position + Vector2(5, 6), box.size), INK.darkened(0.5))
	draw_rect(box, INK)
	draw_rect(box, PAPER, false, 2.0)
	var origin: Vector2 = box.position + Vector2(22, 0)
	var ringing: bool = street.phase == PrologueStreet.Phase.RING
	var label: String = tr("Channel ringing") if ringing else tr("Incoming channel request")
	_words(origin + Vector2(49, 39), label.to_upper(), 17, PAPER)
	_signal(origin + Vector2(12, 30), ringing)
	draw_line(origin + Vector2(0, 55), Vector2(box.end.x - 22, box.position.y + 55), RULE, 1.0)
	_words(origin + Vector2(0, 96), tr("Operation Dethrone"), 31, PAPER)
	if not ringing:
		var accept: String = ObjectiveHint.with_keys(tr("Accept [use]"), pad)
		_words(origin + Vector2(0, 128), accept, 20, PAPER)


func _signal(at: Vector2, ringing: bool) -> void:
	draw_circle(at, 3.0, PAPER)
	var phase: int = (tick - street.accepted_tick) % 18
	for i: int in 3:
		var radius: float = 7.0 + 4.5 * i
		var color: Color = PAPER if not ringing or phase >= i * 5 else RULE.darkened(0.6)
		draw_arc(at, radius, -0.88, 0.88, 16, color, 2.5, true)
		draw_arc(at, radius, PI - 0.88, PI + 0.88, 16, color, 2.5, true)


func _end_card(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), VEIL)
	var w: float = minf(780.0, screen.x * 0.80)
	var box: Rect2 = Rect2(screen * 0.5 - Vector2(w, 250) * 0.5, Vector2(w, 250))
	draw_rect(box, PAPER)
	var left: Vector2 = box.position + Vector2(38, 0)
	var right: Vector2 = Vector2(box.end.x - 38, box.position.y)
	draw_line(left + Vector2.DOWN * 34, right + Vector2.DOWN * 34, INK, 3.0)
	_words(left + Vector2.DOWN * 138, tr("Prologue"), 78, INK)
	draw_line(left + Vector2.DOWN * 166, right + Vector2.DOWN * 166, RULE, 1.5)
	_words(left + Vector2.DOWN * 216, lines.place_name("<location>"), 32, INK)


func _words(at: Vector2, words: String, px: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, color)

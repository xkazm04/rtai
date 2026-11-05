class_name GhostFormHud
extends Control
## The ghost-form HUD widget in screen space (bottom left), D5 style: a paper card with an ink
## rim holding one chip per ghost in the cycle order. The current form's chip is filled soul
## teal and larger; the selected (next) ghost carries an ink chevron and the key hint; a ghost
## on cooldown is swept over in ink (a pie that shrinks as it cools). Under the chips the Madness
## bar, with the selected ghost's cost marked as a notch (a refused activation reads before Q).
## Plain values only (sync() fills them from GhostForms); words come translated by the caller.

const PAPER: Color = Color("e9dcc3")
const INK: Color = Color("17131b")
const TEAL: Color = Color(0.18, 0.77, 0.71)
const CHIP_R: float = 26.0
const GAP: float = 84.0
const MARGIN: float = 36.0
const TEXT_SIZE: int = 18

var order: Array[StringName] = []
## Translated display names by form id (the caller resolves ghost.<id>.name).
var names: Dictionary[StringName, String] = {}
var current: StringName = &"base"
var selected: StringName = &""
## 0..1 cooldown left per form (1 = just started cooling).
var cooling: Dictionary[StringName, float] = {}
var madness_k: float = 0.0
## The selected ghost's Madness cost as a fraction of the meter.
var cost_k: float = 0.0
## 0..1 through a running transformation (the current chip pulses while it plays).
var morph_k: float = 1.0
## The key hint under the selected chip ("Q"); the caller passes the bound key's label.
var key_hint: String = "Q"
## The hint under the chevron in base (Q enters it) and in a form (G switches to it); the caller
## may replace them with the bound keys' glyphs.
var enter_hint: String = "Q"
var next_hint: String = "G"
## true while a story line is up (StoryForms: quest 1's subtitle box takes the bottom centre): the
## card folds to the one chip that matters, the current form (in base the selected ghost).
var compact: bool = false


## Fills the plain values from the state machine (call once per frame).
func sync(g: GhostForms) -> void:
	order = g.table.order
	current = g.current() if g.settled() else g.to_id
	selected = g.selected
	if current != GhostForms.BASE:  # in a form the chevron marks G's switch target
		selected = g.table.next_after(current)
	key_hint = next_hint if current != GhostForms.BASE else enter_hint
	morph_k = g.k()
	madness_k = g.powers.madness / maxf(1.0, g.powers.table.madness_max)
	for id: StringName in order:
		var p: PowerDef = g.powers.table.row(g.table.form(id).power)
		var total: float = float(maxi(1, p.cooldown_ticks)) if p != null else 1.0
		cooling[id] = float(g.powers.cooldown_left(g.table.form(id).power)) / total
	var sel: GhostFormDef = g.table.form(selected)
	var row: PowerDef = g.powers.table.row(sel.power) if sel != null else null
	cost_k = row.madness_cost / g.powers.table.madness_max if row != null else 0.0
	queue_redraw()


func _draw() -> void:
	var screen: Vector2 = get_viewport_rect().size
	var shown: Array[StringName] = shown_chips()
	var w: float = GAP * float(maxi(shown.size(), 1)) + 24.0
	var card: Rect2 = Rect2(Vector2(MARGIN, screen.y - MARGIN - 158.0), Vector2(w, 158.0))
	draw_rect(card.grow(4.0), INK)
	draw_rect(card, PAPER)
	for i: int in shown.size():
		var c: Vector2 = card.position + Vector2(12.0 + GAP * (float(i) + 0.5), 60.0)
		_chip(shown[i], c)
	_madness(Rect2(card.position + Vector2(16.0, 128.0), Vector2(w - 32.0, 14.0)))


## The chips the card draws: every ghost, or folded (compact) the current form or the selected one.
func shown_chips() -> Array[StringName]:
	if not compact or order.is_empty():
		return order
	if current != GhostForms.BASE:
		return [current]
	return [selected if order.has(selected) else order[0]]


func _chip(id: StringName, c: Vector2) -> void:
	var on: bool = id == current
	var r: float = CHIP_R * (1.18 if on else 1.0)
	if on and morph_k < 1.0:
		r *= 1.0 + 0.12 * sin(morph_k * PI)
	draw_circle(c, r + 3.0, INK)
	draw_circle(c, r, TEAL if on else PAPER)
	var cool: float = cooling.get(id, 0.0)
	if cool > 0.0:
		_pie(c, r, cool)
	var label: String = names.get(id, String(id))
	var font: Font = ThemeDB.fallback_font
	var tw: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE).x
	draw_string(
		font,
		c + Vector2(-tw * 0.5, -CHIP_R * 1.18 - 6.0),  # one baseline: the grown chip clips none
		label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		TEXT_SIZE,
		INK
	)
	_glyph(id, c, r * 0.55, PAPER if on else INK)
	if id == selected and not on:
		_chevron(c, r, font)


## The ink chevron and the key hint under the selected (next) ghost.
func _chevron(c: Vector2, r: float, font: Font) -> void:
	var y: float = c.y + r + 8.0
	draw_colored_polygon(
		PackedVector2Array([c + Vector2(-8, r + 4), c + Vector2(8, r + 4), Vector2(c.x, y + 6.0)]),
		INK
	)
	var kw: float = font.get_string_size(key_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE).x
	draw_string(
		font,
		Vector2(c.x - kw * 0.5, y + 24.0),
		key_hint,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		TEXT_SIZE,
		INK
	)


## A pie of ink over the chip: `k` of the circle left to cool.
func _pie(c: Vector2, r: float, k: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([c])
	var steps: int = maxi(2, ceili(24.0 * k))
	for s: int in steps + 1:
		@warning_ignore("return_value_discarded")
		pts.push_back(c + Vector2.from_angle(-PI * 0.5 + TAU * k * float(s) / float(steps)) * r)
	draw_colored_polygon(pts, Color(INK, 0.55))


## Each ghost's mark inside its chip, from the concept's silhouette from above.
func _glyph(id: StringName, c: Vector2, s: float, col: Color) -> void:
	match id:
		&"tonnage":  # the press slab with its four corner feet
			draw_rect(Rect2(c - Vector2(s, s) * 0.6, Vector2(s, s) * 1.2), col)
			for d: Vector2 in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
				draw_circle(c + d * s * 0.85, s * 0.28, col)
		&"dent":  # the crash-test target disc
			draw_arc(c, s * 0.8, 0.0, TAU, 24, col, 3.0)
			draw_circle(c, s * 0.3, col)
		&"kerf":  # the cutting beam's line through the lens
			draw_line(c - Vector2(s, -s), c + Vector2(s, -s), col, 3.0)
			draw_circle(c, s * 0.3, col)
		&"ohm":  # the forked bolt
			var bolt: PackedVector2Array = PackedVector2Array(
				[
					c + Vector2(-s * 0.2, -s),
					c + Vector2(s * 0.3, -s * 0.1),
					c + Vector2(-s * 0.3, s * 0.1),
					c + Vector2(s * 0.2, s)
				]
			)
			draw_polyline(bolt, col, 3.0)


func _madness(bar: Rect2) -> void:
	draw_rect(bar.grow(2.0), INK)
	draw_rect(bar, PAPER)
	draw_rect(
		Rect2(bar.position, Vector2(bar.size.x * clampf(madness_k, 0.0, 1.0), bar.size.y)), INK
	)
	var notch: float = bar.position.x + bar.size.x * clampf(madness_k + cost_k, 0.0, 1.0)
	draw_line(Vector2(notch, bar.position.y - 5.0), Vector2(notch, bar.end.y + 5.0), TEAL, 3.0)

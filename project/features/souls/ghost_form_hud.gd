class_name GhostFormHud
extends Control
## The ghost-form HUD (bottom left): a paper card, one chip per ghost in the cycle order (its face:
## GhostChipFace). The current form's chip is soul teal and larger; the selected (next) ghost has
## an ink chevron and the key hint; a cooling ghost is swept in ink (a shrinking pie). Under the
## chips the Madness bar, the selected ghost's cost a notch. A locked ghost (GhostLocks) shows a
## padlock in a dimmed chip and no name; G passes it by. Plain values only (sync() fills them from
## GhostForms); words come translated by the caller.

const PAPER: Color = Color("e9dcc3")
const INK: Color = Color("17131b")
const TEAL: Color = Color(0.18, 0.77, 0.71)
const CHIP_R: float = 26.0
const GAP: float = 84.0
const MARGIN: float = 36.0
const TEXT_SIZE: int = 18
## n8-hud: the card on the HUD's torn memo paper (HudArt's 9-slice, the dialogue box's paper);
## false = the flat D5 card with its ink rim.
const MEMO: bool = true

var order: Array[StringName] = []
## Translated display names by form id (the caller resolves ghost.<id>.name).
var names: Dictionary[StringName, String] = {}
var current: StringName = &"base"
var selected: StringName = &""
## 0..1 cooldown left per form (1 = just started cooling).
var cooling: Dictionary[StringName, float] = {}
## The ghosts the story has not unlocked yet (true = locked).
var locked: Dictionary[StringName, bool] = {}
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
## The card's sizes: the desktop's full card, or the handheld's compact one (DeviceProfile.hud).
var layout: GhostFormLayout = GhostFormLayout.for_device(DeviceProfile.shared())
## The one chip that carries its name when the layout names only one (the selected ghost).
var _named: StringName = &""


## Fills the plain values from the state machine (call once per frame).
func sync(g: GhostForms) -> void:
	order = g.table.order
	current = g.current() if g.settled() else g.to_id
	selected = g.selected
	if current != GhostForms.BASE:  # in a form the chevron marks G's switch target
		selected = g.locks.next_after(g.table, current)
	key_hint = next_hint if current != GhostForms.BASE else enter_hint
	morph_k = g.k()
	madness_k = g.powers.madness / maxf(1.0, g.powers.table.madness_max)
	for id: StringName in order:
		var p: PowerDef = g.powers.table.row(g.table.form(id).power)
		var total: float = float(maxi(1, p.cooldown_ticks)) if p != null else 1.0
		cooling[id] = float(g.powers.cooldown_left(g.table.form(id).power)) / total
		locked[id] = not g.locks.allows(g.table, id)
	var sel: GhostFormDef = g.table.form(selected)
	var row: PowerDef = g.powers.table.row(sel.power) if sel != null else null
	cost_k = row.madness_cost / g.powers.table.madness_max if row != null else 0.0
	queue_redraw()


func _draw() -> void:
	var screen: Vector2 = get_viewport_rect().size
	var shown: Array[StringName] = shown_chips()
	var l: GhostFormLayout = layout
	_named = named_chip(shown)
	var w: float = l.card_w(shown.size())
	var card: Rect2 = Rect2(Vector2(l.margin, screen.y - l.margin - l.card_h), Vector2(w, l.card_h))
	if MEMO:
		HudPaper.draw(self, paper_of(card))
	else:
		draw_rect(card.grow(4.0), INK)
		draw_rect(card, PAPER)
	for i: int in shown.size():
		var c: Vector2 = card.position + Vector2(12.0 + l.gap * (float(i) + 0.5), l.chip_y)
		_chip(shown[i], c)
	_madness(Rect2(card.position + Vector2(16.0, l.bar_y), Vector2(w - 32.0, l.bar_h)))


## n8-hud: the memo paper round `card`: the tape above the names, the torn hatch outside the words.
static func paper_of(card: Rect2) -> Rect2:
	return card.grow_individual(16.0, 34.0, 10.0, 16.0) if MEMO else card.grow(4.0)


## The chips the card draws: every ghost, or folded (compact) the current form or the selected one.
func shown_chips() -> Array[StringName]:
	if not compact or order.is_empty():
		return order
	if current != GhostForms.BASE:
		return [current]
	return [selected if order.has(selected) else order[0]]


## The chip that carries its name when the layout names one: the selected ghost, else the first.
func named_chip(shown: Array[StringName]) -> StringName:
	if shown.is_empty():
		return &""
	return selected if shown.has(selected) else shown[0]


func _chip(id: StringName, c: Vector2) -> void:
	if locked.get(id, false):
		_locked_chip(c)
		return
	var on: bool = id == current
	var r: float = layout.chip_r * (1.18 if on else 1.0)
	if on and morph_k < 1.0:
		r *= 1.0 + 0.12 * sin(morph_k * PI)
	draw_circle(c, r + 3.0, INK)
	draw_circle(c, r, TEAL if on else PAPER)
	var face: bool = GhostChipFace.draw(self, id, c, r)  # n8-hud: the ghost's face, else the glyph
	var cool: float = cooling.get(id, 0.0)
	if cool > 0.0:
		_pie(c, r, cool)
	var font: Font = ThemeDB.fallback_font
	if layout.all_names or id == _named:
		_name(id, c, font)
	if not face:
		GhostChipGlyph.draw(self, id, c, r * 0.55, PAPER if on else INK)
	if id == selected and not on:
		_chevron(c, r, font)


## The ghost's name above its chip, on one baseline (the grown chip clips none).
func _name(id: StringName, c: Vector2, font: Font) -> void:
	var label: String = names.get(id, String(id))
	var ts: int = layout.text_size
	var tw: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x
	var at: Vector2 = c + Vector2(-tw * 0.5, -layout.chip_r * 1.18 - 6.0)
	draw_string(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, ts, INK)


## A locked ghost: a dimmed chip with an ink padlock (shackle arc over a body), no name.
func _locked_chip(c: Vector2) -> void:
	draw_circle(c, layout.chip_r + 3.0, Color(INK, 0.45))
	draw_circle(c, layout.chip_r, PAPER.darkened(0.18))
	var s: float = layout.chip_r * 0.42
	draw_arc(c + Vector2(0.0, -s * 0.2), s * 0.62, PI, TAU, 12, INK, 3.0)
	draw_rect(Rect2(c + Vector2(-s, -s * 0.2), Vector2(s * 2.0, s * 1.5)), INK)
	draw_circle(c + Vector2(0.0, s * 0.45), s * 0.22, PAPER)


## The ink chevron and the key hint under the selected (next) ghost.
func _chevron(c: Vector2, r: float, font: Font) -> void:
	var y: float = c.y + r + 8.0
	draw_colored_polygon(
		PackedVector2Array([c + Vector2(-8, r + 4), c + Vector2(8, r + 4), Vector2(c.x, y + 6.0)]),
		INK
	)
	var ts: int = layout.text_size
	var kw: float = font.get_string_size(key_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x
	var at: Vector2 = Vector2(c.x - kw * 0.5, y + 6.0 + float(ts))
	draw_string(font, at, key_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, ts, INK)


## A pie of ink over the chip: `k` of the circle left to cool.
func _pie(c: Vector2, r: float, k: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array([c])
	var steps: int = maxi(2, ceili(24.0 * k))
	for s: int in steps + 1:
		@warning_ignore("return_value_discarded")
		pts.push_back(c + Vector2.from_angle(-PI * 0.5 + TAU * k * float(s) / float(steps)) * r)
	draw_colored_polygon(pts, Color(INK, 0.55))


func _madness(bar: Rect2) -> void:
	draw_rect(bar.grow(2.0), INK)
	draw_rect(bar, PAPER)
	draw_rect(
		Rect2(bar.position, Vector2(bar.size.x * clampf(madness_k, 0.0, 1.0), bar.size.y)), INK
	)
	var notch: float = bar.position.x + bar.size.x * clampf(madness_k + cost_k, 0.0, 1.0)
	draw_line(Vector2(notch, bar.position.y - 5.0), Vector2(notch, bar.end.y + 5.0), TEAL, 3.0)

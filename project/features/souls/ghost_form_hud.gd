class_name GhostFormHud
extends Control
## The ghost HUD (bottom left), n11: no card, only the ghosts' avatars docked in the corner, in
## cycle order (GhostChipFace). Ink rims and paper-on-ink marks hold on any ground: the current form
## has a teal rim and stands larger; the selected ghost has a chevron and key hint; a cooling one
## is dimmed with a teal arc; a locked one (GhostLocks) is an ink silhouette under a padlock. Under
## them the Madness bar, the selected ghost's cost a notch. Plain values only (sync() fills them).

const PAPER: Color = Color("e9dcc3")
const INK: Color = Color("17131b")
const TEAL: Color = Color(0.18, 0.77, 0.71)
const CHIP_R: float = 26.0
const GAP: float = 58.0
const MARGIN: float = 18.0
const TEXT_SIZE: int = 18
## The rim round an avatar, px: its ink and, on the current form, the teal outside it.
const RIM_PX: float = 2.0
const CURRENT_RIM_PX: float = 2.5
const COOL_DIM: Color = Color(0.42, 0.42, 0.47, 1.0)
const LOCKED_INK: Color = Color(INK, 0.82)
const TEXT_OUTLINE_PX: int = 5
## The cooldown arc's radius (x the avatar's) and width.
const COOL_ARC_K: float = 1.12
const COOL_ARC_PX: float = 4.0

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
## 0..1 through a running transformation (the current avatar pulses while it plays).
var morph_k: float = 1.0
## The key hint under the selected avatar ("Q"); the caller passes the bound key's label.
var key_hint: String = "Q"
## The hint under the chevron in base (Q enters it) and in a form (G switches to it); the caller
## may replace them with the bound keys' glyphs.
var enter_hint: String = "Q"
var next_hint: String = "G"
## true while a story line is up (StoryForms: quest 1's subtitle box takes the bottom centre): the
## strip folds to the one avatar that matters, the current form (in base the selected ghost).
var compact: bool = false
var layout: GhostFormLayout = GhostFormLayout.for_device(DeviceProfile.shared())
## The one avatar that carries its name when the layout names only one (the selected ghost).
var _named: StringName = &""
var _cursor: WeaponCursor = WeaponCursor.new()


## Fills the plain values from the state machine (once per frame); the cursor follows `weapon`.
func sync(g: GhostForms, weapon: StringName = &"") -> void:
	if PadGlyphArt.active() and enter_hint == "Q":  # n9-handheld: the pad's buttons, once
		enter_hint = PadGlyphArt.action_hint(&"power_hauler", enter_hint)
		next_hint = PadGlyphArt.action_hint(&"power_gearbox", next_hint)
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
	_cursor.show_for(weapon, current)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_EXIT_TREE:
		_cursor.clear()  # the menus keep the system arrow


func _draw() -> void:
	var shown: Array[StringName] = shown_chips()
	var l: GhostFormLayout = layout
	_named = named_chip(shown)
	var w: float = l.card_w(shown.size())
	var top: Vector2 = Vector2(l.margin, get_viewport_rect().size.y - l.margin - l.card_h)
	for i: int in shown.size():
		_chip(shown[i], top + Vector2(l.gap * (float(i) + 0.5), l.chip_y))
	_madness(Rect2(top + Vector2(4.0, l.bar_y), Vector2(w - 12.0, l.bar_h)))


## The avatars the strip draws: every ghost, or folded (compact) the current form or the selected.
func shown_chips() -> Array[StringName]:
	if not compact or order.is_empty():
		return order
	if current != GhostForms.BASE:
		return [current]
	return [selected if order.has(selected) else order[0]]


## The avatar that carries its name when the layout names one: the selected ghost, else the first.
func named_chip(shown: Array[StringName]) -> StringName:
	if shown.is_empty():
		return &""
	return selected if shown.has(selected) else shown[0]


func _chip(id: StringName, c: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	if locked.get(id, false):
		_locked_chip(id, c)
		return
	var on: bool = id == current
	var r: float = layout.chip_r * (1.18 if on else 1.0)
	if on and morph_k < 1.0:
		r *= 1.0 + 0.12 * sin(morph_k * PI)
	var cool: float = cooling.get(id, 0.0)
	GhostChipFace.rim(self, id, c, r, [INK, RIM_PX + (CURRENT_RIM_PX if on else 0.0)])
	if on:
		GhostChipFace.rim(self, id, c, r, [TEAL, CURRENT_RIM_PX])
	var dim: Color = COOL_DIM if cool > 0.0 and not on else Color.WHITE
	if not GhostChipFace.draw(self, id, c, r, dim):
		GhostChipGlyph.draw(self, id, c, r * 0.55, PAPER if on else INK)
	if cool > 0.0:
		_cool_arc(c, r, cool)
	if layout.all_names or id == _named:
		_name(id, c, font)
	if id == selected and not on:
		_chevron(c, r, font)


## The ghost's name above its avatar, ink on a paper outline (the grown avatar clips none).
func _name(id: StringName, c: Vector2, font: Font) -> void:
	var label: String = names.get(id, String(id))
	var ts: int = layout.text_size
	var tw: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x
	_text(font, c + Vector2(-tw * 0.5, -layout.chip_r * 1.18 - 6.0), label)


## Ink on a paper outline: reads on bright ground by the ink and on dark ground by the paper.
func _text(font: Font, at: Vector2, label: String) -> void:
	var ts: int = layout.text_size
	var s: int = TEXT_OUTLINE_PX
	draw_string_outline(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, ts, s, PAPER)
	draw_string(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, ts, INK)


## A locked ghost: an ink silhouette (no spoiler of its colours) under a padlock of paper and ink.
func _locked_chip(id: StringName, c: Vector2) -> void:
	var r: float = layout.chip_r
	if not GhostChipFace.draw(self, id, c, r, LOCKED_INK):
		draw_circle(c, r, LOCKED_INK)
	var s: float = r * 0.42
	var shackle: Vector2 = c + Vector2(0.0, -s * 0.2)
	draw_arc(shackle, s * 0.62, PI, TAU, 12, INK, 6.0)
	draw_arc(shackle, s * 0.62, PI, TAU, 12, PAPER, 3.0)
	var body: Rect2 = Rect2(c + Vector2(-s, -s * 0.2), Vector2(s * 2.0, s * 1.5))
	draw_rect(body.grow(1.5), INK)
	draw_rect(body, PAPER)
	draw_circle(c + Vector2(0.0, s * 0.45), s * 0.22, INK)


## The chevron and the key hint under the selected (next) ghost, paper on an ink edge.
func _chevron(c: Vector2, r: float, font: Font) -> void:
	var y: float = c.y + r + 8.0
	var tip: Vector2 = Vector2(c.x, y + 6.0)
	var a: Vector2 = c + Vector2(-8, r + 4)
	var b: Vector2 = c + Vector2(8, r + 4)
	draw_colored_polygon(PackedVector2Array([a, b, tip]), PAPER)
	draw_polyline(PackedVector2Array([a, b, tip, a]), INK, 2.0, true)
	var ts: int = layout.text_size
	if PadGlyphArt.active():  # n9-handheld: the pad button's drawn glyph
		var gw: float = PadGlyphArt.line_size(key_hint, ts).x
		PadGlyphArt.draw_line(self, Vector2(c.x - gw * 0.5, y + 6.0 + float(ts)), key_hint, ts, INK)
		return
	var kw: float = font.get_string_size(key_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x
	_text(font, Vector2(c.x - kw * 0.5, y + 6.0 + float(ts)), key_hint)


## The time left to cool: a teal arc on an ink arc round the dimmed avatar, `k` of the circle.
func _cool_arc(c: Vector2, r: float, k: float) -> void:
	var a: float = -PI * 0.5
	var at: float = r * COOL_ARC_K
	var steps: int = maxi(4, ceili(32.0 * k))
	draw_arc(c, at, a, a + TAU * k, steps, INK, COOL_ARC_PX + 3.0, true)
	draw_arc(c, at, a, a + TAU * k, steps, TEAL, COOL_ARC_PX, true)


func _madness(bar: Rect2) -> void:
	draw_rect(bar.grow(2.0), INK)
	draw_rect(bar, PAPER)
	draw_rect(
		Rect2(bar.position, Vector2(bar.size.x * clampf(madness_k, 0.0, 1.0), bar.size.y)), INK
	)
	var notch: float = bar.position.x + bar.size.x * clampf(madness_k + cost_k, 0.0, 1.0)
	draw_line(Vector2(notch, bar.position.y - 5.0), Vector2(notch, bar.end.y + 5.0), TEAL, 3.0)

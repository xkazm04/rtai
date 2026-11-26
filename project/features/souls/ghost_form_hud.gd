class_name GhostFormHud
extends Control
## Bottom-left soul strip with a number on each chip and a teal rim on the current form.

const PAPER: Color = Color("e9dcc3")
const INK: Color = Color("17131b")
const TEAL: Color = Color(0.18, 0.77, 0.71)
const CHIP_R: float = 26.0
const GAP: float = 58.0
const MARGIN: float = 18.0
const TEXT_SIZE: int = 18
const RIM_PX: float = 2.0
const CURRENT_RIM_PX: float = 2.5
const COOL_DIM: Color = Color(0.42, 0.42, 0.47, 1.0)
const LOCKED_INK: Color = Color(INK, 0.82)
const TEXT_OUTLINE_PX: int = 5
const COOL_ARC_K: float = 1.12
const COOL_ARC_PX: float = 4.0

var order: Array[StringName] = []
var names: Dictionary[StringName, String] = {}
var current: StringName = &"base"
var selected: StringName = &""
## 0..1 cooldown left per form (1 = just started cooling).
var cooling: Dictionary[StringName, float] = {}
var locked: Dictionary[StringName, bool] = {}
var madness_k: float = 0.0
var cost_k: float = 0.0
var morph_k: float = 1.0
var number_hints: Dictionary[StringName, String] = {}
var key_hint: String
## true while a story line is up (StoryForms: quest 1's subtitle box takes the bottom centre): the
## strip folds to the one avatar that matters, the current form (in base the selected ghost).
var compact: bool = false
## n31 ghost 26: a refused press shakes its chip under a fading amber rim.
var cue: GhostRefusalCue = GhostRefusalCue.new()
var layout: GhostFormLayout = GhostFormLayout.for_device(DeviceProfile.shared())
var _named: StringName = &""
var _cursor: WeaponCursor = WeaponCursor.new()
var _plate: StyleBoxFlat = StyleBoxFlat.new()


func _ready() -> void:
	if layout.gap == GAP:
		layout.gap = 72.0
		layout.all_names = true
	_plate.bg_color = Color(INK, 0.55)
	_plate.set_corner_radius_all(8)


## Fills the plain values from the state machine (once per frame); the cursor follows `weapon`.
func sync(g: GhostForms, weapon: StringName = &"", pilot: GhostPilot = null) -> void:
	order.assign(g.table.deploy_slots)
	current = g.current() if g.settled() else g.to_id
	selected = g.selected
	key_hint = GhostHudHints.binding(&"ghost_deploy") if current == GhostForms.BASE else ""
	morph_k = g.k()
	madness_k = g.powers.madness / maxf(1.0, g.powers.table.madness_max)
	for id: StringName in order:
		number_hints[id] = GhostNumberKeys.hint(g.table, id)
		var p: PowerDef = g.powers.table.row(g.table.form(id).power)
		var total: float = float(maxi(1, p.cooldown_ticks)) if p != null else 1.0
		cooling[id] = float(g.powers.cooldown_left(g.table.form(id).power)) / total
		if pilot != null and not pilot.transform_unlocked and current == GhostForms.BASE:
			var deploy_row: GhostAttacks.DeployRow = pilot.deploy.strike.attacks.deploy.get(id)
			if deploy_row != null:
				var left: int = pilot.deploy.cooldowns.get(id, 0)
				cooling[id] = float(left) / maxi(1, deploy_row.cooldown_ticks)
		locked[id] = not g.locks.allows(g.table, id)
	var sel: GhostFormDef = g.table.form(selected)
	var row: PowerDef = g.powers.table.row(sel.power) if sel != null else null
	cost_k = row.madness_cost / g.powers.table.madness_max if row != null else 0.0
	cue.sync(pilot.deploy if pilot != null else null)
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
	draw_style_box(_plate, Rect2(top, Vector2(w, l.card_h)).grow(GhostChipNumber.STRIP_GROW))
	for i: int in shown.size():
		var c: Vector2 = l.chip_center(get_viewport_rect().size.y, i)
		_chip(shown[i], c)
		var label: String = number_hints.get(shown[i], "")
		_number(GhostChipNumber.anchor(l, get_viewport_rect().size.y, i, label), label)
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


func _chip(id: StringName, at: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	var c: Vector2 = at + cue.offset(id)
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
	if cue.active(id):
		GhostChipFace.rim(self, id, c, r, [cue.rim(id), GhostRefusalCue.RIM_PX])
	var dim: Color = COOL_DIM if cool > 0.0 and not on else Color.WHITE
	if not GhostChipFace.draw(self, id, c, r, dim):
		GhostChipGlyph.draw(self, id, c, r * 0.55, PAPER if on else INK)
	if cool > 0.0:
		_cool_arc(c, r, cool, cue.arc(id, TEAL))
	if layout.all_names or id == _named:
		_name(id, c, font)
	if id == selected and key_hint != "":
		GhostHudHints.label(self, c + Vector2(0.0, r + 8.0), key_hint)


## The ghost's name above its avatar, ink on a paper outline (the grown avatar clips none).
func _name(id: StringName, c: Vector2, font: Font) -> void:
	var label: String = names.get(id, String(id))
	var ts: int = layout.text_size
	var tw: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x
	_text(font, c + Vector2(-tw * 0.5, -layout.chip_r * 1.18 - 6.0), label)


## The chip's key number: large paper digit on an ink plate (GhostChipNumber).
func _number(at: Vector2, label: String) -> void:
	GhostChipNumber.draw(self, at, label, layout.number_size)


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


## The time left to cool: a teal arc on an ink arc round the dimmed avatar, `k` of the circle.
func _cool_arc(c: Vector2, r: float, k: float, ink: Color) -> void:
	var a: float = -PI * 0.5
	var at: float = r * COOL_ARC_K
	var steps: int = maxi(4, ceili(32.0 * k))
	draw_arc(c, at, a, a + TAU * k, steps, INK, COOL_ARC_PX + 3.0, true)
	draw_arc(c, at, a, a + TAU * k, steps, ink, COOL_ARC_PX, true)


func _madness(bar: Rect2) -> void:
	draw_rect(bar.grow(2.0), INK)
	draw_rect(bar, PAPER)
	draw_rect(
		Rect2(bar.position, Vector2(bar.size.x * clampf(madness_k, 0.0, 1.0), bar.size.y)), INK
	)
	var notch: float = bar.position.x + bar.size.x * clampf(madness_k + cost_k, 0.0, 1.0)
	draw_line(Vector2(notch, bar.position.y - 5.0), Vector2(notch, bar.end.y + 5.0), TEAL, 3.0)

class_name Quest1Card
extends CanvasLayer
## The slice's three cards on cream paper in ink: the title (start, quit, the controls), pause
## (resume, quit) and paid (the payout, quit). Built in code; every word through QuestText
## (tr() with the English fallback, LOC-01). Vermilion only on the objective-like headline.

signal start_pressed
signal resume_pressed
signal continue_pressed
signal quit_pressed

const CONTROLS: String = (
	"WASD / arrows move    mouse aims    left click fires\n"
	+ "Space / right click: electroshock    E: use (phones, hiding, allies, torch)\n"
	+ "F: car (soon)    Esc: pause    Gamepad: sticks, RT fire, A use, X shock"
)
## d9-handheld: the controls on a handheld tier, pad first ([action] -> the pad's own button).
const CONTROLS_PAD: String = (
	"[move] move    [aim] aims    [fire] fires\n"
	+ "[melee]: electroshock    [use]: use (phones, hiding, allies, torch)    [pause]: pause"
)
## d9-handheld: the focus mark on a handheld tier (a 7-inch panel at arm's length).
const FOCUS_BORDER: int = 4

var start_button: Button = null
## d9-handheld: the pause card is up (B on a pad resumes, the handheld convention).
var pause_up: bool = false
var _panel: PanelContainer = PanelContainer.new()
var _box: VBoxContainer = VBoxContainer.new()
var _text: QuestText = QuestText.new()


func _enter_tree() -> void:
	build()


## Builds the panel once (also called by the first show_*, before the card enters a tree).
func build() -> void:
	if _panel.get_parent() != null:
		return
	layer = 50
	var shade: StyleBoxFlat = StyleBoxFlat.new()
	shade.bg_color = Color(Ink.CREAM, 0.94)
	shade.border_color = Ink.INK
	shade.set_border_width_all(4)
	shade.set_content_margin_all(36)
	_panel.add_theme_stylebox_override(&"panel", shade)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_box.add_theme_constant_override(&"separation", 14)
	_panel.add_child(_box)
	add_child(_panel)


## The title; `can_continue` adds Continue (the last beat checkpoint) above Start.
func show_title(can_continue: bool = false) -> void:
	build()
	_clear()
	_label(_t(&"SLICE__TITLE", "RTAI: Uprising"), 56, Ink.INK)
	_label(_t(&"SLICE__QUEST_1", "Quest 1: Collect Call"), 34, Ink.VERMILION)
	_controls_line()
	var first: Button = null
	if can_continue:
		first = _button(_t(&"SLICE__CONTINUE", "Continue"), continue_pressed)
	start_button = _button(_t(&"SLICE__START", "Start"), start_pressed)
	@warning_ignore("return_value_discarded")
	_button(_t(&"SLICE__QUIT", "Quit"), quit_pressed)
	(first if first != null else start_button).grab_focus.call_deferred()
	if LaunchArgs.has("--autostart") and OS.is_debug_build():  # n8-hud: film the opening
		start_pressed.emit.call_deferred()


## Pause: the controls, then the settings panel (volume, reduced motion, rebinding) if given.
func show_pause(settings_panel: Control = null) -> void:
	_clear()
	pause_up = true
	_label(_t(&"SLICE__PAUSED", "Paused"), 48, Ink.INK)
	_controls_line()
	if settings_panel != null:
		_box.add_child(settings_panel)
	var resume: Button = _button(_t(&"SLICE__RESUME", "Resume"), resume_pressed)
	@warning_ignore("return_value_discarded")
	_button(_t(&"SLICE__QUIT", "Quit"), quit_pressed)
	resume.grab_focus.call_deferred()


func show_paid(cash: int) -> void:
	_clear()
	_label(_t(&"SLICE__PAID", "Paid."), 56, Ink.INK)
	_label(_t(&"SLICE__PAYOUT", "+$%d. Patch keeps the line open.") % cash, 28, Ink.INK)
	var quit: Button = _button(_t(&"SLICE__QUIT", "Quit"), quit_pressed)
	quit.grab_focus.call_deferred()


## The contract failed: retry from the last beat checkpoint (when there is one) or quit.
func show_failed(can_continue: bool) -> void:
	_clear()
	_label(_t(&"SLICE__FAILED", "The line went dead."), 48, Ink.INK)
	var first: Button = null
	if can_continue:
		first = _button(_t(&"SLICE__RETRY", "Retry from the last checkpoint"), continue_pressed)
	var quit: Button = _button(_t(&"SLICE__QUIT", "Quit"), quit_pressed)
	(first if first != null else quit).grab_focus.call_deferred()


func hide_all() -> void:
	_panel.visible = false
	pause_up = false


## B (ui_cancel on a pad) on the pause card resumes. Pad events only: the keyboard's Esc is
## both ui_cancel and the game's pause toggle, which already resumes.
func _unhandled_input(event: InputEvent) -> void:
	if pause_up and event is InputEventJoypadButton and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		resume_pressed.emit()


func _clear() -> void:
	_panel.visible = true
	pause_up = false
	for c: Node in _box.get_children():
		c.queue_free()
		_box.remove_child(c)


func _label(text: String, size: int, color: Color) -> void:
	var l: Label = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", color)
	_box.add_child(l)


## The controls line; on a handheld row the pad names are the drawn ink glyphs (PadGlyphArt).
func _controls_line() -> void:
	if not PadGlyphArt.active():
		_label(controls_text(), 20, Ink.INK)
		return
	var r: RichTextLabel = RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.add_theme_font_size_override(&"normal_font_size", 20)
	r.add_theme_color_override(&"default_color", Ink.INK)
	r.text = "[center]%s[/center]" % PadGlyphArt.bbcode(controls_text(), 30)
	_box.add_child(r)


func _button(text: String, pressed: Signal) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.add_theme_font_size_override(&"font_size", 28)
	mark_focus(b)
	@warning_ignore("return_value_discarded")
	b.pressed.connect(func() -> void: pressed.emit())
	_box.add_child(b)
	return b


## The controls line: pad first on a handheld tier, the shipped keyboard line elsewhere.
func controls_text() -> String:
	if DeviceProfile.shared().is_handheld():
		return ObjectiveHint.with_keys(_t(&"SLICE__CONTROLS_PAD", CONTROLS_PAD), true)
	if PadGlyphArt.active():  # n9-handheld: the keyboard glyphs (a glyphs: kb study row)
		return ObjectiveHint.with_keys(_t(&"SLICE__CONTROLS_PAD", CONTROLS_PAD), false)
	return _t(&"SLICE__CONTROLS", CONTROLS)


## On a handheld tier the focused button gets a thick ink border (the default mark is a faint
## outline a pad player cannot find on a 7-inch panel); unchanged elsewhere.
static func mark_focus(b: Button) -> void:
	if not DeviceProfile.shared().is_handheld():
		return
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.draw_center = false
	sb.border_color = Ink.INK
	sb.set_border_width_all(FOCUS_BORDER)
	sb.set_expand_margin_all(FOCUS_BORDER)
	b.add_theme_stylebox_override(&"focus", sb)


func _t(key: StringName, source: String) -> String:
	return _text.resolve(key, source)

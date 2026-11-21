class_name GauntletPickView
extends ColorRect
## Modal between-wave selection. Commit on release so a held slot key cannot switch the grant.

var waves: GauntletWaves
var run: GauntletRun
var _cards: HBoxContainer = HBoxContainer.new()
var _caption: Label = Label.new()
var _art: HudArt = HudArt.new()
var _feed: HudFeed = HudFeed.new()
var _pressed_slot: int = -1


func _ready() -> void:
	TranslationServer.add_translation(GauntletHud.ENGLISH)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color(0.075, 0.065, 0.085, 0.73)
	var center: CenterContainer = CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override(&"separation", 12)
	center.add_child(stack)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_color_override(&"font_color", GauntletHud.PAPER)
	_caption.add_theme_font_size_override(&"font_size", 18)
	stack.add_child(_caption)
	var heading: Label = Label.new()
	heading.text = tr("GAUNTLET__CHOOSE")
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override(&"font_size", 38)
	heading.add_theme_color_override(&"font_color", GauntletHud.PAPER)
	stack.add_child(heading)
	_cards.add_theme_constant_override(&"separation", 14)
	_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_child(_cards)
	@warning_ignore("return_value_discarded")
	waves.pick_offered.connect(_present)
	hide()


func _present(ids: Array[StringName]) -> void:
	for child: Node in _cards.get_children():
		_cards.remove_child(child)
		child.queue_free()
	_pressed_slot = -1
	_caption.text = tr("GAUNTLET__CLEARED").format({"wave": run.wave})
	for index: int in ids.size():
		var card: GauntletPickCard = GauntletPickCard.new()
		card.art = _art
		card.feed = _feed
		card.row = waves.draw.rows[ids[index]]
		card.number = index + 1
		_cards.add_child(card)
		@warning_ignore("return_value_discarded")
		card.pressed.connect(_choose.bind(index))
	show()
	(_cards.get_child(0) as Button).grab_focus()


func _choose(index: int) -> void:
	if waves.choose(index):
		hide()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	for i: int in _cards.get_child_count():
		var action: StringName = RivetCarry.SLOT_ACTIONS[i]
		if event.is_action_pressed(action):
			_pressed_slot = i
		elif event.is_action_released(action) and _pressed_slot == i:
			_choose(i)
		else:
			continue
		get_viewport().set_input_as_handled()
		return

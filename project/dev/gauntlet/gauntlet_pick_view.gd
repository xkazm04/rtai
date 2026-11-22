class_name GauntletPickView
extends ColorRect
## Modal between-wave selection. Commit on release so a held slot key cannot switch the grant.

var waves: GauntletWaves
var pilot: GauntletPilot
var _frames: int
var _choice: int
var _cards: HBoxContainer
var _caption: Label
var _art: HudArt = HudArt.new()
var _feed: HudFeed = HudFeed.new()
var _pressed_slot: int = -1


func _ready() -> void:
	TranslationServer.add_translation(GauntletHud.ENGLISH)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color(0.075, 0.065, 0.085, 0.73)
	var center: Control = preload("gauntlet_offers_layout.tscn").instantiate() as Control
	add_child(center)
	_cards = center.get_node(^"Stack/Cards") as HBoxContainer
	_caption = center.get_node(^"Stack/Caption") as Label
	@warning_ignore("return_value_discarded")
	waves.pick_offered.connect(_present)
	hide()


func _present(ids: Array[StringName]) -> void:
	for child: Node in _cards.get_children():
		_cards.remove_child(child)
		child.queue_free()
	_frames = 0
	_pressed_slot = -1
	_caption.text = tr("GAUNTLET__CLEARED").format({"wave": waves.pick_wave()})
	for index: int in ids.size():
		var card: GauntletPickCard = GauntletPickCard.new()
		card.art = _art
		card.feed = _feed
		card.row = waves.draw.rows[ids[index]]
		card.number = index + 1
		_cards.add_child(card)
		if pilot == null:
			@warning_ignore("return_value_discarded")
			card.pressed.connect(_choose.bind(index))
		else:
			card.focus_mode = Control.FOCUS_NONE
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	show()
	if pilot == null:
		(_cards.get_child(0) as Button).grab_focus()


func advance() -> void:
	_frames += 1
	if _frames == 90:
		_choice = pilot.pick(waves.pending)
		for i: int in _cards.get_child_count():
			(_cards.get_child(i) as Button).modulate.a = 1.0 if i == _choice else 0.48
	elif _frames == 120:
		_choose(_choice)


func _choose(index: int) -> void:
	if waves.choose(index) and waves.pending.is_empty():
		hide()


func _input(event: InputEvent) -> void:
	if pilot != null or not is_visible_in_tree():
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

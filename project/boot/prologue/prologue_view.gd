class_name PrologueView
extends CollectCallView

var encounter: PrologueEncounter
var live: LiveInput
var _lesson: HudCorner = HudCorner.new()
var _lesson_text: String
var _text: QuestText = QuestText.new()
var _bell: ProloguePhoneRing = ProloguePhoneRing.new()
var _channel: PrologueChannelCard = PrologueChannelCard.new()


func _ready() -> void:
	super._ready()
	_bell.visible = false
	_bell.position = _stage.layout.phones[encounter.street.phone] * SimConst.PX_PER_M
	print_stage.markers.add_child(_bell)
	_channel.street = encounter.street
	_channel.lines = encounter.lines
	hud_view.add_child(_channel)
	_lesson.paint = _paint_lesson
	hud_view.add_child(_lesson)


func _process(_dt: float) -> void:
	# The gate is south of Rivet. Reserve the subtitle's part of the view for the ground
	# behind the arriving patrol. Release the lean over half a second as the fight begins.
	var weight: float = 1.0
	if encounter.dale_died >= 0:
		weight = clampf(1.0 - float(_stage.tick - encounter.dale_died) / 30.0, 0.0, 1.0)
	var k: float = px_per_m * ViewMode.shared().ground_k()
	var lean_m: float = get_viewport_rect().size.y * 0.18 / k
	focus = _stage.arena.rivet.pos + Vector2.DOWN * lean_m * weight
	if encounter.phase == PrologueEncounter.Phase.BEAT_TWO:
		focus = _battle_focus(k, lean_m)
	super._process(SimClock.TICK_DT)
	_lesson_text = _hint()
	_lesson.queue_redraw()
	_bell.visible = (
		encounter.phase == PrologueEncounter.Phase.STREET
		and _stage.router.ringing(encounter.street.phone)
	)
	if _bell.visible:
		_bell.tick = _stage.tick
		_bell.queue_redraw()
	if encounter.phase == PrologueEncounter.Phase.STREET:
		_channel.tick = _stage.tick
		_channel.pad = live.pad_last
		_channel.queue_redraw()


func _battle_focus(k: float, lean_m: float) -> Vector2:
	var player: Vector2 = _stage.arena.rivet.pos
	var commander: Vector2 = encounter.battle.formation.boss.pos
	var at: Vector2 = player.lerp(commander, 0.5) + Vector2.DOWN * lean_m * 0.75
	at.y = maxf(at.y, minf(commander.y, player.y + lean_m * 2.15))
	var screen: Vector2 = get_viewport_rect().size
	# Allow for the overhead order mark as well as the paper below the boss bar.
	var top: float = BossBar.TOP + BossBar.BAR_H + BossBar.PAPER_GROW.z + 3.0 * px_per_m
	var bottom: float = screen.y - px_per_m
	if encounter.lines.busy() or hud_view.dialogue.showing():
		bottom = HudDialogue.box_of(screen).position.y - 28.0 - px_per_m
	var above: float = (screen.y * 0.5 - top) / k
	var below: float = (bottom - screen.y * 0.5) / k
	at.y = clampf(at.y, commander.y - below, commander.y + above)
	at.y = clampf(at.y, player.y - below, player.y + above)
	return at


func _paint_lesson(card: HudCorner) -> void:
	if _lesson_text.is_empty():
		return
	var font: Font = ThemeDB.fallback_font
	var size_px: int = 21
	var max_width: float = get_viewport_rect().size.x * 0.32
	var text_size: Vector2 = font.get_multiline_string_size(
		_lesson_text, HORIZONTAL_ALIGNMENT_LEFT, max_width - 36, size_px
	)
	var box: Rect2 = Rect2(
		Vector2(36, 135), Vector2(minf(max_width, text_size.x + 36), text_size.y + 22)
	)
	var art: HudArt = hud_view.art
	HudView.nine(
		card, art.texture(art.memo_art), HudView.paper_of(box), art.memo_margin_px, art.memo_scale
	)
	card.draw_multiline_string(
		font,
		box.position + Vector2(18, 11 + font.get_ascent(size_px)),
		_lesson_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		box.size.x - 36,
		size_px,
		-1,
		HudView.INK
	)


func _hint() -> String:
	if encounter.phase == PrologueEncounter.Phase.STREET:
		return _street_hint()
	var hint: String = encounter.prompts.words(live.pad_last)
	if hint != "":
		return hint
	var talk: bool = encounter.phase == PrologueEncounter.Phase.TALK
	if encounter.phase == PrologueEncounter.Phase.BEAT_TWO:
		var battle: PrologueBattle = encounter.battle
		talk = not battle.ranged and battle.due_tick < 0
		if battle.ranged:
			return _objective(battle.formation)
	if talk and encounter.lines.current != "":
		return ObjectiveHint.with_keys(
			_text.resolve(&"PROLOGUE__SKIP", "Skip line [use]"), live.pad_last
		)
	return ""


func _street_hint() -> String:
	match encounter.street.phase:
		PrologueStreet.Phase.OUT:
			return tr("Leave through the gate")
		PrologueStreet.Phase.PHONE:
			return ObjectiveHint.with_keys(tr("Answer the payphone [use]"), live.pad_last)
	if encounter.lines.current != "":
		return ObjectiveHint.with_keys(tr("Skip line [use]"), live.pad_last)
	return ""


func _objective(line: PrologueFormation) -> String:
	var order: String = encounter.battle.command_hint()
	if order != "":
		return order
	if not _stage.pilot.carry.ground.items.is_empty():
		return _text.resolve(&"PROLOGUE__PICK_UP", "Pick up the marked pistol")
	if line.boss.hp <= line.last_stand_hp and line.men_standing():
		return _text.resolve(&"PROLOGUE__SQUAD", "Clear Mulroney's squad")
	if line.boss.exposed:
		return _text.resolve(&"PROLOGUE__EXPOSED", "Mulroney is exposed")
	return _text.resolve(&"PROLOGUE__SHIELDS", "Break the shield line")


func rivet_screen() -> Vector2:
	return get_viewport().get_canvas_transform() * (_stage.arena.rivet.pos * SimConst.PX_PER_M)

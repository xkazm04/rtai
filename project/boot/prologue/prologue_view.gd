class_name PrologueView
extends CollectCallView

var encounter: PrologueEncounter
var live: LiveInput
var _text: QuestText = QuestText.new()
var _channel: PrologueChannelCard = PrologueChannelCard.new()


func _ready() -> void:
	super._ready()
	_channel.street = encounter.street
	_channel.lines = encounter.lines
	hud_view.add_child(_channel)


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
		var commander: Vector2 = encounter.battle.formation.boss.pos
		var player: Vector2 = _stage.arena.rivet.pos
		focus = player.lerp(commander, 0.5) + Vector2.DOWN * lean_m * 0.75
		# Leave the lower subtitle strip clear of the rear rank, with Rivet in the upper frame.
		focus.y = maxf(focus.y, minf(commander.y, player.y + lean_m * 2.15))
	super._process(SimClock.TICK_DT)
	hud_view.state.notice = _hint()
	if encounter.phase == PrologueEncounter.Phase.STREET:
		_channel.tick = _stage.tick
		_channel.pad = live.pad_last
		_channel.queue_redraw()


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

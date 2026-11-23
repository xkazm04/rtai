class_name PrologueMenuDrive
extends RefCounted
## The film and scenario press the same title button and step the real worlds.
## Timestamps are zero-based simulation ticks across both chapters.

const BUDGET: int = 300 * SimClock.TICK_RATE
const FIRST_LINE: String = "rivet-line-stopped"


## The standalone pilot sets a waypoint while Dale speaks. Express that one movement
## through the bound axes as well so the saved input tape can reproduce the approach.
class MenuPilot:
	extends "res://dev/bots/prologue_bot.gd"

	func sample(tick: int) -> TickInput:
		var input: TickInput = super.sample(tick)
		if _stage.intent.move_to.is_finite():
			var walk: Vector2 = _stage.arena.rivet.pos.direction_to(_stage.intent.move_to)
			_stage.intent.move_to = Vector2.INF
			input.move_x = roundi(walk.x * TickInput.AXIS_MAX)
			input.move_y = roundi(walk.y * TickInput.AXIS_MAX)
		return input


var start_tick: int = -1
var end_tick: int = -1
var handover_tick: int = -1
var first_line_tick: int = -1
var _game: Quest1Game
var _chapter: PrologueGame


func press(game: Quest1Game) -> String:
	_game = game
	if not game.card._panel.visible or game.session != null:
		return "Start requires the title card"
	start_tick = 0
	game.card.start_button.pressed.emit()
	_chapter = game.new_game_path.prologue
	if _chapter == null or game.session != null or game.card._panel.visible:
		return "Start did not replace the title with the prologue"
	_chapter.world.set_process(false)
	var pilot: MenuPilot = MenuPilot.new(_chapter.stage, _chapter.encounter)
	if _chapter.checkpoints != null:
		_chapter.checkpoints.tape.live = pilot
	else:
		_chapter.world.loop().set_input(pilot)
	@warning_ignore("return_value_discarded")
	_chapter.encounter.end_card_reached.connect(_end_card)
	@warning_ignore("return_value_discarded")
	game.started.connect(_quest_opened, CONNECT_ONE_SHOT)
	return ""


func _end_card() -> void:
	end_tick = _chapter.stage.tick


func _quest_opened() -> void:
	handover_tick = _chapter.stage.tick
	_game.session.world.set_process(false)


func step() -> String:
	if _game.card._panel.visible:
		return "the title returned during the handover"
	if _game.session == null:
		if _chapter.world.context().clock.tick() >= BUDGET:
			return "prologue pilot timed out in phase %s" % _chapter.encounter.phase
		_chapter.world.loop().step()
		return ""
	return _opening()


func _opening() -> String:
	if end_tick < 0 or handover_tick != end_tick + PrologueStreet.END_TICKS:
		return "quest 1 opened outside the end card hold"
	if _game.new_game_path.prologue != null:
		return "quest 1 still has a playing prologue"
	var session: Quest1Session = _game.session
	session.step()
	var lines: QuestLinePlayer = session.system.runner.lines
	if lines.current == null or lines.current.id != FIRST_LINE or lines.shown.is_empty():
		return "quest 1 missed its opening subtitle"
	var subtitle: PackedStringArray = lines.subtitle(QuestText.new())
	if not subtitle[1].is_empty():
		first_line_tick = handover_tick + 1 + lines.shown[0].tick
	elif session.tick() > SimClock.TICK_RATE:
		return "quest 1 opened but its first subtitle stayed blank"
	return ""


func result() -> Dictionary:
	return {
		"schema": "gtai.prologue-handover/1",
		"start_tick": start_tick,
		"prologue_end_card_tick": end_tick,
		"handover_tick": handover_tick,
		"quest1_first_line_tick": first_line_tick,
		"quest1_first_line": FIRST_LINE,
		"seconds": (first_line_tick - start_tick) / float(SimClock.TICK_RATE),
	}

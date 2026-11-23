class_name NewGamePath
extends RefCounted
## The main menu owns the campaign. Embedded quest films, benchmarks and tapes keep
## their quest-only Start button. An embedding host can opt into the campaign menu.

const PROLOGUE: PackedScene = preload("res://boot/prologue/prologue.tscn")

var campaign_menu: bool = false
var prologue: PrologueGame


func press_start(game: Quest1Game) -> void:
	if prologue != null or game.session != null:
		return
	var main_menu: bool = game.is_inside_tree() and game.get_tree().current_scene == game
	var quest_film: bool = OS.is_debug_build() and LaunchArgs.has("--autostart")
	if (campaign_menu or main_menu) and not quest_film and not LaunchArgs.has("--skip-prologue"):
		open_prologue(game)
	else:
		game.start()


## SaveLoader tries each slot with its own reader, even when meta.json belongs to a bad slot.
func accept(body: Dictionary) -> Variant:
	if body.get("quest") != PrologueAutosave.QUEST:
		return Quest1Autosave.accept(Events, Data).call(body)
	var cp: Checkpoint = CheckpointSlot.read(body)
	if cp == null:
		return null
	var candidate: PrologueGame = _chapter()
	candidate.boot(str(cp.master_seed))
	_bind_saver(candidate)
	if candidate.checkpoints.restore(cp):
		return candidate
	candidate.release()
	candidate.free()
	return null


func resume(game: Quest1Game, loaded: Variant) -> void:
	if loaded is PrologueGame:
		var chapter: PrologueGame = loaded
		open_prologue(game, chapter)
	elif loaded is Quest1Session:
		var session: Quest1Session = loaded
		game._begin(session)
	else:
		game.start()


func _chapter() -> PrologueGame:
	var chapter: PrologueGame = PROLOGUE.instantiate() as PrologueGame
	chapter.embedded = true
	return chapter


func _bind_saver(chapter: PrologueGame) -> void:
	chapter.checkpoints = PrologueAutosave.new(chapter)
	chapter.world.add_system(chapter.checkpoints)


func open_prologue(game: Quest1Game, restored: PrologueGame = null) -> void:
	var saving: bool = game.save_path != ""
	prologue = restored if restored != null else _chapter()
	game.card.hide_all()
	game.add_child(prologue)
	prologue.boot()
	if prologue.encounter == null:
		return
	if saving and restored == null:
		_bind_saver(prologue)
	if prologue.checkpoints != null:
		prologue.checkpoints.writing = saving
	if saving and restored == null:
		prologue.world.loop().step()  # Make the opening resumable before the first frame.
	@warning_ignore("return_value_discarded")
	prologue.encounter.finished.connect(_handover.bind(game), CONNECT_ONE_SHOT)


func _handover(game: Quest1Game) -> void:
	prologue.queue_free()
	prologue = null
	game.start()
	if game.save_path != "" and game.session != null:
		game.session.step()
		@warning_ignore("return_value_discarded")
		game.session.autosave.save_now("prologue-handover")

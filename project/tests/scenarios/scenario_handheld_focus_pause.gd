extends Scenario
## d9-handheld: the focus-out pause, live. Quest 1 runs (the Start button, a few ticks walked), then
## the OS's NOTIFICATION_APPLICATION_FOCUS_OUT reaches every node (the Steam overlay, a Windows
## handheld's shell, alt-tab) and a handheld run (a HandheldFocusPause in the tree, as LaunchArgs
## adds it under `--device=deck`) is paused: the world stops, the pad is off, the pause card is up.
## TST-05: the desktop run (no HandheldFocusPause) must stay live after the same notification.
## (At exit the engine logs one grab_focus outside the tree: the start card's deferred focus, whose
## button the pause card removed in the same synchronous step; a played frame flushes it first.)

const WALK_TICKS: int = 30


func run(tree: SceneTree) -> String:
	var honest: String = _focus_out(tree, true)
	if honest != "":
		return honest
	var planted: String = _focus_out(tree, false)
	return "" if planted != "" else "a run without the focus pause was paused by the focus-out"


## "" when quest 1, running, is paused by the focus-out (with_pause) / stays live (without).
func _focus_out(tree: SceneTree, with_pause: bool) -> String:
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	var game: Quest1Game = scene.instantiate() as Quest1Game
	game.save_path = ""
	game.settings_path = ""
	tree.root.add_child(game)
	var guard: HandheldFocusPause = HandheldFocusPause.new() if with_pause else null
	if guard != null:
		guard.target_quest = game
		tree.root.add_child(guard)
	game.boot()
	game.card.start_button.pressed.emit()
	var s: Quest1Session = game.session
	if s == null:
		_drop(game, guard)
		return "the Start button did not open quest 1"
	s.world.set_process(true)
	for i: int in WALK_TICKS:
		s.step()
	var live_before: bool = not game.paused and s.world.is_processing()
	tree.root.propagate_notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var paused: bool = game.paused and not s.world.is_processing() and not s.live.enabled
	Log.info(
		"scenario",
		(
			"focus pause (guard %s): live before %s, paused after %s"
			% [with_pause, live_before, paused]
		)
	)
	_drop(game, guard)
	if not live_before:
		return "quest 1 was not running before the focus-out"
	return "" if paused else "the focus-out left quest 1 running"


func _drop(game: Quest1Game, guard: HandheldFocusPause) -> void:
	if guard != null:
		guard.free()
	game.free()

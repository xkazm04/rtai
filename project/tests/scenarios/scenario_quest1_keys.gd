extends Scenario
## The slice's keyboard path: quest 1's first beat played with the bound keys only (the
## move_* and interact actions' InputEventKeys, digital, full speed), the way a player on
## WASD does it: walk to the dumpster, let go, press the interact key, and Rivet is hidden.
## The pad path (analog sticks) is scenario_quest1_input.

const LIMIT_TICKS: int = 20 * SimClock.TICK_RATE


func run(tree: SceneTree) -> String:
	var honest: String = _walk_and_hide(tree, true)
	if honest != "":
		return honest
	# TST-05: the planted fault (the interact key never pressed) must leave Rivet in the open
	var planted: String = _walk_and_hide(tree, false)
	return "" if planted != "" else "a run without the interact key still hid Rivet"


## "" when Rivet walked to the dumpster on the move keys and is hidden after it.
func _walk_and_hide(tree: SceneTree, press_use: bool) -> String:
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	var game: Quest1Game = scene.instantiate() as Quest1Game
	game.save_path = ""
	game.settings_path = ""
	tree.root.add_child(game)
	game.boot()
	game.card.start_button.pressed.emit()
	var s: Quest1Session = game.session
	if s == null:
		game.free()
		return "the Start button did not open quest 1"
	s.world.set_process(false)
	var spot: Vector2 = s.stage.layout.hide_at["dumpster"]
	var reach: float = s.stage.layout.hide_r["dumpster"]
	var walked: int = 0
	while s.tick() < LIMIT_TICKS and s.stage.arena.rivet.pos.distance_to(spot) > reach * 0.5:
		var to: Vector2 = spot - s.stage.arena.rivet.pos
		_key(&"move_right", to.x > 0.1)
		_key(&"move_left", to.x < -0.1)
		_key(&"move_down", to.y > 0.1)
		_key(&"move_up", to.y < -0.1)
		s.step()
		walked += 1
	for a: StringName in [&"move_right", &"move_left", &"move_down", &"move_up"]:
		_key(a, false)
	_key(&"interact", press_use)
	s.step()
	_key(&"interact", false)
	s.step()
	var hidden: String = s.stage.hidden_in
	Log.info("scenario", "quest1 keys: walked %d ticks, hidden in '%s'" % [walked, hidden])
	game.free()
	if walked == 0 or walked >= LIMIT_TICKS:
		return "the move keys did not bring Rivet to the dumpster (%d ticks)" % walked
	return "" if hidden == "dumpster" else "the interact key did not hide Rivet (%s)" % hidden


## Presses or releases the action's first bound key, as the OS would deliver it.
func _key(action: StringName, down: bool) -> void:
	if Input.is_action_pressed(action) == down:
		return
	for bound: InputEvent in InputMap.action_get_events(action):
		if bound is InputEventKey:
			var ev: InputEventKey = bound.duplicate()
			ev.pressed = down
			Input.parse_input_event(ev)
			Input.flush_buffered_events()
			return

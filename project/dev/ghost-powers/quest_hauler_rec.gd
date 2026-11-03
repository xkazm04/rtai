extends Node
## The Hauler in quest 1's real view (boot/quest1.tscn), through bound input only: Start, a ring
## of dock guards pinned round Rivet, then Q (power_hauler), the melee press (a stomp on the
## near ring), the left stick (the tank rams east through the outer ring) and a second stomp, one
## tick per frame, a PNG every tick. Dev-only:
##   godot --rendering-driver d3d12 --path project res://dev/ghost-powers/quest_hauler_rec.tscn
##     -- --out=<abs dir> [--ppm=<32|48>]

const RING: int = 6
const END_TICK: int = 330
## Ticks run before the ring (the opening line types out).
const WARM: int = 420

var _out: String = ""
var _ppm: float = 32.0
var _game: Quest1Game
var _frame: int = 0
var _held_frames: int = 0


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--ppm="):
			_ppm = arg.substr(6).to_float()
	var scene: PackedScene = load("res://boot/quest1.tscn") as PackedScene
	_game = scene.instantiate() as Quest1Game
	_game.px_per_m = _ppm
	_game.settings_path = ""
	add_child(_game)
	await _settle()
	_game.card.start_button.pressed.emit()
	_game.session.world.set_process(false)
	_game.session.live.viewport = null
	await _settle()
	await _run()
	get_tree().quit(0)


func _run() -> void:
	var s: Quest1Session = _game.session
	for i: int in WARM:
		s.step()
	var stage: CollectCallStage = s.stage
	var at: Vector2 = stage.arena.rivet.pos
	for i: int in RING:
		var g: Fighter = stage.arena.spawn_guard(at)
		g.pos = at + Vector2.from_angle(TAU * i / RING) * (2.6 if i % 2 == 0 else 6.5)
	for t: int in END_TICK:
		_tap(&"power_hauler", t == 10)
		_tap(&"melee", t == 40 or t == 230)
		_stick(0.9 if t >= 90 and t < 170 else 0.0)
		Input.flush_buffered_events()
		s.step()
		await _save()
		await _hold(s.world.context().clock)
	var h: HaulerStage = stage.pilot.hauler
	(
		Log
		. info(
			"quest_hauler",
			(
				"activations %d stomps %d stomp_hits %d ram_hits %d kills %d held_frames %d kicks %d"
				% [
					h.activations,
					h.form.stomps,
					h.stomp_hits,
					h.ram_hits,
					stage.arena.kills,
					_held_frames,
					_game.view.hauler_kick.kicks,
				]
			)
		)
	)


func _tap(action: StringName, down: bool) -> void:
	for bound: InputEvent in InputMap.action_get_events(action):
		if bound is InputEventKey or bound is InputEventMouseButton:
			var ev: InputEvent = bound.duplicate()
			ev.set(&"pressed", down)
			Input.parse_input_event(ev)
			return


func _stick(x: float) -> void:
	var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_LEFT_X
	ev.axis_value = x
	Input.parse_input_event(ev)


func _settle() -> void:
	for i: int in 3:
		await get_tree().process_frame


## The view's hit-stop held the clock (HaulerKick): one rendered frame per held tick, no sim step.
func _hold(clock: SimClock) -> void:
	while clock.held() > 0.0:
		@warning_ignore("return_value_discarded")
		clock.advance(SimClock.TICK_DT)
		_held_frames += 1
		await _save()


func _save() -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	@warning_ignore("return_value_discarded")
	img.save_png(_out.path_join("f_%04d.png" % _frame))
	_frame += 1

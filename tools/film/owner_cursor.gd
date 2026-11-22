extends ArenaGame
## Freeze each rendered simulation tick until the film harness has sampled the actual OS
## cursor over this window. The wheel receives identical notches in both revisions.

const FIRST: int = 60
const LAST: int = 1019
var capture_dir: String
var exposed_tick: int = -1


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	session.world.set_process(false)
	session.live.viewport = null
	session.stage.arena.rivet.pos = session.plan.base + Vector2(7, -38)
	capture_dir = OS.get_environment("GTAI_MELEE_CURSOR")
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_expose)


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	if tick >= FIRST:
		var ack: String = capture_dir.path_join("ack")
		if not FileAccess.file_exists(ack) or FileAccess.get_file_as_string(ack).to_int() != tick:
			return
	if tick >= LAST:
		get_tree().quit()
		return
	if tick in [3, 8, 13, 233, 239, 420, 593, 599]:
		OpeningFilmPad.scroll(session.live)
	if tick == 780:
		_previous_notch()
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.RIGHT)
	session.step()


func _previous_notch() -> void:
	for bound: InputEvent in InputMap.action_get_events(&"weapon_prev"):
		if bound is InputEventMouseButton:
			var notch: InputEventMouseButton = bound.duplicate() as InputEventMouseButton
			notch.pressed = true
			session.live.note_event(notch)
			return


func _expose() -> void:
	var tick: int = session.tick()
	if tick < FIRST or tick == exposed_tick:
		return
	var f: FileAccess = FileAccess.open(capture_dir.path_join("ready"), FileAccess.WRITE)
	if f == null:
		get_tree().quit(1)
		return
	@warning_ignore("return_value_discarded")
	f.store_line("%d %s" % [tick, session.pilot.wheel.selected()])
	f.close()
	exposed_tick = tick

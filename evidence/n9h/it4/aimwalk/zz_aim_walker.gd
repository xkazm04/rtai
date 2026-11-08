extends Node
## Scratch (n9 it4, not committed): the King arena on pad events; the right stick held OFF_DEG
## off the King; logs the raw stick heading, the bent heading (LiveInput._aim) and the King's bearing.

const OFF_DEG: float = 5.0
var dev: String = "deck"
var out: String = ""
var game: ArenaGame = null


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--device="):
			dev = a.substr(9)
		if a.begins_with("--shots="):
			out = a.substr(8)
	_walk.call_deferred()


func _walk() -> void:
	DeviceProfile.select(dev).apply(get_tree().root)
	game = (load("res://dev/arena/arena.tscn") as PackedScene).instantiate() as ArenaGame
	get_tree().root.add_child(game)
	await _frames(90)
	var s: ArenaSession = game.session if game != null else null
	_say("device %s assist %s" % [dev, s.live.assist != null])
	_axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)
	var sum_raw: float = 0.0
	var sum_bent: float = 0.0
	var n: int = 0
	for i: int in 24:
		var a: CombatArena = s.stage.arena
		var tgt: Vector2 = _nearest(a)
		if tgt == Vector2.INF:
			_say("t%02d no target (arena %s)" % [i, a != null])
			await _frames(30)
			continue
		var to_boss: Vector2 = tgt - a.rivet.pos
		var stick: Vector2 = to_boss.normalized().rotated(deg_to_rad(OFF_DEG))
		_axis(JOY_AXIS_RIGHT_X, stick.x)
		_axis(JOY_AXIS_RIGHT_Y, stick.y)
		await _frames(2)
		var bent: Vector2 = s.live.call(&"_aim")
		var raw_off: float = rad_to_deg(absf(stick.angle_to(to_boss)))
		var bent_off: float = rad_to_deg(absf(bent.angle_to(to_boss)))
		sum_raw += raw_off
		sum_bent += bent_off
		n += 1
		_say("t%02d dist %.1f m  raw off %.2f deg  bent off %.2f deg" % [i, to_boss.length(), raw_off, bent_off])
		if out != "" and i == 6:
			await RenderingServer.frame_post_draw
			var _e: Error = get_tree().root.get_texture().get_image().save_png(out.path_join("aim-%s.png" % dev))
		await _frames(18)
	if n > 0:
		_say("SUMMARY %s n %d mean raw off %.2f deg mean bent off %.2f deg" % [dev, n, sum_raw / n, sum_bent / n])
	get_tree().quit(0)


func _axis(axis: JoyAxis, v: float) -> void:
	var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = v
	Input.parse_input_event(ev)
	var s: ArenaSession = game.session if game != null else null
	if s != null:
		s.live.note_event(ev)


func _frames(k: int) -> void:
	for i: int in k:
		await get_tree().process_frame


func _say(t: String) -> void:
	Log.info("aimwalk", t)


func _nearest(a: CombatArena) -> Vector2:
	var best: Vector2 = Vector2.INF
	if a == null:
		return best
	for t: RangeTarget in PadAimAssist.targets_of(a):
		if best == Vector2.INF or t.pos.distance_to(a.rivet.pos) < best.distance_to(a.rivet.pos):
			best = t.pos
	return best

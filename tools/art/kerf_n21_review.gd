extends Node
## Shot fixture for ghost_review.tscn in the archive's scratch project.
## The ordinary movement drive supplies CRUISE and TURN. Only the stationary shots are staged.

var _game: ArenaGame
var _mark: String
var _shot: String
var _tick: int
var _guard: Fighter


class Stationary:
	extends GhostReviewInput

	func _movement(_t: int) -> TickInput:
		return _pad(Vector2.ZERO, Vector2(1, 1).normalized(), &"")


func _ready() -> void:
	process_priority = 19
	_bind.call_deferred()


func _bind() -> void:
	_game = get_parent().get(&"_game")
	var args: ArenaArgs = ArenaArgs.parse()
	_shot = args.text("--shot")
	_tick = int(args.number("--shot-tick", 0))
	_mark = OS.get_environment("KERF_REVIEW_MARK")
	if _mark in ["hover", "guard", "hit"]:
		var tape: Stationary = Stationary.new(_game.session, &"kerf", false)
		_game.session.world.loop().set_input(tape)
		_game.view.focus.x = GhostReviewInput.MARK.x


func _process(_delta: float) -> void:
	if _game == null:
		return
	var tick: int = _game.session.tick()
	var arena: CombatArena = _game.session.stage.arena
	if _mark == "guard" and tick == _tick - 5 and _guard == null:
		_guard = arena.spawn_guard(arena.rivet.pos + Vector2(-3.0, 0.2))
		_guard.pos = arena.rivet.pos + Vector2(-4.2, 0.2)
		_guard.facing = Vector2.RIGHT
	if _mark == "hit" and tick == _tick - 1:
		arena.hit_dir = Vector2.RIGHT
		arena.damage(arena.rivet, 0.5, 1, &"rifle")
	if tick == _tick:
		_measure.call_deferred()


func _measure() -> void:
	var rig: KerfRig = _game.cast.ghost_view._bodies.kerf
	var body: KerfSpectral = rig._spectral
	var at: Vector2 = body.get_global_transform_with_canvas().origin
	var ground: Transform2D = _game.get_viewport().get_canvas_transform()
	var data: Dictionary = {
		"tick": _game.session.tick(),
		"pose": KerfRoninDrawn.Pose.keys()[body.current],
		"speed": rig.drawn.flight.hover.speed_mps,
		"yaw": rig.drawn.flight.hover.yaw_rate_dps,
		"centre": [at.x, at.y],
		"view": ViewMode.shared().id,
		"ppm": _game.px_per_m,
	}
	if _guard != null:
		var guard: Vector2 = ground * (_guard.pos * SimConst.PX_PER_M)
		data["guard"] = [guard.x, guard.y]
	var f: FileAccess = FileAccess.open(_shot.get_basename() + ".json", FileAccess.WRITE)
	if not f.store_line(JSON.stringify(data)):
		Log.error("kerf_review", "Could not write the pose for %s" % _shot)

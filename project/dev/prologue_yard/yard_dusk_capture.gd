class_name YardDuskCapture
extends RefCounted
## Freeze the real pilot. A second exposure with the actors hidden supplies the exact
## ground under each measured pixel. The camera and tick stay fixed between exposures.

const SIZE: Vector2i = Vector2i(1920, 1080)
const FRONT: Vector2 = Vector2(24.5, -2)
const BUDGET: int = 300 * SimClock.TICK_RATE

var _game: PrologueGame
var _view: PrologueView
var _out: String
var _seen: Dictionary[StringName, bool] = {}
var _frames: Array[Dictionary] = []
var _ok: bool = true


func _init(game: PrologueGame, view: PrologueView, out: String) -> void:
	_game = game
	_view = view
	_out = out


func run() -> bool:
	_view.set_process(false)
	YardCamera.hide_hud(_view)
	while _game.encounter.street.end_tick < 0 and _game.stage.tick < BUDGET and _ok:
		_game.world.loop().step()
		var tick: int = _game.stage.tick
		if tick == 2858 or tick == 6000:
			await _expose("t%d" % tick)
			if tick == 2858:
				await _still("gate", (_game.stage.plan as PrologueYard).gate, 64)
				await _still("front", FRONT, 64)
		elif tick > 6000 and _seen.size() < 2:
			for shot: Shot in _game.stage.arena.shots:
				if _measure_round(shot) and not _seen.has(shot.weapon):
					await _expose("%s_t%d" % [shot.weapon, tick])
					break
	return (
		_ok
		and _game.encounter.street.end_tick >= 0
		and _seen.size() == 2
		and _json("sample_points", {"frames": _frames})
		and _json("result", _game.result())
	)


func _measure_round(shot: Shot) -> bool:
	return (
		not shot.from_rivet
		and shot.weapon in [&"rifle", &"shotgun"]
		and shot.pos.distance_to(shot.origin) >= 1.5
	)


func _expose(label: String) -> void:
	var plan: PrologueYard = _game.stage.plan as PrologueYard
	await _still(label, YardCamera.center(plan, "mid", _game.stage.tick), 32)
	var points: Array[Dictionary] = []
	for h: Fighter in _game.stage.arena.hostiles:
		if h.archetype == &"patrol_cop" and h.alive() and plan.yard.has_point(h.pos):
			points.append(_point("patrol_cop", h.pos, h.id))
	var has_rounds: bool = false
	for shot: Shot in _game.stage.arena.shots:
		if _measure_round(shot):
			has_rounds = true
			_seen[shot.weapon] = true
			points.append(_point(String(shot.weapon), shot.pos, shot.shooter_id))
	_frames.append({"frame": label, "tick": _game.stage.tick, "points": points})
	if has_rounds:
		_view.fx_view.hide()
		await _write_exposure(label + "_no_rounds")
		_view.fx_view.show()
	_view.print_stage.actor_layer().hide()
	await _write_exposure(label + "_ground")
	_view.print_stage.actor_layer().show()


func _point(kind: String, at: Vector2, id: int) -> Dictionary:
	var tx: Transform2D = _view.get_viewport().get_canvas_transform()
	var p: Vector2i = Vector2i((tx * (at * SimConst.PX_PER_M)).round())
	return {"kind": kind, "id": id, "xy": [p.x, p.y]}


func _still(label: String, at: Vector2, ppm: int) -> void:
	_view._process(SimClock.TICK_DT)
	_view.print_stage.kick_px = Vector2.ZERO
	YardCamera.place(_view, at, ppm)
	# Camera2D applies the locked transform after PrintStage.place has stepped the light quads.
	_view.print_stage.lights.step(_game.stage.tick, _view.print_stage.world_px)
	_view.blood.step(_game.stage.tick, _view.print_stage.world_px)
	await _write_exposure(label)


func _write_exposure(label: String) -> void:
	await _game.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var frame: Image = _game.get_viewport().get_texture().get_image()
	if (
		frame == null
		or frame.get_size() != SIZE
		or frame.save_png(_out.path_join(label + ".png")) != OK
	):
		Log.error("yard-dusk", "could not save " + label)
		_ok = false
	else:
		Log.info("yard-dusk", "%s at %d" % [label, _game.stage.tick])


func _json(label: String, value: Dictionary) -> bool:
	var file: FileAccess = FileAccess.open(_out.path_join(label + ".json"), FileAccess.WRITE)
	return file != null and file.store_string(JSON.stringify(value, "  ", true) + "\n")

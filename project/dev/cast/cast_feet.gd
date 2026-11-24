extends "res://dev/cast/cast_lineup.gd"
## A fixed-camera take from the normal actor hosts. Store the displayed cell and its
## viewport transform after every draw so the analyser can inspect the actual sole ink.

var _takes: Array[Dictionary] = []
var _selection: PackedStringArray
var _probe: CastPatrolTake


func _ready() -> void:
	_out = OS.get_environment("GTAI_CAST_OUT")
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	_pitch = OS.get_environment("GTAI_CAST_PITCH").to_int()
	_selection = OS.get_environment("GTAI_CAST_SUBJECT").split(",", false)
	var preview: StringName = StringName(OS.get_environment("GTAI_CAST_PREVIEW"))
	if preview in [CastMulroneyPreview.ID, FoeWardenCardView.ID, FoeGunnerCardView.ID]:
		CastMulroneyPreview.enable(preview)
	if not _out.is_absolute_path() or _ppm not in [32, 64] or _pitch not in [55, 70]:
		_fail("set GTAI_CAST_OUT, GTAI_CAST_PPM and GTAI_CAST_PITCH")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(float(_pitch))
	ViewMode.shared().art = "p%d" % _pitch
	add_child(_board)
	if _open_wave() == null or not await _capture_wave():
		_fail("wave feet take failed")
		return
	_session.close()
	_scene.free()
	if not await _capture_prologue():
		_fail("prologue feet take failed")
		return
	_game.free()
	var path: String = _out.path_join("tracks_%d_%d.json" % [_pitch, _ppm])
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("cannot write %s" % path)
		return
	if not file.store_string(JSON.stringify(_takes, "", false, true)):
		_fail("cannot save feet take")
		return
	file.close()
	Log.info("cast", "saved %s" % path)
	get_tree().quit()


func _far_patrol(_foe: Fighter) -> void:
	pass


func _portrait(subject: Fighter, id: String) -> bool:
	if id == "Rivet" or (not _selection.is_empty() and id not in _selection):
		return true
	if id == CastMulroneyPreview.ID and CastCards.current(subject.archetype) != null:
		CastMulroneyPreview.hide_dress(_scene)
	for other: Fighter in _arena.hostiles:
		other.pos = PARK
	_arena.rivet.pos = MARK + Vector2.RIGHT * 10.0
	var host: ArenaRigs
	for child: Node in _scene.get_children():
		if child is ArenaRigs:
			host = child
	if host == null:
		return false
	var speeds: Dictionary[String, float] = _speeds(subject)
	for gait: String in speeds:
		for facing: String in ["right", "down_right"]:
			var take: Dictionary = {
				"archetype": id,
				"pitch": _pitch,
				"ppm": _ppm,
				"gait": gait,
				"speed_mps": speeds[gait],
				"facing": facing,
				"frames": []
			}
			_prepare(host, take)
			if not await _track(subject, host, take):
				return false
			_takes.append(take)
			if _probe != null:
				_takes.append_array(_probe.takes)
				_probe.actor.pos = PARK
				_probe.free()
				_probe = null
	subject.pos = PARK
	Log.info("cast", "sampled %s" % id)
	return true


func _prepare(host: ArenaRigs, take: Dictionary) -> void:
	take.host = "near"
	if take.archetype == "patrol_cop":
		var speed: float = take.speed_mps
		var fast: bool = StreetCopWalk.strip_for(speed) == StreetCopWalk.RUN
		take.step_m = StreetPatrolAnchors.RUN_M if fast else StreetCopWalk.STEP_M
	var steps: Dictionary[String, float] = {
		"riot_cop": CastRiotAnchors.WALK_STEP_M,
		"rocket_trooper": CastLancerAnchors.WALK_STEP_M,
		"robot_gunner": CastGunnerAnchors.WALK_STEP_M,
		"swat": CastSwatAnchors.WALK_STEP_M
	}
	if steps.has(take.archetype):
		var fast: bool = take.speed_mps > CastCardKinds.RUN_MPS and take.archetype == "swat"
		take.step_m = CastSwatAnchors.RUN_STEP_M if fast else steps[take.archetype]
	if take.archetype == "patrol_cop" and LaunchArgs.has("--cast-patrol-feet"):
		_probe = CastPatrolTake.new()
		host.rigs.get_parent().add_child(_probe)
		_probe.begin(_arena, take)


func _speeds(h: Fighter) -> Dictionary[String, float]:
	var roster: EnemyRoster = _arena.squad_ai.pit.roster
	var speed: float = roster.archetype(h.archetype).speed_mps
	var speeds: Dictionary[String, float] = {}
	if is_zero_approx(speed):
		speeds["sweep"] = 0.0
		return speeds
	speeds["walk"] = speed
	var data: DataTable = DataTable.open(PrologueGame.TABLE, PrologueGame.SCHEMA)
	var arrival: Dictionary = data.object(data.raw, "arrival")
	if h.archetype in [&"patrol_cop", &"appliance_warden"]:
		speeds["arrival_walk"] = data.num(arrival, "walk_mps")
	if h.archetype == &"patrol_cop":
		speeds["city_walk"] = CityHeatTune.load_table().sim_tune[SimConst.PT_WALK_V]
		speeds["run"] = data.num(arrival, "retreat_mps")
	if h.archetype == &"swat":
		speeds["run"] = data.num(data.object(data.raw, "command"), "rifle_bound_mps")
	return speeds


func _track(h: Fighter, host: ArenaRigs, take: Dictionary) -> bool:
	var dir: Vector2 = Vector2.RIGHT if take.facing == "right" else Vector2(1, 1).normalized()
	h.pos = MARK
	h.facing = dir
	for tick: int in 24:
		if _probe != null:
			_probe.sample_pose(h.pos * SimConst.PX_PER_M, dir, 0.0)
		await _advance()
	var camera: Transform2D = get_viewport().get_canvas_transform()
	if not is_equal_approx(camera.x.length() * SimConst.PX_PER_M, _ppm):
		return false
	var mark: Vector2 = camera * (MARK * SimConst.PX_PER_M)
	take.ground_mark = [mark.x, mark.y]
	var speed: float = take.speed_mps
	var ticks: int = 64 if speed == 0 else ceili(6.0 / (speed * SimClock.TICK_DT))
	for tick: int in ticks:
		if speed > 0:
			h.pos = MARK + dir * ((tick + 1) * speed * SimClock.TICK_DT)
		else:
			h.facing = dir.rotated(TAU * tick / (ticks - 1))
		if _probe != null:
			_probe.sample_pose(h.pos * SimConst.PX_PER_M, dir, speed * SimConst.PX_PER_M)
		await _advance()
		if _probe != null:
			_probe.collect(host)
		if not get_viewport().get_canvas_transform().is_equal_approx(camera):
			return false
		var frame: Dictionary = CastFeetFrame.sample(host, h)
		var frames: Array = take.frames
		frames.append(frame)
		if _ppm == 64 and tick == 38 and take.facing == "right" and take.gait == "walk":
			var path: String = _out.path_join("%s_%d_t38.png" % [h.archetype, _pitch])
			if get_viewport().get_texture().get_image().save_png(path) != OK:
				return false
			if not await CastFeetEdge.shoot(self, _scene, host, h, _out):
				return false
	return true


func _advance() -> void:
	_clock.complete_tick()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

extends "res://dev/cast/cast_size_beside.gd"
## Robot thug A's card (row forced on in this dev process only): wind-up, lunge, snap, hit and the
## fall's rest, all down-right, beside a spawned patrol cop and Rivet at 64 px/m, 70 deg, drawn by
## the live card path (tell_left, the claw's shot tick, hurt_tick, hp 0). The arena gets the game's
## enemy lock (GuardTell from the weapon table) so the lunge row shows. Writes
## build/look/n29-thug/poses/thug_poses_64ppm_tilt70.png and its body-only twin (street shadow off).

const POSES: Array[String] = ["attack/0", "attack/1", "attack/2", "hit/0", "fall/2"]
const STEP_M: float = 2.6
const HOLD: int = 40

var _thugs: Array[Fighter] = []


func _ready() -> void:
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root: String = ProjectSettings.globalize_path("res://")
	_dir = root.path_join("../build/look/n29-thug/poses").simplify_path()
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_dir)
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	_ppm = 64
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	if _arena.guard_tell == null:
		_arena.guard_tell = GuardTell.from_table(WeaponTable.shipped())
	_cop = _arena.squad_ai.spawn_member(_arena, CENTRE, &"patrol_cop")
	@warning_ignore("return_value_discarded")
	_arena.squad_ai.mind_for(_cop)
	for i: int in POSES.size():
		var thug: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, FoeThugCardView.ID)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(thug)
		_thugs.append(thug)
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	var ok: bool = await _shoot()
	Log.info("cast", "thug poses pass %s" % ok)
	get_tree().quit(0 if ok else 1)


func _shoot() -> bool:
	for tick: int in range(1, HOLD + 1):
		_pose(tick)
		_clock.complete_tick()
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var ok: bool = _check()
	_save("thug_poses_64ppm_tilt70.png")
	_shadow.hide()
	_pose(HOLD)
	_clock.complete_tick()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_save("thug_poses_64ppm_tilt70_body.png")
	return ok


## Every tick: the line-up and each thug's state, set the way the live sim leaves it.
func _pose(tick: int) -> void:
	_arena.tick = tick
	var look: Vector2 = LOOK.normalized()
	_cop.pos = CENTRE + Vector2(-7.8, 0.0)
	_cop.facing = look
	_arena.rivet.pos = CENTRE + Vector2(-5.2, 0.0)
	_arena.rivet.facing = look
	var lock: int = _arena.guard_tell.lock_ticks
	for i: int in _thugs.size():
		var thug: Fighter = _thugs[i]
		var mind: SquadMind = _arena.squad_ai.mind_for(thug)
		thug.pos = CENTRE + Vector2(-2.6 + STEP_M * i, 0.0)
		thug.facing = look
		thug.tell_left = [lock + 20, lock, 0, 0, 0][i]
		mind.agent.shot_tick = tick if i == 2 else -100000
		if i == 3:
			thug.hurt_tick = HOLD - 8  # hit row (0.13 s < 0.20 s hold), flash (0.08 s) over
			thug.hurt_dir = -look
		if i == 4:
			thug.hp = 0.0
			thug.hurt_tick = tick - 100000
			thug.hurt_dir = look


func _card(thug: Fighter) -> Sprite2D:
	var rig: CutRig = _host.robots.rig_for(thug.id) if _host.robots != null else null
	if rig == null or not rig.has_meta(FoeThugCardView.CARD):
		return null
	return rig.get_meta(FoeThugCardView.CARD)


func _check() -> bool:
	var ok: bool = true
	var canvas: Transform2D = get_viewport().get_canvas_transform()
	for i: int in _thugs.size():
		var card: Sprite2D = _card(_thugs[i])
		if card == null or not card.is_visible_in_tree():
			Log.error("cast", "thug %d: no card" % i)
			ok = false
			continue
		var stem: String = card.texture.resource_path.get_file().get_basename()
		var key: String = "%s/%d" % [stem.trim_prefix("robot_thug_"), card.frame_coords.y]
		var point: Vector2 = canvas * (_thugs[i].pos * SimConst.PX_PER_M)
		Log.info(
			"cast",
			"pose %d %s (want %s) col %d at %s" % [i, key, POSES[i], card.frame_coords.x, point]
		)
		ok = ok and key == POSES[i]
	return ok

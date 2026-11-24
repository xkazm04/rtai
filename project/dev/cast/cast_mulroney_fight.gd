extends "res://dev/cast/cast_lineup.gd"
## Staged movement on the gauntlet street. The yard shotgun, Rivet's pistol, projectile
## collisions and the normal rig pool produce the exchange. Capture with Godot Movie Maker.

const RUN_TICKS: int = 960
const SHOTS: Array[int] = [218, 426, 668]
const REPLIES: Array[int] = [510, 815]
const CENTRE: Vector2 = Vector2(13, 0)

var _host: ArenaRigs
var _boss: Fighter
var _mind: SquadMind
var _shotgun: PrologueShotgun = PrologueShotgun.new()
var _rows_seen: Dictionary[String, bool] = {}


func _ready() -> void:
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	_pitch = OS.get_environment("GTAI_CAST_PITCH").to_int()
	if _ppm not in [32, 64] or _pitch not in [55, 70]:
		_fail("set GTAI_CAST_PPM and GTAI_CAST_PITCH")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(float(_pitch))
	ViewMode.shared().art = "p%d" % _pitch
	CastMulroneyPreview.enable()
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	_equip()
	for tick: int in range(1, RUN_TICKS + 1):
		_exchange(tick)
		_clock.complete_tick()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		_observe(tick)
	var ok: bool = _complete()
	_session.close()
	_scene.free()
	Log.info("cast", "Mulroney fight complete %s, rows %s" % [ok, _rows_seen.keys()])
	get_tree().quit(0 if ok else 1)


func _studio() -> bool:
	_view.focus = CENTRE
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	for item: Node in _scene.find_children("*", "CanvasLayer", true, false):
		var layer: CanvasLayer = item as CanvasLayer
		if layer.layer >= RenderLayers.canvas(&"hud"):
			layer.hide()
	return true


func _equip() -> void:
	_boss = _arena.squad_ai.spawn_member(_arena, CENTRE, CastMulroneyPreview.ID)
	_boss.pos = CENTRE + Vector2(-7.5, -2.5)
	_mind = _arena.squad_ai.mind_for(_boss)
	_boss.hp = _mind.agent.arch.hp
	_boss.max_hp = _boss.hp
	var rivet: Fighter = _arena.rivet
	rivet.pos = CENTRE + Vector2(7, 2.3)
	rivet.weapon = &"pistol"
	_arena.gun = GunHand.make(
		WeaponTable.shipped(), rivet.weapon, _session.world.context().rng.stream(&"gunplay")
	)
	@warning_ignore("return_value_discarded")
	_session.pilot.hold.equip(rivet.weapon)


func _exchange(tick: int) -> void:
	_arena.tick = tick
	_session.stage.tick = tick
	_session.pilot.hold.step()
	var rivet: Fighter = _arena.rivet
	if _boss.alive():
		_walk(tick, rivet)
		_boss.facing = _boss.pos.direction_to(rivet.pos)
		rivet.facing = -_boss.facing
		_boss.tell_left = 0
		for shot: int in SHOTS:
			if tick < shot and tick >= shot - 50:
				_boss.tell_left = shot - tick
		if tick in SHOTS:
			_shotgun.step(_arena, _boss, _mind.agent.arch.weapon, tick)
		var pump: float = _shotgun.pump_progress(tick)
		FoeCastView.set_pump(_boss, pump, pump == 0.0)
		if tick in REPLIES:
			@warning_ignore("return_value_discarded")
			_arena.rivet_fire(_boss.pos)
	_arena._step_shots()
	_arena.gun.settle()


func _walk(tick: int, rivet: Fighter) -> void:
	var speed: float = _mind.agent.arch.speed_mps * SimClock.TICK_DT
	if tick < 150:
		_boss.pos = _boss.pos.move_toward(CENTRE + Vector2(-2, -1.5), speed)
		rivet.pos = rivet.pos.move_toward(CENTRE + Vector2(3.5, 2.3), 2.6 * SimClock.TICK_DT)
	elif tick > 275 and tick < 365:
		_boss.pos = _boss.pos.move_toward(CENTRE + Vector2(-2.8, -0.6), speed)
		rivet.pos = rivet.pos.move_toward(CENTRE + Vector2(3.5, 3.2), 2.8 * SimClock.TICK_DT)
	elif tick > 545 and tick < 617:
		rivet.pos = rivet.pos.move_toward(CENTRE + Vector2(2, 1.7), 3.2 * SimClock.TICK_DT)


func _observe(tick: int) -> void:
	var rig: CutRig = _host.rigs.rig_for(_boss.id)
	if rig == null or rig.head_card == null or not rig.head_card.is_visible_in_tree():
		return
	var sprite: Sprite2D = rig.head_card
	CastMulroneyPreview.trace(rig, tick)
	var path: String = sprite.texture.resource_path.get_file().replace("_planted8", "")
	if not path.begins_with("sergeant_mulroney_"):
		return
	var action: String = path.trim_prefix("sergeant_mulroney_").trim_suffix(".png")
	var key: String = "%s/%d" % [action, sprite.frame_coords.y]
	if not _rows_seen.has(key):
		_rows_seen[key] = true
		Log.info("cast", "frame %d %s facing %s" % [tick, key, sprite.frame_coords.x])


func _complete() -> bool:
	for key: String in [
		"armed_walk/0", "attack/0", "attack/1", "attack/2", "attack/3", "hit/0", "fall/2"
	]:
		if not _rows_seen.has(key):
			return false
	var ppm: float = get_viewport().get_canvas_transform().x.length() * SimConst.PX_PER_M
	return (
		_shotgun.shot_ticks == SHOTS
		and not _boss.alive()
		and _arena.rivet.alive()
		and is_equal_approx(ppm, _ppm)
	)

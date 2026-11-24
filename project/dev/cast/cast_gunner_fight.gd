extends "res://dev/cast/cast_lineup.gd"
## Rivet against robot gunners on the gauntlet street, card on: walk in, lens tell (telegraph_s),
## fire into the normal projectile loop, Rivet's pistol hits and kills. Movie Maker take.
## GTAI_CAST_PPM is 32 or 64, GTAI_CAST_GUNNERS 1 or 3 (one also stands the patrol cop beside).

const RUN_TICKS: int = 1200
const TELL_FROM: int = 170
const CENTRE: Vector2 = Vector2(13, 0)
const SPOTS: Array[Vector2] = [Vector2(-2.2, -0.9), Vector2(-3.4, 2.6), Vector2(-3.8, -3.4)]
const ENTRY: Vector2 = Vector2(-4.5, -1.5)

var _host: ArenaRigs
var _gunners: Array[Fighter] = []
var _minds: Array[SquadMind] = []
var _cop: Fighter
var _rows_seen: Dictionary[String, bool] = {}
var _last_key: Dictionary[int, String] = {}
var _first_shot: Dictionary[int, int] = {}
var _tell_start: Dictionary[int, int] = {}


func _ready() -> void:
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	var count: int = OS.get_environment("GTAI_CAST_GUNNERS").to_int()
	if _ppm not in [32, 64] or count not in [1, 3] or get_window().size != Vector2i(1920, 1080):
		_fail("set GTAI_CAST_PPM and GTAI_CAST_GUNNERS, window 1920x1080")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	CastMulroneyPreview.enable(FoeGunnerCardView.ID)
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	_equip(count)
	for tick: int in range(1, RUN_TICKS + 1):
		_exchange(tick)
		_clock.complete_tick()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		_observe(tick)
	var ok: bool = _complete()
	_session.close()
	_scene.free()
	Log.info("cast", "gunner fight pass %s, rows %s" % [ok, _rows_seen.keys()])
	get_tree().quit(0 if ok else 1)


func _studio() -> bool:
	_view.focus = CENTRE
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	for item: Node in _scene.find_children("*", "CanvasLayer", true, false):
		var layer: CanvasLayer = item as CanvasLayer
		if layer.layer >= RenderLayers.canvas(&"hud") or layer is LightLayer:
			layer.hide()
	return true


func _equip(count: int) -> void:
	for i: int in count:
		var g: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, FoeGunnerCardView.ID)
		g.pos = CENTRE + ENTRY + Vector2(0.0, 2.4 * i)
		var mind: SquadMind = _arena.squad_ai.mind_for(g)
		g.hp = 3.0
		g.max_hp = g.hp
		_gunners.append(g)
		_minds.append(mind)
	if count == 1:
		_cop = _arena.squad_ai.spawn_member(_arena, CENTRE, &"patrol_cop")
		_cop.pos = CENTRE + Vector2(0.4, -1.5)
		_cop.facing = Vector2(1, 1).normalized()
	var rivet: Fighter = _arena.rivet
	rivet.pos = CENTRE + Vector2(3.2, 1.0)
	rivet.hp = 999.0
	rivet.max_hp = rivet.hp
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
	var target: Fighter = null
	for i: int in _gunners.size():
		var g: Fighter = _gunners[i]
		if not g.alive():
			continue
		_gunner(i, g, tick)
		target = target if target != null else g
	if _cop != null:
		_cop.facing = Vector2(1, 1).normalized()
	if target != null:
		_arena.rivet.facing = _arena.rivet.pos.direction_to(target.pos)
	_arena._step_shots()
	_arena.gun.settle()


func _gunner(i: int, g: Fighter, tick: int) -> void:
	var mind: SquadMind = _minds[i]
	var speed: float = mind.agent.arch.speed_mps * SimClock.TICK_DT
	var spot: Vector2 = CENTRE + SPOTS[i]
	var tell: int = mind.agent.arch.telegraph_ticks
	var round_at: int = TELL_FROM + 120 * i
	if tick < 150:
		g.pos = g.pos.move_toward(spot, speed)
	g.facing = g.pos.direction_to(_arena.rivet.pos)
	g.tell_left = 0
	for shot_at: int in [round_at + tell, round_at + tell + 300]:
		if tick >= shot_at - tell and tick < shot_at:
			g.tell_left = shot_at - tick
		if tick == shot_at:
			_fire(i, g, tick)
	var hit_at: int = round_at + tell + 70
	if tick == hit_at or (tick >= hit_at + 300 and tick % 14 == 0):
		@warning_ignore("return_value_discarded")
		_arena.rivet_fire(g.pos)


func _fire(i: int, g: Fighter, tick: int) -> void:
	var shot: Shot = FoeAttacks.round_from(g, _minds[i].agent.arch.weapon)
	_arena.shots.append(shot)
	_minds[i].agent.shot_tick = tick
	if not _first_shot.has(g.id):
		_first_shot[g.id] = tick


func _card_of(g: Fighter) -> Sprite2D:
	var rig: CutRig = _host.robots.rig_for(g.id) if _host.robots != null else null
	if rig == null or not rig.has_meta(FoeGunnerCardView.CARD):
		return null
	return rig.get_meta(FoeGunnerCardView.CARD)


func _observe(tick: int) -> void:
	for g: Fighter in _gunners:
		var card: Sprite2D = _card_of(g)
		if card == null or not card.is_visible_in_tree():
			continue
		var stem: String = card.texture.resource_path.get_file().get_basename()
		stem = stem.trim_prefix("robot_gunner_").replace("planted8_", "")
		var key: String = "%s/%d" % [stem, card.frame_coords.y]
		if stem == "attack" and not _tell_start.has(g.id):
			_tell_start[g.id] = tick
		if _last_key.get(g.id, "") != key:
			_last_key[g.id] = key
			Log.info("cast", "tick %d gunner %d %s hp %.1f" % [tick, g.id, key, g.hp])
		_rows_seen[key] = true


func _complete() -> bool:
	for key: String in ["armed_walk/0", "attack/0", "attack/2", "attack/3", "hit/0", "fall/2"]:
		if not _rows_seen.has(key):
			Log.error("cast", "missing film state %s" % key)
			return false
	var telegraph: int = _minds[0].agent.arch.telegraph_ticks
	for g: Fighter in _gunners:
		var lead: int = _first_shot.get(g.id, -1) - _tell_start.get(g.id, 1 << 30)
		Log.info("cast", "gunner %d tell shows %d ticks before its first round" % [g.id, lead])
		if g.alive() or lead < telegraph:
			return false
	var ppm: float = get_viewport().get_canvas_transform().x.length() * SimConst.PX_PER_M
	return _arena.rivet.alive() and is_equal_approx(ppm, _ppm)

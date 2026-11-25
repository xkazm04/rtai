extends "res://dev/cast/cast_lineup.gd"
## Rivet against three robot thugs on the gauntlet street, card forced on in this dev process only:
## walk in, claw tell (telegraph_s, the lunge in its locked end), snap, recover, Rivet's pistol hits
## and kills; Movie Maker take at 32 px/m, 70 deg. The snap tick is scripted (the claw's shot tick),
## as the gunner film scripts its rounds; logs every drawing change with its tick.

const RUN_TICKS: int = 1200
const TELL_FROM: int = 170
const CENTRE: Vector2 = Vector2(13, 0)
const RIVET_AT: Vector2 = Vector2(3.2, 1.0)
## Around Rivet, apart enough that three bodies (about Rivet's height) do not stack.
const SPOTS: Array[Vector2] = [Vector2(-2.8, -0.4), Vector2(-1.7, 2.3), Vector2(-0.9, -2.7)]
## Each walks in level from 5.8 m left of its spot (2.4 m/s: there by tick 150).
const ENTRY: Vector2 = Vector2(-5.8, 0.0)

var _thugs: Array[Fighter] = []
var _minds: Array[SquadMind] = []
var _host: ArenaRigs
var _rows_seen: Dictionary[String, bool] = {}
var _last_key: Dictionary[int, String] = {}
var _since: Dictionary[int, int] = {}
var _first_snap: Dictionary[int, int] = {}
var _tell_start: Dictionary[int, int] = {}


func _ready() -> void:
	_ppm = 32
	if get_window().size != Vector2i(1920, 1080):
		_fail("window 1920x1080")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(70.0)
	ViewMode.shared().art = "p70"
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("street rig host unavailable")
		return
	if _arena.guard_tell == null:
		_arena.guard_tell = GuardTell.from_table(WeaponTable.shipped())
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
	Log.info("cast", "thug fight pass %s, rows %s" % [ok, _rows_seen.keys()])
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


func _equip() -> void:
	for i: int in SPOTS.size():
		var g: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, FoeThugCardView.ID)
		g.pos = CENTRE + RIVET_AT + SPOTS[i] + ENTRY
		g.hp = 3.0
		g.max_hp = g.hp
		_thugs.append(g)
		_minds.append(_arena.squad_ai.mind_for(g))
	var rivet: Fighter = _arena.rivet
	rivet.pos = CENTRE + RIVET_AT
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
	for i: int in _thugs.size():
		var g: Fighter = _thugs[i]
		if not g.alive():
			continue
		_thug(i, g, tick)
		target = target if target != null else g
	if target != null:
		_arena.rivet.facing = _arena.rivet.pos.direction_to(target.pos)
	_arena._step_shots()
	_arena.gun.settle()


## Walk in, then two claw rounds (tell, snap) 300 ticks apart; Rivet answers each, then kills.
func _thug(i: int, g: Fighter, tick: int) -> void:
	var mind: SquadMind = _minds[i]
	var spot: Vector2 = CENTRE + RIVET_AT + SPOTS[i]
	var tell: int = mind.agent.arch.telegraph_ticks
	var round_at: int = TELL_FROM + 120 * i
	if tick < 150:
		g.pos = g.pos.move_toward(spot, mind.agent.arch.speed_mps * SimClock.TICK_DT)
	g.facing = g.pos.direction_to(_arena.rivet.pos)
	g.tell_left = 0
	for snap_at: int in [round_at + tell, round_at + tell + 300]:
		if tick >= snap_at - tell and tick < snap_at:
			g.tell_left = snap_at - tick
		if tick == snap_at:
			mind.agent.shot_tick = tick
			if not _first_snap.has(g.id):
				_first_snap[g.id] = tick
	var hit_at: int = round_at + tell + 70
	if tick == hit_at or (tick >= hit_at + 300 and tick % 14 == 0):
		@warning_ignore("return_value_discarded")
		_arena.rivet_fire(g.pos)


func _card_of(g: Fighter) -> Sprite2D:
	var rig: CutRig = _host.robots.rig_for(g.id) if _host.robots != null else null
	if rig == null or not rig.has_meta(FoeThugCardView.CARD):
		return null
	return rig.get_meta(FoeThugCardView.CARD)


func _observe(tick: int) -> void:
	for g: Fighter in _thugs:
		var card: Sprite2D = _card_of(g)
		if card == null or not card.is_visible_in_tree():
			continue
		var stem: String = card.texture.resource_path.get_file().get_basename()
		stem = stem.trim_prefix("robot_thug_").replace("planted8_", "")
		var key: String = "%s/%d" % [stem, card.frame_coords.y]
		if stem == "attack" and not _tell_start.has(g.id):
			_tell_start[g.id] = tick
		var last: String = _last_key.get(g.id, "")
		if last != key:
			if last == "hit/0":
				Log.info("cast", "thug %d hit held %d ticks" % [g.id, tick - _since[g.id]])
			_last_key[g.id] = key
			_since[g.id] = tick
			Log.info("cast", "tick %d thug %d %s hp %.1f" % [tick, g.id, key, g.hp])
		_rows_seen[key] = true


func _complete() -> bool:
	for key: String in ["attack/0", "attack/1", "attack/2", "attack/3", "hit/0", "fall/2"]:
		if not _rows_seen.has(key):
			Log.error("cast", "missing film state %s" % key)
			return false
	var telegraph: int = _minds[0].agent.arch.telegraph_ticks
	for g: Fighter in _thugs:
		var lead: int = _first_snap.get(g.id, -1) - _tell_start.get(g.id, 1 << 30)
		Log.info("cast", "thug %d tell shows %d ticks before its first snap" % [g.id, lead])
		if g.alive() or lead < telegraph:
			return false
	var ppm: float = get_viewport().get_canvas_transform().x.length() * SimConst.PX_PER_M
	return _arena.rivet.alive() and is_equal_approx(ppm, _ppm)

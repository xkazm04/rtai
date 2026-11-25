extends Node
## Probe of cast_warden_fight: the same staged exchange, GTAI_CAST_PITCH 55 or 70, and from the lead
## warden's first fall tick it draws, each for a whole frame: fall row 1 (as shipped), fall row 0
## (forced after the rigs' _process), then his card hidden (GTAI_CAST_HOLD_FIRST=off swaps the two).
## Frames go to GTAI_CAST_SWITCH_OUT; the walk and hit frames before are saved with the card on.
const RUN_TICKS: int = 960
const ID: StringName = FoeWardenCardView.ID

var _game: PrologueGame
var _stage: PrologueStage
var _arena: PrologueCombat
var _rigs: CharacterRigs
var _wardens: Array[Fighter] = []
var _centre: Vector2
var _seen: Dictionary[String, bool] = {}
var _held_ticks: int = 0
var _ppm: int
var _shots: String
var _hold: CastWardenHold
var _fall_at: int = -1


func _ready() -> void:
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	if _ppm not in [32, 64] or get_window().size != Vector2i(1920, 1080):
		get_tree().quit(2)
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	var pitch: int = 55 if OS.get_environment("GTAI_CAST_PITCH") == "55" else 70
	ViewMode.shared().set_pitch(float(pitch))
	ViewMode.shared().art = "p%d" % pitch
	_shots = OS.get_environment("GTAI_CAST_SWITCH_OUT")
	_hold = CastWardenHold.new()
	add_child(_hold)
	CastMulroneyPreview.enable(ID)
	_game = PrologueGame.new()
	add_child(_game)
	_game.world.set_process(false)
	_stage = _game.stage as PrologueStage
	_arena = _stage.arena as PrologueCombat
	_centre = _game.encounter.patrol.wave_start
	_prepare()
	for tick: int in range(1, RUN_TICKS + 1):
		_exchange(tick)
		_game.world.context().clock.complete_tick()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		_observe(tick)
		if tick >= 540 and tick < 560:
			_shot(tick)
	var ok: bool = _complete()
	Log.info(
		"cast",
		(
			"warden fight pass %s, first catch %d, held ticks %d"
			% [ok, _arena.first_catch_tick, _held_ticks]
		)
	)
	get_tree().quit(0 if ok else 1)


func _prepare() -> void:
	for child: Node in _game.get_children():
		if child is ArenaRigs:
			_rigs = (child as ArenaRigs).rigs
		if child is PrologueView:
			var view: PrologueView = child
			view.set_process(false)
			view.print_stage.zoom = _ppm / SimConst.PX_PER_M
			view.print_stage.place(_centre)
			view.print_stage.camera.force_update_scroll()
	for item: Node in _game.find_children("*", "", true, false):
		if item is PrologueProps:
			(item as Node2D).hide()
		if item is CanvasLayer and (item as CanvasLayer).layer >= RenderLayers.canvas(&"hud"):
			(item as CanvasLayer).hide()
	for h: Fighter in _arena.hostiles:
		h.pos = _centre + Vector2(90, 90)
		if h.archetype == ID and _wardens.size() < 2:
			_wardens.append(h)
			h.exposed = true
			h.hp = 2.0
			h.max_hp = h.hp
	_wardens[0].pos = _centre + Vector2(-7.0, -3.1)
	_wardens[1].pos = _centre + Vector2(6.0, -2.8)
	_arena.rivet.pos = _centre + Vector2(1.2, 1.0)
	_arena.rivet.weapon = &"pistol"
	_arena.gun = GunHand.make(
		WeaponTable.shipped(), &"pistol", _game.world.context().rng.stream(&"gunplay")
	)
	@warning_ignore("return_value_discarded")
	_stage.pilot.hold.equip(&"pistol")


func _exchange(tick: int) -> void:
	_arena.tick = tick
	_stage.tick = tick
	var rivet: Fighter = _arena.rivet
	var dir: Vector2 = Vector2.RIGHT if tick < 230 else Vector2.LEFT
	_stage.intent.move_by = (
		dir * 0.6 * SimClock.TICK_DT if tick in range(100, 315) else Vector2.ZERO
	)
	_stage._move()
	_stage.pilot.hold.step()
	for i: int in _wardens.size():
		var h: Fighter = _wardens[i]
		var lead: bool = i == 0
		if h.alive():
			_approach(h, tick, lead)
			if (lead and tick in [455, 550, 646]) or (not lead and tick in [746, 841, 910]):
				@warning_ignore("return_value_discarded")
				_arena.rivet_fire(h.pos)
	if _arena.catcher != null:
		_held_ticks += 1
	for h: Fighter in _wardens:
		FoeWardenCardView.set_catch(h, h == _arena.catcher, tick)
	_arena._step_shots()
	_arena.gun.settle()
	rivet.facing = rivet.pos.direction_to(_wardens[0 if _wardens[0].alive() else 1].pos)


func _approach(h: Fighter, tick: int, lead: bool) -> void:
	var mind: SquadMind = _arena.squad_ai.mind_for(h)
	var rivet: Fighter = _arena.rivet
	var offset: Vector2 = Vector2(-1.5, -0.8) if lead else Vector2(2.2, -0.6)
	h.facing = h.pos.direction_to(rivet.pos)
	if h.swing_left == 0 and _arena.catcher != h:
		h.pos = h.pos.move_toward(rivet.pos + offset, mind.agent.arch.speed_mps * SimClock.TICK_DT)
	mind.agent.sees = true
	mind.agent.token = (tick >= 160 and tick < 440) if lead else (tick >= 570 and tick < 730)
	mind.swing(h, _arena, _arena.guard_map)


func _observe(tick: int) -> void:
	for h: Fighter in _wardens:
		var rig: CutRig = _rigs.rig_for(h.id)
		if rig == null or rig.head_card == null or not rig.head_card.is_visible_in_tree():
			continue
		var card: Sprite2D = rig.head_card
		var stem: String = card.texture.resource_path.get_file().get_basename()
		if not stem.begins_with("appliance_warden_"):
			continue
		var key: String = "%s/%d" % [stem.trim_prefix("appliance_warden_"), card.frame_coords.y]
		if LaunchArgs.has("--cast-warden-trace"):
			var at: Vector2 = card.get_global_transform_with_canvas() * card.get_rect().get_center()
			Log.info(
				"warden-frame", "%d %d %s %s held=%s" % [tick, h.id, key, at, h == _arena.catcher]
			)
		if not _seen.has(key):
			_seen[key] = true
			Log.info("cast", "tick %d actor %d %s" % [tick, h.id, key])
		if h == _wardens[0] and key.begins_with("fall/") and _fall_at < 0:
			_fall_at = tick


## Save the lead warden's delivered frame; after his first fall tick, arm the next frame's hold.
func _shot(tick: int) -> void:
	var card: Sprite2D = _rigs.rig_for(_wardens[0].id).head_card
	if _shots.is_empty() or card == null:
		return
	var mode: String = _hold.mode
	var stem: String = "%d_%s_r%d" % [tick, mode, card.frame_coords.y]
	@warning_ignore("return_value_discarded")
	get_viewport().get_texture().get_image().save_png(_shots.path_join(stem + ".png"))
	_hold.card = card
	var step: int = tick - _fall_at
	var order: Array[String] = ["row0", "off"]
	if OS.get_environment("GTAI_CAST_HOLD_FIRST") == "off":
		order.reverse()
	_hold.mode = order[step] if step in [0, 1] else ""
	if _fall_at < 0:
		_hold.mode = ""


func _complete() -> bool:
	for key: String in [
		"planted8_armed_walk/0", "attack/0", "attack/1", "attack/2", "attack/3", "hit/0", "fall/2"
	]:
		if not _seen.has(key):
			Log.error("cast", "missing film state %s" % key)
			return false
	return _arena.first_catch_tick >= 0 and _held_ticks > 1 and _arena.rivet.alive()

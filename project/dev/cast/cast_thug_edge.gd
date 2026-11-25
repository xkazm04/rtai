extends "res://dev/cast/cast_size_beside.gd"
## Robot thug A, live 64 px/m rim: frozen live / raw (card material off) / ground (card hidden)
## exposures of the stand, lunge, hit and fall rest at both pitches, on the live card path.
## Writes $GTAI_CAST_OUT/edge<pitch>_64/edge_<state>/{live,raw,ground}.png; rim() of
## tools/art/cast_mulroney_edge.py counts the added dark exterior pixels.

const STATES: Array[String] = ["walk", "attack", "hit", "fall"]
const SPACING_M: float = 6.0
const HOLD: int = 40

var _root: String
var _thugs: Array[Fighter] = []


func _ready() -> void:
	_root = OS.get_environment("GTAI_CAST_OUT")
	if not _root.is_absolute_path():
		_fail("set GTAI_CAST_OUT")
		return
	CastMulroneyPreview.enable(FoeThugCardView.ID)
	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	_ppm = 64
	add_child(_board)
	var ok: bool = true
	for pitch: int in [70, 55]:
		ok = await _run_pitch(pitch) and ok
	Log.info("cast", "thug edge complete %s" % ok)
	get_tree().quit(0 if ok else 1)


func _run_pitch(pitch: int) -> bool:
	ViewMode.shared().set_pitch(float(pitch))
	ViewMode.shared().art = "p%d" % pitch
	_host = _open_wave()
	if _host == null:
		return false
	if _arena.guard_tell == null:
		_arena.guard_tell = GuardTell.from_table(WeaponTable.shipped())
	_thugs.clear()
	for i: int in STATES.size():
		var thug: Fighter = _arena.squad_ai.spawn_member(_arena, CENTRE, FoeThugCardView.ID)
		@warning_ignore("return_value_discarded")
		_arena.squad_ai.mind_for(thug)
		_thugs.append(thug)
	_arena.rivet.pos = CENTRE + Vector2(0.0, 12.0)
	_view.print_stage.zoom = _ppm / SimConst.PX_PER_M
	_view.print_stage.place(CENTRE)
	_view.print_stage.camera.force_update_scroll()
	for tick: int in range(1, HOLD + 1):
		_pose(tick)
		_clock.complete_tick()
		await get_tree().process_frame
	var ok: bool = true
	for i: int in STATES.size():
		ok = await _edge(pitch, i) and ok
	_session.close()
	_scene.free()
	return ok


func _pose(tick: int) -> void:
	_arena.tick = tick
	var look: Vector2 = LOOK.normalized()
	var lock: int = _arena.guard_tell.lock_ticks
	for i: int in _thugs.size():
		var thug: Fighter = _thugs[i]
		var mind: SquadMind = _arena.squad_ai.mind_for(thug)
		thug.pos = CENTRE + Vector2(SPACING_M * (i - 1.5), 0.0)
		thug.facing = look
		thug.tell_left = lock if i == 1 else 0
		mind.agent.shot_tick = -100000
		if i == 2:
			thug.hurt_tick = HOLD - 8
			thug.hurt_dir = -look
		if i == 3:
			thug.hp = 0.0
			thug.hurt_tick = tick - 100000
			thug.hurt_dir = look


func _card(thug: Fighter) -> Sprite2D:
	var rig: CutRig = _host.robots.rig_for(thug.id) if _host.robots != null else null
	if rig == null or not rig.has_meta(FoeThugCardView.CARD):
		return null
	return rig.get_meta(FoeThugCardView.CARD)


func _edge(pitch: int, index: int) -> bool:
	var card: Sprite2D = _card(_thugs[index])
	if card == null or not card.is_visible_in_tree():
		Log.error("cast", "edge %s: no card" % STATES[index])
		return false
	var stem: String = card.texture.resource_path.get_file().get_basename()
	Log.info(
		"cast", "edge %d %s sheet %s row %d" % [pitch, STATES[index], stem, card.frame_coords.y]
	)
	var folder: String = _root.path_join("edge%d_64" % pitch).path_join("edge_" + STATES[index])
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return false
	var mode: ProcessMode = _scene.process_mode
	_scene.process_mode = Node.PROCESS_MODE_DISABLED
	var material: Material = card.material
	var inherit_material: bool = card.use_parent_material
	var ok: bool = await _expose(_thugs[index], folder, "live")
	card.use_parent_material = false
	card.material = null
	ok = await _expose(_thugs[index], folder, "raw") and ok
	card.hide()
	ok = await _expose(_thugs[index], folder, "ground") and ok
	card.show()
	card.material = material
	card.use_parent_material = inherit_material
	_scene.process_mode = mode
	return ok


func _expose(thug: Fighter, folder: String, label: String) -> bool:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var foot: Vector2 = get_viewport().get_canvas_transform() * (thug.pos * SimConst.PX_PER_M)
	var rect: Rect2i = Rect2i(Vector2i(foot.round()) - Vector2i(192, 192), Vector2i(384, 320))
	var im: Image = get_viewport().get_texture().get_image().get_region(rect)
	return im.save_png(folder.path_join(label + ".png")) == OK

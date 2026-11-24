extends "res://dev/cast/cast_mulroney_poses.gd"
## Frozen live/raw/empty exposures use the same sprite, street, camera and simulation tick.


func _ready() -> void:
	_subject = FoeWardenCardView.ID
	_walk_strip = CastWardenAnchors.WALK
	await super._ready()


func _walks() -> bool:
	if not await super._walks() or not await _reverse():
		return false
	_boss.pos = MARK
	_boss.facing = Vector2(1, 1).normalized()
	for tick: int in 20:
		await _advance()
	if not await _edge("planted8_armed_walk"):
		return false
	var sheets: CastCards.Sheets = CastCards.current(_subject)
	var original: String = sheets.walk
	sheets.walk = original.get_base_dir().path_join(CastWardenAnchors.FOUR)
	await _advance()
	var ok: bool = await _edge("armed_walk")
	sheets.walk = original
	return ok


## Record the live near host through the direction change, including the seam itself.
func _reverse() -> bool:
	var tracks: Array[Dictionary] = []
	for speed: float in [2.8, 3.8]:
		_boss.pos = MARK
		_boss.facing = Vector2(1, 1).normalized()
		for prep: int in 24:
			await _advance()
		var frames: Array[Dictionary] = []
		for tick: int in 100:
			if tick == 45:
				_boss.facing = -_boss.facing
			_boss.pos += _boss.facing * speed * SimClock.TICK_DT
			await _advance()
			frames.append(CastFeetFrame.sample_sprite(_card()))
		tracks.append({"speed": speed, "turn": 45, "frames": frames})
	var file: FileAccess = FileAccess.open(_out.path_join("reversals.json"), FileAccess.WRITE)
	return file != null and file.store_string(JSON.stringify(tracks, "", false, true))


func _attack() -> bool:
	_boss.swing_tick = _arena.tick
	_boss.swing_left = _mind.agent.arch.telegraph_ticks
	for i: int in _mind.agent.arch.telegraph_ticks:
		await _advance()
		if i == 0 and not _photo("wind_up", "attack", 0):
			return false
		_boss.swing_left -= 1
	# The real melee resolves once, on the final decrement. Keep the discharge drawing on that tick.
	FoeWardenCardView.set_catch(_boss, true, _arena.tick + 1)
	await _advance()
	if not _photo("swing", "attack", 1) or not await _edge("attack"):
		return false
	await _advance()
	if not _photo("catch", "attack", 2):
		return false
	FoeWardenCardView.set_catch(_boss, false, _arena.tick + 1)
	await _advance()
	if not _photo("recover", "attack", 3):
		return false
	for i: int in CastCardPose.RECOVERY_TICKS:
		await _advance()
	return _photo("recovered", "armed_walk", StreetWalkerCards.STAND_FRAME)


func _shadow_pair(label: String, action: String, row: int) -> bool:
	if not await super._shadow_pair(label, action, row):
		return false
	if action == "hit":
		var rig: CutRig = _host.rigs.rig_for(_boss.id)
		var ground: Vector2 = rig.global_position + RigCastShadows.card_push(rig)
		var px: float = _card().global_position.distance_to(ground) * _ppm / SimConst.PX_PER_M
		Log.info("cast", "%s wound pivot to shadow ground %.3f px" % [label, px])
		if px > 1.0:
			return false
	return await _edge("hit") if label == "hit_1" else true


func _fall_sample(row: int) -> bool:
	return await _edge("fall") if row == 0 else true


func _edge(action: String) -> bool:
	if _ppm != 64:
		return true
	var card: Sprite2D = _card()
	if card.texture.resource_path.get_file() != "appliance_warden_%s.png" % action:
		return false
	var folder: String = _out.path_join("edge_" + action)
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return false
	var mode: ProcessMode = _scene.process_mode
	_scene.process_mode = Node.PROCESS_MODE_DISABLED
	var material: Material = card.material
	var inherit_material: bool = card.use_parent_material
	var ok: bool = await _expose(folder, "live")
	card.use_parent_material = false
	card.material = null
	ok = await _expose(folder, "raw") and ok
	card.hide()
	ok = await _expose(folder, "ground") and ok
	card.show()
	card.material = material
	card.use_parent_material = inherit_material
	_scene.process_mode = mode
	return ok


func _expose(folder: String, label: String) -> bool:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var foot: Vector2 = get_viewport().get_canvas_transform() * (_boss.pos * SimConst.PX_PER_M)
	var rect: Rect2i = Rect2i(Vector2i(foot.round()) - Vector2i(192, 192), Vector2i(384, 320))
	var im: Image = get_viewport().get_texture().get_image().get_region(rect)
	return im.save_png(folder.path_join(label + ".png")) == OK

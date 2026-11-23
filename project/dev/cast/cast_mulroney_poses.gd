extends "res://dev/cast/cast_lineup.gd"
## Native viewport crops for the admission checks. Fail the take if the actual host
## shows another drawing, facing or row. Capture shadow-off partners on the same tick.

var _host: ArenaRigs
var _boss: Fighter
var _mind: SquadMind


func _ready() -> void:
	_out = OS.get_environment("GTAI_CAST_OUT")
	_ppm = OS.get_environment("GTAI_CAST_PPM").to_int()
	_pitch = OS.get_environment("GTAI_CAST_PITCH").to_int()
	if not _out.is_absolute_path() or _ppm not in [32, 64] or _pitch not in [55, 70]:
		_fail("set GTAI_CAST_OUT, GTAI_CAST_PPM and GTAI_CAST_PITCH")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	ViewMode.shared().set_pitch(float(_pitch))
	ViewMode.shared().art = "p%d" % _pitch
	CastMulroneyPreview.enable()
	add_child(_board)
	_host = _open_wave()
	if _host == null:
		_fail("missing street host")
		return
	_arena.rivet.pos = MARK + Vector2.RIGHT * 8.0
	_boss = _arena.squad_ai.spawn_member(_arena, MARK, CastMulroneyPreview.ID)
	_boss.hp = 10.0
	_mind = _arena.squad_ai.mind_for(_boss)
	var ok: bool = await _walks() and await _pump() and await _reactions()
	_session.close()
	_scene.free()
	Log.info("cast", "Mulroney pose review complete %s" % ok)
	get_tree().quit(0 if ok else 1)


func _advance() -> void:
	_arena.tick += 1
	_clock.complete_tick()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _walks() -> bool:
	for octant: int in 8:
		var direction: Vector2 = Vector2.RIGHT.rotated(octant * PI / 4.0)
		_boss.pos = MARK
		_boss.facing = direction
		var expected: Vector2i = RigHeadCard.frame_of(direction.angle())
		var seen: Dictionary[int, bool] = {}
		for tick: int in 120:
			_boss.pos += direction * _mind.agent.arch.speed_mps * SimClock.TICK_DT
			await _advance()
			var card: Sprite2D = _card()
			if card == null or card.flip_h != bool(expected.y) or card.frame_coords.x != expected.x:
				continue
			var row: int = card.frame_coords.y
			if not seen.has(row):
				if not _photo("walk_%d_%d" % [octant, row], "armed_walk", row):
					return false
				seen[row] = true
			if seen.size() == 4:
				break
		if seen.size() != 4:
			Log.error("cast", "walk octant %d only showed %s" % [octant, seen.keys()])
			return false
	return true


func _pump() -> bool:
	_boss.pos = MARK
	_boss.facing = Vector2(1, 1).normalized()
	_boss.tell_left = 20
	for tick: int in 20:
		await _advance()
	if not _photo("aim", "attack", 0) or not await _shadow_pair("aim", "attack", 0):
		return false
	_boss.tell_left = 0
	_mind.agent.shot_tick = _arena.tick + 1
	await _advance()
	if not _photo("fire", "attack", 1):
		return false
	FoeCastView.set_pump(_boss, 0.25)
	await _advance()
	if not _photo("back", "attack", 2):
		return false
	FoeCastView.set_pump(_boss, 0.75)
	await _advance()
	if not _photo("forward", "attack", 3) or not await _shadow_pair("forward", "attack", 3):
		return false
	FoeCastView.set_pump(_boss, -1.0)
	await _advance()
	return _photo("recovered", "armed_walk", StreetWalkerCards.STAND_FRAME)


func _reactions() -> bool:
	for octant: int in [1, 4, 6]:
		var direction: Vector2 = Vector2.RIGHT.rotated(octant * PI / 4.0)
		_strike(direction, false)
		for tick: int in 4:
			await _advance()
		var key: String = "hit_%d" % octant
		if not _photo(key, "hit", 0) or not await _shadow_pair(key, "hit", 0):
			return false
		for tick: int in 40:
			await _advance()
		if not _photo(key + "_recovered", "armed_walk", StreetWalkerCards.STAND_FRAME):
			return false
	_strike(Vector2.RIGHT, true)
	var seen: Dictionary[int, bool] = {}
	for tick: int in 90:
		await _advance()
		var card: Sprite2D = _card()
		if card == null or not card.texture.resource_path.ends_with("_fall.png"):
			continue
		var row: int = card.frame_coords.y
		if not seen.has(row):
			if not _photo("fall_%d" % row, "fall", row):
				return false
			seen[row] = true
	return seen.size() == 3 and _photo("rest", "fall", 2)


func _strike(direction: Vector2, lethal: bool) -> void:
	# Shock enters the drawn buckle directly. The pistol in the fight opens on the hit strip.
	var weapon: StringName = &"electro_gun" if lethal else &"pistol"
	_arena.hit_at = _boss.pos
	_arena.hit_dir = direction
	_arena.damage(_boss, 100.0 if lethal else 1.0, _arena.rivet.id, weapon)
	_arena.struck.emit(_boss, direction, lethal, weapon)
	_boss.pos = MARK


func _card() -> Sprite2D:
	var rig: CutRig = _host.rigs.rig_for(_boss.id)
	return rig.head_card if rig != null else null


func _photo(label: String, action: String, row: int) -> bool:
	var card: Sprite2D = _card()
	var suffix: String = "/sergeant_mulroney_%s.png" % action
	if (
		card == null
		or not card.is_visible_in_tree()
		or not card.texture.resource_path.ends_with(suffix)
	):
		Log.error("cast", "missing %s for %s" % [suffix, label])
		return false
	if card.frame_coords.y != row:
		Log.error("cast", "%s expected row %d, saw %s" % [label, row, card.frame_coords])
		return false
	if action == "attack" and (card.frame_coords.x != 1 or card.flip_h):
		return false
	var xf: Transform2D = get_viewport().get_canvas_transform()
	if not is_equal_approx(_ppm, xf.x.length() * SimConst.PX_PER_M):
		return false
	var feet: Vector2i = Vector2i((xf * (_boss.pos * SimConst.PX_PER_M)).round())
	var crop: Rect2i = Rect2i(feet - Vector2i(3, 3) * _ppm, Vector2i(6, 5) * _ppm)
	var photo: Image = get_viewport().get_texture().get_image().get_region(crop)
	return photo.save_png(_out.path_join(label + ".png")) == OK


func _shadow_pair(label: String, action: String, row: int) -> bool:
	_shadow.hide()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var ok: bool = _photo(label + "_no_shadow", action, row)
	_shadow.show()
	return ok

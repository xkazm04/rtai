class_name CastLancerStills
extends CastActionPlate
## Six native-size viewport exposures, with the patrol and Rivet on the same ground line.

var _arena: CombatArena
var _clock: SimClock
var _rigs: CharacterRigs
var _h: Fighter
var _patrol: Fighter
var _robots: ArenaRobotRigs


static func capture(
	host: ArenaRigs, session: GauntletSession, mark: Vector2, ppm: int, dir: String
) -> void:
	var sheet: CastLancerStills = CastLancerStills.new()
	sheet._door = OS.get_environment("GTAI_CAST_SUBJECT") == "door"
	host.add_child(sheet)
	var pitch: String = ViewMode.shared().art.trim_prefix("p")
	var name_key: String = "door" if sheet._door else "lancer"
	var path: String = dir.path_join("%s_%dppm_tilt%s.png" % [name_key, ppm, pitch])
	var tree: SceneTree = host.get_tree()
	var ok: bool = await sheet.save(host, session.world.context().clock, mark, ppm, path)
	if ok:
		Log.info("cast", "saved %s" % path)
	session.close()
	host.get_parent().queue_free()
	tree.quit(0 if ok else 1)


func save(host: ArenaRigs, clock: SimClock, mark: Vector2, ppm: int, path: String) -> bool:
	_arena = host.stage.arena
	_rigs = host.rigs
	_robots = host.robots
	_clock = clock
	_ppm = ppm
	_pitch = int(ViewMode.shared().art.trim_prefix("p"))
	_panel = Vector2i(12 * ppm, 4 * ppm)
	for h: Fighter in _arena.hostiles:
		h.pos = mark + Vector2(80, 80)
	_arena.rivet.pos = mark + Vector2.LEFT * (3.8 if _door else 2.8)
	_arena.rivet.facing = Vector2(1, 1).normalized()
	_patrol = _arena.squad_ai.spawn_member(_arena, mark, &"patrol_cop")
	_patrol.pos = mark + Vector2.LEFT * 0.5 if _door else mark
	_patrol.facing = _arena.rivet.facing
	_h = _arena.squad_ai.spawn_member(_arena, mark, &"shield_robot" if _door else &"rocket_trooper")
	_h.pos = mark + Vector2.RIGHT * 3.0
	_h.facing = Vector2.DOWN if _door else Vector2.RIGHT
	var mind: SquadMind = _arena.squad_ai.mind_for(_h)
	await _advance(20)
	for i: int in 20:
		_h.pos.x += 2.4 * SimClock.TICK_DT
		await _advance(1)
		var card: Sprite2D = _card()
		if card == null:
			return false
		if i > 5 and card.frame_coords.y in [0, 2]:
			break
	if not _take("armed_walk", -1) or not await _attack(mind):
		return false
	return await _reaction() and await save_canvas(path, _size(), _draw_plate)


func _attack(mind: SquadMind) -> bool:
	_face(Vector2.RIGHT if _door else Vector2(1, -1).normalized())
	_set_tell(mind.agent.arch.telegraph_ticks)
	await _advance(1)
	if not _take("attack", 0):
		return false
	_set_tell(1 if _door else _arena.guard_tell.lock_ticks)
	await _advance(1)
	if not _take("attack", 1):
		return false
	_set_tell(0)
	if not _door:
		_face(Vector2.UP)
	mind.agent.shot_tick = _arena.tick + 1
	await _advance(1)
	return _take("attack", 2)


func _face(direction: Vector2) -> void:
	_h.facing = direction
	var rig: CutRig = _rigs.rig_for(_h.id)
	if rig != null:
		rig.snap_facing(direction.angle())


func _set_tell(left: int) -> void:
	if _door:
		_h.swing_left = left
	else:
		_h.tell_left = left


func _reaction() -> bool:
	# HitLink clamps the fighter inside the fight map. Return it to its off-map studio mark.
	var mark: Vector2 = _h.pos
	_h.hp = 10
	_arena.hit_dir = Vector2.RIGHT
	_arena.damage(_h, 1, _arena.rivet.id, &"pistol")
	_arena.struck.emit(_h, Vector2.RIGHT, false, &"pistol")
	_h.pos = mark
	await _advance(9)
	if not _take("hit", 0):
		return false
	var reference: Vector2 = _patrol.pos
	_arena.damage(_patrol, _patrol.hp + 100, _arena.rivet.id, &"pistol")
	_arena.struck.emit(_patrol, Vector2.RIGHT, true, &"pistol")
	_patrol.pos = reference + Vector2.LEFT * 0.75 if _door else reference
	_arena.damage(_h, 300, _arena.rivet.id, &"pistol")
	_arena.struck.emit(_h, Vector2.RIGHT, true, &"pistol")
	_h.pos = mark
	await _advance(35)
	return _take("fall", StreetWalkerFall.FALL_FRAMES - 1)


func _advance(count: int) -> void:
	for i: int in count:
		_arena.tick += 1
		_clock.complete_tick()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw


func _card() -> Sprite2D:
	if _door:
		var robot: CutRig = _robots.rig_for(_h.id)
		if robot != null and robot.has_meta(FoeShieldCardView.CARD):
			return robot.get_meta(FoeShieldCardView.CARD)
		return null
	var rig: CutRig = _rigs.rig_for(_h.id)
	return rig.head_card if rig != null else null


func _take(action: String, row: int) -> bool:
	var card: Sprite2D = _card()
	if card == null or not card.is_visible_in_tree():
		Log.error("cast", "%s missing card for %s" % [action, _h.archetype])
		return false
	if not card.texture.resource_path.ends_with("/%s_%s.png" % [_h.archetype, action]):
		Log.error("cast", "%s expected, got %s" % [action, card.texture.resource_path])
		return false
	if row >= 0 and card.frame_coords.y != row:
		Log.error("cast", "%s row %d expected, got %d" % [action, row, card.frame_coords.y])
		return false
	return _expose()

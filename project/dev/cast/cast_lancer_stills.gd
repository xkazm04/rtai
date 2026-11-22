class_name CastLancerStills
extends CanvasLayer
## Six native-size viewport exposures, with the patrol and Rivet on the same ground line.

const FACE: Vector2 = Vector2(1, 0)
const TITLES: Array[String] = ["Walking", "Shoulder", "Locked aim", "Discharge", "Hit", "At rest"]
const ORIGIN: Vector2i = Vector2i(960, 540)

var _arena: CombatArena
var _clock: SimClock
var _rigs: CharacterRigs
var _h: Fighter
var _ppm: int
var _pitch: int
var _panel: Vector2i
var _photos: Array[Texture2D] = []
var _canvas: Node2D
var _paper: Color


static func capture(
	parent: Node, session: GauntletSession, mark: Vector2, ppm: int, dir: String
) -> void:
	var sheet: CastLancerStills = CastLancerStills.new()
	parent.add_child(sheet)
	var host: ArenaRigs
	for child: Node in parent.get_children():
		if child is ArenaRigs:
			host = child
	var pitch: String = ViewMode.shared().art.trim_prefix("p")
	var path: String = dir.path_join("lancer_%dppm_tilt%s.png" % [ppm, pitch])
	var tree: SceneTree = parent.get_tree()
	var ok: bool = (
		host != null and await sheet.save(host, session.world.context().clock, mark, ppm, path)
	)
	if ok:
		Log.info("cast", "saved %s" % path)
	session.close()
	parent.queue_free()
	tree.quit(0 if ok else 1)


func save(host: ArenaRigs, clock: SimClock, mark: Vector2, ppm: int, path: String) -> bool:
	_arena = host.stage.arena
	_rigs = host.rigs
	_clock = clock
	_ppm = ppm
	_pitch = int(ViewMode.shared().art.trim_prefix("p"))
	_panel = Vector2i(12 * ppm, 4 * ppm)
	for h: Fighter in _arena.hostiles:
		h.pos = mark + Vector2(80, 80)
	_arena.rivet.pos = mark + Vector2.LEFT * 2.8
	_arena.rivet.facing = Vector2(1, 1).normalized()
	var patrol: Fighter = _arena.squad_ai.spawn_member(_arena, mark, &"patrol_cop")
	patrol.pos = mark
	patrol.facing = _arena.rivet.facing
	_h = _arena.squad_ai.spawn_member(_arena, mark, &"rocket_trooper")
	_h.pos = mark + Vector2.RIGHT * 3.0
	_h.facing = FACE
	var mind: SquadMind = _arena.squad_ai.mind_for(_h)
	await _advance(20)
	for i: int in 20:
		_h.pos.x += 2.4 * SimClock.TICK_DT
		await _advance(1)
		var rig: CutRig = _rigs.rig_for(_h.id)
		if rig == null or rig.head_card == null:
			return false
		if i > 5 and rig.head_card.frame_coords.y in [0, 2]:
			break
	if not _take("armed_walk", -1):
		return false
	if not await _attack(mind):
		return false
	if not await _reaction():
		return false
	return await _save_plate(path)


func _attack(mind: SquadMind) -> bool:
	_h.tell_left = mind.agent.arch.telegraph_ticks
	await _advance(1)
	if not _take("attack", 0):
		return false
	_h.tell_left = _arena.guard_tell.lock_ticks
	await _advance(1)
	if not _take("attack", 1):
		return false
	_h.tell_left = 0
	mind.agent.shot_tick = _arena.tick + 1
	await _advance(1)
	return _take("attack", 2)


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
	_arena.damage(_h, 30, _arena.rivet.id, &"pistol")
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


func _take(action: String, row: int) -> bool:
	var rig: CutRig = _rigs.rig_for(_h.id)
	if rig == null or rig.head_card == null or not rig.head_card.is_visible_in_tree():
		Log.error(
			"cast",
			(
				"%s at %s: rig %s, feed %s, %d fighters"
				% [
					action,
					_h.pos,
					rig,
					_rigs.feed.ids.slice(0, _rigs.feed.count),
					_arena.hostiles.size()
				]
			)
		)
		return false
	var card: Sprite2D = rig.head_card
	if not card.texture.resource_path.ends_with("/rocket_trooper_%s.png" % action):
		Log.error("cast", "%s expected, got %s" % [action, card.texture.resource_path])
		return false
	if row >= 0 and card.frame_coords.y != row:
		Log.error("cast", "%s row %d expected, got %d" % [action, row, card.frame_coords.y])
		return false
	var shot: Image = get_viewport().get_texture().get_image()
	var start: Vector2i = ORIGIN - Vector2i(roundi(_panel.x * 0.5), _ppm * 3)
	var crop: Image = shot.get_region(Rect2i(start, _panel))
	_paper = crop.get_pixel(0, 0)
	_photos.append(ImageTexture.create_from_image(crop))
	return true


func _save_plate(path: String) -> bool:
	layer = RenderLayers.canvas(&"hud") + 1
	_canvas = Node2D.new()
	add_child(_canvas)
	@warning_ignore("return_value_discarded")
	_canvas.draw.connect(_draw_plate)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image().get_region(
		Rect2i(Vector2i.ZERO, _size())
	)
	return (
		DirAccess.make_dir_recursive_absolute(path.get_base_dir()) == OK
		and image.save_png(path) == OK
	)


func _size() -> Vector2i:
	return Vector2i(2 * _panel.x + 72, 3 * (_panel.y + 32) + 94)


func _draw_plate() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(_size())), _paper)
	_text(Vector2(24, 34), tr("RTAI / Lancer"), 26)
	_text(
		Vector2(24, 58), tr("Rivet, patrol cop and lancer  ·  %d px/m  ·  %d°") % [_ppm, _pitch], 16
	)
	for i: int in TITLES.size():
		var col: int = i % 2
		var line: int = floori(i / 2.0)
		var at: Vector2 = Vector2(24 + col * (_panel.x + 24), 94 + line * (_panel.y + 32))
		_text(at, tr(TITLES[i]), 17)
		_canvas.draw_texture(_photos[i], at + Vector2.DOWN * 4)


func _text(at: Vector2, words: String, px: int) -> void:
	_canvas.draw_string(
		ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, px, CastPlate.INK
	)

extends "res://dev/cast/cast_mulroney_poses.gd"
## Frozen live/raw/ground exposures of the contractor card (rim at 64 px/m) and shadow-off pairs
## (shadow at 32 px/m). His card uses the shared head-card path: the street shadow is the toggle.

## One launch (the RAM-cap wait is per launch): the three bar takes, each on a fresh street.
const RUNS: Array[Vector2i] = [Vector2i(70, 32), Vector2i(70, 64), Vector2i(55, 64)]
## GTAI_CAST_CONTROL=rocket_trooper runs the same takes on the lancer card (a comparison).
## His sheet names: the hit and fall are not quest 1's contractor_hit/fall.png.
const SHEET: Dictionary[String, String] = {
	"planted8_armed_walk": "contractor_planted8_armed_walk.png",
	"attack": "contractor_attack.png",
	"hit": "contractor_cast_hit.png",
	"fall": "contractor_cast_fall.png",
	"hit_calm": "contractor_cast_hit.png",
	"fall_1": "contractor_cast_fall.png",
	"fall_2": "contractor_cast_fall.png"
}

var _root: String
var _prefix: String = "contractor"


func _ready() -> void:
	_root = OS.get_environment("GTAI_CAST_OUT")
	if not _root.is_absolute_path():
		_fail("set GTAI_CAST_OUT")
		return
	_subject = &"contractor"
	_walk_strip = CastContractorAnchors.WALK
	if OS.get_environment("GTAI_CAST_CONTROL") == "rocket_trooper":
		_subject = &"rocket_trooper"
		_prefix = "rocket_trooper"
		_walk_strip = CastLancerAnchors.WALK
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("combo")
	CastMulroneyPreview.enable(_subject)
	var ok: bool = true
	for run: Vector2i in RUNS:
		ok = await _take(run.x, run.y) and ok
	Log.info("cast", "%s pose review complete %s" % [_subject, ok])
	get_tree().quit(0 if ok else 1)


func _take(pitch: int, ppm: int) -> bool:
	_pitch = pitch
	_ppm = ppm
	_out = _root.path_join("poses%d_%d" % [pitch, ppm])
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		return false
	ViewMode.shared().set_pitch(float(pitch))
	ViewMode.shared().art = "p%d" % pitch
	_host = _open_wave()
	if _host == null:
		return false
	_arena.rivet.pos = MARK + Vector2.RIGHT * 8.0
	_boss = _arena.squad_ai.spawn_member(_arena, MARK, _subject)
	_boss.hp = 10.0
	_mind = _arena.squad_ai.mind_for(_boss)
	var ok: bool = await _walks()
	ok = await _attack() and ok
	ok = await _reactions() and ok
	_session.close()
	_scene.free()
	Log.info("cast", "take %d/%d complete %s" % [pitch, ppm, ok])
	return ok


func _photo(label: String, action: String, row: int) -> bool:
	var cast: bool = _prefix == "contractor" and action in ["hit", "fall"]
	return super._photo(label, "cast_" + action if cast else action, row)


func _walks() -> bool:
	_boss.pos = MARK
	_boss.facing = Vector2(1, 1).normalized()
	for tick: int in 30:
		await _advance()
	if not await _shadow_pair("stand", "armed_walk", StreetWalkerCards.STAND_FRAME):
		return false
	if not await super._walks():
		return false
	_boss.pos = MARK
	_boss.facing = Vector2(1, 1).normalized()
	for tick: int in 20:
		await _advance()
	return await _edge("planted8_armed_walk")


func _attack() -> bool:
	_boss.pos = MARK
	_boss.facing = Vector2(1, 1).normalized()
	_boss.tell_left = 20
	for tick: int in 20:
		await _advance()
	if not await _shadow_pair("tell", "attack", 0):
		return false
	_boss.tell_left = 0
	_mind.agent.shot_tick = _arena.tick + 1
	await _advance()
	if not await _shadow_pair("fire", "attack", 2) or not await _edge("attack"):
		return false
	await _advance()
	if not _photo("recover", "attack", 3):
		return false
	for i: int in CastCardPose.RECOVERY_TICKS + 2:
		await _advance()
	return _photo("recovered", "armed_walk", StreetWalkerCards.STAND_FRAME)


func _shadow_pair(label: String, action: String, row: int) -> bool:
	var ok: bool = await super._shadow_pair(label, action, row)
	if not ok or label != "hit_1":
		return ok
	# 4 ticks after the strike the hit flash is lit (pulse); 5 more and it has gone (calm), the
	# hit drawing holds 12 ticks.
	ok = await _edge("hit")
	for tick: int in 5:
		await _advance()
	return await _edge("hit_calm") and ok


func _fall_sample(row: int) -> bool:
	var names: Array[String] = ["fall", "fall_1", "fall_2"]
	return await _edge(names[row])


func _edge(action: String) -> bool:
	if _ppm != 64:
		return true
	var card: Sprite2D = _card()
	if card == null or card.texture.resource_path.get_file() != _sheet(action):
		Log.error("cast", "edge %s: wrong texture" % action)
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


func _sheet(action: String) -> String:
	if _prefix == "contractor":
		return SHEET[action]
	return (
		"%s_%s.png" % [_prefix, action.get_slice("_calm", 0).get_slice("_1", 0).get_slice("_2", 0)]
	)


func _expose(folder: String, label: String) -> bool:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var foot: Vector2 = get_viewport().get_canvas_transform() * (_boss.pos * SimConst.PX_PER_M)
	var rect: Rect2i = Rect2i(Vector2i(foot.round()) - Vector2i(192, 192), Vector2i(384, 320))
	var im: Image = get_viewport().get_texture().get_image().get_region(rect)
	return im.save_png(folder.path_join(label + ".png")) == OK
